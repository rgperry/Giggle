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
    var body: some View {
        VStack {
            PageHeader(text: "Giggle")
            SearchBar(text: "Search for a Giggle")

            ScrollView {
                LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.folderRowPadding) {
                    ItemView(text: "Favorites")
                    ItemView(text: "Recently Shared")
                    ItemView(text: "All Giggles")
                    ItemView(text: "Sports")
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
    ContentView()
}
