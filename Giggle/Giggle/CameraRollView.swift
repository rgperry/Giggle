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

//https://developer.apple.com/documentation/photokit/phpickerviewcontroller
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedMemes: [MemeMedia] //updated xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    @Binding var pickingIsDone: Bool

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
            
            var memesToAppend: [MemeMedia] = [] //updated xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            
            let group = DispatchGroup()  // To track all asynchronous loading tasks
            for result in results {
                if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                    group.enter()
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.gif.identifier) { (url, error) in
                        if let url = url {
                            DispatchQueue.main.async {
                                memesToAppend.append(.gif(url))
                            }
                            group.leave()
                        }
                    }
                }
                else if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            memesToAppend.append(.image(uiImage))
                        }
                        group.leave()
                    }
                }
                else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    group.enter()
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { (url, error) in
                        if let url = url {
                            DispatchQueue.main.async {
                                memesToAppend.append(.video(url))
                            }
                            group.leave()
                        }
                    }
                }
            }
            // Once all images are loaded, update the state
            group.notify(queue: .main) {
                self.parent.selectedMemes.append(contentsOf: memesToAppend)
                self.parent.pickingIsDone = true  // Signal that meme selection is done
            }
        }
    }
}
