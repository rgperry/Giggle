//
//  GenerateMemeView.swift
//  Giggle
//
//  Created by Griffin Gong on 11/10/24.
//

import SwiftUI

struct GenerateMemeView: View {
    @State private var memeDescription: String = ""
    @State private var isClicked = false
    @State private var showAlert = false
    @State private var memeImage: UIImage? = nil

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")
                QuestionMark()
                MemeDescriptionField(memeDescription: $memeDescription)

                GenerateMemeButton(
                    isClicked: $isClicked,
                    memeDescription: $memeDescription,
                    isEnabled: !memeDescription.isEmpty,
                    showAlertAction: { showAlert = true },
                    memeImage: $memeImage
                )
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Missing Description"),
                        message: Text("Please enter a meme description."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
            .navigationDestination(isPresented: $isClicked) {
                MemeCreatedView(memeDescription: memeDescription, memeImage: $memeImage)
            }
        }
        .tint(.black)
        .navigationBarHidden(true)
    }
}

struct QuestionMark: View {
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

//#Preview {
//    GenerateMemeView()
//}
