import SwiftUI
import SwiftData

struct ContentView: View {
    let gridItems = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)] // Adjusting spacing for a 2-column grid
    
    var body: some View {
        VStack {
            // Title
            Text("Giggle")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 30)
                .padding(.bottom, 10)
            
            // Custom Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for a Giggle", text: .constant(""))
                        .padding(8)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(20)  // Rounded corners
                .shadow(radius: 2)
            }
            .padding(.horizontal, 20)
            
            // Grid View for Giggles
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 40) {
                    GiggleItemView(title: "Favorites")
                    GiggleItemView(title: "Recently Shared")
                    GiggleItemView(title: "All Giggles")
                    GiggleItemView(title: "Sports")
                }
                .padding(.horizontal, 40) // Increase padding for more space
                .padding(.top, 20)
            }
            
            // Bottom Tab Bar
            HStack {
                TabBarIcon(systemIconName: "house", tabName: "Home")
                TabBarIcon(systemIconName: "plus", tabName: "Add")
                TabBarIcon(systemIconName: "pencil", tabName: "Edit")
                TabBarIcon(systemIconName: "gearshape", tabName: "Settings")
            }
            .padding(.horizontal, 10)
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
            // Consistent image size for all grid items
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100) // Same image size for all
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(12) // Consistent corner radius for all items
                .shadow(radius: 3) // Same shadow effect for all items
            
            // Consistent font size for all grid items
            Text(title)
                .font(.headline) // Same font size for all items
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
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
