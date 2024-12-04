//
//  Models.swift
//  Giggle
//
//  Created by Matthew Drutis
//

import SwiftUI
import NaturalLanguage
import SwiftData
import OSLog

// here is my main reference for swiftData (youtube playlist from tundsdev)
// https://www.youtube.com/watch?v=kLNNNXD8X2U&list=PLvUWi5tdh92wZ5_iDMcBpenwTgFNan9T7&index=1

// This is the link to the swiftData docs, which I also used for this
// https://developer.apple.com/documentation/swiftdata

let logger = Logger()

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
public class Meme {
    @Attribute(.externalStorage) var image: Data?
    @Attribute(.unique) public var id: UUID
    @Relationship(inverse: \Tag.memes) var tags: [Tag]
    
    var dateAdded: Date
    var dateLastShared: Date?
    var content: String
    var favorited: Bool = false
    var dateFavorited: Date?

    init(content: String, tags: [Tag] = [], image: UIImage, id: UUID? = nil, favorited: Bool = false) {
        // Use the provided id or generate a new UUID if none is provided
        self.id = id ?? UUID()
        self.dateAdded = Date()
        
        self.dateLastShared = nil
        self.content = content
        self.tags = tags
        
        self.favorited = favorited
        
        if self.favorited {
            self.dateFavorited = Date()
        } else {
            self.dateFavorited = nil
        }
        
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
    
    func toggleFavorited() {
        self.favorited.toggle()
        
        if self.favorited {
            self.dateFavorited = Date()
        } else {
            self.dateFavorited = nil
        }
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
