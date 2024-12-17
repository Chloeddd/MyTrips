import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: TripModel
    
    @State private var noteContent = ""
    @State private var selectedDestinationId: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section("笔记内容") {
                    TextEditor(text: $noteContent)
                        .frame(height: 150)
                        .padding(10.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                }
                
                Section("相关目的地（可选）") {
                    Picker("选择目的地", selection: $selectedDestinationId) {
                        Text("无相关目的地").tag(nil as UUID?)
                        ForEach(trip.destinations) { destination in
                            Text(destination.name).tag(destination.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("新建笔记")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Color.indigo)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveNote()
                        dismiss()
                    }
                    .foregroundColor(noteContent.isEmpty ? Color.gray : Color.indigo)
                    .disabled(noteContent.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        let note = TripNote(content: noteContent, destinationId: selectedDestinationId)
        trip.notes.append(note)
    }
} 

#Preview {
    NewNoteView(
        trip: TripModel(
            title: "示例行程",
            destinations: [
                Destination(
                    name: "地点1",
                    address: "1111",
                    latitude: 30,
                    longitude: 130
                ),
                Destination(
                    name: "地点2",
                    address: "2222",
                    latitude: 30,
                    longitude: 130
                )
            ]
        )
    )
}
