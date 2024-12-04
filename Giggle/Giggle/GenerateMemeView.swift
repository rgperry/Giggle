import SwiftUI
import SwiftData

struct GenerateMemeView: View {
    @Bindable var meme: Meme
    
    @State private var isGenerating = false
    @State private var showAlert = false

    // let modelContainer: ModelContainer
    
    var body: some View {
        VStack {
            // Meme Image or Placeholder
            if isGenerating {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)
            } else {
                MemeImageView(image: meme.imageAsUIImage)
            }

            // Content
            Content(
                memeDescription: $meme.content,
                isGenerating: $isGenerating,
                showAlertAction: { showAlert = true },
                generateAction: generateMemeButtonPressed,
                deleteAction: deleteMeme,
                downloadAction: storeMemeButton
            )
            .padding(.bottom, 62)

            Spacer()
            BottomNavBar()
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
        .alert("Missing Description", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                }
    }

    private func generateMemeButtonPressed() {
        guard !meme.content.isEmpty else {
            showAlert = true
            return
        }
        isGenerating = true
        Task {
            let newImage = await generateMeme(description: meme.content)
            DispatchQueue.main.async {
                meme.image = newImage?.pngData() // Save the new image to the meme object
                isGenerating = false
            }
        }
    }

    private func deleteMeme() {
        meme.image = nil
    }

    private func storeMemeButton() {
        Task {
            do {
                let modelContainer = try ModelContainer(for: Meme.self, Tag.self)
                let importManager = MemeImportManager(modelContainer: modelContainer)
                
                // Store memes
                try await importManager.storeMemes(images: [meme.imageAsUIImage]) {
                    print("Meme stored successfully!")
                }
            } catch {
                print("Failed to store meme: \(error.localizedDescription)")
            }
        }
    }
}

struct Content: View {
    @Binding var memeDescription: String
    @Binding var isGenerating: Bool

    var showAlertAction: () -> Void
    var generateAction: () -> Void
    var deleteAction: () -> Void
    var downloadAction: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                // Meme Description
                TextField("Enter your meme description here", text: $memeDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white.cornerRadius(8))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                // Action Buttons
                HStack {
                    Spacer()
                    Button(action: downloadAction) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .padding(10)
                    }
                    Spacer()
                    Button(action: deleteAction) {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .padding(10)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Generate Button
                Button(action: generateAction) {
                    Text(isGenerating ? "Generating..." : "Generate Meme")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isGenerating ? Color.gray : Color.blue)
                        )
                        .padding(.horizontal)
                }
                .disabled(isGenerating)
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
    }
}

// Example Preview
#Preview {
    GenerateMemeView(
        meme: Meme(
            content: "Meme with a dog who doesn’t like exercise",
            tags: [],
            image: UIImage(systemName: "photo") ?? UIImage() // Ensure image data matches expected type
        )
    )
}
