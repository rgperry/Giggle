//
//  ContentView.swift
//  Giggle
//
//  Created by Karan Arora on 10/25/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var searchText = ""

    @Query private var memes: [Meme]
    @Query(sort: \Tag.name) private var allTags: [Tag]

    // https://abdulahd1996.medium.com/appstorage-property-wrapper-2eab0fb5b8fa
    @AppStorage("numSearchResults") private var numSearchResults: Double = 10

    // Get top tags using @Query and computed property
    private var topTags: [Tag] {
        let sortedTags = allTags.sorted { $0.memes.count > $1.memes.count }
        let folderLimit = 10
        return Array(sortedTags.prefix(folderLimit))
    }

    var filteredMemes: [Meme] {
        if searchText.isEmpty {
//            DataManager.clearDB(context: context)
            return memes
        } else {
//            DataManager.clearDB(context: context)
            return DataManager.findSimilarEntries(
                query: searchText,
                context: context,
                limit: Int(numSearchResults),
                tagName: nil
            )
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")

                SearchBar(text: "Search for a Giggle", searchText: $searchText)
                    ScrollView {
//                        LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.folderRowPadding) {
//                            // If search bar is empty, show folders
//                            if searchText.isEmpty {
//                                FolderItem(text: "Favorites", isPinned: true)
//                                FolderItem(text: "All Giggles", isPinned: true)
//                                FolderItem(text: "Recently Shared", isPinned: true)
//
//                                // Display top 10 tags as folders
//                                ForEach(topTags, id: \.name) { tag in
//                                    FolderItem(
//                                        text: "\(tag.name)",
//                                        isPinned: false
//                                    )
//                                }
//
//                            }
//                            // Else show memes for search query
//                            else {
//                                ForEach(filteredMemes) { meme in
//                                    GiggleItem(meme: meme)
//                                }
//                            }
//                        }
                        LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.folderRowPadding) {
                            // If search bar is empty, show folders
                            if searchText.isEmpty {
                                folderItemsView
//                                FolderItem(
//                                    text: "Favorites",
//                                    memes: memes.filter { $0.favorited }, isPinned: true
//                                )
//                                FolderItem(
//                                    text: "All Giggles",
//                                    memes: memes, isPinned: true
//                                )
//                                FolderItem(
//                                    text: "Recently Shared",
//                                    memes: memes.filter { $0.dateLastShared != nil }, isPinned: true
//                                )
//
//                                // Display top 10 tags as folders
//                                ForEach(topTags, id: \.name) { tag in
//                                    FolderItem(
//                                        text: "\(tag.name)",
//                                        isPinned: false,
//                                        memes: memes.filter { $0.tags.contains(where: { $0.name == tag.name }) }
//                                    )
//                                }
                            }
                            // Else show memes for search query
                            else {
                                searchResultsView
//                                ForEach(filteredMemes) { meme in
//                                    GiggleItem(meme: meme)
//                                }
                            }
                        }

                        .padding(.horizontal, GridStyle.columnPadding)
                        .padding(.top, GridStyle.searchBarPadding)
                    }

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
        }
        .tint(.black)
        .navigationBarHidden(true)
    }
    private var folderItemsView: some View {
        Group {
            FolderItem(
                text: "Favorites",
                memes: memes.filter { $0.favorited },
                isPinned: true
            )
            FolderItem(
                text: "All Giggles",
                memes: memes,
                isPinned: true
            )
            FolderItem(
                text: "Recently Shared",
                memes: memes.filter { $0.dateLastShared != nil },
                isPinned: true
            )

            ForEach(topTags, id: \.name) { tag in
                FolderItem(
                    text: "\(tag.name)",
                    memes: memes.filter { $0.tags.contains(where: { $0.name == tag.name }) },
                    isPinned: false
                )
            }
        }
    }

    // Extracted search results section
    private var searchResultsView: some View {
        ForEach(filteredMemes) { meme in
            GiggleItem(meme: meme)
        }
    }
}

#Preview {
    ContentView()
}
