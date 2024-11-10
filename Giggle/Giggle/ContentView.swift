//
//  ContentView.swift
//  Giggle
//
//  Created by Karan Arora on 10/25/24.
//

import SwiftUI
import SwiftData

// TODO
// Make ContentView a wrapper?
// Put components in different files for better organization - semi-done

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")

                SearchBar(text: "Search for a Giggle", searchText: $searchText)
                if searchText.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.folderRowPadding) {
                            FolderItem(text: "Favorites", isPinned: true)
                            FolderItem(text: "Recently Shared", isPinned: true)
                            FolderItem(text: "All Giggles", isPinned: true)
                            FolderItem(text: "Sad")
                            FolderItem(text: "Sports")
                            FolderItem(text: "Surprised")
                        }
                        .padding(.horizontal, GridStyle.columnPadding)
                        .padding(.top, GridStyle.searchBarPadding)
                    }
                }

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
        }.tint(.black)
    }
}

#Preview {
    ContentView()
}
