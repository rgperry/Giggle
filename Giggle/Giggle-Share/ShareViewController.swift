//
//  ShareViewController.swift
//  Giggle-Share
//
//  Created by Robert Perry on 11/10/24.
//

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
                                print("Error loading item: (error)")
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
            print("Saved media to: (destinationURL)")
        } catch {
            print("Error saving media: (error)")
        }
    }
}
