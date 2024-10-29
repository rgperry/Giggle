//
//  MessagesViewController.swift
//  Giggle_IMessage
//
//  Created by Tamaer Alharastani on 10/27/24.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    //dummy images
    var imagesArray: [UIImage] = []
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count  // Return the count of your data array,
        //Replace imagesArray.count with the actual array you’re using to hold the images.

    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("MessagesViewController loaded")
        collectionView.backgroundColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)

        searchBar.delegate = self
        collectionView.dataSource = self
        
        setupCollectionViewLayout()
        collectionView.delegate = self
        
        //dummy images
        let configuration = UIImage.SymbolConfiguration(pointSize: 100, weight: .regular)
        if let symbolImage = UIImage(systemName: "person.circle.fill", withConfiguration: configuration)?
               .withTintColor(.black, renderingMode: .alwaysOriginal) {
            imagesArray = Array(repeating: symbolImage, count: 10)
        }
        //end dummy images
        collectionView.reloadData() // Ensure the collection view reloads with the data
    }
    //ADDED FUNCTIONS - Tamaer
    func setupCollectionViewLayout() {
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // Define the size of each item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            // Define the size of each group to hold 3 items in a row
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(130))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)

            // Define the section with the group
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10

            return section
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        // Configure the cell with data, such as setting an image
        cell.imageView.image = imagesArray[indexPath.item]  // Assuming imagesArray contains the images you want to display
        //Replace imagesArray.count with the actual array you’re using to hold the images.

        return cell
    }
    //for image attaching to imessage on tap
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the selected image
        let selectedImage = imagesArray[indexPath.item]
        
        // Create an MSMessageTemplateLayout and set the image
        let layout = MSMessageTemplateLayout()
        layout.image = selectedImage
        //layout.caption = "Sent from Giggle" // Optional caption

        // Create an MSMessage with the layout
        let message = MSMessage()
        message.layout = layout

        // Insert the message into the conversation
        activeConversation?.insert(message, completionHandler: { error in
            if let error = error {
                print("Failed to insert message: \(error.localizedDescription)")
            }
        })
        //pull menu down when image is seleted
        requestPresentationStyle(.compact)
        
    }

    //
    //END OF ADDED FUNCTIONS - Tamaer
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        super.willBecomeActive(with: conversation)
        print("MessagesViewController became active")
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
