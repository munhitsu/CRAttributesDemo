//
//  CRAttributesDemoApp.swift
//  Shared
//
//  Created by Mateusz Lapsa-Malawski on 27/12/2021.
//

import SwiftUI
import CRAttributes

@main
struct CRAttributesDemoApp: App {
    let persistenceController = CRStorageController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.localContainer.viewContext)
        }
    }
}
