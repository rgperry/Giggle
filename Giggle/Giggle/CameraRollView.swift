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

//Loading other types of media: https://stackoverflow.com/questions/70943855/phpicker-load-video
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
            let group = DispatchGroup()
            
            picker.dismiss(animated: true)
            results.forEach { result in
                guard let typeIdentifier = result.itemProvider.registeredTypeIdentifiers.first,
                      let utType = UTType(typeIdentifier) else { return }
                if utType.conforms(to: .movie) || utType.conforms(to: .gif) { // process videos or gifs
                    var name = ""
                    if let suggestedName = result.itemProvider.suggestedName {
                        if utType.conforms(to: .movie) {
                            if utType.conforms(to: .mpeg4Movie) {
                                name = suggestedName + UUID().uuidString + ".mp4"
                            } else {
                                name = suggestedName + UUID().uuidString + ".mov"
                            }
                        } else {
                            name = suggestedName + UUID().uuidString + ".gif"
                        }
                    }
                    group.enter()
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] url, error in
                        guard let self, let url else { return }
                        if let error {
                            print(error.localizedDescription)
                        }
                        // copying file
                        let fm = FileManager.default
                        let destination = fm.temporaryDirectory.appendingPathComponent(name)
                        do {
                            try fm.copyItem(at: url, to: destination)
                            if (utType.conforms(to: .movie)) {
                                memesToAppend.append(.video(destination))
                            } else {
                                memesToAppend.append(.gif(destination))
                            }
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                        group.leave()
                    }
                } else if utType.conforms(to: .image) {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            memesToAppend.append(.image(uiImage))
                        }
                        group.leave()
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


