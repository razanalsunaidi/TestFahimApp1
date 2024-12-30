import SwiftUI
import UIKit

struct GIFImageView: UIViewRepresentable {
    var gifName: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        
        if let gifUrl = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let data = try? Data(contentsOf: gifUrl) {
            imageView.loadGif(data: data)
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

extension UIImageView {
    func loadGif(data: Data) {
        // Load GIF data into a UIImage object
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return
        }
        
        var images: [UIImage] = []
        let count = CGImageSourceGetCount(source)
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }
        
        // Set the UIImageView's animation images and start animating
        self.animationImages = images
        self.animationDuration = Double(images.count) * 0.1
        self.startAnimating()
    }
}

struct SignLang2: View {
    var body: some View {
        VStack(spacing: 0) {
            // الهيدر
            ZStack {
                Rectangle()
                    .foregroundColor(AppColors.customColor)
                HStack {
                    Spacer()
                    Text("فَهِيم")
                        .font(.largeTitle)
                        .bold(true)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.top, 15)
            }
            .frame(height: 150)
            .ignoresSafeArea()
            
            Spacer() // هذا الـ Spacer سيدفع المربعين إلى أسفل الشاشة

                     GIFImageView(gifName: "هل انت بخير ٢")
                                .frame(width: 160, height: 160)
                                .padding(.top, 100) // لضبط موقع الجيف داخل المربع
                      
            ZStack {
                ZStack{
                    Text("hi")
                    // مربع بلون E4DDCB
                    Rectangle()
                        .fill(Color(hex: "#E4DDCB"))
                        .clipShape(TopRoundedCorners(cornerRadius: 24))
                        .frame(width: 160, height: 360)
                        .padding(.trailing, 240)
                        .padding(.bottom, -20) // نزول المربع الكبير للأسفل
                    
                }
                // مربع مقوس من الأعلى فقط
                Rectangle()
                    .fill(Color(hex: "#EFEADC"))
                    .clipShape(TopRoundedCorners(cornerRadius: 100)) // شكل الحواف العلوية فقط
                    .frame(height: 300) // تحديد ارتفاع المربع
                    .padding(.bottom, -40) // إزالة المسافة من الأسفل
                
                }
            .frame(maxHeight: .infinity, alignment: .bottom) // تأكد من أن المربعين في الأسفل
        }
        .edgesIgnoringSafeArea(.bottom) // تجاهل الأمان من الأسفل للتأكد من أن المربعين يصلان إلى أسفل الشاشة
    }
}

// شكل مخصص للحواف العلوية فقط
struct TopRoundedCorners: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height)) // أسفل يسار
        path.addLine(to: CGPoint(x: 0, y: cornerRadius)) // فوق يسار
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
                          control: CGPoint(x: 0, y: 0)) // تقوس الزاوية العلوية اليسرى
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0)) // خط علوي
        path.addQuadCurve(to: CGPoint(x: rect.width, y: cornerRadius),
                          control: CGPoint(x: rect.width, y: 0)) // تقوس الزاوية العلوية اليمنى
        path.addLine(to: CGPoint(x: rect.width, y: rect.height)) // أسفل يمين
        path.closeSubpath() // إغلاق الشكل
        return path
    }
}

#Preview {
    SignLang2()
}
