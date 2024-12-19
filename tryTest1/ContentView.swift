

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
    @State private var searchText: String = ""
    @StateObject private var mediaPicker = MediaPicker()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .foregroundColor(AppColors.customColor)
                    HStack {
                        Spacer()
                        Text("فَهِيم")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .padding(.leading, 45)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                            .onTapGesture {
                                mediaPicker.presentPhotoPicker()
                            }
                    }
                    .padding(.top, 15)
                }
                .frame(height: 150)
                .ignoresSafeArea()

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("البحث ..", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .offset(y: -50)

                Spacer()

                if let mediaURL = mediaPicker.selectedMediaURL {
                    VStack(spacing: 10) {
                        Text(mediaPicker.transcribedText)
                            .padding()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)

                        VideoPlayer(player: AVPlayer(url: mediaURL))
                            .frame(height: 300)
                            .padding()

                        if let videoToShow = getVideoForText(mediaPicker.transcribedText) {
                            VideoPlayerView(videoName: videoToShow.name)
                                .frame(height: 300)
                                .padding()
                        } else {
                            Text("لا يوجد فيديو مطابق.")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Text("لا يوجد ملفات صوتيه مترجمة إلى لغة الأشارة بعد!")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .foregroundColor(.gray)
                }

                VStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Text("لإضافة ملف صوتي")
                            .foregroundColor(.gray)
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                            .foregroundColor(.gray)
                        Text("اضغط على")
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                Spacer()
            }
            .sheet(isPresented: $mediaPicker.isShowingPicker) {
                PhotoPicker(mediaPicker: mediaPicker)
            }
            .onAppear {
                mediaPicker.requestPhotoLibraryPermission()
                mediaPicker.requestSpeechRecognitionPermission()
            }
        }
    }

    private func getVideoForText(_ text: String) -> VideoItem? {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "\u{200F}", with: "")

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
            print("No matching video found for: \(normalizedText)")
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
            guard let result = results.first else { return }

            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let error = error {
                        print("Error loading video: \(error.localizedDescription)")
                        return
                    }
                    guard let videoURL = url else { return }

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
            if status != .authorized {
                print("Photo library access denied.")
            }
        }
    }

    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition access denied.")
            }
        }
    }

    func presentPhotoPicker() {
        isShowingPicker = true
    }

    func extractAudio(from videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else { return }

        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("extractedAudio.m4a")
        try? FileManager.default.removeItem(at: outputURL)

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                self.transcribeAudio(from: outputURL)
            }
        }
    }

    func transcribeAudio(from audioURL: URL) {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA")) else { return }
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
            }
        }
    }
}

struct VideoPlayerView: View {
    let videoName: String

    var body: some View {
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

struct AppColors {
    static let customColor = Color(hex: "#C1B6A3")
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}
