//
//  AppState.swift
//  MathSolveAI
//
//  Created by Rafet Can AKAY on 18.02.2025.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var isLoading: Bool = true  // Tracks loading status
    
    init() {
        loadData()  // Start loading when the app launches
    }

    func loadData() {
        // Simulate an API call or database fetch
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            DispatchQueue.main.async {
                self.isLoading = false  // Hide loading screen after 3s
            }
        }
    }
}
