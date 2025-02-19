//
//  ContentView.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appState: AppState  // Access global state

    var body: some View {
        Group {
            if appState.isLoading {
                SplashLoadingView()
            } else {
                MainView()
            }
        }
        
    }
}


