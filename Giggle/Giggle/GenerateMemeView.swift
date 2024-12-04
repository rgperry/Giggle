//
//  GenerateMemeView.swift
//  Giggle
//
//  Created by Griffin Gong on 11/10/24.
//

import SwiftUI

struct GenerateMemeView: View {
    @State private var memeDescription: String = ""
    @State private var isClicked = false
    @State private var showAlert = false
    @State private var memeImage: UIImage? = nil
    @State private var isLoading = false // Track loading state

    var body: some View {
        NavigationStack {
            VStack {
                // Page Header
                PageHeader(text: "Giggle")

                // Meme Image or Placeholder
                Spacer()
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Generating your meme...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                } else if let memeImage = memeImage {
                    MemeImageView(image: memeImage)
                        .frame(width: 200, height: 200)
                } else {
                    QuestionMark()
                }
                Spacer()

                // Meme Description Field
                MemeDescriptionField(memeDescription: $memeDescription)

                // Generate Meme Button
                GenerateMemeButton(
                    isClicked: $isClicked,
                    memeDescription: $memeDescription,
                    isEnabled: !memeDescription.isEmpty,
                    showAlertAction: { showAlert = true },
                    memeImage: $memeImage,
                    isLoading: $isLoading // Pass the loading state
                )
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Missing Description"),
                        message: Text("Please enter a meme description."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                Spacer()

                // Bottom Navigation Bar
                BottomNavBar()
                    .padding(.bottom, 10)
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
            .navigationDestination(isPresented: $isClicked) {
                MemeCreatedView(
                        meme: Meme(
                            content: memeDescription,
                            tags: [], // Add tags if applicable
                            image: UIImage() // Convert UIImage to Data
                        )
                    )
            }
        }
        .tint(.black)
        .navigationBarHidden(true)
    }
}

struct QuestionMark: View {
    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "questionmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundColor(.white)

            Spacer()
        }
    }
}

//#Preview {
//    GenerateMemeView()
//}
