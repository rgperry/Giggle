//
//  MemeCreatedView.swift
//  Giggle
//
//  Created by Griffin Gong on 11/10/24.
//

import SwiftUI

struct MemeCreatedView: View {
    @State var memeDescription: String
    @State private var navigateToGenerateMemeView = false
    @State private var navigateToMemeCreatedView = false
    @State private var navigateToAllGiggles = false

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")
                // MemeImageView(image: )

                ActionButtonsView(
                    downloadAction: {
                        navigateToAllGiggles = true
                    },
                    refreshAction: {
                        navigateToMemeCreatedView = true
                    },
                    deleteAction: {
                        navigateToGenerateMemeView = true
                    }
                )

                MemeDescriptionField(memeDescription: $memeDescription)

                GenerateMemeButton(isClicked: .constant(false), isEnabled: true, showAlertAction: {})

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
            .navigationDestination(isPresented: $navigateToGenerateMemeView) {
                GenerateMemeView()
            }
            .navigationDestination(isPresented: $navigateToMemeCreatedView) {
                MemeCreatedView(memeDescription: memeDescription)
            }
            .navigationDestination(isPresented: $navigateToAllGiggles) {
                FolderView(header: "All Giggles")
            }
        }
    }
}

struct ActionButtonsView: View {
    var downloadAction: () -> Void
    var refreshAction: () -> Void
    var deleteAction: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            DownloadButton(downloadAction: downloadAction)
            RefreshButton(refreshAction: refreshAction)
            DeleteButton(deleteAction: deleteAction)
        }
        .padding(.vertical, 20)
    }
}

struct DownloadButton: View {
    let size: CGFloat = 65
    var downloadAction: () -> Void

    var body: some View {
        Button(action: {
            downloadAction()
        }) {
            Image(systemName: "square.and.arrow.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.5, height: size * 0.5) // Icon size adjusted to fit within button frame
                .foregroundColor(.white)
                .frame(width: size, height: size) // Consistent button size
                .background(Color.clear)
        }
    }
}

struct RefreshButton: View {
    var refreshAction: () -> Void

    var body: some View {
        Button(action: {
            refreshAction()
        }) {
            Image(systemName: "arrow.counterclockwise")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
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

#Preview {
    MemeCreatedView(memeDescription: "Sample Meme Description")
}
