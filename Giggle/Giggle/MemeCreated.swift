//
//  MemeCreated.swift
//  Giggle
//
//  Created by Griffin Gong on 10/27/24.
//

import SwiftUI

struct GeneratedMemeView: View {
    var body: some View {
        VStack {
            // Main Header Component (reused)
            MainHeader(text: "Giggle")

            Spacer()

            // Generated Meme Image Component
            MemeImageView()

            Spacer()

            // Action Buttons (Download, Refresh, Delete)
            ActionButtonsView()

            // Meme Description Text Field (reused with new initial text)
            MemeDescriptionField()

            // Generate Meme Button (reused)
            GenerateMemeButton()

            Spacer()

            // Bottom Navigation Bar (reused)
            BottomNavBar()
        }
        .background(Color.purple.ignoresSafeArea()) // Background color
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
            ActionButton(iconName: "square.and.arrow.down")  // Download button
            ActionButton(iconName: "arrow.clockwise")        // Refresh button
            ActionButton(iconName: "xmark")                  // Delete button
        }
        .padding(.vertical, 20)
    }
}

// Component: Action Button
struct ActionButton: View {
    var iconName: String
    let size: CGFloat = 40

    var body: some View {
        Button(action: {
            // Add the appropriate action here
        }) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.white)
                .padding()
        }
    }
}

#Preview {
    GeneratedMemeView()
}
