//
//  BottomNavBar.swift
//  Giggle
//
//  Created by Karan Arora on 11/12/24.
//

import SwiftUI

struct BottomNavBar: View {
    @State private var isImagePickerPresented = false
    @State private var selectedMemes: [MemeMedia] = [] //updated xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    @State private var isStoring: Bool = false
    @State private var pickingIsDone = false
    
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
                        pickingIsDone = false
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
                ImagePicker(selectedMemes: $selectedMemes, pickingIsDone: $pickingIsDone) //updated xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            }
            .onChange(of: selectedMemes) { //updated   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                print("selected memes changed")
            // only add new memes when there are a few in the selectedPhotos. (this .onchange gets called twice bc we clear the selected images array.)
//            guard selectedImages.isEmpty else { return }
                guard !isStoring else { return }
                guard pickingIsDone, !selectedMemes.isEmpty else { //updated    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                    logger.info("picking not done yet wait!!!!!")
                    return
                }
                Task {
                    isStoring = true
                    defer { isStoring = false }
                    
                    do { //updated    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                        let importManager = MemeImportManager(modelContainer: context.container)
                        try await importManager.storeMemes(memes: selectedMemes) { //updated  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                            logger.info("Successfully stored \(selectedMemes.count) images to the SwiftData database")
                            DispatchQueue.main.async {
                                selectedMemes.removeAll()
                            }
                        }
                    } catch {
                        logger.error("Error storing \(selectedMemes.count) memes: \(error)")
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
