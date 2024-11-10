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
