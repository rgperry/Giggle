import SwiftUI
import SwiftData


// TODO
// Make ContentView a wrapper?
// Put components in different files for better organization - semi-done

struct ContentView: View {
    var body: some View {
        TabView {
            // Home Screen
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            // Add Screen
            AddView()
                .tabItem {
                    Image(systemName: "plus")
                    Text("Add")
                }

            // Edit (Generate Meme) Screen
            GenerateMemeView()
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Edit")
                }

            // Settings Screen
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(.black) // Customize the color of the selected tab icon
    }
}

// Home Screen
struct HomeView: View {
    let gridItems = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")
                SearchBar(text: "Search for a Giggle")

                ScrollView {
                    LazyVGrid(columns: GridStyle.grid, spacing: GridStyle.folderRowPadding) {
                        FolderItem(text: "Favorites", isPinned: true)
                        FolderItem(text: "Recently Shared", isPinned: true)
                        FolderItem(text: "All Giggles", isPinned: true)
                        FolderItem(text: "Sad")
                        FolderItem(text: "Sports")
                        FolderItem(text: "Surprised")
                    }
                    .padding(.horizontal, GridStyle.columnPadding)
                    .padding(.top, GridStyle.searchBarPadding)
                }

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
        }.tint(.black)
    }
}

struct PinIcon: View {
    var body: some View {
        Image(systemName: "pin.fill")
            .foregroundColor(.gray)
            .font(.system(size: 35))
            .offset(x: -71, y: -80)

        .background(Color(red: 104/255, green: 86/255, blue: 182/255).ignoresSafeArea())
    }
}

// Add Screen Placeholder
struct AddView: View {
    var body: some View {
        VStack {
            MainHeader(text: "Add")
            Spacer()
            Text("Add Content Goes Here")
            Spacer()
        }
        .background(Color.purple.ignoresSafeArea())
    }
}

// Generate Meme Screen
struct GenerateMeme: View {
    var body: some View {
        VStack {
            MainHeader(text: "Generate Meme")
            Spacer()
            Text("Generate Meme Content Goes Here")
            Spacer()
        }
        .background(Color.purple.ignoresSafeArea())
    }
}

// Settings Screen Placeholder
struct SettingsView: View {
    var body: some View {
        VStack {
            MainHeader(text: "Settings")
            Spacer()
            Text("Settings Content Goes Here")
            Spacer()
        }
        .background(Color.purple.ignoresSafeArea())
    }
}

// Reusable Components (MainHeader, ItemView, SearchBar, etc.)
struct ItemView: View {
    var title: String
    let size: CGFloat = 140

    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(radius: 4)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

struct SearchBar: View {
    var text: String

    var body: some View {
        HStack {
            HStack {
                TextField(text, text: .constant(""))
                    .padding(8)
                    .foregroundColor(.black)

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 23)
    }
}

struct MainHeader: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 45, weight: .semibold, design: .default))
            .padding(.top, 10)
            .padding(.bottom, 15)
            .foregroundColor(.white)
            .tracking(1)
    }
}

#Preview {
    ContentView()
}
