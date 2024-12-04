//
//  ShareViewController.swift
//  Giggle-Share-RT
//  Created by Robert Perry on 10/27/24.
//  Improved by Tamaer Alharastani on 11/10/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import SwiftData

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load.")

        showSaveConfirmation()
    }

    private func showSaveConfirmation() {
        print("Showing save options alert.")
         let alertController = UIAlertController(title: "Save to Giggle?", message: "Where u wanna put this?", preferredStyle: .alert)

         let saveToAllAction = UIAlertAction(title: "All Giggles", style: .default) { [weak self] _ in
             print("Save to All Giggles selected.")
             self?.processSharedItems(saveAsFavorite: false)
         }

         let saveToFavoritesAction = UIAlertAction(title: "All Giggles + Favorites", style: .default) { [weak self] _ in
             print("Save to All Giggles + Favorites selected.")
             self?.processSharedItems(saveAsFavorite: true)
         }

         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
             print("Cancel action selected.")
             self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
         }

         alertController.addAction(saveToAllAction)
         alertController.addAction(saveToFavoritesAction)
         alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            print("Presenting alert controller.")
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func processSharedItems(saveAsFavorite: Bool) {
        print("Processing shared items.")
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            print("Found first extension item.")
            if let attachments = item.attachments {
                print("Found attachments.")
                for attachment in attachments {
                    attachment.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] (data, error) in
                        if let error = error {
                            print("Error loading item with public.image: \(error)")
                            self?.showFailureAlert()
                            return
                        }

                        print("Item loaded successfully.")
                        if let url = data as? URL, let image = UIImage(contentsOfFile: url.path) {
                            print("Loaded image from URL.")
                            self?.saveImageToDataStore(image, isFavorite: saveAsFavorite)
                        } else if let imageData = data as? Data, let image = UIImage(data: imageData) {
                            print("Loaded image from data.")
                            self?.saveImageToDataStore(image, isFavorite: saveAsFavorite)
                        } else {
                            print("Failed to convert data to image.")
                            self?.showFailureAlert()
                        }

                        self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                }
            }
        }
    }

    private func saveImageToDataStore(_ image: UIImage, isFavorite: Bool) {
        print("Attempting to save image to data store.")
        do {
            let modelContainer = try ModelContainer(for: Meme.self, Tag.self)
            print("Model container initialized successfully.")
            let modelContext = ModelContext(modelContainer)

            guard modelContext != nil else {
                print("Failed to initialize ModelContext.")
                showFailureAlert()
                return
            }

            Task {
                if isFavorite {
                    print("Attempting to store image into Giggle Favorites.")
                } else {
                    print("Attempting to store image into All Giggles.")
                }
                
                let importManager = MemeImportManager(modelContainer: modelContainer)

                var memes: [MemeMedia] = []
                memes.append(.image(image))
                
                if isFavorite {
                    do {
                        try await importManager.storeMemes(memes: memes, favorited: true) {
                            logger.info("Successfully stored 1 image to Giggle All + Favorites from Share Extension")
                        }
                    }
                    catch {
                        logger.error("Error storing 1 image to Giggle All + Favorites from Share extension \(error)")
                    }
                }
                
                else {
                    do {
                        try await importManager.storeMemes(memes: memes) {
                            logger.info("Successfully stored 1 image to Giggle All from Share Extension")
                        }
                    }
                    catch {
                        logger.error("Error storing 1 image to Giggle All from Share extension \(error)")
                    }
                }
            }
        } catch {
            print("Error initializing ModelContainer: \(error)")
            showFailureAlert()
        }
    }

    private func showFailureAlert() {
        let alertController = UIAlertController(title: "Failed to Save", message: "The image could not be saved to Giggle.", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
