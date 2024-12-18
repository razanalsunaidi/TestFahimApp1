import SwiftUI
import AVKit
import Photos
import PhotosUI
import Speech

struct VideoItem: Identifiable {
    let id = UUID()
    let name: String
}

struct ContentView: View {
    @StateObject private var mediaPicker = MediaPicker()
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Select Media") {
                    mediaPicker.presentPhotoPicker()
                }
                .padding()

                if let mediaURL = mediaPicker.selectedMediaURL {
                    VideoPlayer(player: AVPlayer(url: mediaURL))
                        .frame(height: 300)
                        .padding()
                    Text(mediaPicker.transcribedText)
                        .padding()
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)

                    // Show video based on the transcribed text
                    if let videoToShow = getVideoForText(mediaPicker.transcribedText) {
                        VideoPlayerView(videoName: videoToShow.name)
                            .frame(height: 300)
                            .padding()
                    } else {
                        Text("No matching video found.")
                            .foregroundColor(.red)
                    }
                } else {
                    Text("No media selected.")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Media Player")
            .sheet(isPresented: $mediaPicker.isShowingPicker) {
                PhotoPicker(mediaPicker: mediaPicker)
            }
            .onAppear {
                mediaPicker.requestPhotoLibraryPermission()
                mediaPicker.requestSpeechRecognitionPermission()
            }
        }
    }
    
    // Updated function to get the video based on transcribed text
    private func getVideoForText(_ text: String) -> VideoItem? {
        // Normalize the text by trimming whitespace and removing non-visible characters
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "\u{200F}", with: "") // Remove Right-to-Left Mark

        // Debug: Print the normalized text and its unicode representation
        print("Normalized Transcribed Text: \(normalizedText)")
        print("Unicode Representation: \(normalizedText.unicodeScalars.map { String(format: "%04X", $0.value) })")

        // Match the normalized text with the expected video names
        switch normalizedText {
        case "أهلا":
            return VideoItem(name: "أهلا")
        case "كم عمرك":
            return VideoItem(name: "كم عمرك")
        case "ما اسمك":
            return VideoItem(name: "ما اسمك")
        case "كيف العائلة":
            return VideoItem(name: "كيف العائلة")
        case "كيف حالك":
            return VideoItem(name: "كيف حالك")
        default:
            print("No matching video found for: \(normalizedText)") // Debug: Print unmatched case
            return nil
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @ObservedObject var mediaPicker: MediaPicker

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(mediaPicker: mediaPicker)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var mediaPicker: MediaPicker

        init(mediaPicker: MediaPicker) {
            self.mediaPicker = mediaPicker
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first else {
                mediaPicker.isShowingPicker = false
                return
            }

            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let error = error {
                        print("Error loading video: \(error.localizedDescription)")
                        return
                    }

                    guard let videoURL = url else {
                        print("Video URL is nil")
                        return
                    }

                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")

                    do {
                        try FileManager.default.copyItem(at: videoURL, to: tempURL)
                        DispatchQueue.main.async {
                            self.mediaPicker.selectedMediaURL = tempURL
                            self.mediaPicker.extractAudio(from: tempURL)
                        }
                    } catch {
                        print("Error copying video file: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

class MediaPicker: ObservableObject {
    @Published var isShowingPicker = false
    @Published var selectedMediaURL: URL?
    @Published var transcribedText: String = ""

    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Photo library access granted.")
            case .denied, .restricted:
                print("Photo library access denied.")
            case .notDetermined:
                print("Photo library access not determined.")
            @unknown default:
                break
            }
        }
    }

    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Speech recognition access granted.")
            case .denied, .restricted:
                print("Speech recognition access denied.")
            case .notDetermined:
                print("Speech recognition access not determined.")
            @unknown default:
                break
            }
        }
    }

    func presentPhotoPicker() {
        isShowingPicker = true
    }

    func extractAudio(from videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        let audioTrack = asset.tracks(withMediaType: .audio).first
        
        guard let audioTrack = audioTrack else {
            print("No audio track found")
            return
        }
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("extractedAudio.m4a")

        try? FileManager.default.removeItem(at: outputURL)

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("Audio extraction completed.")
                self.transcribeAudio(from: outputURL)
            case .failed:
                print("Audio extraction failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
            case .cancelled:
                print("Audio extraction canceled.")
            default:
                break
            }
        }
    }

    func transcribeAudio(from audioURL: URL) {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA")) else {
            print("Speech recognizer is not available")
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
            } else if let error = error {
                print("Transcription error: \(error.localizedDescription)")
            }
        }
    }
}

struct VideoPlayerView: View {
    let videoName: String

    var body: some View {
        Group {
            if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mov") {
                let player = AVPlayer(url: videoURL)
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
            } else {
                Text("Video file not found.")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    ContentView()
}
