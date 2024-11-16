//
//  GiggleItem.swift
//  Giggle
//
//  Created by Karan Arora on 11/12/24.
//

import SwiftUI

// FINISH: use this to create shared code between GiggleItem and FolderItem eventually?
//struct Item: View {
//    let size: CGFloat = 150
//    var image: UIImage
//    
//    var body: some View {
//        Image(uiImage: image)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: size, height: size)
//            .foregroundColor(.black)
//            .background(.white)
//            .cornerRadius(18)
//            .shadow(radius: 4)
//    }
//}

struct GiggleItem: View {
    let size: CGFloat = 150
    
    @Bindable var meme: Meme
    @Environment(\.modelContext) private var context

    @State private var navigateToMemeInfo = false

    var body: some View {
        NavigationStack {
            VStack {
                Image(uiImage: meme.imageAsUIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(18)
                    .shadow(radius: 4)
                    .onTapGesture {
                        navigateToMemeInfo = true
                    }
                    .contextMenu {
                        Button(action: {
                            copyImage()
                            
                            meme.dateLastShared = Date()
                            DataManager.saveContext(
                                context: context,
                                success_message: "Successfully updated date shared",
                                fail_message: "Failed to update date shared",
                                id: meme.id
                            )
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }

                        Button(action: {
                            shareImage()
                            
                            meme.dateLastShared = Date()
                            DataManager.saveContext(
                                context: context,
                                success_message: "Successfully updated date shared",
                                fail_message: "Failed to update date shared",
                                id: meme.id
                            )
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }

                Button(action: {
                    meme.favorited.toggle()
                    DataManager.saveContext(
                        context: context,
                        success_message: "Successfully updated favorited status",
                        fail_message: "Failed to update favorited status",
                        id: meme.id
                    )
                }) {
                    Image(systemName: meme.favorited ? "heart.fill" : "heart")
                        .foregroundColor(meme.favorited ? .red : .black)
                        .font(.system(size: 50))
                }
                .offset(x: -72, y: -175)
            }
            .navigationDestination(isPresented: $navigateToMemeInfo) {
                MemeInfoView(
                    meme: meme
                )
            }
        }
    }

    private func copyImage() {
        let imageToCopy = meme.imageAsUIImage
        UIPasteboard.general.image = imageToCopy
    }

    private func shareImage() {
        let activityVC = UIActivityViewController(activityItems: [meme.imageAsUIImage], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
