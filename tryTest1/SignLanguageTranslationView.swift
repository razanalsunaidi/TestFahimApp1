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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var historyManager: HistoryManager
    
    init(text: String) {
        self._text = State(initialValue: text)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer() // Push everything to the right initially
                
                Text("فَهِيم")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .offset(x:35)
                
                Spacer()
                
                // Save button aligned to the right corner
                Button(action: {
                    if let videoToShow = getVideoForText(text) {
                        let savedItem = SavedItem(text: text, videoName: videoToShow.name)
                        historyManager.savedItems.append(savedItem)
                    }
                    dismiss() // Dismiss the current view and go back to the home page
                }) {
                    Text("حفظ")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex:"FFFFFF"))
                        .padding(10)
                        .background(Color.clear) // Transparent background
                }
                .padding(.trailing)
            }
            .padding()
            .background(Color(hex: "C1B6A3"))
            
            
            Spacer()
            
            VStack(spacing: 0) {
                
                Spacer() // هذا الـ Spacer سيدفع المربعين إلى أسفل الشاشة
                
                VStack{
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
                
                
                
                ZStack {
                    // المربع الكبير مع النص داخله
                    Rectangle()
                        .fill(Color(hex: "#EFEADC"))
                        .clipShape(TopRoundedCorners(cornerRadius: 100)) // شكل الحواف العلوية فقط
                        .frame(height: 300) // تحديد ارتفاع المربع
                        .padding(.bottom, -40) // إزالة المسافة من الأسفل
                        .overlay(
                            Text(text)
                                .foregroundColor(.black)
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center) // لجعل النص في الوسط
                                .padding()
                        )
                        .zIndex(1) // جعل المستطيل الكبير فوق
                    
                    // المربع الصغير مع النص داخله (في الجزء العلوي فقط)
                    Rectangle()
                        .fill(Color(hex: "#E4DDCB"))
                        .clipShape(TopRoundedCorners(cornerRadius: 24))
                        .frame(width: 160, height: 360)
                        .padding(.trailing, 240)
                        .padding(.bottom, -20) // نزول المربع للأسفل
                        .overlay(
                            VStack {
                                Text("النص")
                                    .foregroundColor(.black) // لون النص
                                    .font(.headline) // نوع الخط
                                    .bold()
                                    .padding(.horizontal, -140) // إبعاد النص عن الحافة العلوية
                                    .padding(.top, 9) // إبعاد النص عن الحافة العلوية
                                    .multilineTextAlignment(.center) // النص في المنتصف
                                Spacer() // ترك باقي المساحة فارغة
                            }
                        )
                        .zIndex(0) // جعل المستطيل الصغير خلف المستطيل الكبير
                }
                .frame(maxHeight: .infinity, alignment: .bottom) // التأكد من أن العناصر في الأسفل
                .edgesIgnoringSafeArea(.bottom) // تجاهل الأمان من الأسفل
            }
            
        }
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
}
