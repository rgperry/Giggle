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
import AVFoundation

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
class Meme {
    @Attribute(.externalStorage) var mediaData: Data? //xxxxx
    @Attribute(.unique) var id: UUID
    @Relationship(inverse: \Tag.memes) var tags: [Tag]
    
    var dateAdded: Date
    var dateLastShared: Date?
    var content: String
    var favorited: Bool = false
    var dateFavorited: Date?
    var mediaType: MediaType

    enum MediaType: String, Codable {
        case image
        case gif
        case video
    }

    init(content: String, tags: [Tag] = [], media: MemeMedia, id: UUID? = nil) {
        // Use the provided id or generate a new UUID if none is provided
        self.id = id ?? UUID()
        self.dateAdded = Date()
        
        self.dateLastShared = nil
        self.content = content
        self.tags = tags
        
        self.favorited = false
        self.dateFavorited = nil
        
        switch media {
        case .image(let image):
            self.mediaType = .image
            do {
                self.mediaData = try convertImageToPNG(image)
            } catch {
                logger.error("Image conversion failed for \(self.id)")
                self.mediaData = try? convertImageToPNG(UIImage(systemName: "photo"))
            }
        case .gif(let url), .video(let url):
            self.mediaType = media == .gif(url) ? .gif : .video
            do {
                self.mediaData = try Data(contentsOf: url) //Not sure if this is bad to store all this data here xxxxxxxxxxxxxxxxxxxxxxx
            } catch {
                logger.error("Failed to load media data from \(url) for \(self.id)")
                self.mediaData = nil
            }
        }
    }
    
    // Computed property to get the UIImage from meme Data
    var memeAsUIImage: UIImage { //imageAsUIImage
        get async {
            switch mediaType {
            case .image:
                guard let imageData = mediaData else {
                    return UIImage(systemName: "photo") ?? UIImage()
                }
                return UIImage(data: imageData) ?? UIImage()
            case .gif, .video:
                return await extractFirstFrame(fromMediaAt: mediaData) ?? UIImage(systemName: "video") ?? UIImage()
            }
        }
    }
    
    //https://developer.apple.com/documentation/avfoundation/avassetimagegenerator
    private func extractFirstFrame(fromMediaAt data: Data?) async -> UIImage? {
        guard let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return nil }
        
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true // Fix orientation of video
        
        do {
            let image = try await imageGenerator.image(at: CMTime.zero)
            return UIImage(cgImage: image.image)
        } catch {
            print("Failed to extract first frame: \(error)")
            return nil
        }
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
