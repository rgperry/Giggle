//
//  ContentView.swift
//  Giggle
//
//  Created by Karan Arora on 10/25/24.
//

import SwiftUI
import SwiftData

//struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}


struct ContentView: View {
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())] // For a 2-column grid
    
    var body: some View {
        VStack {
            // Title
            Text("Giggle")
                .font(.largeTitle)
                .padding(.top, 30)
                .padding(.bottom, 10)
            
            // Search Bar
            HStack {
                TextField("Search for a Giggle", text: .constant(""))
                    .padding(.horizontal)
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
            .padding(.horizontal, 20)
            
            // Grid View for Giggles
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    // Dummy data - replace with your dynamic content
                    GiggleItemView(title: "Favorites")
                    GiggleItemView(title: "Recently Shared")
                    GiggleItemView(title: "All Giggles")
                    GiggleItemView(title: "Sports")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Bottom Tab Bar
            HStack {
                TabBarIcon(systemIconName: "house", tabName: "Home")
                TabBarIcon(systemIconName: "plus", tabName: "Add")
                TabBarIcon(systemIconName: "pencil", tabName: "Edit")
                TabBarIcon(systemIconName: "gearshape", tabName: "Settings")
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.purple.ignoresSafeArea())
    }
}

// Reusable GiggleItem View for the grid
struct GiggleItemView: View {
    var title: String
    
    var body: some View {
        VStack {
            // Replace with your actual images
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

// Reusable TabBarIcon View for the bottom navigation
struct TabBarIcon: View {
    var systemIconName: String
    var tabName: String
    
    var body: some View {
        VStack {
            Image(systemName: systemIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .padding(.top, 10)
            Text(tabName)
                .font(.caption)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

// Preview
struct GiggleHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
