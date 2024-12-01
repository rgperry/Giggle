//
//  Datastore.swift
//  Giggle
//
//  Created by Matthew Drutis on 10/29/24.
//

import SwiftData
import NaturalLanguage
import SwiftUI
import Alamofire

@ModelActor
actor MemeImportManager {
    func storeMemes(images: [UIImage], completion: @escaping () -> Void) async throws {
        guard !images.isEmpty else {
            logger.log("NO IMAGES TO IMPORT")
            return
        }
        
        let startTime = Date()
        
        try await withThrowingTaskGroup(of: Meme.self) { group in
            for image in images {
                group.addTask {
                    let (tags, content) = try await DataManager.getInfo(for: image)
                    
                    // Direct insertion without actor synchronization
                    let meme = Meme(content: content, tags: tags, image: image)
                    return meme
                }
            }
            
            for try await item in group {
                modelContext.insert(item)
            }
        }
        
        // Save outside of the task group
        try modelContext.save()
        
        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)
        let averageTime = totalTime / Double(images.count)
        
        print("Total Import Time: \(String(format: "%.2f", totalTime)) seconds")
        print("Average Time per Image: \(String(format: "%.2f", averageTime)) seconds")
        print("Total Images Imported: \(images.count)")
        
        completion()
    }
}

func memeSearchPredicate(for searchText: String) -> NSPredicate {
    NSPredicate { meme, _ in
        guard let meme = meme as? Meme, !searchText.isEmpty else { return false }
        
        // Check content for search text
        let matchesContent = meme.content.localizedCaseInsensitiveContains(searchText)
        
        // Split searchText into words
        let searchWords = searchText.split(separator: " ").map { String($0) }

        let matchesTags = meme.tags.contains { tag in
            // Check if any word in search query matches the tag
            searchWords.contains { word in
                tag.name.localizedCaseInsensitiveContains(word)
            }
        }
        
        // Include the meme if it matches either tag or content
        return matchesContent || matchesTags
    }
}

// Utility Class
class DataManager {
    // (no longer being used in the main app (may be useful though for sentiment search so I will leave it here for now))
    static func findSimilarEntries(query: String, context: ModelContext, limit: Int = 10, tagName: String?) -> [Meme] {
        logger.debug("searching for similar entries \(query)")
        let embedding = NLEmbedding.sentenceEmbedding(for: .english)
        guard let embedding = embedding else {
            return []
        }

        // Fetch all entries
        let descriptor = FetchDescriptor<Meme>()
        guard let entries = try? context.fetch(descriptor) else { return [] }

        // First filter by tag if tagName is provided
        let filteredEntries = tagName != nil ?
            entries.filter { meme in
                meme.tags.contains { $0.name == tagName }
            } : entries

        // Calculate distances and sort
        let entriesWithDistances = filteredEntries.compactMap { entry -> (Meme, Double)? in
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

    static func findSimilarEntries(query: String, memes: [Meme], limit: Int = 10, tagName: String?) -> [Meme] {
        logger.debug("searching for similar entries \(query)")
        let embedding = NLEmbedding.sentenceEmbedding(for: .english)
        guard let embedding = embedding else {
            return []
        }

        // First filter by tag if tagName is provided
        let filteredEntries = tagName != nil ?
        memes.filter { meme in
                meme.tags.contains { $0.name == tagName }
        } : memes

        // Calculate distances and sort
        let entriesWithDistances = filteredEntries.compactMap { entry -> (Meme, Double)? in
            let memeAsText = entry.content + " With tags " + entry.tags.map { $0.name }.joined(separator: ", ")

            let distance = embedding.distance(
                between: query,
                and: memeAsText,
                distanceType: .cosine
            )
            logger.log("\(distance)")
            // Only include entries with distance <= 1.27
//            guard distance <= 1.27 else {
//                return nil
//            }
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
        do {
            // Loop through each image
            for (index, image) in images.enumerated() {
                do {
                    // Retrieve tags and content for each image
                    let (tags, content) = try await DataManager.getInfo(for: image)
                    
                    let meme = Meme(content: content, tags: tags, image: image)
                    context.insert(meme)
                    
                    logger.info("Successfully processed image \(index + 1) of \(images.count)")
                } catch {
                    logger.error("Error processing image \(index + 1): \(error.localizedDescription)")
                    continue // This will skip the failed image and continue with others
                }
            }
            
            // Save all successfully processed memes
            try context.save()
            logger.info("Successfully saved \(images.count) memes")
            completion()
        } catch {
            logger.error("Error saving to context: \(error.localizedDescription)")
            completion()
        }
    }

    //Tamaer A. 11/12/24
    @MainActor
    static func loadMemes(completion: @escaping ([Meme]) -> Void) async {
        do {
            // Initialize ModelContainer and ModelContext the same way as in saveImageToDataStore
            let modelContainer = try ModelContainer(for: Meme.self, Tag.self)
            let modelContext = ModelContext(modelContainer)

            let fetchDescriptor = FetchDescriptor<Meme>()

            // Fetch Meme objects using the initialized modelContext
            let memes = try modelContext.fetch(fetchDescriptor)
            logger.log("Successfully loaded \(memes.count) memes")

            // Pass the fetched memes to the completion handler
            completion(memes)

        } catch {
            logger.error("Failed to initialize ModelContainer or load memes: \(error.localizedDescription)")
            completion([])
        }
    }

    static func getInfo(for image: UIImage) async throws -> ([Tag], String) {
        guard let apiUrl = URL(string: "https://18.223.212.43/imageInfo/?contentLength=100") else {
            print("getInfo: bad url")
            return ([], "NO CONTENT")
        }
        
        struct ResponseBody: Decodable {
            let tags: [String] // Add the properties that match your API response
            let content: String
        }
        
        let response = try await AF.upload(multipartFormData: { mpFD in
                if let jpegImage = image.jpegData(compressionQuality: 0.8) {
                    mpFD.append(jpegImage, withName: "image", fileName: "giggleImage.jpg", mimeType: "image/jpeg")
                }
        }, to: apiUrl, method: .post)
            .serializingDecodable(ResponseBody.self)
            .value
        
        debugPrint(response)
        let tags = response.tags.map { Tag(name: $0) }
        return (tags, response.content)
    }

    static func saveContext(context: ModelContext, success_message: String, fail_message: String, id: UUID) {
        do {
            try context.save()
            print(success_message)
        } catch {
            logger.error("\(fail_message) for Meme \(id): \(error.localizedDescription)")
        }
    }

    static func clearDB(context: ModelContext) {
        do {
            // Create fetch descriptors for both models
            let tagFetchDescriptor = FetchDescriptor<Tag>()
            let memeFetchDescriptor = FetchDescriptor<Meme>()
            
            // Fetch all tags
            let tags = try context.fetch(tagFetchDescriptor)
            
            // Delete all tags
            for tag in tags {
                context.delete(tag)
            }
            
            // Fetch all memes
            let memes = try context.fetch(memeFetchDescriptor)
            
            // Delete all memes
            for meme in memes {
                context.delete(meme)
            }
            
            // Save the context to persist the deletions
            try context.save()
        } catch {
            print("Error clearing database: \(error.localizedDescription)")
        }
    }
}

func generateMeme(description: String) async -> UIImage? {
    let urlString = "https://18.223.212.43/generateMeme/?description=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    guard let url = URL(string: urlString) else { return nil }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    } catch {
        print("Error in generateMeme: \(error)")
        return nil
    }
}

func regenerateMeme(description: String) async -> UIImage? {
    let url = URL(string: "https://18.223.212.43/redoGeneration")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = ["description": description]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)

    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let imageFile = json["imageFile"],
           let imageData = Data(base64Encoded: imageFile) {
            return UIImage(data: imageData)
        }
    } catch {
        print("Error in regenerateMeme: \(error)")
    }
    
    return nil // Return nil if the operation fails
}
