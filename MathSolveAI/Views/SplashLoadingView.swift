//
//  SplashLoadingView.swift
//  MathSolveAI
//
//  Created by Rafet Can AKAY on 18.02.2025.
//

import SwiftUI

import SwiftUI

struct SplashLoadingView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(ksplashScreenUpColor), Color(ksplashScreenDownColor)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            Image("turtleicon")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.width * 0.4)
        }
    }
}

