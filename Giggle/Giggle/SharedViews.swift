//
//  SharedViews.swift
//  Giggle
//
//  Created by Karan Arora on 10/27/24.
//  Adjusted for thumbnails/animations by Tamaer Al-Harastani 11/21/24
//

import SwiftUI
import SwiftData
import UIKit

struct FolderItem: View {
    var text: String
    var memes: [Meme]
    let size: CGFloat = 150
    
    @State var isPinned = false
    @State private var currentIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var uiImage: UIImage? = nil
    
    // Thumbnail cycle interval
    let interval: TimeInterval = 10.0

    var body: some View {
        NavigationLink(destination: FolderView(header: text)) {
            ZStack {
                VStack {
                    ZStack {
                        if !memes.isEmpty {
                            ZStack {
                                let x: UIImage = uiImage ?? UIImage(systemName: "person.circle.fill")!
                                
                                Image(uiImage: x)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill) // Make the image fill the space
                                    .frame(width: size, height: size)
                                    .clipped() // Ensure no overflow
                                    .cornerRadius(18)
                                    .shadow(radius: 4)
//                                ForEach(Array(memes.indices), id: \.offset) { index, meme in
//                                    if index == currentIndex {
//                                        let x: UIImage = uiImage ?? UIImage(systemName: "person.circle.fill")!
//                                        Image(uiImage: x)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fill) // Make the image fill the space
//                                            .frame(width: size, height: size)
//                                            .clipped() // Ensure no overflow
//                                            .cornerRadius(18)
//                                            .shadow(radius: 4)
//                                            .transition(.opacity.animation(.easeInOut(duration: 1))) // Smooth fade
////                                            .transition(.scale.combined(with: .opacity).animation(.easeInOut(duration: 0.5))) // Fade + Scale
////                                            .transition(.asymmetric(
////                                                insertion: .scale.animation(.easeOut(duration: 0.3)),
////                                                removal: .opacity.animation(.easeInOut(duration: 0.7))
////                                            )) //Pop Effect
////                                            .transition(.scale.combined(with: .opacity).animation(.easeInOut(duration: 0.5)))
//                                    }
//                                }
                            }
                            .task {
                                uiImage = await memes.first?.memeAsUIImage
                            }
                        } else {
                            // Fallback image for empty folders
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size, height: size)
                                .foregroundColor(.black)
                                .background(.white)
                                .cornerRadius(18)
                                .shadow(radius: 4)
                        }
                    }

                    Text(text.capitalized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 3)
                }
                .padding(.vertical, 20)

                if isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 35))
                        .shadow(color: .black, radius: 4, x: 0, y: 0)
                        .offset(x: -65, y: -size / 2 - 13)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startTimer() {
        if !memes.isEmpty {
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % memes.count
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct SearchBar: View {
    var text: String
    @Binding var searchText: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                TextField(text, text: $searchText)
                    .padding(8)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(18)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 23)
    }
}

struct PageHeader: View {
    var text: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(text)
            .font(.system(size: 45, weight: .semibold, design: .rounded))
            .padding(.top, 10)
            .padding(.bottom, 15)
            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
    }
}

struct MemeDescriptionField: View {
    @Binding var memeDescription: String
    @Environment(\.colorScheme) var colorScheme // Detect light or dark mode

    var body: some View {
        VStack {
            TextField("Describe a meme to create!", text: $memeDescription)
                .padding()
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(15)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 20)
        }
    }
}


struct GenerateMemeButton: View {
    @Binding var isClicked: Bool
    @Binding var memeDescription: String
    var isEnabled: Bool
    var showAlertAction: () -> Void
    @Binding var memeImage: UIImage?
    @Binding var isLoading: Bool // Add loading state binding
    @Environment(\.colorScheme) var colorScheme // Detect light or dark mode

    var body: some View {
        Button(action: {
            if isEnabled {
                print("Generate meme with Dalle3 AI!")
                isLoading = true // Start loading
                Task {
                    let generatedImage = await generateMeme(description: memeDescription)
                    guard let generatedImage else {
                        logger.error("ERROR GENERATING IMAGE")
                        isLoading = false // Stop loading if generation fails
                        return
                    }
                    memeImage = generatedImage
                    isLoading = false // Stop loading
                    isClicked = true
                }
            } else {
                // Trigger alert if no description
                showAlertAction()
            }
        }) {
            Text("Generate with Dalle3 AI")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? Color(UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0)) : Color(UIColor(red: 104/255, green: 86/255, blue: 182/255, alpha: 1.0))) // Text color contrast
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    isLoading
                        ? Color.gray // Loading state color
                    : (colorScheme == .dark ? Color.black : Color.white) // Dynamic background color
                )                .cornerRadius(10)
                .padding(.horizontal, 80)
                .padding(.bottom, 30)
        }
        .disabled(isLoading) // Disable button while loading
        Spacer().frame(height: 40)
    }
}


struct MemeImageView: View {
    let image: UIImage

    var body: some View {
        // This lets you make the image have rounded corners and fill the space
        // between the content above and below it. However, the image's aspect ratio
        // will change (probably zoom in or out)
        /*
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: geometry.size.width * 0.9, // Full width of the screen
                    height: geometry.size.height * 1 // Force height to 70% of available space
                )
                .cornerRadius(20)
                .shadow(radius: 7)
        }
         */
        
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: geometry.size.width * 0.9, maxHeight: geometry.size.height * 0.97)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            // .cornerRadius(100)
                .shadow(radius: 7)
        }
    }
}
