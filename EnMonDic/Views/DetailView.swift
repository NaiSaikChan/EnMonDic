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
    }
    
    private func pronounceWord(_ text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synthesizer.speak(utterance)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage of a preview context
        let context = PersistenceController.preview.container.viewContext
        let sampleWord = MonDic(context: context)
        sampleWord.english = "Hello"
        sampleWord.mon = "မ္ၚဵုရအဴ"
        return DetailView(word: sampleWord).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
