//
//  ContentView.swift
//  EnMonDic
//
//  Created by SaikChan on 13/09/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MonDic.english, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MonDic>
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: DetailView(word: item)) {
                    VStack(alignment: .leading){
                        Text(item.english ?? "")
                            .font(.custom("Mon3Anonta1", size: 20))
                            .fontWeight(.bold)
                        Text(item.mon ?? "")
                            .font(.custom("Pyidaungsu", size: 16))
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 5)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .onAppear {
            loadDataIfNeeded(context: viewContext)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MonDic(context: viewContext)
            newItem.english = "love"
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
