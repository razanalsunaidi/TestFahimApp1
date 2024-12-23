import SwiftUI
import AVKit

struct VideoItem: Identifiable {
    let id = UUID()
    let name: String
}

struct SignLanguageTranslationView: View {
    @State private var text: String
    @State private var isPanelExpanded: Bool = false
    @State private var isPanelExpanded1: Bool = false

    init(text: String) {
        self._text = State(initialValue: text)
    }

    var body: some View {
        VStack {
            // شريط علوي
            HStack {
                Spacer()
                Text("فَهِيم")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color(hex: "C1B6A3"))

            Spacer()

            // عرض النص المحول
            VStack {
                HStack {
                    Text("النص")
                        .font(.title3)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isPanelExpanded1.toggle()
                        }
                    }) {
                        Image(systemName: "eye")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(.trailing)
                    }
                    .padding(.vertical, 10)
                }
                Text(text)
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 315)
                    .padding()
            }
            .background(Color(hex: "C1B6A3"))
            .cornerRadius(20)
            .offset(y: isPanelExpanded1 ? 0 : +300)

            Spacer()

            // عرض الفيديو المطابق للنص
            VStack {
                Spacer()

                VStack {
                    HStack {
                        Text("لغة إشارة")
                            .font(.title3)
                            .padding(.leading)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isPanelExpanded.toggle()
                            }
                        }) {
                            Image(systemName: "eye")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding(.trailing)
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color(hex: "EFEADA"))

                    // الحصول على الفيديو المطابق وعرضه
                    if let videoToShow = getVideoForText(text) {
                        VideoPlayerView(videoName: videoToShow.name)
                            .frame(height: 300)
                            .padding()
                    } else {
                        Text("لا يوجد فيديو مطابق للنص.")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .background(Color(hex: "EFEADA"))
                .cornerRadius(20)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
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
            Text("لم يتم العثور على ملف الفيديو.")
                .foregroundColor(.red)
        }
    }
}

struct SignLanguageTranslationView_Previews: PreviewProvider {
    static var previews: some View {
        SignLanguageTranslationView(
            text: "أهلا" // أدخل نصًا لاختبار عرض الفيديو
        )
    }
}
