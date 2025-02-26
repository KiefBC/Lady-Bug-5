import SwiftUI

struct Ladybug: Identifiable {
    var id = UUID()
    var name: String = "Ladybug"
    var date: Date = Date()
}

// Row View for each list item
struct RowView: View {
    var ladybug: Ladybug
    
    var body: some View {
        HStack {
            Image(systemName: "ladybug.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
            
            Text(ladybug.name)
            
            Spacer()
        }
    }
}

struct DetailView: View {
    @Binding var ladybug: Ladybug
    
    var body: some View {
        VStack {
            Image(systemName: "ladybug.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.black)
            
            TextField("Name", text: $ladybug.name)
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, h:mma"
        return formatter.string(from: ladybug.date)
    }
}

struct ContentView: View {
    @State private var ladybugs = [Ladybug]()
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ladybugs) { ladybug in
                    NavigationLink(destination: DetailView(ladybug: binding(for: ladybug))) {
                        RowView(ladybug: ladybug)
                    }
                }
                .onDelete(perform: deleteLadybugs)
                .onMove(perform: moveLadybugs)
            }
            .navigationTitle("Ladybugs")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addLadybug) {
                        Image(systemName: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    private func binding(for ladybug: Ladybug) -> Binding<Ladybug> {
        guard let index = ladybugs.firstIndex(where: { $0.id == ladybug.id }) else {
            fatalError("Ladybug not found")
        }
        return $ladybugs[index]
    }
    
    // Add a new ladybug to the list
    private func addLadybug() {
        ladybugs.append(Ladybug())
    }
    
    // Delete ladybugs
    private func deleteLadybugs(at offsets: IndexSet) {
        ladybugs.remove(atOffsets: offsets)
    }
    
    // Move ladybugs for drag and drop reordering
    private func moveLadybugs(from source: IndexSet, to destination: Int) {
        ladybugs.move(fromOffsets: source, toOffset: destination)
    }
}
