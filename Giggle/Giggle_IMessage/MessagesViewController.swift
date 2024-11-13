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

let logger = Logger(subsystem: "com.Giggle.Giggle", category: "MessagesViewController")
//ADDED FUNCTIONS - Tamaer
extension UIImage {
    //generate lower quality thumbnails to save memory
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
    //@State private var searchText = ""
    //@Query private var memes: [Meme] = []
    var searchText: String = ""  // Store search text
    //var meme: [Meme] = []  // Load memes here as needed
//    private var context: ModelContext?  // Define context as optional to set it later
//    func setContext(_ context: ModelContext) {
//        self.context = context
//        logger.log("Context set successfully.")
//    }


    //@Query(sort: \Tag.name) private var allTags: [Tag]

    var imagesArray: [Meme] = []

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logger.log("MessagesViewController loaded")
        collectionView.backgroundColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)

        searchBar.delegate = self
        collectionView.dataSource = self

        //searchBar.barTintColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)
        //searchBar.barTintColor = UIColor.purple
        searchBar.backgroundImage = UIImage() // Remove the default background image for a solid color
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
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        collectionView.reloadData()  //reload to reflect the filtered memes
    }

    //returns the desired meme array
    //var modelContext: ModelContext
    var filteredMemes: [Meme] {
        //setContext(modelContext)
        logger.log("Filtering Memes")
        //guard let context = self.context
//        else {
//            logger.log("No context, returning All Giggles")
//            return imagesArray
//        }
        if searchText.isEmpty {
            logger.log("Memes Filtered, returning All Giggles")
            return imagesArray
        } else {
            logger.log("Memes Filtered, returning subset")
            //return []//temp
            return DataManager.findSimilarEntries(query: searchText, context: context, limit: 10, tagName: nil)
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
    //

    //thumnails
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let meme = filteredMemes[indexPath.item]
        cell.imageView.image = meme.imageAsUIImage.thumbnail(maxWidth: 50)
        logger.log("Setting image for meme at index \(indexPath.item): \(meme.imageAsUIImage)")
        return cell
    }

    // Attaches image to message box on tap
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

        // Insert the message into the conversation
        conversation.insert(message) { error in
            if let error = error {
                logger.log("Failed to insert message: \(error.localizedDescription)")
            }
        }

        // Minimize the extension view
        requestPresentationStyle(.compact)
    }


    //
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

//struct MessagesViewControllerWrapper: UIViewControllerRepresentable {
//    var modelContext: ModelContext  // Accept modelContext as an initializer parameter
//
//    func makeUIViewController(context: Context) -> MessagesViewController {
//        let messagesVC = MessagesViewController()
//        messagesVC.setContext(modelContext)  // Pass modelContext to MessagesViewController
//        return messagesVC
//    }
//
//    func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
//        // Implement if needed to respond to SwiftUI state changes
//    }
//}
