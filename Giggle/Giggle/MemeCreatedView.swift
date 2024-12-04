import SwiftUI
import SwiftData

struct MemeCreatedView: View {
    @Bindable var meme: Meme

    @State private var isGenerating = false
    @State private var showAlert = false
    @State private var navigateToAllGiggles = false // Navigation state
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            PageHeader(text: "Giggle")
            // Meme Image or Placeholder
            if let imageData = meme.image, let image = UIImage(data: imageData) {
                MemeImageView(image: image)
            } else if isGenerating {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                Text("Generating your meme...")
                    .foregroundColor(.white)
                    .font(.headline)
            } else {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)
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
        .navigationDestination(isPresented: $navigateToAllGiggles) {
            FolderView(header: "All Giggles")
        }
    }

    private func generateMemeButtonPressed() {
        guard !meme.content.isEmpty else {
            showAlert = true
            return
        }
        isGenerating = true
        Task {
            if let newImage = await generateMeme(description: meme.content) {
                DispatchQueue.main.async {
                    if let imageData = newImage.pngData() {
                        meme.image = imageData
                    }
                    isGenerating = false
                }
            } else {
                DispatchQueue.main.async {
                    isGenerating = false
                }
            }
        }
    }

    private func deleteMeme() {
        meme.content = ""
        meme.image = nil
        dismiss()
    }

    private func storeMemeButton() {
        Task {
            do {
                let modelContainer = try ModelContainer(for: Meme.self, Tag.self)
                let importManager = MemeImportManager(modelContainer: modelContainer)
                try await importManager.storeMemes(images: [UIImage(data: meme.image!)!]) {
                    print("Meme stored successfully!")
                    navigateToAllGiggles = true // Navigate after storing
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
                    Text(isGenerating ? "Generating..." : "Generate New Meme")
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
