//
//  SharedViews.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI
import SwiftData
import UIKit

struct FolderItem: View {
    var text: String
    let size: CGFloat = 150
    @State var isPinned = false

    var body: some View {
        NavigationLink(destination: FolderView(header: text)) {
            ZStack {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                        .foregroundColor(.black)
                        .background(.white)
                        .cornerRadius(18)
                        .shadow(radius: 4)

                    Text(text.capitalized)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 20)

                if isPinned {
                    Image(
                        systemName: "pin.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 47))
                        .shadow(color: .black, radius: 4, x: 0, y: 0
                        )
                    .offset(x: -65, y: -size / 2 - 13)
                }
            }
        }
    }
}

struct SearchBar: View {
    var text: String
    @Binding var searchText: String

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)

                TextField(text, text: $searchText)
                    .padding(8)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .background(.white)
            .cornerRadius(18)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 23)
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

struct MemeDescriptionField: View {
    // Binding to use an external variable
    @Binding var memeDescription: String

    var body: some View {
        VStack {
            TextField("Describe the meme you want to create!", text: $memeDescription)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal, 30)
            Spacer().frame(height: 20)
        }
    }
}

struct GenerateMemeButton: View {
    @Binding var isClicked: Bool
    var isEnabled: Bool
    var showAlertAction: () -> Void

    var body: some View {
        Button(action: {
            if isEnabled {
                isClicked = true
                print("Generate meme with Dalle3 AI!")
            } else {
                // Trigger alert if no description
                showAlertAction()
            }
        }) {
            Text("Generate with Dalle3 AI")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
                .padding(.horizontal, 80)
                .padding(.bottom, 30)
        }
        Spacer().frame(height: 40)
    }
}

struct MemeImageView: View {
    let image: UIImage

    var body: some View {
        VStack {
            Spacer()

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                //.frame(width: 400, height: 400)

            Spacer()
        }
    }
}

struct DeleteButton: View {
    let size: CGFloat = 40
    var deleteAction: () -> Void

    var body: some View {
        Button(action: {
            deleteAction()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.4, height: size * 0.4) // Make the icon smaller within the circle
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Circle().fill(Color.clear)) // Transparent fill for the circle
                .overlay(Circle().stroke(Color.white, lineWidth: 2)) // White border
        }
    }
}
