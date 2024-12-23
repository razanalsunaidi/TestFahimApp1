//
//  tryTest1App.swift
//  tryTest1
//
//  Created by Razan Alsunaidi on 15/06/1446 AH.
//

import SwiftUI
import SwiftData

@main
struct tryTest1App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: Fahem.self)
    }
}
