//
//  MemeInfoView.swift
//  Giggle
//
//  Created by Griffin Gong on 11/10/24.
//

import SwiftUI

struct MemeInfoView: View {
    @Bindable var meme: Meme
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            PageHeader(text: "Giggle")
            MemeImageView(image: meme.imageAsUIImage)

            ContentWithWhiteBackground(
                tags: $meme.tags,
                favorited: $meme.favorited,
                dateAdded: meme.dateAdded,
                source: "TODO",
                addTagAction: addTag,
                favoriteAction: favoriteMeme,
                deleteAction: deleteMeme,
                dismissAction: dismiss
            ).offset(y: -62)

            Spacer()
            BottomNavBar()
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
    }
    
    private func addTag(newTag: String) {
        meme.addTag(newTag)
                
        DataManager.saveContext(
            context: context,
            success_message: "Successfully added tag \(newTag) to meme",
            fail_message: "Failed to add tag \(newTag) to meme",
            id: meme.id
        )
    }
    
    private func favoriteMeme() {
        meme.toggleFavorited()
        
        DataManager.saveContext(
            context: context,
            success_message: "Successfully updated favorited status and date favorited",
            fail_message: "Failed to update favorited status or date favorited",
            id: meme.id
        )
    }
    
    private func deleteMeme() {
        context.delete(meme)
        
        DataManager.saveContext(
            context: context,
            success_message: "Successfully deleted meme",
            fail_message: "Failed to delete meme",
            id: meme.id
        )
    }
}

struct ContentWithWhiteBackground: View {
    @Binding var tags: [Tag]
    @Binding var favorited: Bool
    
    var dateAdded: Date
    var source: String
    
    var addTagAction: (String) -> Void
    var favoriteAction: () -> Void
    var deleteAction: () -> Void
    var dismissAction: DismissAction
    
    @State private var newTag: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Tags Section
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Tags")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .underline()

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
                                Circle().fill(Color.clear)
                            )
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: 2)
                            )
                    }
                }.padding(.bottom, 4)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag.name)")
                                .font(.system(size: 14))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Colors.backgroundColor)
                                )
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
            }

            MoreInfo(dateAdded: dateAdded, source: source)

            // Action buttons
            HStack {
                // Heart button
                Spacer()
                Button(action: {
                    favoriteAction()
                }) {
                    Image(systemName: favorited ? "heart.fill" : "heart")
                        .font(.system(size: 43))
                        .foregroundColor(favorited ? .red : .black)
                        .padding(10)
                }
                
                // Delete button
                Spacer()
                Button(action: {
                    deleteAction()
                    // dismissAction()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 43))
                        .foregroundColor(.black)
                        .padding(10)
                }
                
                Spacer()
            }
        }
        .padding(15) // Padding inside the box
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Colors.giggleWhite)
                .shadow(radius: 10)
        )
        // Constrain width to 95% of the screen
        .frame(maxWidth: UIScreen.main.bounds.width * 0.95)
        .padding(.horizontal)
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
                .padding(.top, 10)
                .underline()

            HStack {
                Text("Date Saved:").fontWeight(.bold)
                Text(dateAdded.formatted(date: .abbreviated, time: .shortened))
            }
            HStack {
                Text("Source:").fontWeight(.bold)
                Text(source)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(5)
    }
}

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
