//
//  datastore.swift
//  Giggle
//
//  Created by Matthew Drutis on 10/29/24.
//
import SwiftData
import NaturalLanguage
import SwiftUI

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

// This isn't being used now, but if we wanted to do search solely based on tags, we could with this.
@Model
class Tag {
    @Attribute(.unique) var name: String
    @Relationship var memes: [Meme]
    
    init(name: String) {
        self.name = name
        self.memes = []
    }
//    // Computed property to get the memes with this tag
//    var memesWithThisTag: [Meme] {
//        return memes.filter { $0.tags.contains(self) }
//    }
}

@Model
class Meme {
    @Attribute(.externalStorage) var image: Data?
    @Attribute(.unique) var id: UUID
    @Relationship(inverse: \Tag.memes) var tags: [Tag]
    var dateAdded: Date
    var content: String
    
    // Initializer
    init(content: String, tags: [Tag] = [], image: UIImage, id: UUID? = nil) {
        // Use the provided id or generate a new UUID if none is provided
        self.id = id ?? UUID()
        self.dateAdded = Date()
        self.content = content
        self.tags = tags
        do {
            self.image = try convertImageToPNG(image)
        } catch {
            logger.error("Image conversion failed for \(self.id)")
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

extension Meme {
    func addTag(_ tagName: String) {
        let tag = Tag(name: tagName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
        if !tags.contains(where: { $0.name == tag.name }) {
            tags.append(tag)
        }
    }

    func removeTag(_ tagName: String) {
        let tagName = tagName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        tags.removeAll { $0.name == tagName }
    }
}

 // Utility Class
class DataManager {
    static func findSimilarEntries(query: String, context: ModelContext, limit: Int = 10) -> [Meme] {
        logger.debug("searching for similar entries \(query)")
        let embedding = NLEmbedding.sentenceEmbedding(for: .english)
        guard let embedding = embedding else {
            return []
        }
        
        // Fetch all entries
        let descriptor = FetchDescriptor<Meme>()
        guard let entries = try? context.fetch(descriptor) else { return [] }
        
        
        // Calculate distances and sort
        let entriesWithDistances = entries.compactMap { entry -> (Meme, Double)? in
            let memeAsText = entry.content + " With tags " + entry.tags.map { $0.name }.joined(separator: ", ")
            
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
        // Loop through each image
        for (_, image) in images.enumerated() {
            // Retrieve tags and content for each image
            let (tags, content) = await DataManager.getInfo(for: image)
            
            let meme = Meme(content: content, tags: tags, image: image)
            context.insert(meme)
        }
        
        do {
            try context.save()
            logger.error("successfully saved \(images.count) memes")
        } catch {
            logger.error("Error in storeMemes: \(error.localizedDescription)")
        }
        completion()
    }

    static func getInfo(for image: UIImage) async -> ([Tag], String){
        // Replace this with your actual tagging logic
        
        var tags = ["funny", "cute", "dog", "doberman"]
        
        // convert all tags to lowercase and remove whitespace
        tags = tags.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        
        return (tags.map { Tag(name: $0) }, "Sample content based on image") // Mock data for now
    }
    
    // this could be useful for testing
    static func clearDB(context: ModelContext) {
        do {
            try context.delete(model: Meme.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

// TODO
func generateMeme(description: String) async -> (UIImage) {
    // call backend to generate meme
    return UIImage()
}

// TODO
func regenerateMeme(description: String, prevImage: UIImage) async -> (UIImage) {
    // call backend to generate meme
    return UIImage()
}



