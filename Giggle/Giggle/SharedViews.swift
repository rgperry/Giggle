//
//  SharedViews.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//

import SwiftUI
import SwiftData
import OSLog

let logger = Logger()

struct GiggleItem: View {
    var text: String?
    let size: CGFloat = 150
    let meme: Meme
    @State private var isLiked = false
    
    var body: some View {
        VStack {
            Image(uiImage: meme.imageAsUIImage)
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
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)
                
                TextField(text, text: $searchText)
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
    @Environment(\.modelContext) private var context
    
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
            .onChange(of: selectedImages) {
                print("selected memes changed")
            // only add new memes when there are a few in the selectedPhotos. (this .onchange gets called twice bc we clear the selected images array.)
//            guard selectedImages.isEmpty else { return }
            print("made it apst tyhe guard")
            Task {
                print("made it in the task")
                // ignore the modelContext warning here - Matt (@MainActor decorator on storeMemes function fixed this)
                await DataManager.storeMemes(context: context, images: selectedImages) {
                    logger.info("Successfully store \(selectedImages.count) images to the swiftData database")
                    selectedImages.removeAll()
                    }
                }
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


// ---------------------------------- Griffin Stuff ------------------------------

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
    @Binding var memeDescription: String // Binding to use an external variable

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
    @Binding var isClicked: Bool
    var isEnabled: Bool
    var showAlertAction: () -> Void // Closure to trigger alert

    var body: some View {
        Button(action: {
            if isEnabled {
                isClicked = true
                print("Generate meme with Dalle3 AI!")
            } else {
                showAlertAction() // Trigger alert if no description
            }
        }) {
            Text("Generate with Dalle3 AI")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
                .padding(.horizontal, 80)
                .padding(.bottom, 30)
        }
        Spacer().frame(height: 40)
    }
}

// Component: Meme Image View
struct MemeImageView: View {
    var body: some View {
        VStack {
            Spacer()

            Image("lebron_meme_441")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 400)

            Spacer()
        }
    }
}

// Component: Action Buttons View (Download, Refresh, Delete)
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
// Component: Download Button
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

// Component: Refresh Button
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

// Component: Delete Button
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

struct Tags: View {
    var tags: [String]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Tags")
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Colors.backgroundColor.ignoresSafeArea())
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        // Action for add tag button
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Circle().fill(Color.white))
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(5)
        }
    }
}


struct MoreInfo: View {
    var dateSaved: String
    var source: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("More Info")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 10)

            HStack {
                Text("Date Saved:")
                    .fontWeight(.bold)
                Text(dateSaved)
            }
            HStack {
                Text("Source:")
                    .fontWeight(.bold)
                Text(source)
            }
        }
    }
}

// GRIFFIN ADDED THIS FOR HIS IMPLEMENTATION OF MEME INFO VIEW
struct LikeButton: View {
    @Binding var isLiked: Bool

    var body: some View {
        Button(action: {
            isLiked.toggle()
        }) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundColor(isLiked ? .red : .black)
                .font(.system(size: 35))
        }
    }
}
