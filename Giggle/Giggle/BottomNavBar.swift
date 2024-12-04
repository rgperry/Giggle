//
//  BottomNavBar.swift
//  Giggle
//
//  Created by Karan Arora on 11/12/24.
//

import SwiftUI

struct BottomNavBar: View {
    @State private var isImagePickerPresented = false
    @State private var selectedImages: [UIImage] = []
    @State private var isStoring: Bool = false
    @State private var pickingIsDone = false
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                //.fill(Color(white: 0.98))
                .fill(Color(UIColor.systemBackground))
                .frame(height: 127)
                .edgesIgnoringSafeArea(.bottom)

            HStack {
                NavigationLink(destination: ContentView()) {
                    BottomNavBarIcon(icon: "house.fill")
                }
                
                BottomNavBarIcon(icon: "plus.circle.fill")
                    .onTapGesture {
                        isImagePickerPresented = true
                        pickingIsDone = false
                    }
                
                // have to fix this image thing
                NavigationLink(destination: MemeCreatedView(meme: Meme(content: "", tags: [], image: UIImage(systemName: "photo") ?? UIImage()))) {
                    BottomNavBarIcon(icon: "paintbrush.fill")
                }


                NavigationLink(destination: SettingsView()) {
                    BottomNavBarIcon(icon: "gearshape.fill")
                }
            }
            .padding(.leading, 25)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImages: $selectedImages, pickingIsDone: $pickingIsDone)
            }
            .onChange(of: selectedImages) { //update so change on vids and GIFs xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                print("selected memes changed")
            // only add new memes when there are a few in the selectedPhotos. (this .onchange gets called twice bc we clear the selected images array.)
//            guard selectedImages.isEmpty else { return }
                guard !isStoring else { return }
                guard pickingIsDone, !selectedImages.isEmpty else {
                    logger.info("picking not done yet wait!!!!!")
                    return
                }
                Task {
                    isStoring = true
                    defer { isStoring = false }
                    
                    do {
                        let importManager = MemeImportManager(modelContainer: context.container)
                        try await importManager.storeMemes(images: selectedImages) {
                            logger.info("Successfully stored \(selectedImages.count) images to the SwiftData database")
                            DispatchQueue.main.async {
                                selectedImages.removeAll()
                            }
                        }
                    } catch {
                        logger.error("Error storing \(selectedImages.count) memes: \(error)")
                    }
                }
            }
            .padding(.bottom, 59)
        }
        .frame(height: 15)
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
                .foregroundColor(Color.primary)
                .padding(.trailing, 30)
        }
    }
}
