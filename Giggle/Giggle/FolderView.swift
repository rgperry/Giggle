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
    @Query(filter: #Predicate<Meme> { meme in
            meme.tags.contains { $0.name == "header" }
        }) private var memes: [Meme]
    @Environment(\.modelContext) private var context
    
    // Moved filtering logic here
    var filteredMemes: [Meme] {
        if searchText.isEmpty {
            return memes
        } else {
            return DataManager.findSimilarEntries(query: searchText, context: context, limit: 50, tagName: header)
        }
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

#Preview {
    FolderView(header: "Favorites")
}
