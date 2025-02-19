//
//  ResultView.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import Foundation
import SwiftUI
struct ResultView: View {
    
    @ObservedObject var viewModel: ProblemSolverViewModel
  
    @State private var offset = CGSize(width: 0, height: UIScreen.main.bounds.height) // Start with the view offscreen at the bottom
      
    var body: some View {
        
        ZStack {
        
            Spacer()
            VStack(spacing: 8) {
                
                // Add a Spacer above the exit button to push it down
                Spacer().frame(height: UIScreen.main.bounds.height * 0.06)  // 10% of the screen height to create space at the top
                    
                HStack {
                    // Exit button at the top left
                    Button(action: {
                        viewModel.resetViewModel()
                    }) {
                        Image(systemName: "xmark.circle.fill") // "X" icon
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                
                // If a problem is detected
                if let solution = viewModel.solution {
                    if solution.cannotdetectedproblem {
                        Text("No problem detected. Please take a clear photo of the equation.")
                            .font(.title2)
                            .foregroundColor(.red)
                            .padding()
                        
                            
                        
                    } else if solution.cannotfindsolution {
                        Text("No problem detected. Please take a clear photo of the equation.")
                            .font(.title2)
                            .foregroundColor(.red)
                            .padding()
                        
                            
                        
                    } else {
                        // If problem is detected, show problem text, solution, and steps
                        Text("Problem : \(solution.foundProblem)")
                            .font(.title)
                            .foregroundColor(Color.red)
                            .padding()
                        
                            
                        
                        Text("Solution : \(solution.solutionText)")
                            .font(.title2)
                            .foregroundColor(Color.green)
                            .padding()
                        
                            
                        
                        if !solution.stepsOfSolution.isEmpty {
                            Text("Steps :")
                                .font(.headline)
                                .padding()
                                .foregroundColor(Color.white)
                            
                                
                            
                            VStack(alignment: .leading, spacing: 8) { // Added spacing of 8 points
                                ForEach(solution.stepsOfSolution, id: \.self) { step in
                                    Text(step)
                                        .padding(.leading)
                                        .padding(.bottom, 4) // Add spacing between steps
                                        
                                }
                            }
                        }
                    }
                    
                } else {
                    // If no solution is available (e.g., still loading or no result)
                    Text("Solution not found. Please try again by taking a new photo.")
                        .font(.title2)
                        .foregroundColor(.red)
                        .padding()
                        
                }
                
                Spacer()
                // Button to retake the photo
                Button("Retake Photo") {
                    viewModel.resetViewModel()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .cornerRadius(5)
            
            .offset(y: offset.height) // Offset starts at the bottom
            .onAppear {
                // Animate the view from bottom to top
                withAnimation(.easeInOut(duration: 0.25)) {
                    offset = CGSize(width: 0, height: 0) // Move it up to its normal position
                }
            }
            .onDisappear {
                // Animate the view back to the bottom when disappearing
                withAnimation(.easeInOut(duration: 0.25)) {
                    offset = CGSize(width: 0, height: UIScreen.main.bounds.height)
                }
            }
            
            .edgesIgnoringSafeArea(.all)
           
        } .animation(.easeInOut(duration: 0.25), value: viewModel.isSolutionReceived)  // Apply animation on change of isPresented
        
    } //view
    
} // struct
