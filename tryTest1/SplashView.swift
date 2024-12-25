import SwiftUI
import AVKit

struct SplashView: View {
    var body: some View {
        ZStack {
            // الخلفية باللون C1B6A3
            Color(uiColor: UIColor(hex: "#C1B6A3"))
                .edgesIgnoringSafeArea(.all) // تأكد من تغطية كامل الشاشة

            if let gifURL = Bundle.main.url(forResource: "splash", withExtension: "gif") {
                GIFView(url: gifURL)
                    .aspectRatio(contentMode: .fit) // استخدم fit للحفاظ على الجودة
                    .edgesIgnoringSafeArea(.all) // تأكد من أن الـ GIF يغطي كامل الشاشة
                    .offset(x: -30) // إزاحة الصورة لليسار قليلاً
            } else {
                Text("GIF file not found.")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            // الانتقال بعد 3 ثوانٍ
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: ContentView())
            }
        }
    }
}

struct GIFView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> UIView {
        let webView = UIWebView()
        webView.scalesPageToFit = true
        webView.isUserInteractionEnabled = false
        webView.loadRequest(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// تحويل hex إلى UIColor
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
