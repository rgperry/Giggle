//
//  SharedLogic.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI
import SwiftData

struct Colors {
    static let backgroundColor = Color(red: 104/255, green: 86/255, blue: 182/255)
    static let giggleWhite = Color(white: 0.98)
}

struct GridStyle {
    static let grid = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    // Padding between the grid columns
    static let columnPadding: CGFloat = 33
    
    // Padding between rows of folders
    static let folderRowPadding: CGFloat = 0
    
    // Padding between rows of memes
    static let memeRowPadding: CGFloat = 0

    static let searchBarPadding: CGFloat = 28
}

public func shareMeme(meme: Meme, context: ModelContext) {
    let activityVC = UIActivityViewController(activityItems: [meme.imageAsUIImage], applicationActivities: nil)

    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first?.rootViewController {
        rootVC.present(activityVC, animated: true, completion: nil)
        
        meme.dateLastShared = Date()
        
        DataManager.saveContext(
            context: context,
            success_message: "Successfully updated the last shared date",
            fail_message: "Failed to update the last shared date",
            id: meme.id
        )
    }
}

public func copyMeme(meme: Meme, context: ModelContext) {
    let imageToCopy = meme.imageAsUIImage
    UIPasteboard.general.image = imageToCopy
    
    meme.dateLastShared = Date()
    
    DataManager.saveContext(
        context: context,
        success_message: "Successfully updated date shared",
        fail_message: "Failed to update date shared",
        id: meme.id
    )
}

public func favoriteMeme(meme: Meme, context: ModelContext) {
    meme.toggleFavorited()
    
    DataManager.saveContext(
        context: context,
        success_message: "Successfully updated favorited status and date favorited",
        fail_message: "Failed to update favorited status or date favorited",
        id: meme.id
    )
}

public func deleteMeme(meme: Meme, context: ModelContext) {
    context.delete(meme)
    
    let tagsToDelete = meme.tags.filter {
        $0.memes.count == 1 && $0.memes.first?.id == meme.id
    }
    
    tagsToDelete.forEach { tag in
        print("Deleting tag: \(tag.name)")
        context.delete(tag)
    }
    
    DataManager.saveContext(
        context: context,
        success_message: "Successfully deleted meme and tags",
        fail_message: "Failed to delete meme and tags",
        id: meme.id
    )
}
