import SwiftUI

struct ImageView: UIViewControllerRepresentable {
    
    class ImageViewController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        /// The image.
        var image: UIImage?

        /// Determines whether or not the picker should be visible.
        @Binding var pickerVisible: Bool
        
        /// Creates an ImageViewController
        /// - Parameter pickerVisible: Whether or not the picker should be visible.
        init(pickerVisible: Binding<Bool>) {
            _pickerVisible = pickerVisible
        }
        
        /// Sets `pickerVisible` to false and the `image` to the `editedImage`.
        /// Called when the user selected an image.
        /// This function is called internally from a Swift library; it is not meant to be called from the outside.
        /// - Parameters:
        ///   - picker: A reference to the `UIImagePickerController`.
        ///   - info: A dictionary containing data such as the original image and the edited image.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            pickerVisible = false
            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        
        /// Sets `pickerVisible` to false.
        /// Called when the user cancelled image selection.
        /// This function is called internally from a Swift library; it is not meant to be called from the outside.
        /// - Parameter picker: A reference to the `UIImagePickerController`.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            pickerVisible = false
        }
    }
    
    /// Determines whether or not the picker should be visible.
    @Binding var pickerVisible: Bool
    
    /// Determines the image source type (e.g., `UIImagePickerController.SourceType.camera`, `UIImagePickerController.SourceType.photoLibrary`).
    @Binding var sourceType: UIImagePickerController.SourceType

    /// Determines the action to be taken when an image is selected.
    let action: (UIImage?) -> Void

    /// Called as part of creating the curstom view controller described in `makeUIViewController`.
    /// It provides the `ImageViewController` class as the custom view controller to use.
    /// This function is called internally from a Swift library; it is not meant to be called from the outside.
    func makeCoordinator() -> ImageViewController {
        return ImageViewController(pickerVisible: $pickerVisible)
    }
    
    /// Creates a view controller that permits image editing and conveys image selection events in a SwiftUI-compatible format to the delegate provided by the context parameter.
    /// The source used for the image is taken from `sourceType`.
    /// This function is called internally from a Swift library; it is not meant to be called from the outside.
    /// - Parameter context: Environment values used to implement the view controller.
    /// - Returns: An instantiated view controller.
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    /// Conveys image selection events by calling `action`.
    /// This function is called internally from a Swift library; it is not meant to be called from the outside.
    /// - Parameters:
    ///   - uiViewController: A reference to the custom view controller created by `makeUIViewController`.
    ///   - context: Environment values used to implement the view controller.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImageView>) {
        action(context.coordinator.image)
    }
}
