import SwiftUI
import SwiftData

struct MainTabView: View {
    // 当前选中的标签
    @State private var selectedTab = 0
    @State private var showCreateTrip = false
    @State private var showingNewTripSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TripView(showCreateTrip: $showCreateTrip)
                    .tag(0)
                
                TripNoteView()
                    .tag(1)
            }
            
            // 导航栏
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Button(action: { selectedTab = 0 }) {
                        VStack {
                            Image(systemName: "map.fill")
                                .font(.system(size: 20))
                            Text("行程")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(selectedTab == 0 ? .black : .gray)
                    }
                    
                    Spacer()
                    
                    // 空视图占位
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 60)
                    
                    Spacer()
                    
                    Button(action: { selectedTab = 1 }) {
                        VStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 20))
                            Text("笔记")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(selectedTab == 1 ? .black : .gray)
                    }
                    
                    Spacer()
                }
                .frame(height: 50)
                .background(
                    Rectangle()
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: -5)
                )
            }
            
            // 添加行程按钮
            Button(action: {
//                showCreateTrip = true
                showingNewTripSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.black)
                    .clipShape(Circle())
            }
            .offset(y: -20)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingNewTripSheet) {
            NewTripView()
        }
    }
}

struct NewTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var tripTitle = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack{
                        Text("给新行程取个名字吧👋")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.vertical, 100.0)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("请输入行程名称", text: $tripTitle)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.top, 20)
            }
            .navigationBarItems(
                leading: Button("取消") { 
                    dismiss() 
                }
                    .foregroundColor(.indigo),
                trailing: Button(action: {
                    let newTrip = TripModel(title: tripTitle)
                    modelContext.insert(newTrip)
                    dismiss()
                }) {
                    Text("开始规划")
                        .fontWeight(.medium)
                        .foregroundColor(tripTitle.isEmpty ? Color.gray : Color.indigo)
                }
                .disabled(tripTitle.isEmpty)
            )
        }
    }
}


#Preview {
    MainTabView()
}
