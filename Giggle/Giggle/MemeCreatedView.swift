//
//  MemeCreatedView.swift
//  Giggle
//
//  Created by Griffin Gong on 10/27/24.
//

import SwiftUI

struct MemeCreatedView: View {
    var memeDescription: String

    var body: some View {
        VStack {
            PageHeader(text: "Giggle")

            MemeImageView()
            
            ActionButtonsView()
            
            MemeDescriptionField(memeDescription: .constant(memeDescription))
            
            GenerateMemeButton(isClicked:.constant(false), isEnabled: true, showAlertAction: {})
            
            BottomNavBar()
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
    }
}

#Preview {
    MemeCreatedView(memeDescription: "Sample Meme Description")
}
