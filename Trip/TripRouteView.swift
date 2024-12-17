import SwiftUI
import MapKit
import SwiftData
import Contacts

struct TripRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: TripModel
    
    @State private var transportType: MKDirectionsTransportType = .automobile
    @State private var camera: MapCameraPosition = .automatic
    @State private var routes: [MKRoute] = []
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack {
            // 自定义标题栏
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                Map(position: $camera) {
                    ForEach(trip.destinations, id: \.self) { item in
                        
                    }
                    
                    ForEach(trip.destinations) { destination in
                        Marker(destination.name, coordinate: destination.coordinate)
                            .tint(.indigo)
                    }
                    
                    ForEach(routes, id: \.self) { route in
                        MapPolyline(route.polyline)
                            .stroke(.indigo, lineWidth: 4)
                    }
                }
                .padding(.horizontal, 20.0)
                .padding(.top, 10)
                .frame(height: 400.0)
                
                HStack{
                    Button(action:{
                        transportType = .walking
                        getAllRoutes()
                    }){
                        Text("\(Image(systemName: "figure.walk")) 步行路线")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundColor(transportType == .walking ? Color.indigo : Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(transportType == .walking ? Color.indigo : Color.gray)
                    )
                    .frame(width: 130)
                    
                    Spacer()
                        .frame(width: 40)
                    
                    Button(action:{
                        transportType = .automobile
                        getAllRoutes()
                    }){
                        Text("\(Image(systemName: "car.fill")) 驾车路线")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .foregroundColor(transportType == .automobile ? Color.indigo : Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(transportType == .automobile ? Color.indigo : Color.gray)
                    )
                    .frame(width: 130)
                }
                .padding(.vertical, 8.0)
                
                ScrollView{
                    ForEach(0..<trip.destinations.count) { index in
                        VStack {
                            PositionCard(destination: trip.destinations[index])
                            
                            if index < routes.count {
                                RouteCard(time: formatTime(seconds: routes[index].expectedTravelTime), distance: formatDistance(meters: routes[index].distance), transportType: transportType)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear{
            getAllRoutes()
        }
//        .navigationBarItems(trailing: Button(action:{
//            createTripImage()
//        }){
//            Text("生成行程图 \(Image(systemName: "square.and.arrow.up"))")
//        })
    }
    
    private func getAllRoutes() {
        routes.removeAll()
        for i in 0..<trip.destinations.count - 1{
            let start = trip.destinations[i].coordinate
            let end = trip.destinations[i+1].coordinate
            calculateRoute(from: start, to: end, transportType: transportType)
        }
        
        isLoading = false
    }
    
    private func calculateRoute(from: CLLocationCoordinate2D,
                             to: CLLocationCoordinate2D,
                                transportType: MKDirectionsTransportType) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            routes.append(route)
        }
    }
    
    // 格式化时间
    private func formatTime(seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    // 格式化距离
    private func formatDistance(meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f公里", meters / 1000)
        } else {
            return String(format: "%.0f米", meters)
        }
    }
    
    private func createTripImage() {
        DispatchQueue.main.async {
            let mapView = UIHostingController(rootView: Map(position: $camera))
            
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 400))
            
            let image = renderer.image{ context in
                mapView.view.drawHierarchy(in: mapView.view.bounds, afterScreenUpdates: true)
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}

struct PositionCard: View {
    let destination: Destination
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8){
                HStack{
                    Image(systemName: "mappin.and.ellipse.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.indigo)
                    
                    Text(destination.name)
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                Text(destination.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
//        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.white))
//                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
//        )
    }
}

struct RouteCard: View {
    let time: String
    let distance : String
    let transportType : MKDirectionsTransportType
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.down")
                .font(.system(size: 20))
            
            if transportType == .walking {
                Image(systemName: "figure.walk")
            }else {
                Image(systemName: "car.fill")
            }
            Text("\(distance) 预计\(time)")
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        TripRouteView(
            trip: TripModel(
                title: "示例数据：北京三日游",
                destinations: [
                    Destination(
                        name: "故宫",
                        address: "详细地址详细地址详细地址详细地址详细地址详细地址",
                        latitude: 39.9163,
                        longitude: 116.3972
                    ),
                    Destination(
                        name: "长城",
                        address: "详细地址",
                        latitude: 40.4319,
                        longitude: 116.5704
                    ),
                    Destination(
                        name: "天坛",
                        address: "详细地址",
                        latitude: 39.8822,
                        longitude: 116.4066
                    )
                ]
            )
        )
    }
}
