//
//  CameraRollView.swift
//  Giggle
//
//  Created by Robert Perry on 10/27/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedImages: [UIImage]
    @Binding var pickingIsDone: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        // Only show images
        config.filter = .images
        // Allow multiple selections
        config.selectionLimit = 0

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        // Called when the user finishes selecting images
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)

                var imagesToAppend: [UIImage] = []
                
                // Iterate over the selected results and check if we can load the UIImage
                let group = DispatchGroup()  // To track all asynchronous loading tasks
                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        group.enter()
                        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                            if let uiImage = image as? UIImage {
                                imagesToAppend.append(uiImage)
                            }
                            group.leave()
                        }
                    }
                }

                // Once all images are loaded, update the state
                group.notify(queue: .main) {
                    self.parent.selectedImages.append(contentsOf: imagesToAppend)
                    self.parent.pickingIsDone = true  // Signal that image selection is done
                }
            }
    }
}
