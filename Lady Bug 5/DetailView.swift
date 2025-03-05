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

            TextField("Name", text: $ladybug.name)
                .font(.title)
                .multilineTextAlignment(.center)

            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(false)
        .onChange(of: ladybug) { _ in
            saveLadybugs()
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
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, h:mma"
        return formatter.string(from: ladybug.date)
    }
    
    private func saveImage() {
        saveLadybugs()
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
                    }
                }
            } else {
                // If no existing data, just save this one
                UserDefaults.standard.set(encoded, forKey: "ladybugs")
            }
        }
    }
}
