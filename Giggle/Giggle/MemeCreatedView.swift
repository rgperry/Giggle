import SwiftUI
import SwiftData

struct MemeCreatedView: View {
    @Bindable var meme: Meme
    
    @State private var isGenerating = false
    @State private var showAlert = false

    var body: some View {
        VStack {
            PageHeader(text: "Giggle")
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
                downloadAction: storeMemeButton,
                refreshAction: generateMemeButtonPressed
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
    var refreshAction: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 8) {
                // Meme Description
                TextField("Enter meme description", text: $memeDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 10)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                    .padding(.bottom, 5)

                // Action Buttons
                HStack(spacing: 15) {
                    Button(action: downloadAction) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Button(action: refreshAction) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Button(action: deleteAction) {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 5)

                // Generate Button
                Button(action: generateAction) {
                    Text(isGenerating ? "Generating..." : "Generate Meme")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isGenerating ? Color.gray : Color.blue)
                        )
                }
                .disabled(isGenerating)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Colors.giggleWhite)
                    .shadow(radius: 5)
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
        }
    }
}


// Example Preview
#Preview {
    MemeCreatedView(
        meme: Meme(
            content: "Meme with a dog who doesn’t like exercise",
            tags: [],
            image: UIImage(systemName: "photo") ?? UIImage() // Ensure image data matches expected type
        )
    )
}
