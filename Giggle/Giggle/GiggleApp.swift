//
//  GiggleApp.swift
//  Giggle
//
//  Created by Karan Arora on 10/25/24.
//

// FINISH: not sure if we need this or what it does. Probably delete

import SwiftUI
import SwiftData

@main
struct GiggleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

