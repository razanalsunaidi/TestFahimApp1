import SwiftUI

struct SavedItem: Identifiable {
    let id = UUID()
    let text: String
    let videoName: String
}


class HistoryManager: ObservableObject {
    @Published var savedItems: [SavedItem] = []
}
