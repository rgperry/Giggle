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
    @AppStorage("numSearchResults") private var numSearchResults: Double = 10
    
    var filteredMemes: [Meme] {
        switch header {
            case "Favorites":
                let allMemes = getAllMemesWithSearch()
                
                // Technically don't need .distantPast comparison as favorited and dateFavorited
                // should always be updated together
                let favoritedMemes = allMemes
                    .filter({ $0.favorited })
                    .sorted { ($0.dateFavorited ?? .distantPast) > ($1.dateFavorited ?? .distantPast) }
                
                return favoritedMemes
            
            case "All Giggles":
                return getAllMemesWithSearch().sorted { $0.dateAdded > $1.dateAdded }
            
            case "Recently Shared":
                let allMemes = getAllMemesWithSearch()
                let recentlySharedMemes = allMemes
                    .filter { $0.dateLastShared != nil }
                    .sorted { $0.dateLastShared! > $1.dateLastShared! }
                    .prefix(24)
                    
                return Array(recentlySharedMemes)
            
            // Filter by tag if `header` is not a special folder
            default:
                let tagFilteredMemes = memes.filter { meme in
                    meme.tags.contains { $0.name == header }
                }
            
            let filteredAgain = searchText.isEmpty ? tagFilteredMemes : tagFilteredMemes.filter { memeSearchPredicate(for: searchText).evaluate(with: $0) }
            
                return filteredAgain.sorted { $0.dateAdded > $1.dateAdded }
        }
    }
    
    // Used in the three special folders - Favorites, All Giggles, and Recently Shared.
    // In other words, filter off the set of all memes rather than memes with a certain tag.
    func getAllMemesWithSearch() -> [Meme]  {
        // If there's a search text, filter all memes by it
        if searchText.isEmpty {
            return memes
        }

        return memes.filter { memeSearchPredicate(for: searchText).evaluate(with: $0) }
    }

    var body: some View {
        VStack {
            PageHeader(text: header.capitalized)
            
            SearchBar(
                text: "Search \(header.capitalized)",
                searchText: $searchText
            )

            ScrollView {
                LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.memeRowPadding) {
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
    FolderView(header: "All Giggles")
}
