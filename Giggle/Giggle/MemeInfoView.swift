//
//  MemeInfoView.swift
//  Giggle
//
//  Created by Griffin Gong on 11/10/24.
//

import SwiftUI

struct MemeInfoView: View {
    @Bindable var meme: Meme

    @State private var navigateToAllGiggles = false

    var body: some View {
        NavigationStack {
            VStack { // VStack instead of ScrollView to remove scrolling
                // Header
                PageHeader(text: "Giggle")

                // Meme Image
                MemeImageView(image: meme.imageAsUIImage)

                // Tags and More Info Section (White Background Container)
                ContentWithWhiteBackground(
                    tags: meme.tags,
                    dateAdded: meme.dateAdded,
                    source: "Giggle App",
                    addTagAction: { newTag in
                        meme.addTag(newTag)
                    }
                )
                // This moves the ContentWithWhiteBackground further above the bottom nav bar
                .padding(.bottom, 65)

                Spacer() // Spacer ensures the BottomNavBar stays at the bottom
                BottomNavBar()
            }
            
            .background(Colors.backgroundColor.ignoresSafeArea())
            .navigationDestination(isPresented: $navigateToAllGiggles) {
                FolderView(header: "All Giggles")
            }
        }
    }
}


struct ContentWithWhiteBackground: View {
    var tags: [Tag]
    var dateAdded: Date
    var source: String
    var addTagAction: (String) -> Void
    @State private var newTag: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Tags Section
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Tags")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Spacer()

                    Button(action: {
                        guard !newTag.isEmpty else { return }
                        addTagAction(newTag)
                        newTag = ""
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .frame(width: 25, height: 25)
                            .background(
                                Circle()
                                    .fill(Color.clear) // Transparent fill
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2) // Black circular border
                            )
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag.name)")
                                .font(.caption)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Colors.backgroundColor.ignoresSafeArea())
                                .foregroundColor(.white)
                        }
                    }
                }
            }

            // More Info Section
            MoreInfo(dateAdded: dateAdded, source: source)

            // Action Buttons (Heart and Delete)
            HStack {
                Spacer()
                Button(action: {
                    // Add heart action here
                }) {
                    Image(systemName: "heart")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .padding(10)
                }
                Spacer()
                Button(action: {
                    // Add delete action here
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .padding(10)
                }
                Spacer()
            }
        }
        .padding(15) // Padding inside the box
        .background(
            RoundedRectangle(cornerRadius: 20) // Rounded rectangle background
                .fill(.white)
                .shadow(radius: 2) // Subtle shadow
        )
        .frame(maxWidth: UIScreen.main.bounds.width * 0.9) // Constrain width to 90% of the screen
        .padding(.horizontal) // Center the white box with spacing
    }
}



struct MoreInfo: View {
    var dateAdded: Date
    var source: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("More Info")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 15)

            HStack {
                Text("Date Saved:")
                    .fontWeight(.bold)
                Text(dateAdded.formatted(date: .abbreviated, time: .shortened))
            }
            HStack {
                Text("Source:")
                    .fontWeight(.bold)
                Text(source)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(5)
    }
}

struct FavoriteButton: View {
    @Binding var favorited: Bool

    var body: some View {
        Button(action: {
            favorited.toggle()
        }) {
            Image(systemName: favorited ? "heart.fill" : "heart")
                .foregroundColor(favorited ? .red : .black)
                .font(.system(size: 35))
        }
    }
}

// this preview is for you to see how everything looks like
#Preview {
    MemeInfoView(
        meme: Meme(
            content: "This is a sample meme for preview purposes",
            tags: [
                Tag(name: "dog"),
                Tag(name: "exercise"),
                Tag(name: "funny"),
                Tag(name: "hi"),
                Tag(name: "hello"),
                Tag(name: "yo"),
            ],
            image: UIImage(systemName: "photo") ?? UIImage()
        )
    )
}


// .background(Colors.backgroundColor.ignoresSafeArea())
