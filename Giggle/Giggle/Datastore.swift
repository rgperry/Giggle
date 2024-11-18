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
        guard let apiUrl = URL(string: "https://3.138.136.6/imageInfo/") else {
            print("getInfo: bad url")
            return ([], "NO CONTENT")
        }
        
        struct ResponseBody: Decodable {
            let tags: [String] // Add the properties that match your API response
            let content: String
        }
        
        let response = try? await AF.upload(multipartFormData: { mpFD in
            if let jpegImage = image.jpegData(compressionQuality: 0.1) {
                mpFD.append(jpegImage, withName: "image", fileName: "giggleImage", mimeType: "image/jpeg")
            }
        }, to: apiUrl, method: .post).responseDecodable(of: [ResponseBody].self) { response in
            debugPrint(response)
        }
        // .serializingDecodable([ResponseBody].self).value
        return ([], "Nullish")
//        guard let firstResponse = response!.first else {
//            print("No response data in array")
//            return ([Tag(name: "HELP")], "No content generated")
//        }
//        
//        let tags = firstResponse.tags.map { Tag(name: $0) }
//        return (tags, firstResponse.content)
        
        
        
        
//        // Prepare the URL and request
//        let url = URL(string: "https://3.138.136.6/imageInfo/?numTags=10&contentLength=200")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Create JSON payload
//        let body = [["Id": UUID().uuidString, "imageFile": base64Image]]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
//        
//        // Debug: Print the JSON body
//        if let httpBody = request.httpBody {
//            print("Request Body: ", String(data: httpBody, encoding: .utf8) ?? "Invalid body")
//        }
//
//        // Perform the request
//        do {
//            let (data, _) = try await URLSession.shared.data(for: request)
//
//            // Debug: Check if data is received and print it
//            print("Received Data:", String(data: data, encoding: .utf8) ?? "Invalid data")
//            
//            // Parse the response data
//            if let responseArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
//               let firstResult = responseArray.first,
//               let tags = firstResult["tags"] as? [String],
//               let content = firstResult["content"] as? String {
//                return (tags.map { Tag(name: $0) }, content)
//            } else {
//                print("Parsing Error: Response array is nil or has unexpected format")
//            }
//        } catch {
//            print("Error in getInfo: \(error)")
//        }
//        return ([], "Error retrieving info") // Return empty data on failure
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
            try context.delete(model: Tag.self)
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
