//
//  datastore.swift
//  Giggle
//
//  Created by Matthew Drutis on 10/29/24.
//
import SwiftData
import NaturalLanguage

@Model
final class Meme {
    // Primary properties
    var id: UUID
    var dateAdded: Date
    var tags: [String]
    var content: String
    var filePath: String
    
    // Store the content words for neighbor search
    var searchableWords: [String]
    
    init(content: String, tags: [String], filePath: String) {
        self.id = UUID()
        self.dateAdded = Date()
        self.content = content
        self.tags = tags
        self.filePath = filePath
        // Store normalized words for searching
        self.searchableWords = content
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
    }
}

// Database manager class
class DatabaseManager {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    let embedder: NLEmbedding
    
    init() throws {
        let schema = Schema([Meme.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(modelContainer)
        
        guard let wordEmbedding = NLEmbedding.wordEmbedding(for: .english) else {
            throw NSError(domain: "DatabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize word embedding"])
        }
        self.embedder = wordEmbedding
    }
    
    // Add new entry
    func addMeme(content: String, tags: [String], filePath: String) throws {
        let entry = Meme(content: content, tags: tags, filePath: filePath)
        modelContext.insert(entry)
        try modelContext.save()
    }
    
//    // Semantic search using NLEmbedding.neighbors
//    func semanticSearch(query: String, limit: Int = 10) throws -> [Entry] {
//        let queryWords = query.components(separatedBy: .whitespacesAndNewlines)
//            .filter { !$0.isEmpty }
//            .map { $0.lowercased() }
//        
//        // Get all entries
//        let descriptor = FetchDescriptor<Entry>()
//        let entries = try modelContext.fetch(descriptor)
//        
//        // For each entry, calculate the average similarity with query words
//        let entryScores = entries.map { entry -> (Entry, Double) in
//            var totalSimilarity = 0.0
//            var countedPairs = 0
//            
//            // Compare each query word with each entry word
//            for queryWord in queryWords {
//                for entryWord in entry.searchableWords {
//                    if let similarity = embedder.distance(between: queryWord, and: entryWord) {
//                        totalSimilarity += similarity
//                        countedPairs += 1
//                    }
//                }
//            }
//            
//            // Calculate average similarity
//            let averageSimilarity = countedPairs > 0 ? totalSimilarity / Double(countedPairs) : 0
//            return (entry, averageSimilarity)
//        }
//        
//        // Sort by similarity (higher distance means more similar) and return top results
//        return entryScores
//            .sorted { $0.1 > $1.1 }
//            .prefix(limit)
//            .map { $0.0 }
//    }
//    
//    // Alternative search using direct neighbors function
//    func quickSearch(query: String, limit: Int = 10) throws -> [Entry] {
//        let descriptor = FetchDescriptor<Entry>()
//        let entries = try modelContext.fetch(descriptor)
//        
//        // Get neighbors for the query
//        guard let neighbors = embedder.neighbors(for: query, maximumCount: limit) else {
//            return []
//        }
//        
//        // Filter entries that contain the neighbor words
//        let rankedEntries = entries.filter { entry in
//            neighbors.contains { neighborWord in
//                entry.searchableWords.contains(neighborWord.0)
//            }
//        }
//        
//        return Array(rankedEntries.prefix(limit))
//    }
//    
//    // Tag-based search
//    func searchByTags(_ tags: [String]) throws -> [Entry] {
//        let predicate = #Predicate<Entry> { entry in
//            tags.contains { tag in
//                entry.tags.contains(tag)
//            }
//        }
//        
//        var descriptor = FetchDescriptor<Entry>()
//        descriptor.predicate = predicate
//        return try modelContext.fetch(descriptor)
//    }
}
