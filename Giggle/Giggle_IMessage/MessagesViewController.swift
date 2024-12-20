//  MessagesViewController.swift
//  Giggle_IMessage
//
//  Created by Tamaer Alharastani on 10/27/24.
//

import UIKit
//UIKit Source https://reintech.io/blog/developing-imessage-apps-sticker-packs-ios
import Messages
import SwiftUI
import SwiftData
import Combine

//ADDED FUNCTIONS - Tamaer
extension UIImage {
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
    var allMemes: [Meme] = [] // Original, unfiltered memes
    
    private var resetSearchTimer: Timer?
    //private var searchTimer: Timer?
    private var isSearching = false // Debounce mechanism to prevent overlapping searches

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var segmentedControl: UISegmentedControl!
    
    var filteredMemes: [Meme] {
        switch currentTab {
            case .favorites:
                return imagesArray
                    .filter { $0.favorited }
                    .sorted { ($0.dateFavorited ?? .distantPast) > ($1.dateFavorited ?? .distantPast) }
                
            case .recentlyShared:
                return imagesArray
                    .filter { $0.dateLastShared != nil }
                    .sorted { $0.dateLastShared! > $1.dateLastShared! }
                    .prefix(24)
                    .map { $0 }
                
            case .allGiggles:
                return imagesArray.sorted { $0.dateAdded > $1.dateAdded }
        }
    }
    
    enum MemeTab {
        case favorites
        case recentlyShared
        case allGiggles
    }
    
    var currentTab: MemeTab = .allGiggles {
        didSet {
            collectionView.reloadData()
        }
    }

    @objc func tabChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 1:
                currentTab = .favorites
                searchBar.placeholder = "Search Favorite Giggles"
            
            case 2:
                currentTab = .recentlyShared
                searchBar.placeholder = "Search Recently Shared"
            
            default:
                currentTab = .allGiggles
                searchBar.placeholder = "Search All Giggles"
        }
    }

    let dynamicBackgroundColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor.black :
            UIColor.white
    }

    let dynamicSelectedTintColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0) :
            UIColor.systemGray4
    }

    let dynamicTextColor = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor.lightGray :
            UIColor.black
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //logger.log("MessagesViewController loaded")
        collectionView.backgroundColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)
        
        searchBar.delegate = self
        collectionView.dataSource = self
        
        searchBar.placeholder = "Search All Giggles"
        searchBar.backgroundImage = UIImage() // Remove the default background image for a solid color
        searchBar.backgroundColor = .clear // Make the search bar transparent
        searchBar.searchTextField.backgroundColor = UIColor.systemBackground
        view.backgroundColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)
        
        setupSearchToggle()
        
        setupCollectionViewLayout()
        collectionView.delegate = self
        collectionView.prefetchDataSource = self //enable prefetching so app only loads what is seen
        collectionView.reloadData()
        
        segmentedControl = UISegmentedControl(items: ["All Giggles", "Favorites", "Recents"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.backgroundColor = dynamicBackgroundColor // Dynamic background color
        segmentedControl.selectedSegmentTintColor = .clear // Ensure selected tint does not obscure text

        segmentedControl.setTitleTextAttributes([.foregroundColor: dynamicTextColor], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0),
            .font: UIFont.boldSystemFont(ofSize: 16) // Optional: Adjust font style
        ], for: .selected)

        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6)
        ])
        
        setupVibeCheckerButton()
        resetSearchTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(resetIfSearchEmpty), userInfo: nil, repeats: true)
    }

    
    //Switch for Message Analysis
    private func setupSearchToggle() {
        let toggleContainer = UIView()
        toggleContainer.translatesAutoresizingMaskIntoConstraints = false
        toggleContainer.backgroundColor = UIColor.systemBackground
        toggleContainer.layer.cornerRadius = 10   // Rounded corners
        toggleContainer.layer.masksToBounds = true
        
        let searchToggle = UISwitch()
        searchToggle.translatesAutoresizingMaskIntoConstraints = false
        searchToggle.isOn = false // Default state
        
        searchToggle.onTintColor = UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0) // Custom ON state color
        searchToggle.thumbTintColor = UIColor.white // Custom thumb color
        
        searchToggle.addTarget(self, action: #selector(toggleSearchMode(_:)), for: .valueChanged)

        toggleContainer.addSubview(searchToggle)
        
        view.addSubview(toggleContainer)

        NSLayoutConstraint.activate([
            toggleContainer.heightAnchor.constraint(equalToConstant: 36),
            toggleContainer.widthAnchor.constraint(equalToConstant: 60),
            toggleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            toggleContainer.topAnchor.constraint(equalTo: searchBar.topAnchor),
            
            searchToggle.centerXAnchor.constraint(equalTo: toggleContainer.centerXAnchor, constant: -1), // Adjust X-axis offset if needed
            searchToggle.centerYAnchor.constraint(equalTo: toggleContainer.centerYAnchor, constant: 0) // Adjust Y-axis offset for centering
        ])

    }
    //
    private var vibeCheckerButtonContainer: UIView?

    private func setupVibeCheckerButton() {
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.backgroundColor = UIColor.systemBackground
        buttonContainer.layer.cornerRadius = 10   // Rounded corners
        buttonContainer.layer.masksToBounds = true
        buttonContainer.isHidden = true // Hidden by default
        vibeCheckerButtonContainer = buttonContainer // Store reference for toggling visibility

        let vibeCheckerButton = UIButton(type: .system)
        vibeCheckerButton.translatesAutoresizingMaskIntoConstraints = false
        vibeCheckerButton.setTitle("Click to Search Message on Vibes", for: .normal)
        vibeCheckerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16) // Adjusted font size
        vibeCheckerButton.setTitleColor(UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0), for: .normal) // Dynamic text color
        vibeCheckerButton.setTitleColor(UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0), for: .highlighted)
        vibeCheckerButton.backgroundColor = .clear // Transparent background for the button

        vibeCheckerButton.addTarget(self, action: #selector(vibeCheckerClicked), for: .touchUpInside)

        buttonContainer.addSubview(vibeCheckerButton)

        view.addSubview(buttonContainer)

        NSLayoutConstraint.activate([
            buttonContainer.heightAnchor.constraint(equalToConstant: 35),
            buttonContainer.widthAnchor.constraint(equalTo: collectionView.widthAnchor, constant: -12), // Adjust width relative to the collection view
            buttonContainer.centerXAnchor.constraint(equalTo: searchBar.centerXAnchor), // Align horizontally with the search bar
            buttonContainer.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -2), // Move closer to or overlap with the search bar

            vibeCheckerButton.widthAnchor.constraint(equalToConstant: 378), // Set desired button width
            vibeCheckerButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            vibeCheckerButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor)
        ])

    }

    @objc private func vibeCheckerClicked() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter a message to check its vibe.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        Task {
            if let relevantTags = await getSentimentWrapper(message: searchText) {
                //logger.log("Relevant tags: \(relevantTags)")
                if relevantTags.isEmpty {
                    let alert = UIAlertController(title: "No Results", message: "No relevant tags were found for your message.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    await MainActor.run {
                        present(alert, animated: true, completion: nil)
                    }
                    return
                }

                await performSearch(query: relevantTags)
            } else {
                let alert = UIAlertController(title: "Error", message: "Unable to fetch sentiment analysis results. Please try again.", preferredStyle: .alert)
                await MainActor.run {
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    //
    private var isAdvancedSearch = false
    @objc func toggleSearchMode(_ sender: UISwitch) {
        isAdvancedSearch = sender.isOn
        searchBar.placeholder = isAdvancedSearch ? "Paste Message Here!" : "Search All Giggles"

        if isAdvancedSearch {
            segmentedControl.isHidden = true
            vibeCheckerButtonContainer?.isHidden = false
        } else {
            segmentedControl.isHidden = false
            vibeCheckerButtonContainer?.isHidden = true
        }

        Task { @MainActor in
            currentTab = .allGiggles
            segmentedControl.selectedSegmentIndex = 0
            //logger.log("Switched to All Giggles due to toggle change.")
        }
        
        collectionView.reloadData()
    }

    //reset to all giggles if search bar is empty. auto reload kinda
    @objc private func resetIfSearchEmpty() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.searchText.isEmpty && self.imagesArray != self.allMemes {
                //logger.log("Search is empty. Resetting to all memes.")
                self.imagesArray = self.allMemes
                self.collectionView.reloadData()
            }
        }
    }

    //LOAD MEMES FROM DATA
    private var hasLoadedMemes = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setupLoadingIndicator()
        
        if !hasLoadedMemes {
            hasLoadedMemes = true
            Task {
                //showLoadingIndicator()
                await DataManager.loadMemes { [weak self] loadedMemes in
                    self?.allMemes = loadedMemes // Store all memes
                    self?.imagesArray = loadedMemes // Initialize with all memes
                    self?.currentTab = .allGiggles
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
        let collectionViewWidth = collectionView.bounds.width

        searchBar.frame = CGRect(
            x: collectionView.frame.origin.x - 2,
            y: searchBar.frame.origin.y - 4,
            width: collectionViewWidth - 60,
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
        
        guard !isAdvancedSearch else {
            //logger.log("Advanced search mode is active. Ignoring search bar text change.")
            return
        }
        
        Task {
            if searchText.isEmpty {
                await performSearch(query: "") // Handle the case for empty search text
            } else {
                await performSearch(query: searchText) // Call the async search function
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
        
        //logger.log("Search button clicked. Keyboard dismissed.")
    }

    private func performSearch(query: String) async {
        //logger.log("Running search for query: \(query)")
        
        // let sharedDefaults = UserDefaults(suiteName: "group.com.Giggle.Giggle")
        // let numSearchResults = sharedDefaults?.integer(forKey: "numSearchResultsiMessage") ?? 10
        
        // logger.log("\(numSearchResults)")
        
        self.imagesArray = self.allMemes

        let results: [Meme]

        if query.isEmpty {
            results = self.allMemes // Reset to full list of memes
            //logger.log("Search query is empty. Returning all memes.")
        } else if isAdvancedSearch {

            //logger.log("Advanced search mode active. Returning all memes (no filtering applied).")
            results = Array(
                imagesArray.filter { memeSearchPredicate(for: query).evaluate(with: $0) }
                    .sorted { $0.dateAdded > $1.dateAdded }
                    // .prefix(numSearchResults)
                )
        } else {
            results = Array(
                imagesArray.filter { memeSearchPredicate(for: query).evaluate(with: $0) }
                    .sorted { $0.dateAdded > $1.dateAdded }
                    // .prefix(numSearchResults)
                )
            //logger.log("Search results count for query '\(query)': \(results.count)")
        }

        // Update UI on the main thread
        await MainActor.run {
            self.imagesArray = results
            self.collectionView.reloadData()
        }
    }


    //clear imagesArray to free up memory when needed
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //logger.log("Received memory warning, clearing imagesArray.")
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
                top: itemSpacing + 38,     // Space above the section
                leading: itemSpacing, // Space on the left side
                bottom: itemSpacing,  // Space below the section
                trailing: itemSpacing // Space on the rwight side
            )

            return section
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = filteredMemes.count
        //logger.log("Number of items in section: \(count)")
        
        return count
    }

    //method for loading only what is on screen
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let meme = filteredMemes[indexPath.item]

            // ROB CHANGES
            Task {
                _ = await meme.memeAsUIImage.thumbnail(maxWidth: 20) // Prefetch thumbnails for images about to appear
            }
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
        
        imageCell.imageView.image = UIImage(systemName: "photo") //placeholder

        // Load high-quality image asynchronously and ensure it doesn’t get overridden
        // ROB CHANGES
        Task {
            let highQualityImage = await meme.memeAsUIImage.thumbnail(maxWidth: 200)

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

        // ROB CHANGES
        Task {
            cell.imageView.image = await meme.memeAsUIImage.thumbnail(maxWidth: 50)
        }
        //logger.log("Setting image for meme at index \(indexPath.item): \(meme.imageAsUIImage)")
        return cell
    }

    //for image attaching to imessage on tap
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ensure activeConversation is available

        // ROB CHANGES  ------------------------------------------------
        Task {
            guard let conversation = activeConversation else {
                logger.log("No active conversation found.")
                return
            }
            
            let meme = filteredMemes[indexPath.item]
            
            let originalImage = await meme.memeAsUIImage.fixedOrientation()//preserve orientation
            
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
            meme.dateLastShared = Date()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
            //ensure the extension view minimizes immediately on tap
        DispatchQueue.main.async {
            self.requestPresentationStyle(.compact)
        }
        // ------------------------------------------------------------------

//        guard let conversation = activeConversation else {
//            //logger.log("No active conversation found.")
//            return
//        }
//
//        let meme = filteredMemes[indexPath.item]
//        let originalImage = meme.imageAsUIImage.fixedOrientation()//preserve orientation
//
//        // Configure the message layout with the meme's image
//        let layout = MSMessageTemplateLayout()
//        layout.image = originalImage
//        // layout.caption = "Sent from Giggle" // Optional caption
//
//        // Create and configure the message
//        let message = MSMessage()
//        message.layout = layout
//
//        searchBar.resignFirstResponder()
//
//        // Insert the message into the conversation
//        conversation.insert(message) { error in
//            if let error = error {
//                //logger.log("Failed to insert message: \(error.localizedDescription)")
//            }
//            //UPDATE SHARE DATE
//            // Update the dateLastShared for the sent meme
//            meme.dateLastShared = Date()
//
//            // FINISH: maybe put a context.save() here eventually?
//            //DataManager.updateMeme(meme)
//
//            // Reload the collection view to reflect the updated order
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//            //
//        }

        //ensure the extension view minimizes immediately on tap
//        DispatchQueue.main.async {
//            self.requestPresentationStyle(.compact)
//        }
    }
    //END OF ADDED FUNCTIONS - Tamaer

    // MARK: - Conversation Handling
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        super.willBecomeActive(with: conversation)
        //logger.log("MessagesViewController became active")
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
