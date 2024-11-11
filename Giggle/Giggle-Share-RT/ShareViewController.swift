//
//  ShareViewController.swift
//  Giggle-Share-RT
//  Created by Robert Perry on 10/27/24.
//  Tamaer Alharastani on 11/10/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import SwiftData
import OSLog

let logger = Logger()

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View did load.")
        
        showSaveConfirmation()
    }
    
    private func showSaveConfirmation() {
        print("Showing save confirmation alert.")
        let alertController = UIAlertController(title: "Save to Giggle?", message: "Do you want to save this to all Giggles?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            print("Yes action selected.")
            self?.processSharedItems()
        }
        
        let noAction = UIAlertAction(title: "No", style: .default) { [weak self] _ in
            print("No action selected.")
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        DispatchQueue.main.async {
            print("Presenting alert controller.")
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func processSharedItems() {
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
                            self?.saveImageToDataStore(image)
                        } else if let imageData = data as? Data, let image = UIImage(data: imageData) {
                            print("Loaded image from data.")
                            self?.saveImageToDataStore(image)
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
    
    private func saveImageToDataStore(_ image: UIImage) {
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
                print("Attempting to store image into all giggles.")
                await DataManager.storeMemes(context: modelContext, images: [image]) {
                    print("Successfully stored 1 image to the SwiftData database.")
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
