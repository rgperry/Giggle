//
//  SettingsView.swift
//  Giggle
//
//  Created by Karan Arora on 11/10/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var numberOfResults: Double = 10

    var body: some View {
        VStack {
            PageHeader(text: "Settings")

            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Number of Search Results to Display:")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                
                Text("\(Int(numberOfResults))")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                Slider(value: $numberOfResults, in: 10...50, step: 1)
                    .padding(.horizontal, 40)
                    .tint(.white)
                
            }
            .padding()
            .padding(.top, -10)

            BottomNavBar().frame(maxHeight: .infinity, alignment: .bottom)
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
    }
}

#Preview {
    SettingsView()
}
