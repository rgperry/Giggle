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

enum ImageConversionError: Error {
    case imageNotFound
    case pngConversionFailed
}

func convertImageToPNG(_ uiImage: UIImage?) throws -> Data {
    guard let image = uiImage else {
        throw ImageConversionError.imageNotFound
    }
    guard let pngData = image.pngData() else {
        throw ImageConversionError.pngConversionFailed
    }
    return pngData
}

@Model
class Meme {
    @Attribute(.unique) var id: UUID
    var dateAdded: Date
    var tags: [String]
    var content: String
    @Attribute(.externalStorage) var image: Data?

    // Initializer
    init(content: String, tags: [String] = [], image: UIImage, id: UUID? = nil) {
        // Use the provided id or generate a new UUID if none is provided
        self.id = id ?? UUID()
        self.dateAdded = Date()
        self.content = content
        self.tags = tags
//        self.image = try? convertImageToPNG(image)
        do {
            self.image = try convertImageToPNG(image)
        } catch {
            print("Image conversion failed for \(self.id)")
            self.image = try? convertImageToPNG(UIImage(systemName: "photo"))
        }
    }
    // Computed property to get the UIImage from image Data
    var imageAsUIImage: UIImage {
        guard let imageData = image else {
            return UIImage(systemName: "photo") ?? UIImage()
        }
        return UIImage(data: imageData) ?? UIImage()
    }
}

 // Utility Class
class DataManager {
    static func findSimilarEntries(query: String, context: ModelContext, limit: Int = 10) -> [Meme] {
        print("searching for similar entries \(query)")
        let embedding = NLEmbedding.sentenceEmbedding(for: .english)
        guard let embedding = embedding else {
            return []
        }
        
        // Fetch all entries
        let descriptor = FetchDescriptor<Meme>()
        guard let entries = try? context.fetch(descriptor) else { return [] }
        
        
        // Calculate distances and sort
        let entriesWithDistances = entries.compactMap { entry -> (Meme, Double)? in
            let memeAsText = entry.content + " With tags " + entry.tags.joined(separator: ", ")
            
            let distance = embedding.distance(
                between: query,
                and: memeAsText,
                distanceType: .cosine
            )
            return (entry, distance)
        }
        
        // Sort by similarity (lower distance = more similar)
        let sortedEntries = entriesWithDistances
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { $0.0 }
        
        return sortedEntries
    }
    
    // Decorated with @MainActor to avoid concurrency issues with passing down the model context
    @MainActor
    static func storeMemes(context: ModelContext, images: [UIImage], completion: @escaping () -> Void) async {
//        print("begin loading the memes")
        // Loop through each image
        for (_, image) in images.enumerated() {
//            print("Loading image #\(i)")
            // Retrieve tags and content for each image
            let (tags, content) = await DataManager.getInfo(for: image)
            
            let meme = Meme(content: content, tags: tags, image: image)
            context.insert(meme)
        }
        
        do {
            try context.save()
            print("successfully saved \(images.count) memes")
        } catch {
            print("Error in storeMemes: \(error.localizedDescription)")
        }
        completion()
    }

    // Placeholder for an async function that retrieves tags and content for an image
    static func getInfo(for image: UIImage) async -> ([String], String){
        // Replace this with your actual tagging logic
        return (["funny", "cute", "dog", "doberman"], "Sample content based on image") // Mock data for now
    }
    
    // this could be useful for testing
    static func clearDB(context: ModelContext) {
        do {
            try context.delete(model: Meme.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
        
    // TODO add a helper to update an image, when the tags are changed
    static func addTag(context: ModelContext, imageID: String, tagsToAdd: [String]) -> () {
        
    }
    
    static func removeTag(context: ModelContext, imageID: String, tagsToRemove: [String]) -> () {
        
    }
    
    
}
