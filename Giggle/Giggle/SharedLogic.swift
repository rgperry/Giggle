//
//  SharedLogic.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI

struct Colors {
    static let backgroundColor = Color(red: 104/255, green: 86/255, blue: 182/255)
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
