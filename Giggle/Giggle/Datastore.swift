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
                    // Decide if you want to continue with other images or return early
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

//    static func getInfo(for image: UIImage) async throws -> ([Tag], String) {
//        guard let apiUrl = URL(string: "https://3.138.136.6/imageInfo/") else {
//            print("getInfo: bad url")
//            return ([], "NO CONTENT")
//        }
//        
//        struct ResponseBody: Decodable {
//            let tags: [String]
//            let content: String
//        }
//        
//        var returnedResponse: ResponseBody
//        
//        let response = try await AF.upload(multipartFormData: { mpFD in
//            if let jpegImage = image.jpegData(compressionQuality: 0.8) {
//                mpFD.append(jpegImage, withName: "image", fileName: "giggleImage.jpg", mimeType: "image/jpeg")
//            }
//        }, to: apiUrl, method: .post).responseData { response in
//            guard let data = response.data, response.error == nil else {
//                logger.error("Networking error in getInfo")
//                return
//            }
//            if let httpStatus = response.response, httpStatus.statusCode != 200 {
//                print("imageInfo: HTTP STATUS: \(httpStatus.statusCode)")
//                return
//            }
//            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
//                print("getChatts: failed JSON deserialization")
//                return
//            }
//            returnedResponse = jsonObj.first as? ResponseBody ?? nil
//        }
//        
//        guard let firstResponse = response.first else {
//            print("No response data in array")
//            return ([Tag(name: "HELP")], "No content generated")
//        }
//        
//        let tags = firstResponse.tags.map { Tag(name: $0) }
//        return (tags, firstResponse.content)
//    }
    
    static func getInfo(for image: UIImage) async throws -> ([Tag], String) {
        guard let apiUrl = URL(string: "https://3.138.136.6/imageInfo/") else {
            print("getInfo: Bad URL")
            return ([], "NO CONTENT")
        }
        
        struct ResponseBody: Decodable {
            let tags: [String]
            let content: String
        }
        
        do {
            // Upload image and parse response
            let response = try await AF.upload(multipartFormData: { mpFD in
                if let jpegImage = image.jpegData(compressionQuality: 0.8) {
                    mpFD.append(jpegImage, withName: "image", fileName: "giggleImage.jpg", mimeType: "image/jpeg")
                }
            }, to: apiUrl, method: .post)
            .validate() // Ensure only successful responses (2xx) are processed
            .serializingDecodable(ResponseBody.self)
            .value // Await and extract the decoded value
            
            // Convert tags to Tag struct
            let tags = response.tags.map { Tag(name: $0) }
            return (tags, response.content)
            
        } catch let error as AFError {
            print("Alamofire error: \(error.localizedDescription)")
            throw error
        } catch {
            print("Unknown error: \(error.localizedDescription)")
            throw error
        }
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
