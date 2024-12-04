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

public func shareMeme(meme: Meme, context: ModelContext) async {
    let activityVC = await UIActivityViewController(activityItems: [meme.memeAsUIImage], applicationActivities: nil)

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

public func copyMeme(meme: Meme, context: ModelContext) async {
    let imageToCopy = await meme.memeAsUIImage
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
    
    // This could probably be removed to deleteTag
    let tagsToDelete = meme.tags.filter {
        $0.memes.count == 1 // && $0.memes.first?.id == meme. // I don't think the ID check is necessary
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

public func deleteTagIfUnused(tagName: String, context: ModelContext) {
    let fetchDescriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == tagName })

    // Query for the tag with the matching name
    if let tag = try? context.fetch(fetchDescriptor).first {
        // Check if no more memes use this tag
        if tag.memes.count == 0 {
            print("Deleting tag: \(tag.name)")
            context.delete(tag)
        }
    } else {
        print("Tag with name \(tagName) not found")
    }
}

    // Remove tag overall fi
    // if let tag = meme.tags.first(where: { $0.name == tagName }) {
    
    // Check if tag is no longer connected to any more memes
//    let tag = Tags.
//
//    // Check if this was the last meme using this tag
//    if tag.memes.count == 1 {
//        print("Deleting tag: \(tag.name)")
//        context.delete(tag)
//    }
// }
