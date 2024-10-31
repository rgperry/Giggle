import SwiftUI

struct MemeInfoView: View {
    var memeImage: Image
    var tags: [String]
    var dateSaved: String
    var source: String

    @State private var isLiked = false
    @State private var navigateToAllGiggles = false

    var body: some View {
        NavigationStack {
            VStack {
                PageHeader(text: "All Giggles")
                
                MemeImageView()
                
                // Directly calling Tags component
                Tags(tags: tags)
                
                // More Info View
                MoreInfo(dateSaved: dateSaved, source: source)
                
                // Delete Button
                DeleteButton(deleteAction: {
                    navigateToAllGiggles = true
                })
                
                // Like Button
                LikeButton(isLiked: $isLiked)
            
                BottomNavBar()
                
            }
            .background(Colors.backgroundColor.ignoresSafeArea())
            .navigationDestination(isPresented: $navigateToAllGiggles) {
                FolderView(header: "All Giggles")
            }
        }
    }
}

#Preview {
    MemeInfoView(
        memeImage: Image("exercise_meme"),
        tags: ["dog", "exercise", "fat"],
        dateSaved: "10/7/24",
        source: "Dalle3"
    )
}
