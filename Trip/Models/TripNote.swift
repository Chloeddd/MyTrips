import Foundation
import SwiftData

@Model
class TripNote {
    var id: UUID
    var content: String
    var createdAt: Date
    var destinationId: UUID?
    var lastEditedAt: Date?
    
    init(content: String, destinationId: UUID? = nil) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.destinationId = destinationId
    }
} 