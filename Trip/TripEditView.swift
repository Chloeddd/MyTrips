import SwiftUI
import MapKit
import SwiftData
import Contacts

struct TripEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: TripModel
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: MKMapItem?
    @State private var camera: MapCameraPosition = .automatic
    @State private var destinationToDelete: Destination?
    
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
                
//                    Text(trip.title)
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .padding([.top, .bottom, .trailing], 16.0)
//                        .padding(.leading, 20)
//                        .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        VStack{
                            Map(position: $camera) {
                                // 显示所有搜索结果
                                ForEach(searchResults, id: \.self) { item in
                                    if item == selectedLocation {
                                        Marker(item.name ?? "选中位置", coordinate: item.placemark.coordinate)
                                            .tint(.blue)
                                    } else {
                                        Marker(item.name ?? "搜索结果", coordinate: item.placemark.coordinate)
                                            .tint(.yellow)
                                    }
                                }
                                
                                // 显示已确认的位置
                                ForEach(trip.destinations) { destination in
                                    Marker(destination.name, coordinate: destination.coordinate)
                                        .tint(.red)
                                }
                            }
                            .padding(.horizontal, 20.0)
                            .padding(.top, 10.0)
                        }
                        .frame(height: UIScreen.main.bounds.height / 3)
                        
                        VStack {
                            TextField("搜索位置", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .onChange(of: searchText) {
                                    searchLocations()
                                }
                            
                            if !searchResults.isEmpty {
                                ScrollView {
                                    LazyVStack {
                                        ForEach(searchResults, id: \.self) { item in
                                            Button(action: {
                                                selectedLocation = item
                                                let coordinates = searchResults.map { $0.placemark.coordinate }
                                                if let region = calculateRegion(for: coordinates) {
                                                    camera = .region(region)
                                                }
                                            }) {
                                                HStack {
                                                    Text(item.name ?? "未知位置")
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                    if item == selectedLocation {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                            }
                                            Divider()
                                        }
                                    }
                                }
                            }
                            
                            if let selected = selectedLocation {
                                Button("添加到行程") {
                                    addDestination(from: selected)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(Color.black)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .frame(width: 150)
                            }
                        }
                        .frame(maxHeight: 250)
                        .background(Color(.white))
                        
                        VStack{
                            HStack{
                                Text("行程目的地")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                NavigationLink(destination: TripRouteView(trip: trip)){
                                    HStack{
                                        Text("路线")
                                            .foregroundColor(.indigo)
                                        Image(systemName: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath")
    //                                        .padding(2.0)
                                            .font(.system(size: 20))
                                            .foregroundColor(.indigo)
    //                                        .background(Color(.indigo))
                                    }
    //                                .cornerRadius(5)
                                }
                            }
                            .padding(.trailing)
                            
                            VStack(spacing: 12) {
                                ScrollView{
                                    ForEach(trip.destinations) { destination in
                                        DestinationCard(destination: destination)
                                            .onLongPressGesture {
                                                destinationToDelete = destination
                                            }
                                    }
                                }
                            }
                        }
                        .padding([.top, .leading, .trailing])
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .alert("确定删除", isPresented: .constant(destinationToDelete != nil), presenting: destinationToDelete) { destination in
                Button("取消", role: .cancel) {
                    destinationToDelete = nil
                }
                Button("删除", role: .destructive) {
                    if let index = trip.destinations.firstIndex(where: { $0.id == destination.id }) {
                        trip.destinations.remove(at: index)
                    }
                    destinationToDelete = nil
                }
            } message: { destination in
                Text("确定要删除目的地 \(destination.name) 吗？")
            }
        }
    }
    
    private func addDestination(from mapItem: MKMapItem) {
        let destination = Destination(
            name: mapItem.name ?? "未知位置",
            address: mapItem.placemark.title ?? "未知地址",
            latitude: mapItem.placemark.coordinate.latitude,
            longitude: mapItem.placemark.coordinate.longitude
        )
        
        trip.destinations.append(destination)
        
        selectedLocation = nil
        searchText = ""
        searchResults = []
    }
    
    private func deleteDestinations(at offsets: IndexSet) {
        trip.destinations.remove(atOffsets: offsets)
    }
    
    private func searchLocations() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("搜索错误: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            searchResults = response.mapItems
            
            if !response.mapItems.isEmpty {
                let coordinates = response.mapItems.map { $0.placemark.coordinate }
                if let region = calculateRegion(for: coordinates) {
                    camera = .region(region)
                }
            }
        }
    }
    
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

struct DestinationCard: View {
    let destination: Destination
    
    @State private var showingSheet = false
    
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
            
            // 跳转地图导航按钮
//            Button(action: openInMaps) {
//                Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
//                    .padding(.trailing)
//                    .font(.system(size: 20))
//                    .foregroundColor(.indigo)
//            }
            
            Button(action: {
                showingSheet = true
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .padding(.trailing)
                    .font(.system(size: 20))
                    .foregroundColor(.indigo)
            }
            
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.white))
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .sheet(isPresented: $showingSheet) {
            DestinationDetailView(destination: destination)
        }
    }
}
    
#Preview {
    TripEditView(
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
