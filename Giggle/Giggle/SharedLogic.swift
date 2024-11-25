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
