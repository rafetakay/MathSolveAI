//
//  Solution.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 13.02.2025.
//

import Foundation

struct Solution: Codable {
    let foundProblem: String
    let solutionText: String
    let stepsOfSolution: [String]
    let cannotdetectedproblem: Bool
    let cannotfindsolution: Bool
    
    enum CodingKeys: String, CodingKey {
        case foundProblem = "foundproblem"
        case solutionText = "solutiontext"
        case stepsOfSolution = "steps"
        case cannotdetectedproblem = "cannotdetectedproblem"
        case cannotfindsolution = "cannotfindsolution"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        foundProblem = try values.decode(String.self, forKey: .foundProblem)
        solutionText = try values.decode(String.self, forKey: .solutionText)
        stepsOfSolution = try values.decode([String].self, forKey: .stepsOfSolution)
        
        let cannotDetected = try values.decode(String.self, forKey: .cannotdetectedproblem)
        let cannotFind = try values.decode(String.self, forKey: .cannotfindsolution)
        
        cannotdetectedproblem = (cannotDetected == "true")
        cannotfindsolution = (cannotFind == "true")
    }
}

