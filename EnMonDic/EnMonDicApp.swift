//
//  EnMonDicApp.swift
//  EnMonDic
//
//  Created by SaikChan on 13/09/2024.
//

import SwiftUI

@main
struct EnMonDicApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
