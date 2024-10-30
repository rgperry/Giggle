//
//  datastore.swift
//  Giggle
//
//  Created by Matthew Drutis on 10/29/24.
//
import SwiftData
import NaturalLanguage

@Model
class Meme {
    @Attribute(.unique) var id: UUID
    var dateAdded: Date
    var tags: [String]
    var content: String
    var filePath: String
//    var contentEmbedding: [Double]  // Store embedding vector
    
    init(content: String, tags: [String] = [], filePath: String = "") {
        self.id = UUID()
        self.dateAdded = Date()
        // async get content function
        self.content = content
        // async get tag function
        self.tags = tags
        self.filePath = filePath
//        self.contentEmbedding = Entry.generateEmbedding(for: content) ?? []
    }
}

// Search utility class
class SearchManager {
    private let embedding: NLEmbedding?
    
    init() {
        self.embedding = NLEmbedding.sentenceEmbedding(for: .english)
    }
    
    func findSimilarEntries(query: String, in context: ModelContext, limit: Int = 5) -> [Meme] {
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
}
