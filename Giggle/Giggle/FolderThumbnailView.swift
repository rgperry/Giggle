//
//  FolderThumbnailView.swift
//  Giggle
//
//  Created by Tamaer Alharastani on 11/21/24.
//

import SwiftUI

struct FolderThumbnailView: View {
    var memes: [Meme] // Pass the memes for the folder
    @State private var currentIndex: Int = 0
    @State private var timer: Timer? = nil

    let interval: TimeInterval = 2.0 // Time interval for cycling images

    var body: some View {
        ZStack {
            if !memes.isEmpty {
                GiggleItem(meme: memes[currentIndex % memes.count]) // Use existing GiggleItem
                    .frame(width: 100, height: 100) // Adjust thumbnail size
                    .clipped()
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo") // Fallback image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
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
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            currentIndex = (currentIndex + 1) % (memes.count) // Cycle through memes
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
