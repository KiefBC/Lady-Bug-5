import SwiftUI
import Photos
import AVFoundation

struct DetailView: View {
    @Binding var ladybug: Ladybug
    @State private var isImagePickerPresented = false
    @State private var pickerVisible = false
    @State private var showCameraAlert = false
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
                        forceSaveToUserDefaults() // Force immediate save when image is removed
                    }
                    .foregroundColor(.red)
                }

                TextField("Name", text: $ladybug.name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        // Explicitly save when Enter/Return is pressed
                        saveChangesToUserDefaults()
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
                                self.forceSaveToUserDefaults() // Force immediate save when image is added
                            }
                        }
                    }
                )
            }
        }  // End of ZStack
        .padding()
        .navigationBarBackButtonHidden(false)
        .onChange(of: ladybug) { oldValue, newValue in
            saveChangesToUserDefaults()
        }
        .toolbar {
            ToolbarItemGroup {
                Button(
                    action: {
                        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                            if response &&
                                UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                                self.showCameraAlert = false
                                self.imageSource = UIImagePickerController.SourceType.camera
                                self.pickerVisible.toggle()
                            } else {
                                self.showCameraAlert = true
                            }
                        }
                    },
                    label: {
                        Image(systemName: "camera")
                    }
                )
            }
        }
        .alert(isPresented: $showCameraAlert) {
            Alert(title: Text("Error"), message: Text("Camera not available"), dismissButton: .default(Text("OK")))
        }
        .onDisappear {
            // Final save attempt when leaving detail view
            forceSaveToUserDefaults()
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, h:mma"
        return formatter.string(from: ladybug.date)
    }
    
    private func saveImage() {
        print("Saving image for ladybug: \(ladybug.id)")
        forceSaveToUserDefaults() // Force immediate save after picking image
    }
    
    // Standard save method - used for most changes
    private func saveChangesToUserDefaults() {
        print("Saving changes to UserDefaults for ladybug: \(ladybug.id)")
        saveLadybugs()
    }
    
    // Force save method - used specifically for image operations
    private func forceSaveToUserDefaults() {
        print("FORCE SAVING to UserDefaults for ladybug: \(ladybug.id), has image: \(ladybug.image != nil)")
        saveLadybugs()
        
        // Get all ladybugs
        if let data = UserDefaults.standard.data(forKey: "ladybugs"),
           let allLadybugs = try? JSONDecoder().decode([Ladybug].self, from: data) {
            
            // Find and update our specific ladybug
            if let index = allLadybugs.firstIndex(where: { $0.id == ladybug.id }) {
                var updatedLadybugs = allLadybugs
                updatedLadybugs[index] = ladybug
                
                // Force save the entire array back to UserDefaults
                if let encodedUpdated = try? JSONEncoder().encode(updatedLadybugs) {
                    UserDefaults.standard.set(encodedUpdated, forKey: "ladybugs")
                    UserDefaults.standard.synchronize() // Force immediate write to disk
                    
                    print("Successfully force-saved all \(updatedLadybugs.count) ladybugs to UserDefaults")
                }
            }
        }
    }
    
    private func saveLadybugs() {
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
        }
    }
}
