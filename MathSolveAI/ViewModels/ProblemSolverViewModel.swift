//
//  ProblemSolverViewModel.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import SwiftUI
import Combine

class ProblemSolverViewModel: ObservableObject {
    
    @Published var capturedImage: UIImage?
    @Published var extractedText: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var isSolutionReceived = false
    @Published var solution: Solution?
    
    func resetViewModel() {
        capturedImage = nil
        
        isLoading = false
        extractedText = nil
        errorMessage = nil
        
        solution = nil
        isSolutionReceived = false
        
    }
    
    
    func extractMathFromImage(image: UIImage) {
        isLoading = true
        ExtractTextService.extractText(from: image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let equation):
                    self?.extractedText = equation
                    self?.solveMathEquation(equation: equation)
                case .failure(let error):
                    self?.errorMessage = "Text Could Not Received : \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }
    }

    func solveMathEquation(equation: String) {
        ProblemSolverAPI.solve(equation: equation) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let solution):
                    self?.solution = solution
                    self?.isSolutionReceived = true
                case .failure(let error):
                    self?.errorMessage = "Solution Error : \(error.localizedDescription)"
                    self?.isSolutionReceived = false
                }
            }
        }
    }
}
