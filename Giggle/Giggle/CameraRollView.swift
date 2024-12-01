//
//  CameraRollView.swift
//  Giggle
//
//  Created by Robert Perry on 10/27/24.
//

import Foundation
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedImages: [UIImage]
    @Binding var selectedVideos: [URL]
    @Binding var selectedGIFs: [URL]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        
        config.filter = .any(of: [.images, .videos])
        
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
            
            // Iterate over the selected results and check if we can load the UIImage
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        // Update the selectedImages array
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(uiImage)
                            }
                        }
                    }
                }
                else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { (url, error) in
                        if let url = url {
                            DispatchQueue.main.async {
                                self.parent.selectedVideos.append(url)
                            }
                        }
                    }
                }
                else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.gif.identifier) { (url, error) in
                        if let url = url {
                            DispatchQueue.main.async {
                                self.parent.selectedGIFs.append(url)
                            }
                        }
                    }
                }
            }
        }
    }
}
