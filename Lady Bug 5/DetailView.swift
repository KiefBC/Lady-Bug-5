import SwiftUI
import Photos
import AVFoundation

struct DetailView: View {
    @Binding var ladybug: Ladybug
    @State private var isImagePickerPresented = false
    @State private var pickerVisible = false
    @State private var showCameraAlert = false
    @State private var showPhotoLibraryAlert = false
    @State private var imageSource = UIImagePickerController.SourceType.camera
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VStack {
                if let image = ladybug.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.black)
                } else {
                    Image(systemName: "ladybug.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.black)
                }

                Button("Select Image") {
                    isImagePickerPresented = true
                }
                .sheet(isPresented: $isImagePickerPresented, onDismiss: saveImage) {
                    ImagePicker(image: $ladybug.image)
                }
                
                // Add Remove Image button
                if ladybug.image != nil {
                    Button("Remove Image") {
                        ladybug.image = nil
                        saveLadybugs()
                    }
                    .foregroundColor(.red)
                }

                TextField("Name", text: $ladybug.name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        // Explicitly save when Enter/Return is pressed
                        saveLadybugs()
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
            
            if pickerVisible {
                ImageView(
                    pickerVisible: $pickerVisible,
                    sourceType: $imageSource,
                    action: { (value) in
                        if let image = value {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                                self.ladybug.image = image
                                self.saveLadybugs() // Add this line to ensure saving after camera capture
                            }
                        }
                    }
                )
            }
        }  // End of ZStack
        .padding()
        .navigationBarBackButtonHidden(false)
        .onChange(of: ladybug) { oldValue, newValue in
            saveLadybugs()
        }
        .toolbar {
            ToolbarItemGroup {
                // Photo Library Button
                Button(
                    action: {
                        PHPhotoLibrary.requestAuthorization { status in
                            DispatchQueue.main.async {
                                if status == .authorized {
                                    self.showPhotoLibraryAlert = false
                                    self.imageSource = UIImagePickerController.SourceType.photoLibrary
                                    self.pickerVisible = true
                                } else {
                                    self.showPhotoLibraryAlert = true
                                }
                            }
                        }
                    },
                    label: {
                        Image(systemName: "book")
                    }
                )
                
                // Camera Button
                Button(
                    action: {
                        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                            DispatchQueue.main.async {
                                if response &&
                                    UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                                    self.showCameraAlert = false
                                    self.imageSource = UIImagePickerController.SourceType.camera
                                    self.pickerVisible = true
                                } else {
                                    self.showCameraAlert = true
                                }
                            }
                        }
                    },
                    label: {
                        Image(systemName: "camera")
                    }
                )
            }
        }
        .alert("Camera Error", isPresented: $showCameraAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Camera not available")
        }
        .alert("Photo Library Error", isPresented: $showPhotoLibraryAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("No access to photo library")
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, h:mma"
        return formatter.string(from: ladybug.date)
    }
    
    private func saveImage() {
        print("Saving image for ladybug: \(ladybug.id)")
        saveLadybugs()
    }
    
    private func saveLadybugs() {
        print("Attempting to save ladybug: \(ladybug.id), has image: \(ladybug.image != nil)")
        
        // Debug output to check image data
        if let imageData = ladybug.imageAsData {
            print("Image data size: \(imageData.count) bytes")
        } else {
            print("No image data present")
        }

        if let encoded = try? JSONEncoder().encode([ladybug]) {
            let existingData = UserDefaults.standard.data(forKey: "ladybugs")
            if let existingData = existingData,
               let existingLadybugs = try? JSONDecoder().decode([Ladybug].self, from: existingData) {
                // Find and update the specific ladybug in the existing array
                var updatedLadybugs = existingLadybugs
                if let index = updatedLadybugs.firstIndex(where: { $0.id == ladybug.id }) {
                    updatedLadybugs[index] = ladybug
                    if let encodedUpdated = try? JSONEncoder().encode(updatedLadybugs) {
                        UserDefaults.standard.set(encodedUpdated, forKey: "ladybugs")
                        UserDefaults.standard.synchronize() // Force immediate write to disk
                    }
                } else {
                    // If the ladybug isn't found, add it to the array
                    updatedLadybugs.append(ladybug)
                    if let encodedUpdated = try? JSONEncoder().encode(updatedLadybugs) {
                        UserDefaults.standard.set(encodedUpdated, forKey: "ladybugs")
                        UserDefaults.standard.synchronize() // Force immediate write to disk
                    }
                }
            } else {
                // If no existing data, just save this one
                UserDefaults.standard.set(encoded, forKey: "ladybugs")
                UserDefaults.standard.synchronize() // Force immediate write to disk
            }
            
            // Verify the save operation
            if let saved = UserDefaults.standard.data(forKey: "ladybugs") {
                print("Successfully saved \(saved.count) bytes to UserDefaults")
                
                // Double-check that our ladybug is in the saved data
                if let verifiedLadybugs = try? JSONDecoder().decode([Ladybug].self, from: saved) {
                    let found = verifiedLadybugs.contains(where: { $0.id == ladybug.id })
                    print("Verification: ladybug \(ladybug.id) found in saved data: \(found)")
                    
                    // Check if image data was properly saved
                    if let savedLadybug = verifiedLadybugs.first(where: { $0.id == ladybug.id }) {
                        print("Verification: ladybug has image data: \(savedLadybug.imageAsData != nil)")
                        if let imageData = savedLadybug.imageAsData {
                            print("Verification: image data size: \(imageData.count) bytes")
                        }
                    }
                }
            } else {
                print("Failed to retrieve saved data from UserDefaults")
            }
        }
    }
}
