import SwiftUI

struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: TripModel
    let note: TripNote
    
    @State private var editedContent: String
    @State private var selectedDestinationId: UUID?
    
    init(trip: TripModel, note: TripNote) {
        self.trip = trip
        self.note = note
        _editedContent = State(initialValue: note.content)
        _selectedDestinationId = State(initialValue: note.destinationId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("笔记内容") {
                    TextEditor(text: $editedContent)
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
            .navigationTitle("编辑笔记")
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
                        updateNote()
                        dismiss()
                    }
                    .foregroundColor(editedContent.isEmpty ? Color.gray : Color.indigo)
                    .disabled(editedContent.isEmpty)
                }
            }
        }
    }
    
    private func updateNote() {
        note.content = editedContent
        note.destinationId = selectedDestinationId
    }
} 

#Preview {
    EditNoteView(
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
        ),
        note: TripNote(
            content: "笔记示例笔记示例笔记示例笔记示例"
        )
    )
}
