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
    @State var selectedVideos: [URL] = []
    @State var selectedGIFs: [URL] = []
    
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(white: 0.98))
                .frame(height: 127)
                .edgesIgnoringSafeArea(.bottom)

            HStack {
                NavigationLink(destination: ContentView()) {
                    BottomNavBarIcon(icon: "house.fill")
                }
                
                BottomNavBarIcon(icon: "plus.circle.fill")
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
                
                NavigationLink(destination: GenerateMemeView()) {
                    BottomNavBarIcon(icon: "paintbrush.fill")
                }
                
                NavigationLink(destination: SettingsView()) {
                    BottomNavBarIcon(icon: "gearshape.fill")
                }
            }
            .padding(.leading, 25)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImages: $selectedImages, selectedVideos: $selectedVideos, selectedGIFs: $selectedGIFs)
            }
            .onChange(of: selectedImages) { //update so change on vids and GIFs xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                print("selected memes changed")
            // only add new memes when there are a few in the selectedPhotos. (this .onchange gets called twice bc we clear the selected images array.)
//            guard selectedImages.isEmpty else { return }
                Task {
                    // ignore the modelContext warning here - Matt (@MainActor decorator on storeMemes function fixed this)
                    await DataManager.storeMemes(context: context, images: selectedImages) { //update for vids and GIFs xxxxxxxxxxxxxxxxxxxxxxxxxxxx
                        logger.info("Successfully store \(selectedImages.count) images to the swiftData database")
                        selectedImages.removeAll()
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
                .padding(.trailing, 30)
        }
    }
}
