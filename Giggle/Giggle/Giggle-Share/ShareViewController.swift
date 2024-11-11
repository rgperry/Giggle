//
//  ShareViewController.swift
//  Giggle-Share
//
//  Created by Robert Perry on 10/27/24.
//

//import UIKit
//import Social
//
//class ShareViewController: SLComposeServiceViewController {
//
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//    
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }
//
//}

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = self.extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment in attachments {
                    // Check if the item is an image, GIF, or video
                    if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) ||
                        attachment.hasItemConformingToTypeIdentifier(UTType.gif.identifier) ||
                        attachment.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                        
                        // Load the item
                        attachment.loadItem(forTypeIdentifier: attachment.registeredTypeIdentifiers.first ?? "", options: nil) { [weak self] (data, error) in
                            // Check for errors
                            if let error = error {
                                print("Error loading item: \(error)")
                                return
                            }
                            
                            // Handle the URL for the image, GIF, or video
                            if let url = data as? URL {
                                // Save the media to the app
                                self?.saveMedia(at: url)
                            }
                            // Complete the request
                            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func saveMedia(at url: URL) {
        // Specify a directory in your app's shared container or sandbox
        let fileManager = FileManager.default
        
        // Example: Save to the app's documents directory
        guard let appGroupContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourcompany.yourapp") else {
            print("Could not find app group container")
            return
        }
        
        let destinationURL = appGroupContainer.appendingPathComponent(url.lastPathComponent)
        
        // Move the file to the destination
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL) // Remove if exists
            }
            try fileManager.moveItem(at: url, to: destinationURL) // Move to new location
            print("Saved media to: \(destinationURL)")
        } catch {
            print("Error saving media: \(error)")
        }
    }
}
