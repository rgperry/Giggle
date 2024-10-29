//
//  FolderView.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI

struct FolderView: View {
    var header: String
    
    @State var isLiked = true
    
    var body: some View {
        VStack {
            PageHeader(text: header)
            SearchBar(text: "Search " + header)
        
            ScrollView {
                LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.memeRowPadding) {
                    ZStack {
                        GiggleItem()
                        
                        // FINISH: button works when you click on image but not when you click on heart itself
                        Button(action: {
                            isLiked.toggle()
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .black)
                                .font(.system(size: 35))
                                .offset(x: -72, y: -70)
                        }
                    }
                    
                    GiggleItem()
                    GiggleItem()
                    GiggleItem()
                    GiggleItem()
                    GiggleItem()
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
    FolderView(header: "Favorites")
}
