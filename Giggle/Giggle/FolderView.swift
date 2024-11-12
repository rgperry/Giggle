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
            case "All Giggles":
                // If there's a search text, filter all memes by the search query
                return searchText.isEmpty ? memes : DataManager.findSimilarEntries(
                    query: searchText,
                    context: context,
                    limit: Int(numSearchResults),
                    tagName: nil // No specific tag for "All Giggles" search
                )

            case "Recently Shared":
                // Return the 24 most recent shared memes
                let memesToSearch = searchText.isEmpty ? memes : DataManager.findSimilarEntries(
                    query: searchText,
                    context: context,
                    limit: Int(numSearchResults),
                    tagName: nil // No specific tag for "Recently Shared" search
                )
                let recentlySharedMemes = memesToSearch
                        .filter { $0.dateLastShared != nil }
                        .sorted { $0.dateLastShared ?? Date.distantPast > $1.dateLastShared! }
                        .prefix(24)
                    
                return Array(recentlySharedMemes)

            default:
                // Filter by tag if `header` is not "All Giggles" or "Recently Shared"
                let tagFilteredMemes = memes.filter { meme in
                    meme.tags.contains { $0.name == header }
                }

                // Apply search filter if there's a search text
                return searchText.isEmpty ? tagFilteredMemes : DataManager.findSimilarEntries(
                    query: searchText,
                    context: context,
                    limit: Int(numSearchResults),
                    tagName: header.isEmpty ? nil : header
                )
            }
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
    FolderView(header: "All Giggles")
}
