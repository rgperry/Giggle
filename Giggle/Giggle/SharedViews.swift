//
//  SharedViews.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI

struct ItemView: View {
    var text: String?
    let size: CGFloat = 150

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
            
            if let text = text {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct SearchBar: View {
    var text: String
    
    var body: some View {
        HStack {
            HStack {
                TextField(text, text: .constant(""))
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
    }
}

struct BottomNavBar: View {
    var body: some View {
        HStack {
            BottomNavBarIcon(systemIconName: "house", tabName: "Home")
            BottomNavBarIcon(systemIconName: "plus", tabName: "Add")
            BottomNavBarIcon(systemIconName: "pencil", tabName: "Edit")
            BottomNavBarIcon(systemIconName: "gearshape", tabName: "Settings")
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

struct PageHeader: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 45, weight: .semibold, design: .rounded))
            .padding(.top, 10)
            .padding(.bottom, 15)
            .foregroundColor(.white)
    }
}
