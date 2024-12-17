//
//  TripApp.swift
//  Trip
//
//  Created by admin on 2024/11/29.
//

import SwiftUI
import SwiftData

@main
struct TripApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TripModel.self)
    }
}
