//import SwiftUI
//import AVKit
//import Photos
//import PhotosUI
//import Speech
//
//struct AppColors {
//    static let customColor = Color(hex: "#C1B6A3")
//}
//
//extension Color {
//    init(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if hexSanitized.hasPrefix("#") {
//            hexSanitized.remove(at: hexSanitized.startIndex)
//        }
//
//        var rgb: UInt64 = 0
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//
//        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
//        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
//        let blue = Double(rgb & 0x0000FF) / 255.0
//
//        self.init(red: red, green: green, blue: blue)
//    }
//}
//
//class MediaPicker: ObservableObject {
//    @Published var isShowingPicker = false
//    @Published var selectedMediaURL: URL?
//    @Published var transcribedText: String = ""
//
//    func requestPhotoLibraryPermission() {
//        PHPhotoLibrary.requestAuthorization { status in
//            if status != .authorized {
//                print("Photo library access denied.")
//            }
//        }
//    }
//
//    func requestSpeechRecognitionPermission() {
//        SFSpeechRecognizer.requestAuthorization { status in
//            if status != .authorized {
//                print("Speech recognition access denied.")
//            }
//        }
//    }
//
//    func presentPhotoPicker() {
//        isShowingPicker = true
//    }
//
//    func extractAudio(from videoURL: URL, completion: @escaping (String) -> Void) {
//        let asset = AVURLAsset(url: videoURL)
//        guard let audioTrack = asset.tracks(withMediaType: .audio).first else { return }
//
//        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("extractedAudio.m4a")
//        try? FileManager.default.removeItem(at: outputURL)
//
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .m4a
//        exportSession.exportAsynchronously {
//            if exportSession.status == .completed {
//                self.transcribeAudio(from: outputURL, completion: completion)
//            }
//        }
//    }
//
//    func transcribeAudio(from audioURL: URL, completion: @escaping (String) -> Void) {
//        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA")) else { return }
//        let request = SFSpeechURLRecognitionRequest(url: audioURL)
//        recognizer.recognitionTask(with: request) { result, error in
//            if let result = result {
//                completion(result.bestTranscription.formattedString)
//            } else if let error = error {
//                print("Transcription error: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//struct PhotoPicker: UIViewControllerRepresentable {
//    @ObservedObject var mediaPicker: MediaPicker
//    var onComplete: (URL?, String) -> Void
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .videos
//        configuration.selectionLimit = 1
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(mediaPicker: mediaPicker, onComplete: onComplete)
//    }
//
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var mediaPicker: MediaPicker
//        var onComplete: (URL?, String) -> Void
//
//        init(mediaPicker: MediaPicker, onComplete: @escaping (URL?, String) -> Void) {
//            self.mediaPicker = mediaPicker
//            self.onComplete = onComplete
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//            guard let result = results.first else {
//                onComplete(nil, "")
//                return
//            }
//
//            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
//                    if let error = error {
//                        print("Error loading video: \(error.localizedDescription)")
//                        return
//                    }
//                    guard let videoURL = url else { return }
//
//                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
//                    do {
//                        try FileManager.default.copyItem(at: videoURL, to: tempURL)
//                        self.mediaPicker.extractAudio(from: tempURL) { transcription in
//                            DispatchQueue.main.async {
//                                self.onComplete(tempURL, transcription)
//                            }
//                        }
//                    } catch {
//                        print("Error copying video file: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ContentView: View {
//    @State private var searchText: String = ""
//    @StateObject private var mediaPicker = MediaPicker()
//    @State private var transcribedText: String = ""
//    @State private var isNavigationActive = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                ZStack {
//                    Rectangle()
//                        .foregroundColor(AppColors.customColor)
//                    HStack {
//                        Spacer()
//                        Text("فَهِيم")
//                            .font(.largeTitle)
//                            .foregroundColor(.black)
//                            .padding(.leading, 45)
//                        Spacer()
//                        Image(systemName: "photo.on.rectangle")
//                            .font(.title)
//                            .foregroundColor(.white)
//                            .padding(.trailing, 20)
//                            .onTapGesture {
//                                mediaPicker.presentPhotoPicker()
//                            }
//                    }
//                    .padding(.top, 15)
//                }
//                .frame(height: 150)
//                .ignoresSafeArea()
//                
//                Spacer()
//                
//                VStack(spacing: 0) {
//                    Spacer()
//                        .frame(height: 200) // تحديد ارتفاع مخصص للمسافة المرنة قبل المحتوى
//                    VStack(spacing: 10) {
//                        Text ("لا يوجد ملفات صوتيه مترجمة إلى لغة الأشارة بعد!")
//                            .foregroundColor(.gray)
//                        HStack(spacing: 4) {
//                            Text("لإضافة ملف صوتي")
//                                .foregroundColor(.gray)
//                            Image(systemName: "photo.on.rectangle")
//                                .font(.body)
//                                .foregroundColor(.gray)
//                            Text("اضغط على")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .padding()
//                    Spacer()
//                }
//                
//                
//                NavigationLink(
//                    destination: SignLang2(),
//                    isActive: $isNavigationActive
//                ) {
//                    EmptyView()
//                }
//            }
//            .sheet(isPresented: $mediaPicker.isShowingPicker) {
//                PhotoPicker(mediaPicker: mediaPicker) { url, transcription in
//                    self.transcribedText = transcription
//                    self.isNavigationActive = true
//                }
//            }
//            .onAppear {
//                mediaPicker.requestPhotoLibraryPermission()
//                mediaPicker.requestSpeechRecognitionPermission()
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
