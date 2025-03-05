import SwiftUI

struct ContentView: View {
    @State private var ladybugs: [Ladybug] = [Ladybug()]
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            List {
                ForEach($ladybugs) { $ladybug in
                    NavigationLink(destination: DetailView(ladybug: $ladybug)) {
                        RowView(ladybug: $ladybug)
                    }
                    .onChange(of: ladybug) { _ in
                        saveLadybugs()
                    }
                }
                .onDelete(perform: deleteLadybugs)
                .onMove(perform: moveLadybugs)
            }
            .padding(.horizontal, 20) // Add horizontal padding to the list

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
            .onAppear(perform: loadLadybugs)
            .onDisappear(perform: saveLadybugs)
        }
    }

    private func addLadybug() {
        ladybugs.append(Ladybug())
        saveLadybugs()
    }

    private func deleteLadybugs(at offsets: IndexSet) {
        ladybugs.remove(atOffsets: offsets)
        saveLadybugs()
    }

    private func moveLadybugs(from source: IndexSet, to destination: Int) {
        ladybugs.move(fromOffsets: source, toOffset: destination)
        saveLadybugs()
    }

    private func loadLadybugs() {
        if let data = UserDefaults.standard.data(forKey: "ladybugs"),
           let decoded = try? JSONDecoder().decode([Ladybug].self, from: data) {
            ladybugs = decoded
        }
    }

    func saveLadybugs() {
        if let encoded = try? JSONEncoder().encode(ladybugs) {
            UserDefaults.standard.set(encoded, forKey: "ladybugs")
        }
    }
}
