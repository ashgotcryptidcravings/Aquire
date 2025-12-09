//
//  AquireApp.swift
//  Aquire
//
//  Created by ZZZerosworld on 12/8/25.
//

import SwiftUI

@main
struct AquireApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
