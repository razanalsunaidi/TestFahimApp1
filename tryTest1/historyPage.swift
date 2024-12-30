//import SwiftUI
//
//struct HistoryVideoItem: Identifiable {
//    let id = UUID()
//    let name: String
//}
//
//struct HistoryPage: View {
//    @State private var videoHistory: [HistoryVideoItem] = []
//    @State private var videoName: String = ""
//    @State private var showingAddVideo = false
//
//    var body: some View {
//        VStack {
//            // Header
//            ZStack {
//                Rectangle()
//                    .foregroundColor(Color(hex: "#C1B6A3")) // Set your desired header background color
//                    .frame(height: 150) // Fixed height for the header
//
//                HStack {
//                    Spacer()
//                    Text("فَهِيم")
//                        .font(.largeTitle)
//                        .foregroundColor(.black) // White text color
//                        .padding(.top, 50) // Adjust top padding for centering
//
//                    Spacer()
//                    Button(action: {
//                        showingAddVideo.toggle()
//                    }) {
//                        Image(systemName: "photo.on.rectangle")
//                            .font(.title)
//                            .foregroundColor(.white) // White icon color
//                            .padding(.trailing, 20)
//                    }
//                }
//                .padding(.horizontal, 30) // Adjust horizontal padding
//            }
//            .ignoresSafeArea()
//
//            // Video History List
//            List(videoHistory) { video in
//                Text(video.name)
//            }
//            .listStyle(PlainListStyle())
//            .padding(.top, 10)
//        }
//    }
//
//    // Function to add video to history
//    private func addVideo() {
//        if !videoName.isEmpty {
//            let newVideo = HistoryVideoItem(name: videoName)
//            videoHistory.append(newVideo)
//            videoName = "" // Reset the video name after adding
//        }
//    }
//}
//
//struct AddVideoView: View {
//    @Binding var videoName: String
//    let onAdd: () -> Void
//    var dismissAction: () -> Void
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Add Video")) {
//                    TextField("Video Name", text: $videoName)
//                }
//
//                Button(action: {
//                    onAdd()
//                    dismissAction() // Call dismiss action after adding
//                }) {
//                    Text("Add Video")
//                }
//            }
//            .navigationTitle("Add Video")
//            .navigationBarItems(trailing: Button("Done") {
//                dismissAction() // Dismiss the view
//            })
//        }
//    }
//}
//
//#Preview {
//    HistoryPage()
//}
