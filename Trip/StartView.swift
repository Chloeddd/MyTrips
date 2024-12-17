import SwiftUI

struct StartView: View {
    @State private var shouldNavigateToMain = false
    
    var body: some View {
        VStack {
            Image(systemName: "map.circle.fill")
                .font(.system(size: 100))
                .frame(width: 150.0, height: 150.0)
            
            Text("My Trips")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5.0)
            
            Text("Plan and record every trip")
                .fontWeight(.semibold)
                .foregroundColor(Color.gray.opacity(0.5))
            
            Button(action: {
                shouldNavigateToMain = true
            }) {
                Text("Start")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .padding(.top, 200.0)
        }
        .padding()
        .navigationDestination(isPresented: $shouldNavigateToMain) {
            MainTabView()
        }
    }
} 

#Preview {
    StartView()
}
