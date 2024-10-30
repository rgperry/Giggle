//
//  datastore.swift
//  Giggle
//
//  Created by Matthew Drutis on 10/29/24.
//
import SwiftData
import NaturalLanguage
import SwiftUI

// May need a separate @Model for each tag, depending on how we execute the search?

@Model
class Meme {
    @Attribute(.unique) var id: UUID
    var dateAdded: Date
    var tags: [String]
    var content: String
    var image: UIImage

    init(content: String, tags: [String] = [], image: UIImage) {
        self.id = UUID()
        self.dateAdded = Date()
        self.content = content
        self.tags = tags
        self.image = image
    }
}

// Utility Class
class DataManager {
    static func findSimilarEntries(query: String, in context: ModelContext, limit: Int = 10) -> [Meme] {
        let embedding = NLEmbedding.sentenceEmbedding(for: .english)
        guard let embedding = embedding else {
            return []
        }
        
        // Fetch all entries
        let descriptor = FetchDescriptor<Meme>()
        guard let entries = try? context.fetch(descriptor) else { return [] }
        
        // Calculate distances and sort
        let entriesWithDistances = entries.compactMap { entry -> (Meme, Double)? in
            
            let distance = embedding.distance(
                between: query,
                and: entry.content,
                distanceType: .cosine
            )
            return (entry, distance)
        }
        
        // Sort by similarity (lower distance = more similar)
        let sortedEntries = entriesWithDistances
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { $0.0 }
        
        return Array(sortedEntries)
    }
    static func storeMemes(in context: ModelContext, images: [UIImage]) async {
        // Loop through each image
        for image in images {
            // Retrieve tags and content for each image
            let (tags, content) = await DataManager.getInfo(for: image)
            
             let meme = Meme(content: content, tags: tags, image: image)
             context.insert(meme)
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    // Placeholder for an async function that retrieves tags and content for an image
    static func getInfo(for image: UIImage) async -> ([String], String) {
        // Replace this with your actual tagging logic
        return (["funny", "cute", "dog", "doberman"], "Sample content based on image") // Mock data for now
    }
    
    // this could be useful for testing
    static func clearDB(in context: ModelContext) {
        do {
            try context.delete(model: Meme.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
        
    // TODO add a helper to update an image, when the tags are changed
    static func updateImage(imageID: String) async -> () {
        
    }
    
    
}
