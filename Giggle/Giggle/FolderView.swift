//
//  FolderView.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI
import SwiftData

struct FolderView: View {
    var header: String
    @State private var searchText = ""
    @Query private var memes: [Meme]  // Fetches all memes initially
    @Environment(\.modelContext) private var context
    @Query private var settings: [AppSettings]
    
    // Moved filtering logic here
    var filteredMemes: [Meme] {
        if (header == "All Giggles") {
            return memes
        }
        let tagFilteredMemes = memes.filter { meme in
            meme.tags.contains { $0.name == header }
        }
        if let settings = settings.first {
            return searchText.isEmpty ? tagFilteredMemes : DataManager.findSimilarEntries(query: searchText, context: context, limit: settings.num_results, tagName: header)
        }
        return tagFilteredMemes
    }
    
    var body: some View {
        VStack {
            PageHeader(text: header)
            SearchBar(
                text: "Search for \(header) memes",
                searchText: $searchText
            )
        
            ScrollView {
                LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.memeRowPadding) {
                    // Display filtered results when searching
                    ForEach(filteredMemes) { meme in
                        GiggleItem(meme: meme)
                    }
                }
                .padding(.horizontal, GridStyle.columnPadding)
                .padding(.top, GridStyle.searchBarPadding)
            }
            
            BottomNavBar()
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
    }
}

//#Preview {
//    FolderView(header: "Favorites")
//}
