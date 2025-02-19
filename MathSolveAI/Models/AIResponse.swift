//
//  AIResponse.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 13.02.2025.
//

import Foundation

struct AIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String?
        }
        let message: Message
    }
    let choices: [Choice]
}
