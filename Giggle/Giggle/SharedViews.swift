//
//  SharedViews.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI

struct GiggleItem: View {
    var text: String?
    let size: CGFloat = 150
    @State private var isLiked = false

    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(radius: 4)
                .onTapGesture {
                    //short tap to open meme view

                }
                .contextMenu {
                    Button(action: {
                        copyImage()
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }

                    Button(action: {
                        shareImage()
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }

            Button(action: {
                isLiked.toggle()
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .red : .black)
                    .font(.system(size: 50))
            }
            .offset(x: -72, y: -175)

            if let text = text {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    //Handle copying the image (placeholder for now)
    private func copyImage() {
        //PLACEHOLDER
    }

    //Handle sharing the image
    private func shareImage() {
        let image = UIImage(systemName: "person.circle.fill")!
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct FolderItem: View {
    var text: String
    let size: CGFloat = 150
    @State var isPinned = false

    var body: some View {
        NavigationLink(destination: FolderView(header: text)) {
            ZStack {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(radius: 4)

                    Text(text)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 20)

                Button(action: {
                    isPinned.toggle()
                }) {
                    Image(systemName: isPinned ? "pin.fill" : "pin")
                        .foregroundColor(.gray)
                        .font(.system(size: 55))
                        .shadow(color: .black, radius: 4, x: 0, y: 0)
                }
                .offset(x: -65, y: -size / 2 - 10)
            }
        }
    }
}


struct SearchBar: View {
    var text: String

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)

                TextField(text, text: .constant(""))
                    .padding(8)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .background(.white)
            .cornerRadius(18)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 23)
    }
}

struct BottomNavBar: View {
    @State private var isImagePickerPresented = false
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(white: 0.97))
                .frame(height: 84)
                .edgesIgnoringSafeArea(.bottom)

            HStack {
                BottomNavBarIcon(icon: "house.fill")
                BottomNavBarIcon(icon: "plus.circle.fill")
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
                BottomNavBarIcon(icon: "paintbrush.fill")
                BottomNavBarIcon(icon: "gearshape.fill")
            }
            .padding(.leading, 25)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImages: $selectedImages)
            }
            .padding(.bottom, 19)
        }
        .frame(height: 10)
    }
}

struct BottomNavBarIcon: View {
    var icon: String
    let size: CGFloat = 49

    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .padding(.trailing, 30)
        }
    }
}

struct PageHeader: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 45, weight: .semibold, design: .rounded))
            .padding(.top, 10)
            .padding(.bottom, 15)
            .foregroundColor(.white)
    }
}


struct QuestionMarkImage: View {
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

// Component: Meme Description Text Field
struct MemeDescriptionField: View {
    @State private var memeDescription: String = ""

    var body: some View {
        VStack {
            TextField("Describe the meme you want to create!", text: $memeDescription)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal, 30)
            Spacer().frame(height: 20)
        }
    }
}

// Component: Generate Meme Button
struct GenerateMemeButton: View {
    var body: some View {
        VStack {
            Button(action: {
                // Action for generating meme
                print("Generate meme with Dalle3 AI!")
            }) {
                Text("Generate with Dalle3 AI")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.horizontal, 80)
            }
            Spacer().frame(height: 40)
        }
    }
}

// Component: Meme Image View
struct MemeImageView: View {
    var body: some View {
        Image("generated_meme") // Replace "generated_meme" with the appropriate image name or use network image logic
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 250)
            .cornerRadius(18)
            .shadow(radius: 5)
    }
}

// Component: Action Buttons View (Download, Refresh, Delete)
struct ActionButtonsView: View {
    var body: some View {
        HStack(spacing: 40) {
            DownloadButton()
            RefreshButton()
            DeleteButton()
        }
        .padding(.vertical, 20)
    }
}

// Component: Download Button
struct DownloadButton: View {
    var body: some View {
        ActionButton(iconName: "square.and.arrow.down")
    }
}

// Component: Refresh Button
struct RefreshButton: View {
    var body: some View {
        ActionButton(iconName: "arrow.clockwise")
    }
}

// Component: Delete Button (xmark with circle styling)
struct DeleteButton: View {
    let size: CGFloat = 40

    var body: some View {
        Button(action: {
            // Add delete action here
        }) {
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                // circle styling
                .frame(width: size * 0.4, height: size * 0.4)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Circle().fill(Color.clear)) // Transparent fill for the circle
                .overlay(Circle().stroke(Color.white, lineWidth: 2)) // White border
        }
    }
}


// Component: General Action Button used for Download and Refresh
struct ActionButton: View {
    var iconName: String
    let size: CGFloat = 65

    var body: some View {
        Button(action: {
            // Add the appropriate action here
        }) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.5, height: size * 0.5) // Icon size adjusted to fit within button frame
                .foregroundColor(.white)
                .frame(width: size, height: size) // Consistent button size
                .background(Color.clear)
        }
    }
}
