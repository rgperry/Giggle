//
//  SettingsView.swift
//  Giggle
//
//  Created by Karan Arora on 11/10/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var numberOfEntries: String = ""

    var body: some View {
        VStack {
            PageHeader(text: "Settings")

            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Number of Entries:")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.leading, 20)

                TextField("Enter number of entries", text: $numberOfEntries)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
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
