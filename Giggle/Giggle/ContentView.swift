//
//  ContentView.swift
//  Giggle
//
//  Created by Karan Arora on 10/25/24.
//

import SwiftUI
import SwiftData
import OSLog

let logger = Logger()


// TODO
// Make ContentView a wrapper?
// Put components in different files for better organization?

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var searchText = ""

    let gridItems = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        VStack {
            MainHeader(text: "Giggle")
            SearchBar(text: "Search for a Giggle", searchText: $searchText)

            if searchText.isEmpty {
                ScrollView {
                    LazyVGrid(columns: gridItems, spacing: 40) {
                        ItemView(title: "Favorites")
                        ItemView(title: "Recently Shared")
                        ItemView(title: "All Giggles")
                        ItemView(title: "Sports")
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 28)
                }
            }
            BottomNavBar()
        }
        .background(Color(red: 104/255, green: 86/255, blue: 182/255).ignoresSafeArea())
    }
}

struct ItemView: View {
    var title: String
    let size: CGFloat = 140

    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(radius: 4)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

struct MemeView: View {
    let size: CGFloat = 140
    let meme: Meme

    var body: some View {
        VStack {
            Image(uiImage: meme.imageAsUIImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(radius: 4)
        }
    }
}

struct SearchBar: View {
    var text: String
    @Binding var searchText: String
    @Query private var memes: [Meme]
    @Environment(\.modelContext) private var context
    
    var filteredMemes: [Meme] {
        if searchText.isEmpty {
            return memes
        } else {
            return DataManager.findSimilarEntries(query: searchText, context: context, limit: 10)
        }
    }
    
    var body: some View {
        HStack {
            HStack {
                TextField(text, text: $searchText)
                    .padding(8)
                    .foregroundColor(.black)
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 23)
        
        // Display the filtered results
        if !searchText.isEmpty {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(filteredMemes) { meme in
                        MemeView(meme: meme)
                    }
                }
                .padding()
            }
        }
    }
}

struct BottomNavBar: View {
    @State private var isPickerPresented = false
    @State private var selectedImages: [UIImage] = []
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack {
            BottomNavBarIcon(systemIconName: "house", tabName: "Home")
            BottomNavBarIcon(systemIconName: "plus", tabName: "Add")
                .onTapGesture {
                    isPickerPresented = true
                }
            BottomNavBarIcon(systemIconName: "pencil", tabName: "Edit")
            BottomNavBarIcon(systemIconName: "gearshape", tabName: "Settings")
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .onChange(of: selectedImages) {
            // only add new memes when there are a few in the selectedPhotos. (this .onchange gets called twice bc we clear the selected images array.)
            guard selectedImages.isEmpty else { return }
            Task {
                // ignore the modelContext warning here - Matt (@MainActor decorator on storeMemes function fixed this)
                await DataManager.storeMemes(context: context, images: selectedImages) {
                    logger.info("Successfully store \(selectedImages.count) images to the swiftData database")
                    selectedImages.removeAll()
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

struct BottomNavBarIcon: View {
    var systemIconName: String
    var tabName: String
    let size: CGFloat = 42

    var body: some View {
        VStack {
            Image(systemName: systemIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .padding(.trailing, 30)
        }
    }
}

struct MainHeader: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 45, weight: .semibold, design: .default))
            .padding(.top, 10)
            .padding(.bottom, 15)
            .foregroundColor(.white)
            .tracking(1)
    }
}

#Preview {
    ContentView()
}
