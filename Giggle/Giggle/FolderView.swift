//
//  FolderView.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI

struct FolderView: View {
    var header: String
    var searchBarText: String
    
    @State var isLiked = true
    
    var body: some View {
        VStack {
            PageHeader(text: header)
            SearchBar(text: searchBarText)
        
            ScrollView {
                LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.memeRowPadding) {
                    ZStack {
                        ItemView()
                        
                        // FINISH: button is not working
                        Button(action: {
                            isLiked.toggle()
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .black)
                                .font(.system(size: 35))
                                .offset(x: -72, y: -70)
                        }
                    }
                    
                    ItemView()
                    ItemView()
                    ItemView()
                    ItemView()
                    ItemView()
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
    FolderView(header: "Favorites", searchBarText: "Search Favorites")
}
