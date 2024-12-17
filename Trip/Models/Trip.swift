import Foundation
import SwiftData
import CoreLocation

@Model
class TripModel {
    var id: UUID
    var title: String
    @Relationship(deleteRule: .cascade)
    var destinations: [Destination]
    @Relationship(deleteRule: .cascade)
    var notes: [TripNote]
    
    init(title: String, destinations: [Destination] = [], notes: [TripNote] = []) {
        self.id = UUID()
        self.title = title
        self.destinations = destinations
        self.notes = notes
    }
}

@Model
class Destination {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, 
         address: String,
         latitude: Double, 
         longitude: Double) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
