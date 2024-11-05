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
                        Folder(folderName: "Favorites", pinned: true)
                        Folder(folderName: "Recently Shared", pinned: true)
                        Folder(folderName: "All Giggles", pinned: true)
                        
                        Folder(folderName: "Sad")
                        Folder(folderName: "Sports")
                        Folder(folderName: "Surprised")
                    }
                    .padding(.horizontal, GridStyle.columnPadding)
                    .padding(.top, GridStyle.searchBarPadding)
                }

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
        }.tint(.black)
    }
}

struct Folder: View {
    var folderName: String
    var pinned: Bool = false

    var body: some View {
        NavigationLink(destination: FolderView(header: folderName)) {
            ZStack {
                //We don't want this to be a GiggleItem; create FolderItem?
                GiggleItem(text: folderName)

                if pinned {
                    PinIcon()
                }
            }
        }
    }
}

struct PinIcon: View {
    var body: some View {
        Image(systemName: "pin.fill")
            .foregroundColor(.gray)
            .font(.system(size: 35))
            .offset(x: -71, y: -80)
    }
}

#Preview {
    ContentView()
}
