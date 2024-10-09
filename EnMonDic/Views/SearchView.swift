//
//  SearchView.swift
//  EnMonDic
//
//  Created by SaikChan on 13/09/2024.
//

import SwiftUI
import CoreData

struct SearchView: View {
    @State private var searchText: String = ""
    @FocusState private var isSearching: Bool
    @State private var words: [MonDic] = []
    @State private var isLoading: Bool = true
    @Environment(\.colorScheme) private var scheme
    @Environment(\.managedObjectContext) private var viewContext
    @Namespace private var animation
    
    var body: some View {
        NavigationStack{
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    if isLoading {
                        ProgressView("Loading...")
                        
                    } else {
                        DictionaryView()
                    }
                }
                .onChange(of: searchText) {
                    fetchDataInBackground(query: searchText) { fetchedWords in
                        self.words = fetchedWords // Update the state variable on the main thread
                    }
                }
                .onAppear {
                    loadDataIfNeeded(context: viewContext)
                    fetchInitialData()
                }
                .navigationBarHidden(true)
                .safeAreaPadding(15)
                .safeAreaInset(edge: .top, spacing: 0) {
                    ExpandableNavigationBar()
                }
                .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
            }
            .scrollTargetBehavior(CustomScrollTargetBehavious())
            .background(.gray.opacity(0.15))
            .contentMargins(.top, 190, for: .scrollIndicators)
        }
    }
    
    /// Expandable Navigation Bar
    @ViewBuilder
    func ExpandableNavigationBar(_ title: String = "Dictionary") -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            let scrollviewHeight = proxy.bounds(of: .scrollView(axis: .vertical))?.height ?? 0
            let scaleProgress = minY > 0 ? 1 + (max(min(minY / scrollviewHeight, 1), 0) * 0.5) : 1
            let progress = isSearching ? 1 : max(min(-minY / 70, 1), 0)
            
            VStack(spacing: 10) {
                //Title
                Text(title)
                    .font(.largeTitle.bold())
                    .scaleEffect(scaleProgress, anchor: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                    TextField("Search Conversations", text: $searchText)
                        .focused($isSearching)
                    
                    if isSearching {
                        Button(action: {
                            isSearching = false
                            searchText = ""
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        })
                        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                    }
                }
                .foregroundStyle(Color.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 15 - (progress * 15))
                .frame(height: 45)
                .clipShape(.capsule)
                .background{
                    RoundedRectangle(cornerRadius: 25 - (progress * 25))
                        .fill(.background)
                        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                        .padding(.top, -progress * 130)
                        .padding(.horizontal, -progress * 15)
                }
            }
            .padding(.top, 25)
            .padding(.horizontal, 15)
            .offset(y: minY < 0 || isSearching ? -minY : 0)
            .offset(y: -progress * 65)
        }
        .frame(height: 130)
        .padding(.bottom, 10)
        .padding(.bottom, isSearching ? -65 : 0)
    }
    
    /// Dictionary View
    @ViewBuilder
    func DictionaryView() -> some View {
        if words.isEmpty {
            Text("No words found")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            ForEach(words) { item in
                NavigationLink(destination: DetailView(word: item)) {
                    HStack(alignment: .top){
                        VStack(alignment: .leading, spacing: 5) {
                            Text(highlightedText(for: item.english ?? ""))
                                .font(.custom("Mon3Anonta1", size: 18))
                                .fontWeight(.heavy)
                            
                            Text(highlightedText(for: item.mon ?? ""))
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
        }
    }
    
    // Function to highlight the search term within the text
    private func highlightedText(for text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let range = attributedString.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive]) {
            attributedString[range].foregroundColor = .blue // Highlight color
            attributedString[range].font = .bold(.body)() // Optional: Make it bold
        }
        
        return attributedString
    }
    
    private func fetchInitialData() {
        isLoading = true
        fetchDataInBackground(query: "") { fetchedWords in
            self.words = fetchedWords
            self.isLoading = false
            print("Initial fetch complete. Loaded \(fetchedWords.count) words.")
        }
    }
    
    // Fetch data in the background using a background context with whole-word matching
    private func fetchDataInBackground(query: String, completion: @escaping ([MonDic]) -> Void) {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<MonDic> = MonDic.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MonDic.english, ascending: true)]
            
            if !query.isEmpty {
                // Whole-word matching with exact match
                fetchRequest.predicate = NSPredicate(format: "english BEGINSWITH[cd] %@", query)
            }
            
            fetchRequest.fetchBatchSize = 20 // Adjust batch size to balance performance
            
            do {
                let results = try context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(results)
                }
            } catch {
                print("Failed to fetch data: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
}

struct CustomScrollTargetBehavious: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < 70 {
            if target.rect.minY < 35 {
                target.rect.origin = .zero
            } else {
                target.rect.origin = .init(x: 0, y: 70)
            }
        }
    }
}

#Preview {
    SearchView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
