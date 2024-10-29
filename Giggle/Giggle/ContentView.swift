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
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")
                SearchBar(text: "Search for a Giggle")

                ScrollView {
                    LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.folderRowPadding) {
                        NavigationLink(destination: FolderView(header: "Favorites")) {
                            ZStack {
                                ItemView(text: "Favorites")

                                Image(systemName: "pin.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 35))
                                    .offset(x: -71, y: -80)
                            }
                        }

                        NavigationLink(destination: FolderView(header: "Recently Shared")) {
                            ZStack {
                                ItemView(text: "Recently Shared")

                                Image(systemName: "pin.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 35))
                                    .offset(x: -71, y: -80)
                            }
                        }

                        NavigationLink(destination: FolderView(header: "All Giggles")) {
                            ZStack {
                                ItemView(text: "All Giggles")

                                Image(systemName: "pin.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 35))
                                    .offset(x: -71, y: -80)
                            }
                        }

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
}

#Preview {
    ContentView()
}
