import SwiftUI

struct Ladybug: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String = "Ladybug"
    var date: Date = Date()
    var imageAsData: Data?
    
    var image: UIImage? {
        get {
            guard let imageAsData = imageAsData else { return nil }
            return UIImage(data: imageAsData)
        }
        set {
            if let newImage = newValue {
                // Compress the image to save space
                if let compressedData = newImage.jpegData(compressionQuality: 0.7) {
                    imageAsData = compressedData
                } else {
                    // Fallback to PNG if JPEG compression fails
                    imageAsData = newImage.pngData()
                }
            } else {
                imageAsData = nil
            }
        }
    }
    
    // Add coding keys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, name, date, imageAsData
    }
    
    // Custom init from decoder to ensure all properties are properly loaded
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        date = try container.decode(Date.self, forKey: .date)
        imageAsData = try container.decodeIfPresent(Data.self, forKey: .imageAsData)
    }
    
    // Default init
    init() {
        id = UUID()
        name = "Ladybug"
        date = Date()
        imageAsData = nil
    }
}
