//import SwiftUI
//
//struct GIFItem: Identifiable {
//    let id = UUID()
//    let name: String
//}
//
//struct SignLang22: View {
//    @State private var text: String = "اسفل"
//    @State private var gifName: String = "default"
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // الهيدر
//            ZStack {
//                Rectangle()
//                    .foregroundColor(AppColors.customColor)
//                HStack {
//                    Spacer()
//                    Text("فَهِيم")
//                        .font(.largeTitle)
//                        .bold()
//                        .foregroundColor(.black)
//                    Spacer()
//                }
//                .padding(.top, 15)
//            }
//            .frame(height: 150)
//            .ignoresSafeArea()
//
//            Spacer() // هذا الـ Spacer سيدفع المربعين إلى أسفل الشاشة
//
//            // عرض GIF
//            GIFImageView(gifName: gifName)
//                .frame(width: 160, height: 160)
//                .padding(.top, 100) // لضبط موقع الـ GIF داخل المربع
//
//            ZStack {
//                // المربع الكبير مع النص داخله
//                Rectangle()
//                    .fill(Color(hex: "#EFEADC"))
//                    .clipShape(TopRoundedCorners(cornerRadius: 100)) // شكل الحواف العلوية فقط
//                    .frame(height: 300) // تحديد ارتفاع المربع
//                    .padding(.bottom, -40) // إزالة المسافة من الأسفل
//                    .overlay(
//                        Text(text)
//                            .foregroundColor(.black)
//                            .font(.title)
//                            .bold()
//                            .multilineTextAlignment(.center) // لجعل النص في الوسط
//                            .padding()
//                    )
//                    .zIndex(1) // جعل المستطيل الكبير فوق
//
//                // المربع الصغير مع النص داخله (في الجزء العلوي فقط)
//                Rectangle()
//                    .fill(Color(hex: "#E4DDCB"))
//                    .clipShape(TopRoundedCorners(cornerRadius: 24))
//                    .frame(width: 160, height: 360)
//                    .padding(.trailing, 240)
//                    .padding(.bottom, -20) // نزول المربع للأسفل
//                    .overlay(
//                        VStack {
//                            Text("النص")
//                                .foregroundColor(.black) // لون النص
//                                .font(.headline) // نوع الخط
//                                .bold()
//                                .padding(.horizontal, -140) // إبعاد النص عن الحافة العلوية
//                                .padding(.top, 9) // إبعاد النص عن الحافة العلوية
//                                .multilineTextAlignment(.center) // النص في المنتصف
//                            Spacer() // ترك باقي المساحة فارغة
//                        }
//                    )
//                    .zIndex(0) // جعل المستطيل الصغير خلف المستطيل الكبير
//            }
//            .frame(maxHeight: .infinity, alignment: .bottom) // التأكد من أن العناصر في الأسفل
//            .edgesIgnoringSafeArea(.bottom) // تجاهل الأمان من الأسفل
//        }
//        .onAppear {
//            updateGIF(for: text) // تحديث الـ GIF بناءً على النص
//        }
//    }
//
//    private func updateGIF(for text: String) {
//        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//            .folding(options: .diacriticInsensitive, locale: .current)
//            .lowercased()
//
//        switch normalizedText {
//        case "كريم":
//            gifName = "كريم"
//        case "رافقتك السلامة":
//            gifName = "رافقتك السلامة"
//        case "هل انت بخير ٢":
//            gifName = "هل انت بخير ٢"
//        case "لحظة من فضلك":
//            gifName = "لحظة من فضلك"
//        case "لست احتمل هذا":
//            gifName = "لست احتمل هذا"
//        case "أعلى":
//            gifName = "أعلى"
//        case "أسفل":
//            gifName = "اسفل"
//        default:
//            gifName = "default" // اسم GIF افتراضي إذا لم يتم العثور على تطابق
//        }
//    }
//}
//
//// شكل مخصص للحواف العلوية فقط
//struct TopRoundedCorners: Shape {
//    var cornerRadius: CGFloat
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: 0, y: rect.height)) // أسفل يسار
//        path.addLine(to: CGPoint(x: 0, y: cornerRadius)) // فوق يسار
//        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
//                          control: CGPoint(x: 0, y: 0)) // تقوس الزاوية العلوية اليسرى
//        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0)) // خط علوي
//        path.addQuadCurve(to: CGPoint(x: rect.width, y: cornerRadius),
//                          control: CGPoint(x: rect.width, y: 0)) // تقوس الزاوية العلوية اليمنى
//        path.addLine(to: CGPoint(x: rect.width, y: rect.height)) // أسفل يمين
//        path.closeSubpath() // إغلاق الشكل
//        return path
//    }
//}
//
//// UIViewRepresentable لعرض ملفات GIF
//struct GIFImageView: UIViewRepresentable {
//    var gifName: String
//
//    func makeUIView(context: Context) -> UIImageView {
//        let imageView = UIImageView()
//
//        // التأكد من أن الـ GIF موجود في bundle
//        if let gifUrl = Bundle.main.url(forResource: gifName, withExtension: "gif"),
//           let data = try? Data(contentsOf: gifUrl) {
//            imageView.loadGif(data: data)
//        } else {
//            print("GIF file not found: \(gifName).gif")
//        }
//
//        return imageView
//    }
//
//    func updateUIView(_ uiView: UIImageView, context: Context) {}
//}
//
//extension UIImageView {
//    func loadGif(data: Data) {
//        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
//            return
//        }
//
//        var images: [UIImage] = []
//        let count = CGImageSourceGetCount(source)
//
//        for i in 0..<count {
//            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
//                images.append(UIImage(cgImage: cgImage))
//            }
//        }
//
//        self.animationImages = images
//        self.animationDuration = Double(images.count) * 0.1
//        self.startAnimating()
//    }
//}
//
//#Preview {
//    SignLang2()
//}
