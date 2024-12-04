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
    
    var header: String

    var body: some View {
        VStack {
            Text(header)
                .font(.system(size: 35, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.bottom, -1)
            
            MemeImageView(image: meme.imageAsUIImage)

            ContentWithWhiteBackground(
                tags: $meme.tags,
                favorited: $meme.favorited,
                dateAdded: meme.dateAdded,
                addTagAction: addTag,
                removeTagAction: removeTag,
                favoriteAction: { favoriteMeme(meme: meme, context: context) },
                deleteAction: { deleteMeme(meme: meme, context: context) },
                shareAction: { shareMeme(meme: meme, context: context) },
                copyAction: { copyMeme(meme: meme, context: context) },
                dismissAction: dismiss
            ).padding(.bottom, 62)

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
    
    private func removeTag(tagName: String) {
        // Remove tag from meme
        meme.removeTag(tagName)
        // Delete tag if it is not attached to any other memes
        deleteTagIfUnused(tagName: tagName, context: context)
        
        DataManager.saveContext(
            context: context,
            success_message: "Successfully removed tag \(tagName) from meme",
            fail_message: "Failed to remove tag \(tagName) from meme",
            id: meme.id
        )
    }
}

struct ContentWithWhiteBackground: View {
    @Binding var tags: [Tag]
    @Binding var favorited: Bool
    
    var dateAdded: Date
    
    var addTagAction: (String) -> Void
    var removeTagAction: (String) -> Void
    
    var favoriteAction: () -> Void
    var deleteAction: () -> Void
    var shareAction: () -> Void
    var copyAction: () -> Void
    var dismissAction: DismissAction
    
    @State private var newTag: String = ""
    @State private var showAddTagPopup = false
    @State private var showDeleteTagAlert = false
    @State private var selectedTagToDelete: Tag?
    
    @State private var memeCopied = false
    @State private var memeDeleted = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                // Tags Section
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Tags")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .underline()

                        Button(action: {
                            showAddTagPopup = true // Show iOS alert
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
                    }
                    .padding(.bottom, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                Button(action: {
                                    showDeleteTagAlert = true
                                    selectedTagToDelete = tag
                                }) {
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
                                .confirmationDialog(
                                    "Delete tag \"\(selectedTagToDelete?.name ?? "")\"?",
                                    isPresented: $showDeleteTagAlert,
                                    titleVisibility: .visible
                                ) {
                                    Button("Delete", role: .destructive) {
                                        guard let tagToDelete = selectedTagToDelete else { return }
                                        removeTagAction(selectedTagToDelete!.name)
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                            }
                        }
                    }
                }

                MoreInfo(dateAdded: dateAdded)

                // Action buttons
                HStack {
                    Spacer()
                    
                    // Favorite button
                    Button(action: {
                        favoriteAction()
                    }) {
                        Image(systemName: favorited ? "heart.fill" : "heart")
                            .font(.system(size: 43))
                            .foregroundColor(favorited ? .red : .black)
                            .padding(10)
                            .padding(.top, 12)
                    }
                    Spacer()
                    
                    // Share button
                    Button(action: {
                        shareAction()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 43))
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    Spacer()
                    
                    // Copy button
                    Button(action: {
                        copyAction()
                        memeCopied = true
                    }) {
                        ZStack {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 43))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .opacity(memeCopied ? 1 : 0)
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .offset(x: 19, y: -20)
                        }
                        .padding(10)
                    }
                    Spacer()
                    
                    // Delete button
                    Button(action: {
                        dismissAction()
                        memeDeleted = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 43))
                            .foregroundColor(.black)
                            .padding(10)
                            .padding(.trailing, 10)
                    }
                    Spacer()
                }
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Colors.giggleWhite)
                    .shadow(radius: 10)
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.95)
            .padding(.horizontal)
        }
        // iOS Native Alert for Adding a Tag
        .alert("Add New Tag", isPresented: $showAddTagPopup) {
            TextField("Enter tag name", text: $newTag)
            
            Button("Add") {
                guard !newTag.isEmpty else { return }
                
                addTagAction(newTag)
                newTag = "" // Reset input field
            }
            
            Button("Cancel", role: .cancel) {
                newTag = ""
            }
        }
        .onDisappear {
            if memeDeleted {
                deleteAction()
            }
        }
    }
}

struct MoreInfo: View {
    var dateAdded: Date

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
        ),
        header: "All Giggles"
    )
}
