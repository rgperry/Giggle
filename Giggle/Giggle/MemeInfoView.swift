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
                
                Tags(tags: tags)
                
                MoreInfo(dateSaved: dateSaved, source: source)
                
                
                DeleteButton(deleteAction: {
                    navigateToAllGiggles = true
                })
                
                // LikeButton directly in MemeInfoView
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
