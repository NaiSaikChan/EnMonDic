//
//  FavoriteView.swift
//  EnMonDic
//
//  Created by SaikChan on 14/09/2024.
//

import SwiftUI
import CoreData

struct FavoriteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch Request to get favorite words
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MonDic.english, ascending: true)],
        predicate: NSPredicate(format: "isFavorite == true"), // Only show favorite words
        animation: .default
    ) private var words: FetchedResults<MonDic>
    
    var body: some View {
        NavigationStack {
            List{
                ForEach(words) {word in
                    VStack(alignment: .leading) {
                        Text(word.english ?? "")
                            .font(.custom("Pyidaungsu", size: 20))
                        Text(word.mon ?? "")
                            .font(.custom("Pyidaungsu", size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: deleteWords(at:))
            }
            .navigationTitle("Favorites")
            .toolbar {
                EditButton()
            }
        }
    }
    
//Delete the words
    private func deleteWords(at offsets: IndexSet) {
        offsets.map { words[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete words: \(error)")
        }
    }
}


struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
