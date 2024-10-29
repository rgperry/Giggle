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
                        Folder(folderName: "Sports")
                    }
                    .padding(.horizontal, GridStyle.columnPadding)
                    .padding(.top, GridStyle.searchBarPadding)
                }

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
        }.tint(.white)
    }
}

struct Folder: View {
    var folderName: String
    var pinned: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")
                SearchBar(text: "Search for a Giggle")

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

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
        }.tint(.black)
    }
}

struct PinIcon: View {
    var body: some View {
        Image(systemName: "pin.fill")
            .foregroundColor(.gray)
            .font(.system(size: 35))
            .offset(x: -71, y: -80)

        .background(Color(red: 104/255, green: 86/255, blue: 182/255).ignoresSafeArea())
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
