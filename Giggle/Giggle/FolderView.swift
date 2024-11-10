//
//  FolderView.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI

struct FolderView: View {
    var header: String
        
    var body: some View {
        VStack {
            PageHeader(text: header)
            SearchBar(text: "Search " + header)
        
            ScrollView {
                LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.memeRowPadding) {
                    GiggleItem()
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
