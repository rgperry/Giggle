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
            
            if let text = text {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct SearchBar: View {
    var text: String
    
    var body: some View {
        HStack {
            HStack {
                TextField(text, text: .constant(""))
                    .padding(8)
                    .foregroundColor(.black)
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 23)
    }
}

struct BottomNavBar: View {
    var body: some View {
        HStack {
            BottomNavBarIcon(icon: "house.fill")
            BottomNavBarIcon(icon: "plus")
            BottomNavBarIcon(icon: "paintbrush.fill")
            BottomNavBarIcon(icon: "gearshape.fill")
        }
        .padding(.horizontal, 10)
    }
}

struct BottomNavBarIcon: View {
    var icon: String
    let size: CGFloat = 42

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
