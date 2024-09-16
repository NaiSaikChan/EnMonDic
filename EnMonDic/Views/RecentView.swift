//
//  RecentView.swift
//  EnMonDic
//
//  Created by SaikChan on 14/09/2024.
//

import SwiftUI
import CoreData

struct RecentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch Request to get words sorted by lastViewe date
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MonDic.lastViewed, ascending: true)],
        predicate: NSPredicate(format: "lastViewed != nil"),
        animation: .default
    ) private var words: FetchedResults<MonDic>
    
    var body: some View {
        NavigationStack {
            ForEach(words) { item in
                NavigationLink(destination: DetailView(word: item)) {
                    HStack(alignment: .top){
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.english ?? "")
                                .font(.custom("Mon3Anonta1", size: 18))
                                .fontWeight(.heavy)
                            
                            Text(item.mon ?? "")
                                .font(.custom("Pyidaungsu", size: 16))
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                            
                        }
                        .padding(.vertical, 12) // Increase vertical padding
                        .padding(.horizontal, 15) // Add horizontal padding
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                Divider()
            }
            .onDelete(perform: deleteItems)
            .navigationBarHidden(true)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { words[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct RecentView_Previews: PreviewProvider {
    static var previews: some View {
        RecentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
