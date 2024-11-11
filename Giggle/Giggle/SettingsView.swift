//
//  SettingsView.swift
//  Giggle
//
//  Created by Karan Arora on 11/10/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var numberOfResults: Double = 10
    @Environment(\.modelContext) private var context
    @Query private var settings: [AppSettings]  // Expecting a single row

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
                    .onChange(of: numberOfResults) {
                        print("asdffghjihgbjuhgbnjuh")
                        if let settings = settings.first {
                            settings.num_results = Int(numberOfResults)
                            print("saving settings")
                            try? context.save()
                        }
                    }
                
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
