import SwiftUI
import SwiftData

struct TripView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [TripModel]
    @Binding var showCreateTrip: Bool
    @State private var tripToDelete: TripModel?
    
    var body: some View {
        VStack {
            Text("我的行程")
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
                            NavigationLink(destination: TripEditView(trip: trip)) {
                                TripCard(trip: trip)
                                    .onLongPressGesture {
                                        tripToDelete = trip
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .alert("确认删除行程", isPresented: .constant(tripToDelete != nil), presenting: tripToDelete) { trip in
                Button("取消", role: .cancel) {
                    tripToDelete = nil
                }
                Button("删除", role: .destructive) {
                    modelContext.delete(trip)
                    tripToDelete = nil
                }
            } message: { trip in
                Text("确定要删除\(trip.title)吗？")
            }
        }
    }
}

struct TripCard: View {
    let trip: TripModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Image(systemName: "location.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.indigo)
                
                Text(trip.title)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            Text(trip.destinations.map(\.name).joined(separator: " · "))
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

