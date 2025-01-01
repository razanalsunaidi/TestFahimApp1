import SwiftUI
import WebKit
import SwiftData

struct GifItem: Identifiable {
    let id = UUID()
    let name: String
}

struct SignLanguageTranslationView: View {
    @State private var text: String
    @State private var isTextPanelExpanded: Bool = false
    @State private var isGifPanelExpanded: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var historyManager: HistoryManager
    @Environment(\.modelContext) private var context

    init(text: String) {
        self._text = State(initialValue: text)
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Text("فَهِيم")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .offset(x: 35)

                Spacer()

                Button(action: {
                    if let gifToShow = getGifForText(text) {
                        let savedItem = SavedItem(text: text, videoName: gifToShow.name)
                        historyManager.savedItems.append(savedItem)
                    }
                    dismiss()
                }) {
                    Text("حفظ")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "FFFFFF"))
                        .padding(10)
                        .background(Color.clear)
                }
                .padding(.trailing)
            }
            .padding()
            .background(Color(hex: "C1B6A3"))

            Spacer()

            VStack(spacing: 0) {
                Spacer()

                VStack {
                    if let gifToShow = getGifForText(text) {
                        GifImageView(gifName: gifToShow.name)
                            .frame(height: 300)
                            .padding()
                            .offset(y: 115) // تحريك الجيف للأسفل فقط
                    } else {
                        Text("لا يوجد GIF مطابق للنص.")
                            .foregroundColor(.red)
                            .padding()
                    }
                }


                ZStack {
                    Rectangle()
                        .fill(Color(hex: "#EFEADC"))
                        .clipShape(TopRoundedCorners(cornerRadius: 100))
                        .frame(height: 300)
                        .padding(.bottom, -40)
                        .overlay(
                            Text(text)
                                .foregroundColor(.black)
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                        )
                        .zIndex(1)

                    Rectangle()
                        .fill(Color(hex: "#E4DDCB"))
                        .clipShape(TopRoundedCorners(cornerRadius: 24))
                        .frame(width: 160, height: 360)
                        .padding(.trailing, 240)
                        .padding(.bottom, -20)
                        .overlay(
                            VStack {
                                Text("النص")
                                    .foregroundColor(.black)
                                    .font(.headline)
                                    .bold()
                                    .padding(.horizontal, -140)
                                    .padding(.top, 9)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        )
                        .zIndex(0)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }

    private func getGifForText(_ text: String) -> GifItem? {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "\u{200F}", with: "")
        switch normalizedText {
        case "كريم":
            return GifItem(name: "كريم")
        case "رافقتك السلامة":
            return GifItem(name: "رافقتك السلامة")
        case "هل أنت بخير":
            return GifItem(name: "2هل أنت بخير")
        case "لحظة من فضلك":
            return GifItem(name: "لحظة من فضلك")
        case "لست احتمل هذا":
            return GifItem(name: "لست احتمل هذا")
        case "أعلى":
            return GifItem(name: "أعلى")
        case "أسفل":
            return GifItem(name: "أسفل")
        default:
            print("No matching GIF found for: \(normalizedText)")
            return nil
        }
    }
}

struct GifImageView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let gifURL = Bundle.main.url(forResource: gifName, withExtension: "gif") {
            webView.load(URLRequest(url: gifURL))
        }
        webView.scrollView.isScrollEnabled = false
        webView.contentMode = .scaleAspectFit
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct SignLanguageTranslationView_Previews: PreviewProvider {
    static var previews: some View {
        SignLanguageTranslationView(text: "كريم")
    }
}
