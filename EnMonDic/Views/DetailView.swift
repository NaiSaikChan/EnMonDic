//
//  DetailView.swift
//  EnMonDic
//
//  Created by SaikChan on 13/09/2024.
//

import SwiftUI
import CoreData
import AVFoundation

struct DetailView: View {
    @ObservedObject var word: MonDic
    @Environment(\.managedObjectContext) private var viewContext
    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(word.english ?? "")
                    .font(.custom("Pyidaungsu", size: 26))
                    .bold()
                Spacer()
                Button(action: {
                    toggleFavorite()
                }) {
                    Image(systemName: word.isFavorite ? "suit.heart.fill" : "suit.heart")
                        .foregroundColor(word.isFavorite ? .yellow : .gray)
                }
                .accessibilityLabel(word.isFavorite ? "Remove from favorites" : "Add to favorites")
            }
            
                    Text(word.mon ?? "")
                        .font(.custom("Pyidaungsu", size: 18))
                        .foregroundColor(.secondary)
                
            
            Button(action: {
                pronounceWord(word.english ?? "", language: "en-US")
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Pronounce in English")
                }
                .padding(.all, 5)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
//        .navigationTitle("Detail")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Mark Viewed") {
                    updateLastViewed()
                }
            }
        }
    }
    
    private func toggleFavorite() {
        word.isFavorite.toggle()
        saveContext()
    }
    
    private func updateLastViewed() {
        word.lastViewed = Date()
        saveContext()
    }
    
    private func pronounceWord(_ text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synthesizer.speak(utterance)
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage of a preview context
        let context = PersistenceController.preview.container.viewContext
        let sampleWord = MonDic(context: context)
        sampleWord.english = "Hello"
        sampleWord.mon = "မ္ၚဵုရအဴ"
        return DetailView(word: sampleWord).environment(\.managedObjectContext, context)
    }
}
