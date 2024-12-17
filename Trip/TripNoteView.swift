import SwiftUI
import SwiftData

struct TripNoteView: View {
    @Query private var trips: [TripModel]
    
    var body: some View {
        VStack {
            Text("行程笔记")
                .font(.title)
                .fontWeight(.bold)
                .padding([.top, .bottom, .trailing], 16.0)
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                VStack(spacing: 12) {
                    if trips.isEmpty {
                        ContentUnavailableView(
                            "No Trips",
                            systemImage: "globe.desk",
                            description: Text("You can set a new trip \n tapping on the \(Image(systemName: "plus.circle.fill")) button.")
                        ).padding(.top, 40.0)
                    } else {
                        ForEach(trips) { trip in
                            NavigationLink(destination: TripNoteListView(trip: trip)) {
                                TripNoteCard(trip: trip)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct TripNoteCard: View {
    let trip: TripModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(trip.title)
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            if trip.notes.isEmpty {
                Text("暂无笔记")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                // 只显示最新的2条笔记预览
                ForEach(trip.notes.sorted(by: { $0.createdAt > $1.createdAt }).prefix(2)) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.content)
                            .font(.subheadline)
                            .lineLimit(2)
                            .foregroundColor(.black)
                        
                        HStack {
                            if let destinationId = note.destinationId,
                               let destination = trip.destinations.first(where: { $0.id == destinationId }) {
                                Label(destination.name, systemImage: "mappin")
                                    .font(.caption)
                                    .foregroundColor(.indigo)
                            }
                            
                            Spacer()
                            
                            Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 2)
                    
                    if note.id != trip.notes.sorted(by: { $0.createdAt > $1.createdAt }).prefix(2).last?.id {
                        Divider()
                    }
                }
                
                if trip.notes.count > 2 {
                    Text("查看全部\(trip.notes.count)条笔记...")
                        .font(.caption)
                        .foregroundColor(.indigo)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
