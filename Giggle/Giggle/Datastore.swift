//
//  Datastore.swift
//  Giggle
//
//  Created by Matthew Drutis on 10/29/24.
//

import SwiftData
import NaturalLanguage
import SwiftUI
import OSLog

 // Utility Class
class DataManager {
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

    static func getInfo(for image: UIImage) async -> ([Tag], String){
        // Dummy values loaded for searching
        // load each image in then change tags and rebuild and load new image in until done.
//
//        var tags = ["funny", "cute", "dog", "doberman"] //change to whatever tags you want image to be
//
//        // convert all tags to lowercase and remove whitespace
//        tags = tags.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
//
//        return (tags.map { Tag(name: $0) }, "Sample content based on image") // Mock data for now

        // Dummy values loaded for searching

        // commment below this out for dummy
        // Convert image to PNG data and base64 encode
        guard let pngData = try? convertImageToPNG(image) else {
            return ([], "Image conversion failed")
        }

        let base64Image = pngData.base64EncodedString()

        // Prepare the URL and request
        let url = URL(string: "https://3.138.136.6/imageInfo/?numTags=10&contentLength=200")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create JSON payload
        let body = [["Id": UUID().uuidString, "imageFile": base64Image]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)

        // Debug: Print the JSON body
        if let httpBody = request.httpBody {
            print("Request Body: ", String(data: httpBody, encoding: .utf8) ?? "Invalid body")
        }

        // Perform the request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            // Debug: Check if data is received and print it
            print("Received Data:", String(data: data, encoding: .utf8) ?? "Invalid data")

            // Parse the response data
            if let responseArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstResult = responseArray.first,
               let tags = firstResult["tags"] as? [String],
               let content = firstResult["content"] as? String {
                return (tags.map { Tag(name: $0) }, content)
            } else {
                print("Parsing Error: Response array is nil or has unexpected format")
            }
        } catch {
            print("Error in getInfo: \(error)")
        }
        return ([], "Error retrieving info") // Return empty data on failure
        // until here
    }

    static func saveContext(context: ModelContext, success_message: String, fail_message: String, id: UUID) {
        do {
            try context.save()
            print(success_message)
        } catch {
            logger.error("\(fail_message) for Meme \(id): \(error.localizedDescription)")
        }
    }

    // Used for testing
    static func clearDB(context: ModelContext) {
        do {
            try context.delete(model: Meme.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

func generateMeme(description: String) async -> UIImage? {
    let urlString = "https://3.138.136.6/generateMeme/?description=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
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
    let url = URL(string: "https://3.138.136.6/redoGeneration")!
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
