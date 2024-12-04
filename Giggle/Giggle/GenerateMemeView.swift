//
//  MemeCreatedView.swift
//  Giggle
//
//  Created by Griffin Gong on 11/10/24.
//

import SwiftUI

struct GenerateMemeView: View {
    @State var memeDescription: String
    @Binding var memeImage: UIImage?
    @State private var isGenerating = false
    @State private var navigateToMemeCreatedView = false // Navigation state

    var body: some View {
        NavigationStack {
            VStack {
                // Page Header
                Text("Giggle")
                    .font(.system(size: 35, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Meme Image or Placeholder
                Spacer()
                if let memeImage = memeImage, !isGenerating {
                    MemeImageView(image: memeImage)
                        .frame(width: 200, height: 200)
                } else if isGenerating {
                    ProgressView()
                        .frame(width: 200, height: 200)
                } else {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
                
                // Meme Description Field
                TextField("Meme with a dog who doesn’t like exercise", text: $memeDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                    .background(Color.white.cornerRadius(10))
                    .padding(.vertical, 10)
                    .padding(.bottom, 10) // Adds space below the field
                
                // Generate Button with Navigation
                NavigationLink(
                    destination: MemeCreatedView(meme: Meme(content: memeDescription, tags: [], image: memeImage ?? UIImage(systemName: "photo")!
)),
                    isActive: $navigateToMemeCreatedView // Binding to navigation state
                ) {
                    Button(action: {
                        generateMemeButtonPressed()
                    }) {
                        Text(isGenerating ? "Generating..." : "Generate with DALL·E AI")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                            .background(isGenerating ? Color.gray.cornerRadius(10) : Color.blue.cornerRadius(10))
                    }
                    .padding(.bottom, 20) // Moves the button further down
                    .disabled(isGenerating)
                }

                Spacer()

                // Bottom Navigation Bar
                BottomNavBar()
                    .padding(.bottom, 10)
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
        }
    }
    
    private func generateMemeButtonPressed() {
        guard !memeDescription.isEmpty else { return }
        isGenerating = true
        
        Task {
            if let generatedImage = await generateMeme(description: memeDescription) {
                DispatchQueue.main.async {
                    self.memeImage = generatedImage
                    isGenerating = false
                    navigateToMemeCreatedView = true // Navigate after generation
                }
            } else {
                DispatchQueue.main.async {
                    isGenerating = false
                    print("Failed to generate meme.")
                }
            }
        }
    }
}

// Updated Preview
#Preview {
    GenerateMemeView(
        memeDescription: "Meme with a dog who doesn’t like exercise",
        memeImage: .constant(nil)
    )
}

