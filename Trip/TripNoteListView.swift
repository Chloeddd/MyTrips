import SwiftUI

struct TripNoteListView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: TripModel
    @State private var showingNewNoteSheet = false
    @State private var noteToDelete: TripNote?
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .foregroundColor(.black)
                
                Spacer()
                
                Button(action: { showingNewNoteSheet = true }) {
                    Image(systemName: "note.text.badge.plus")
                        .font(.system(size: 25))
                        .foregroundColor(.indigo)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            VStack {
                Text(trip.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding([.top, .bottom, .trailing], 16.0)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView {
                    VStack(spacing: 12) {
                        if trip.notes.isEmpty {
                            ContentUnavailableView(
                                "No Notes",
                                systemImage: "note.text",
                                description: Text("You can write a new note \n tapping on the \(Image(systemName: "note.text.badge.plus")) button.")
                            ).padding(.top, 40.0)
                        } else {
                            ForEach(trip.notes.sorted(by: { $0.createdAt > $1.createdAt })) { note in
                                NoteCard(note: note, trip: trip)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            noteToDelete = note
                                        } label: {
                                            Label("删除笔记", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingNewNoteSheet) {
            NewNoteView(trip: trip)
        }
        .alert("确认删除笔记", isPresented: .constant(noteToDelete != nil), presenting: noteToDelete) { note in
            Button("取消", role: .cancel) {
                noteToDelete = nil
            }
            Button("删除", role: .destructive) {
                if let index = trip.notes.firstIndex(where: { $0.id == note.id }) {
                    trip.notes.remove(at: index)
                }
                noteToDelete = nil
            }
        } message: { note in
            Text("确定要删除这条笔记吗？")
        }
    }
}

struct NoteCard: View {
    let note: TripNote
    let trip: TripModel
    @State private var showingEditSheet = false
    
    var associatedDestination: Destination? {
        trip.destinations.first { $0.id == note.destinationId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.content)
                .font(.body)
                .foregroundColor(.black)
            
            HStack {
                if let destination = associatedDestination {
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
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            EditNoteView(trip: trip, note: note)
        }
    }
}

#Preview {
    NavigationStack {
        TripNoteListView(
            trip: TripModel(
                title: "示例行程",
                destinations: [],
                notes: [
                    TripNote(
                        content: "   笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例\n   笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例",
                        destinationId: UUID() // 这里可以根据需要设置关联目的地
                    ),
                    TripNote(
                        content: "笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例"
                    ),
                    TripNote(
                        content: "笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例笔记示例"
                    )
                ]
            )
        )
    }
}
