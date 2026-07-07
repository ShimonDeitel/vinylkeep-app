import Foundation

struct RecordEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var detail1: String
    var detail2: String
    var note: String
    var date: Date
    var isFavorite: Bool = false
}
