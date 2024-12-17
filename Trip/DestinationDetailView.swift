import SwiftUI
import MapKit

struct DestinationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let destination: Destination
    
    // 用于存储用户位置
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var routes: [MKRoute] = []
    @State private var camera: MapCameraPosition = .automatic
    // 位置管理器
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(destination.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(destination.address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    VStack {
                        Map(position: $camera) {
                            Marker(destination.name, coordinate: destination.coordinate)
                                .tint(.indigo)
                            
                            if let userLocation = locationManager.location {
                                Marker("我的位置", coordinate: userLocation)
                                    .tint(.blue)
                            }
                            
                            ForEach(routes, id: \.self) { route in
                                MapPolyline(route.polyline)
                                    .stroke(.indigo, lineWidth: 4)
                            }
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                        
                        // 交通方式选择和时间显示
                        if let userLocation = locationManager.location {
                            VStack(spacing: 15) {
                                HStack(spacing: 16) {
                                    Button(action:{
                                        calculateRoute(from: userLocation,
                                                      to: destination.coordinate,
                                                      transportType: .walking)
                                    }){
                                        Text("步行路线")
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(Color.black)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                                    .frame(width: 100)
                                    
                                    Button(action:{
                                        calculateRoute(from: userLocation,
                                                      to: destination.coordinate,
                                                      transportType: .automobile)
                                    }){
                                        Text("驾车路线")
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(Color.black)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                                    .frame(width: 100)
                                    
                                    Button(action: openInMaps) {
                                        Text("打开地图")
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(Color.black)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                                    .frame(width: 100)
                                }
                                
                                // 显示路线信息
                                ForEach(routes, id: \.self) { route in
                                    HStack {
                                        Text("预计时间：\(formatTime(seconds: route.expectedTravelTime))")
                                        Text("距离：\(formatDistance(meters: route.distance))")
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                    .foregroundColor(Color.black)
                }
            }
        }
        .onAppear {
            // 请求位置权限
            locationManager.requestLocation()
            
            // 设置初始相机位置
            camera = .region(MKCoordinateRegion(
                center: destination.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    // 打开地图app
    private func openInMaps() {
        let coordinate = destination.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = destination.name
        
        mapItem.openInMaps()
    }
    
    // 计算路线
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
            routes = [route]
            
            // 创建包含起点和终点的区域
//            let rect = route.polyline.boundingMapRect
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (from.latitude + to.latitude) / 2,
                    longitude: (from.longitude + to.longitude) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: abs(from.latitude - to.latitude) * 1.3,
                    longitudeDelta: abs(from.longitude - to.longitude) * 1.3
                )
            )
            // 更新相机位置
            camera = .region(region)
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
}

// 位置管理器类
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var locationError: Error?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        // 检查位置服务是否启用
        if CLLocationManager.locationServicesEnabled() {
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()  // 改用持续更新位置
        }
    }
    
    func locationManager(_ manager: CLLocationManager, 
                        didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, 
                        didFailWithError error: Error) {
        print("位置获取错误: \(error.localizedDescription)")
        locationError = error
    }
    
    func locationManager(_ manager: CLLocationManager,
                        didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("位置权限被拒绝或受限")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

#Preview {
    DestinationDetailView(destination: Destination(
       name: "故宫",
       address: "详细地址详细地址详细地址详细地址详细地址详细地址",
       latitude: 39.9163,
       longitude: 116.3972)
    )
}
