import SwiftUI

struct GenerateMemeView: View {
    var body: some View {
        VStack {
            // Main Header Component (reuse existing one)
            MainHeader(text: "Giggle")
            
            Spacer()
            
            // Question Mark Image Component
            QuestionMarkImage()
            
            Spacer()
            
            // Meme Description Text Field
            MemeDescriptionField()
            
            // Generate Meme Button
            GenerateMemeButton()
            
            Spacer()
            
            // Bottom Navigation Bar (no arguments needed)
            BottomNavBar()
        }
        .background(Color.purple.ignoresSafeArea()) // Background color
    }
}

// Enum to represent different tabs
enum Tab {
    case home, add, edit, settings
}

// Component: Question Mark Image
struct QuestionMarkImage: View {
    var body: some View {
        Image(systemName: "questionmark.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .foregroundColor(.white)
    }
}

// Component: Meme Description Text Field
struct MemeDescriptionField: View {
    @State private var memeDescription: String = ""
    
    var body: some View {
        TextField("Describe the meme you want to create!", text: $memeDescription)
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 20)
    }
}

// Component: Generate Meme Button
struct GenerateMemeButton: View {
    var body: some View {
        Button(action: {
            // Action for generating meme
            print("Generate meme with Dalle3 AI!")
        }) {
            Text("Generate with Dalle3 AI")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

// Component: Bottom Navigation Bar (manage its own state)
struct BottomNavBar: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 80)
                .shadow(radius: 2)

            HStack {
                Spacer()

                BottomNavBarIcon(systemIconName: "house", tab: .home, selectedTab: $selectedTab)
                Spacer()

                BottomNavBarIcon(systemIconName: "plus", tab: .add, selectedTab: $selectedTab)
                Spacer()

                BottomNavBarIcon(systemIconName: "pencil", tab: .edit, selectedTab: $selectedTab)
                Spacer()

                BottomNavBarIcon(systemIconName: "gearshape", tab: .settings, selectedTab: $selectedTab)
                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }
}

struct BottomNavBarIcon: View {
    var systemIconName: String
    var tab: Tab
    @Binding var selectedTab: Tab
    let size: CGFloat = 30

    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Image(systemName: systemIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(selectedTab == tab ? .blue : .black)
        }
    }
}

#Preview {
    GenerateMemeView()
}
