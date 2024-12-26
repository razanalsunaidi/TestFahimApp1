import SwiftUI
import AVKit

struct VideoItem: Identifiable {
    let id = UUID()
    let name: String
}

struct SignLanguageTranslationView: View {
    @State private var text: String
    @State private var isTextPanelExpanded: Bool = false
    @State private var isVideoPanelExpanded: Bool = false

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

            // عرض لغة الإشارة في الأعلى
            VStack {
                VStack {
                    HStack {
                        Text("لغة إشارة")
                            .font(.title3)
                            .padding(.leading)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isVideoPanelExpanded.toggle()
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

                    // عرض الفيديو المطابق للنص
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
                .offset(y: isVideoPanelExpanded ? 0 : +300) // تحريك لغة الإشارة
                .animation(.easeInOut, value: isVideoPanelExpanded)
            }

            Spacer()

            // عرض النص المحول في الأسفل
            VStack {
                HStack {
                    Text("النص")
                        .font(.title3)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isTextPanelExpanded.toggle()
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
                    .frame(maxWidth: .infinity, maxHeight: 315, alignment: .topTrailing) // محاذاة النص إلى الأعلى واليمين
                    .multilineTextAlignment(.trailing) // محاذاة النص في كل الأسطر إلى اليمين
                    .padding()
            }
            .background(Color(hex: "C1B6A3"))
            .cornerRadius(20)
            .offset(y: isTextPanelExpanded ? -30 : +270) // تحريك النص إلى الأعلى قليلاً
            .animation(.easeInOut, value: isTextPanelExpanded)

            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    private func getVideoForText(_ text: String) -> VideoItem? {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "\u{200F}", with: "")
        switch normalizedText {
        case "كريم":
            return VideoItem(name: "كريم")
        case "رافقتك السلامة":
            return VideoItem(name: "رافقتك السلامة")
        case "هل أنت بخير":
            return VideoItem(name: "هل أنت بخير")
        case "لحظة من فضلك":
            return VideoItem(name: "لحظة من ضلك")
        case "لست احتمل هذا":
            return VideoItem(name: "لست احتمل هذا")
        case "أعلى":
            return VideoItem(name: "أعلى")
        case "أسفل":
            return VideoItem(name: "أسفل")
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
            text: "كريم" // أدخل نصًا لاختبار عرض الفيديو
        )
    }
}
