//
//  AddWordView.swift
//  MEM Dictionary
//
//  Created by SaikChan on 11/09/2024.
//

import SwiftUI

struct AddWordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var english = ""
    @State private var mon = ""
    
    var body: some View {
        
        NavigationStack {
            Form {
                Section(header: Text("New Word")) {
                    TextField("English or Mon", text: $english)
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // Optional: Adds a border for visual consistency
                        .font(.custom("Pyidaungsu", size: 16))
                    
                    // Multiline input for Mon text
                    VStack(alignment: .leading) {
                        Text("Definition")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $mon)
                            .frame(minHeight: 300) // Adjust the height as needed
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary, lineWidth: 0.5) // Adds a border
                            )
                            .font(.custom("Pyidaungsu", size: 16))
                        Text("Your personal saved words in the dictionary will be lost after deleting the app.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Word")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addWord()
                        dismiss()
                    }
                    .disabled(english.isEmpty || mon.isEmpty) // Disable save if fields are empty
                }
            }
        }
    }
    
    private func addWord() {
        let newWord = MonDic(context: viewContext)
        newWord.id = UUID()
        newWord.english = english
        newWord.mon = mon
        newWord.isFavorite = true
        newWord.lastViewed = nil
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save new word: \(error)")
        }
    }
}

struct AddWordView_Previews: PreviewProvider {
    static var previews: some View {
        AddWordView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
