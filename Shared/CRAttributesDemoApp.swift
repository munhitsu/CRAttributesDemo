//
//  CRAttributesDemoApp.swift
//  Shared
//
//  Created by Mateusz Lapsa-Malawski on 27/12/2021.
//

import SwiftUI

@main
struct CRAttributesDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
