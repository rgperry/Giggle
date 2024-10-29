//
//  MemeCreatedView.swift
//  Giggle
//
//  Created by Griffin Gong on 10/27/24.
//

import SwiftUI

struct MemeCreatedView: View {
    var body: some View {
        VStack {
            QuestionMarkImage()
            
            ActionButtonsView()

            MemeDescriptionField()

            GenerateMemeButton()

            BottomNavBar()
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
    }
}


#Preview {
    MemeCreatedView()
}
