//
//  GenerateMemeView.swift
//  Giggle
//
//  Created by Griffin Gong on 10/27/24.
//

import SwiftUI

struct GenerateMemeView: View {
    var body: some View {
        VStack {
            
            QuestionMarkImage()
            
            MemeDescriptionField()
            
            GenerateMemeButton()
            
            BottomNavBar()
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
    }
}

#Preview {
    GenerateMemeView()
}
