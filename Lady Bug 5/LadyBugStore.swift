import SwiftUI
import Combine

// This class will manage all ladybug data and persistence
class LadybugStore: ObservableObject {
    @Published var ladybugs: [Ladybug] = [Ladybug()]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLadybugs()
        
        // Set up automatic saving when ladybugs array changes
        $ladybugs
            .debounce(for: 0.5, scheduler: RunLoop.main) // Wait for changes to settle
            .sink { [weak self] _ in
                self?.saveLadybugs()
            }
            .store(in: &cancellables)
    }
    
    func loadLadybugs() {
        print("Loading ladybugs from UserDefaults")
        if let data = UserDefaults.standard.data(forKey: "ladybugs"),
           let decoded = try? JSONDecoder().decode([Ladybug].self, from: data) {
            print("Loaded \(decoded.count) ladybugs")
            ladybugs = decoded
        } else {
            print("No ladybugs found in UserDefaults or decoding failed")
            // Initialize with default if none found
            if ladybugs.isEmpty {
                ladybugs = [Ladybug()]
            }
        }
    }
    
    func saveLadybugs() {
        print("Saving \(ladybugs.count) ladybugs to UserDefaults")
        
        if let encoded = try? JSONEncoder().encode(ladybugs) {
            UserDefaults.standard.set(encoded, forKey: "ladybugs")
            UserDefaults.standard.synchronize() // Force immediate write to disk
            print("Successfully saved ladybugs to UserDefaults")
        } else {
            print("Failed to encode ladybugs")
        }
    }
    
    func addLadybug() {
        ladybugs.append(Ladybug())
    }
    
    func deleteLadybug(at offsets: IndexSet) {
        ladybugs.remove(atOffsets: offsets)
    }
    
    func moveLadybug(from source: IndexSet, to destination: Int) {
        ladybugs.move(fromOffsets: source, toOffset: destination)
    }
    
    func updateLadybug(_ ladybug: Ladybug) {
        if let index = ladybugs.firstIndex(where: { $0.id == ladybug.id }) {
            ladybugs[index] = ladybug
        }
    }
}
