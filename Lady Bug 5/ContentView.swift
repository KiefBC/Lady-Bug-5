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
                    .onChange(of: ladybug) { oldValue, newValue in
                        print("Ladybug changed in ContentView: \(newValue.id), has image: \(newValue.image != nil)")
                        saveLadybugs()
                    }
                }
                .onDelete(perform: deleteLadybugs)
                .onMove(perform: moveLadybugs)
            }
            .padding(.horizontal, 20)

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
        let newLadybug = Ladybug()
        ladybugs.append(newLadybug)
        print("Added new ladybug: \(newLadybug.id)")
        saveLadybugs()
    }

    private func deleteLadybugs(at offsets: IndexSet) {
        print("Deleting ladybugs at offsets: \(offsets)")
        ladybugs.remove(atOffsets: offsets)
        saveLadybugs()
    }

    private func moveLadybugs(from source: IndexSet, to destination: Int) {
        print("Moving ladybugs from \(source) to \(destination)")
        ladybugs.move(fromOffsets: source, toOffset: destination)
        saveLadybugs()
    }

    private func loadLadybugs() {
        print("Loading ladybugs from UserDefaults")
        if let data = UserDefaults.standard.data(forKey: "ladybugs"),
           let decoded = try? JSONDecoder().decode([Ladybug].self, from: data) {
            print("Loaded \(decoded.count) ladybugs")
            
            // Debug info about loaded ladybugs
            for (index, bug) in decoded.enumerated() {
                print("Loaded ladybug \(index): id=\(bug.id), name=\(bug.name), has image=\(bug.image != nil)")
                if let imageData = bug.imageAsData {
                    print("  Image data size: \(imageData.count) bytes")
                }
            }
            
            ladybugs = decoded
        } else {
            print("No ladybugs found in UserDefaults or decoding failed")
            // Initialize with an empty ladybug if none found
            if ladybugs.isEmpty {
                ladybugs = [Ladybug()]
            }
        }
    }

    func saveLadybugs() {
        print("Saving \(ladybugs.count) ladybugs to UserDefaults")
        
        // Debug info about ladybugs being saved
        for (index, bug) in ladybugs.enumerated() {
            print("Saving ladybug \(index): id=\(bug.id), name=\(bug.name), has image=\(bug.image != nil)")
            if let imageData = bug.imageAsData {
                print("  Image data size: \(imageData.count) bytes")
            }
        }
        
        if let encoded = try? JSONEncoder().encode(ladybugs) {
            UserDefaults.standard.set(encoded, forKey: "ladybugs")
            UserDefaults.standard.synchronize() // Force immediate write to disk
            
            // Verify the save operation
            if let savedData = UserDefaults.standard.data(forKey: "ladybugs") {
                print("Successfully saved \(savedData.count) bytes to UserDefaults")
                
                // Double-check that our data was properly saved
                if let verifiedLadybugs = try? JSONDecoder().decode([Ladybug].self, from: savedData) {
                    print("Verification: saved \(verifiedLadybugs.count) ladybugs")
                }
            } else {
                print("Failed to retrieve saved data from UserDefaults")
            }
        } else {
            print("Failed to encode ladybugs")
        }
    }
}
