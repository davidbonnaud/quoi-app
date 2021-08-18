//
//  quoi_appApp.swift
//  quoi-app
//
//  Created by David Bonnaud on 8/18/21.
//

import SwiftUI

@main
struct quoi_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
