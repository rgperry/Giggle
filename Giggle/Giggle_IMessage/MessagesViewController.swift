//  MessagesViewController.swift
//  Giggle_IMessage
//
//  Created by Tamaer Alharastani on 10/27/24.
//

import UIKit
import Messages
import OSLog
import SwiftUI
import SwiftData
import Combine

//ADDED FUNCTIONS - Tamaer
extension UIImage {
    // Generate lower quality thumbnails to save memory
    func thumbnail(maxWidth: CGFloat = 100) -> UIImage {
        let aspectRatio = size.height / size.width
        let targetSize = CGSize(width: maxWidth, height: maxWidth * aspectRatio)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }  // No need to adjust if already correct

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

class MessagesViewController: MSMessagesAppViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    @Environment(\.modelContext) private var context

    var searchText: String = ""  // Store search text

    var imagesArray: [Meme] = []
    var filteredMemes: [Meme] = []  // Store filtered memes
    private var searchDebounce: AnyCancellable?  // Combine publisher for debouncing

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logger.log("MessagesViewController loaded")
        collectionView.backgroundColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)

        searchBar.delegate = self
        collectionView.dataSource = self

        searchBar.backgroundImage = UIImage() // Remove the default background image for a solid color
        searchBar.backgroundColor = .clear // Make the search bar transparent
        searchBar.searchTextField.backgroundColor = UIColor.systemBackground
        view.backgroundColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)

        setupCollectionViewLayout()
        collectionView.delegate = self
        collectionView.prefetchDataSource = self //enable prefetching so app only loads what is seen
        collectionView.reloadData()
    }

    //LOAD MEMES FROM DATA
    private var hasLoadedMemes = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setupLoadingIndicator()
        // Load memes only once when the view appears for the first time
        if !hasLoadedMemes {
            hasLoadedMemes = true
            Task {
                //showLoadingIndicator()
                await DataManager.loadMemes { [weak self] loadedMemes in
                    self?.imagesArray = loadedMemes
                    self?.filteredMemes = loadedMemes  // Initialize with all memes
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        adjustSearchBarWidth()
        adjustCollectionViewHeight()
    }

    private func adjustSearchBarWidth() {
        // Get the width of the collection view
        let collectionViewWidth = collectionView.bounds.width

        // Set the search bar width to match the collection view's width
        searchBar.frame = CGRect(
            x: collectionView.frame.origin.x - 2,
            y: searchBar.frame.origin.y - 4,
            width: collectionViewWidth + 4,
            height: searchBar.frame.height
        )
    }

    private func adjustCollectionViewHeight() {
        collectionView.frame = CGRect(
            x: collectionView.frame.origin.x,
            y: collectionView.frame.origin.y - 14, // Move up
            width: collectionView.frame.width,
            height: collectionView.frame.height
        )
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText

        DispatchQueue.global(qos: .userInitiated).async {
            self.performSearch(query: searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
        logger.log("Search button clicked. Keyboard dismissed.")
    }

    private func performSearch(query: String) {
        logger.log("Running search for query: \(query)")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let results: [Meme]
            if query.isEmpty {
                results = self.imagesArray
                logger.log("Memes Filtered, returning All Giggles")
            } else {
                results = DataManager.findSimilarEntries(
                    query: query,
                    memes: self.imagesArray,
                    limit: 5,
                    tagName: nil
                )
                logger.log("Memes Filtered, returning subset")
            }

            // Log the size of the filtered results
            logger.log("Search results count for query '\(query)': \(results.count)")

            // Update the filtered array and UI on the main thread
            DispatchQueue.main.async {
                self.filteredMemes = results
                logger.log("Filtered memes updated: \(self.filteredMemes.count) items.")
                self.collectionView.reloadData()
            }
        }
    }

    //clear imagesArray to free up memory when needed
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        logger.log("Received memory warning, clearing imagesArray.")
        //imagesArray.removeAll()
        collectionView.reloadData()
    }

    func setupCollectionViewLayout() {
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSpacing: CGFloat = 3 //space between items

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(130))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = itemSpacing //row spacing equal to column spacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: itemSpacing,     // Space above the section
                leading: itemSpacing, // Space on the left side
                bottom: itemSpacing,  // Space below the section
                trailing: itemSpacing // Space on the rwight side
            )

            return section
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = filteredMemes.count
        logger.log("Number of items in section: \(count)")
        return count
    }

    //method for loading only what is on screen
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let meme = filteredMemes[indexPath.item]
            _ = meme.imageAsUIImage.thumbnail(maxWidth: 20) // Prefetch thumbnails for images about to appear
        }
    }

    //release images when they are not in view
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ImageCell, indexPath.item < filteredMemes.count else { return }
        imageCell.imageView.image = nil
    }

    //private var imageCache = NSCache<NSString, UIImage>()
    //bring them back to good quality when they are in view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ImageCell, indexPath.item < filteredMemes.count else { return }
        let meme = filteredMemes[indexPath.item]

        // Load high-quality image asynchronously and ensure it doesn’t get overridden
        DispatchQueue.global(qos: .utility).async {
            let highQualityImage = meme.imageAsUIImage.thumbnail(maxWidth: 200)

            // Set high-quality image on main thread with a fade-in effect
            DispatchQueue.main.async {
                if collectionView.indexPath(for: cell) == indexPath {
                    UIView.transition(with: imageCell.imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        imageCell.imageView.image = highQualityImage
                    }, completion: nil)
                }
            }
        }
    }

    //thumbnails
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let meme = filteredMemes[indexPath.item]
        cell.imageView.image = meme.imageAsUIImage.thumbnail(maxWidth: 50)
        //logger.log("Setting image for meme at index \(indexPath.item): \(meme.imageAsUIImage)")
        return cell
    }

    //for image attaching to imessage on tap
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ensure activeConversation is available
        guard let conversation = activeConversation else {
            logger.log("No active conversation found.")
            return
        }

        let meme = filteredMemes[indexPath.item]

        let originalImage = meme.imageAsUIImage.fixedOrientation()//preserve orientation

        // Configure the message layout with the meme's image
        let layout = MSMessageTemplateLayout()
        layout.image = originalImage
        // layout.caption = "Sent from Giggle" // Optional caption

        // Create and configure the message
        let message = MSMessage()
        message.layout = layout

        searchBar.resignFirstResponder()

        // Insert the message into the conversation
        conversation.insert(message) { error in
            if let error = error {
                logger.log("Failed to insert message: \(error.localizedDescription)")
            }
        }

        //ensure the extension view minimizes immediately on tap
        DispatchQueue.main.async {
            self.requestPresentationStyle(.compact)
        }
    }
    //END OF ADDED FUNCTIONS - Tamaer

    // MARK: - Conversation Handling
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        super.willBecomeActive(with: conversation)
        logger.log("MessagesViewController became active")
        collectionView.reloadData()
        // Use this method to configure the extension and restore previously stored state.
    }

    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.

        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.

        // Use this method to trigger UI updates in response to the message.
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.

        // Use this to clean up state related to the deleted message.
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.

        // Use this method to prepare for the change in presentation style.
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.

        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
}
