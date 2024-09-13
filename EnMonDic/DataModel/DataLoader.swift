//
//  DataLoader.swift
//  EnMonDic
//
//  Created by SaikChan on 13/09/2024.
//

import Foundation
import CoreData
import SwiftUI

struct DictionaryEntry: Codable {
    let word: String
    let def: String
}

struct DictionaryWrapper: Codable {
    let data: [DictionaryEntry]
}

func loadAllJSONFilesAndSaveToCoreData(context: NSManagedObjectContext) {
    // Get all filenames that match the dictionary JSON naming pattern
    let fileNames = getJSONFileNames()
    
    for fileName in fileNames {
        let entries = loadJSON(from: fileName)
        saveEntriesToCoreData(entries: entries, context: context)
    }
    
    print("All JSON data loaded and saved to CoreData successfully!")
}

// Function to retrieve all JSON file names matching a pattern
func getJSONFileNames() -> [String] {
    let fileManager = FileManager.default
    let bundleURL = Bundle.main.bundleURL
    
    do {
        // Get all files in the bundle directory
        let fileURLs = try fileManager.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
        
        // Filter files that match the dictionary naming pattern (e.g., "dictionary A.json")
        let jsonFileNames = fileURLs
            .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("dictionary") }
            .map { $0.deletingPathExtension().lastPathComponent }
        
        return jsonFileNames
    } catch {
        print("Error retrieving JSON files: \(error)")
        return []
    }
}

// Function to load JSON data from a specified file
func loadJSON(from filename: String) -> [DictionaryEntry] {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
        print("Failed to locate \(filename).json in bundle.")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let wrapper = try decoder.decode(DictionaryWrapper.self, from: data)
        return wrapper.data
    } catch {
        print("Error parsing JSON from \(filename): \(error)")
        return []
    }
}

// Function to save loaded entries to CoreData
func saveEntriesToCoreData(entries: [DictionaryEntry], context: NSManagedObjectContext) {
    guard !entries.isEmpty else {
        print("No entries found in the provided JSON data.")
        return
    }
    
    for entry in entries {
        let word = MonDic(context: context)
        word.id = UUID()
        word.english = entry.word
        word.mon = entry.def
        word.isFavorite = false
        word.lastViewed = nil
    }
    
    do {
        try context.save()
        print("Data saved to CoreData successfully!")
    } catch {
        print("Failed to save data to CoreData: \(error)")
    }
}

func loadDataIfNeeded(context: NSManagedObjectContext) {
    // Check if CoreData already has data
    let fetchRequest: NSFetchRequest<MonDic> = MonDic.fetchRequest()
    fetchRequest.fetchLimit = 1 // Limit to 1 to improve performance
    
    do {
        let count = try context.count(for: fetchRequest)
        if count == 0 {
            // No data in CoreData, so load from JSON
            loadAllJSONFilesAndSaveToCoreData(context: context)
        } else {
            print("CoreData already has data, skipping JSON import.")
        }
    } catch {
        print("Failed to count CoreData entries: \(error)")
    }
}
