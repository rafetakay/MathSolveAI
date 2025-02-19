//
//  MathSolveAI.swift
//  MathSolveAI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import SwiftUI

@main
struct MathSolveAI: App {
    
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
    }
}
