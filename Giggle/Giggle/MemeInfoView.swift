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
    @State private var displayedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")

                MemeImageView(image: displayedImage ?? UIImage(systemName: "photo")!)
                Tags(tags: meme.tags)
                MoreInfo(dateAdded: meme.dateAdded, source: "TODO")
                
                DeleteButton(deleteAction: {
                    navigateToAllGiggles = true
                })
                FavoriteButton(favorited: $meme.favorited)

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
            .onAppear {
                loadImage()
            }
            .navigationDestination(isPresented: $navigateToAllGiggles) {
                FolderView(header: "All Giggles")
            }
        }
    }
    
    private func loadImage() {
        Task {
            let image = await meme.memeAsUIImage
            DispatchQueue.main.async {
                self.displayedImage = image
            }
        }
    }
}

struct Tags: View {
    var tags: [Tag]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Tags")
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text("#\(tag.name)")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Colors.backgroundColor.ignoresSafeArea())
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        // Action for add tag button
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Circle().fill(.white))
                            .overlay(Circle().stroke(.black, lineWidth: 1))
                    }
                }
            }
            .background(.white)
            .cornerRadius(5)
        }
    }
}

struct MoreInfo: View {
    var dateAdded: Date
    var source: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("More Info")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 10)

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

//#Preview {
//    MemeInfoView(
//        memeImage: Image("exercise_meme"),
//        tags: ["dog", "exercise", "fat"],
//        dateSaved: "10/7/24",
//        source: "Dalle3"
//    )
//}
