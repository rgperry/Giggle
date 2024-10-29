//
//  datastore.swift
//  Giggle
//
//  Created by Matthew Drutis on 10/29/24.
//
import SwiftData
import NaturalLanguage

@Model
class Entry {
    var id: UUID
    var dateAdded: Date
    var tags: [String]
    var content: String
    var filePath: String
    var contentEmbedding: [Double]  // Store embedding vector
    
    init(content: String, tags: [String] = [], filePath: String = "") {
        self.id = UUID()
        self.dateAdded = Date()
        self.content = content
        self.tags = tags
        self.filePath = filePath
        self.contentEmbedding = Entry.generateEmbedding(for: content) ?? []
    }
    
    // Generate embedding vector for content
    static func generateEmbedding(for text: String) -> [Double]? {
        guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) else { return nil }
        return embedding.vector(for: text)
    }
}

// Search utility class
class SearchManager {
    private let embedding: NLEmbedding?
    
    init() {
        self.embedding = NLEmbedding.sentenceEmbedding(for: .english)
    }
    
    func findSimilarEntries(query: String, in context: ModelContext, limit: Int = 5) -> [Entry] {
        guard let embedding = embedding,
              let queryVector = embedding.vector(for: query) else {
            return []
        }
        
        // Fetch all entries
        let descriptor = FetchDescriptor<Entry>()
        guard let entries = try? context.fetch(descriptor) else { return [] }
        
        // Calculate distances and sort
        let entriesWithDistances = entries.compactMap { entry -> (Entry, Double)? in
            guard !entry.contentEmbedding.isEmpty else { return nil }
            
            // this computes it on the fly, not ideal for our search! (we can test the speed of it)
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
