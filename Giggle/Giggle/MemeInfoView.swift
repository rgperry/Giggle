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
                favoriteAction: { favoriteMeme(meme: meme, context: context) },
                deleteAction: deleteMeme,
                shareAction: { shareMeme(meme: meme, context: context) },
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
    
    private func deleteMeme() {
        context.delete(meme)
        
        DataManager.saveContext(
            context: context,
            success_message: "Successfully deleted meme",
            fail_message: "Failed to delete meme",
            id: meme.id
        )
        
        dismiss() // Redirect to the previous view
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
    var shareAction: () -> Void
    var dismissAction: DismissAction
    
    @State private var newTag: String = ""
    @State private var showAddTagPopup = false
    @State private var showDeleteTagAlert = false
    @State private var selectedTagToDelete: Tag?

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
                                .confirmationDialog("Delete Tag?", isPresented: $showDeleteTagAlert, titleVisibility: .visible) {
                                    Button("Delete", role: .destructive) {
                                        guard let tagToDelete = selectedTagToDelete else { return }
                                        tags.removeAll { $0 == tagToDelete }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                            }
                        }
                    }
                }

                MoreInfo(dateAdded: dateAdded, source: source)

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
                    }
                    
                    Spacer()
                    // Share button
                    Button(action: {
                        shareAction()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 43))
                            .foregroundColor(.black)
                            .padding(10)
                    }

                    Spacer()
                    // Delete button
                    Button(action: {
                        deleteAction()
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 43))
                            .foregroundColor(.black)
                            .padding(10)
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
