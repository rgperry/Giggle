import SwiftUI

struct MemeCreatedView: View {
    @State var memeDescription: String
    @State private var navigateToGenerateMemeView = false
    @State private var navigateToMemeCreatedView = false
    @State private var navigateToAllGiggles = false
    
    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "Giggle")

                MemeImageView()

                ActionButtonsView(
                    downloadAction: {
                        navigateToAllGiggles = true
                    },
                    refreshAction: {
                        navigateToMemeCreatedView = true
                    },
                    deleteAction: {
                        navigateToGenerateMemeView = true
                    }
                )
                
                MemeDescriptionField(memeDescription: $memeDescription)

                GenerateMemeButton(isClicked: .constant(false), isEnabled: true, showAlertAction: {})

                BottomNavBar()
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
            .navigationDestination(isPresented: $navigateToGenerateMemeView) {
                GenerateMemeView()
            }
            .navigationDestination(isPresented: $navigateToMemeCreatedView) {
                MemeCreatedView(memeDescription: memeDescription)
            }
            .navigationDestination(isPresented: $navigateToAllGiggles) {
                FolderView(header: "All Giggles")
            }
        }
    }
}

#Preview {
    MemeCreatedView(memeDescription: "Sample Meme Description")
}
