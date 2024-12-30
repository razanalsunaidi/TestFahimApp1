//import SwiftUI
//import AVKit
//struct VideoItem: Identifiable {
//    let id = UUID()
//    let name: String
//}
//
//struct SignLanguageTranslationView: View {
//    @State private var text: String
//    @State private var isTextPanelExpanded: Bool = false
//    @State private var isVideoPanelExpanded: Bool = false
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject var historyManager: HistoryManager
//
//    init(text: String) {
//        self._text = State(initialValue: text)
//    }
//
//    var body: some View {
//        VStack {
//            HStack {
//                Spacer() // Push everything to the right initially
//
//                Text("فَهِيم")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.black)
//                    .offset(x:35)
//
//                Spacer()
//
//                // Save button aligned to the right corner
//                Button(action: {
//                    if let videoToShow = getVideoForText(text) {
//                        let savedItem = SavedItem(text: text, videoName: videoToShow.name)
//                        historyManager.savedItems.append(savedItem)
//                    }
//                    dismiss() // Dismiss the current view and go back to the home page
//                }) {
//                    Text("حفظ")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .foregroundColor(Color(hex:"FFFFFF"))
//                        .padding(10)
//                        .background(Color.clear) // Transparent background
//                }
//                .padding(.trailing)
//            }
//            .padding()
//            .background(Color(hex: "C1B6A3"))
//
//
//            Spacer()
//
//            VStack {
//                VStack {
//                    HStack {
//                        Text("لغة إشارة")
//                            .font(.title3)
//                            .padding(.leading)
//                        Spacer()
//                        Button(action: {
//                            withAnimation {
//                                isVideoPanelExpanded.toggle()
//                            }
//                        }) {
//                            Image(systemName: "eye")
//                                .font(.title2)
//                                .foregroundColor(.black)
//                                .padding(.trailing)
//                        }
//                    }
//                    .padding(.vertical, 10)
//                    .background(Color(hex: "EFEADA"))
//
//                    if let videoToShow = getVideoForText(text) {
//                        VideoPlayerView(videoName: videoToShow.name)
//                            .frame(height: 300)
//                            .padding()
//                    } else {
//                        Text("لا يوجد فيديو مطابق للنص.")
//                            .foregroundColor(.red)
//                            .padding()
//                    }
//                }
//                .background(Color(hex: "EFEADA"))
//                .cornerRadius(20)
//                .offset(y: isVideoPanelExpanded ? 0 : +100)
//                .animation(.easeInOut, value: isVideoPanelExpanded)
//            }
//
//            Spacer()
//
//            VStack {
//                HStack {
//                    Text("النص")
//                        .font(.title3)
//                        .padding(.leading)
//                    Spacer()
//                    Button(action: {
//                        withAnimation {
//                            isTextPanelExpanded.toggle()
//                        }
//                    }) {
//                        Image(systemName: "eye")
//                            .font(.title2)
//                            .foregroundColor(.black)
//                            .padding(.trailing)
//                    }
//                    .padding(.vertical, 10)
//                }
//
//                Text(text)
//                    .font(.title3)
//                    .padding()
//                    .frame(maxWidth: .infinity, maxHeight: 315, alignment: .topTrailing)
//                    .multilineTextAlignment(.trailing)
//                    .padding()
//            }
//            .background(Color(hex: "C1B6A3"))
//            .cornerRadius(20)
//            .offset(y: isTextPanelExpanded ? -100 : 20)
//            .animation(.easeInOut, value: isTextPanelExpanded)
//
//            Spacer()
//        }
//        .edgesIgnoringSafeArea(.bottom)
//    }
//
//    private func getVideoForText(_ text: String) -> VideoItem? {
//        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//            .folding(options: .diacriticInsensitive, locale: .current)
//            .lowercased()
//            .replacingOccurrences(of: "\u{200F}", with: "")
//        switch normalizedText {
//        case "كريم":
//            return VideoItem(name: "كريم")
//        case "رافقتك السلامة":
//            return VideoItem(name: "رافقتك السلامة")
//        case "هل أنت بخير":
//            return VideoItem(name: "هل أنت بخير")
//        case "لحظة من فضلك":
//            return VideoItem(name: "لحظة من ضلك")
//        case "لست احتمل هذا":
//            return VideoItem(name: "لست احتمل هذا")
//        case "أعلى":
//            return VideoItem(name: "أعلى")
//        case "أسفل":
//            return VideoItem(name: "أسفل")
//        default:
//            print("No matching video found for: \(normalizedText)")
//            return nil
//        }
//    }
//}
//
//struct VideoPlayerView: View {
//    let videoName: String
//    var body: some View {
//        if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mov") {
//            let player = AVPlayer(url: videoURL)
//            VideoPlayer(player: player)
//                .onAppear {
//                    player.play()
//                }
//        } else {
//            Text("لم يتم العثور على ملف الفيديو.")
//                .foregroundColor(.red)
//        }
//    }
//}
//
//struct SignLanguageTranslationView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignLanguageTranslationView(
//            text: "كريم" // أدخل نصًا لاختبار عرض الفيديو
//        )
//    }
//}
//
