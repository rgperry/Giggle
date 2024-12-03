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
    @Binding var memeImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")
                MemeImageView(image: memeImage!)

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

                GenerateMemeButton(isClicked: .constant(false), memeDescription: $memeDescription, isEnabled: true, showAlertAction: {}, memeImage: $memeImage)

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
            .navigationDestination(isPresented: $navigateToGenerateMemeView) {
                GenerateMemeView()
            }
            .navigationDestination(isPresented: $navigateToMemeCreatedView) {
                MemeCreatedView(memeDescription: memeDescription, memeImage: $memeImage)
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

//#Preview {
//    MemeCreatedView(memeDescription: "Sample Meme Description")
//}
