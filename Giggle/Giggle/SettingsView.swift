//
//  SettingsView.swift
//  Giggle
//
//  Created by Karan Arora on 11/10/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("numSearchResults") private var numSearchResults: Double = 10
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack {
            PageHeader(text: "Settings")

            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Number of Search Results to Display:")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                
                Text("\(Int(numSearchResults))")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                Slider(value: $numSearchResults, in: 10...50, step: 1)
                    .padding(.horizontal, 40)
                    .tint(.white)

                // Button that triggers async function
                Button(action: {
                    // Using Task to call the async function
                    DataManager.clearDB(context: context)
                }) {
                    Text("Delete all giggles")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)

            }
            .padding()
            .padding(.top, -10)

            BottomNavBar().frame(maxHeight: .infinity, alignment: .bottom)
        }
        .background(Colors.backgroundColor.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    SettingsView()
}
