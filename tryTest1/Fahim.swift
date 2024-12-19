import Foundation
import SwiftData

@Model
final class Fahem {
    @Attribute(.unique) var id: UUID
       var url: URL
       var dateUploaded: Date
       var keywordMappings: [String: String]

       init(
           id: UUID = UUID(),
           url: URL,
           dateUploaded: Date = Date(),
           keywordMappings: [String: String] = [:]
       ) {
           self.id = id
           self.url = url
           self.dateUploaded = dateUploaded
           self.keywordMappings = keywordMappings
       }
}
