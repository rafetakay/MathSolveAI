//
//  ProblemSolverApi.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import Foundation

import Foundation

class ProblemSolverAPI {
    
    static let aiKey = Bundle.main.infoDictionary?["AI_API_KEY"] as? String ?? ""
    
    static func solve(equation: String, completion: @escaping (Result<Solution, Error>) -> Void) {
        // Validate URL
        let url = URL(string: "https://api.deepinfra.com/v1/openai/chat/completions")!
       
        let deepInfraKey = aiKey
        
        
        // Create request
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(deepInfraKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanEquation = equation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prompt = """
             Extract the first valid math problem found in the given text.
             Here is the text: \(cleanEquation).
             
             If you find a valid problem, store it in 'foundproblem'.
             Solve it correctly and provide a short solution in 'solutiontext'.
             Show step-by-step calculations in 'steps' with a maximum of 4 steps.
             
             If no meaningful problem is found, set 'cannotdetectedproblem' to "true" and 'cannotfindsolution' to "true".
             If a problem is found but cannot be solved, set 'cannotfindsolution' to "true", otherwise "false".
             
             Return only JSON format:
             {
                 "foundproblem": "<detected problem>",
                 "solutiontext": "<correct solution>",
                 "steps": ["Step 1: ...", "Step 2: ..."],
                 "cannotdetectedproblem": "<true or false>",
                 "cannotfindsolution": "<true or false>"
             }
             """


        // Prepare request data
        let parameters: [String: Any] = [
            "model": "mistralai/Mistral-7B-Instruct-v0.1",
            "messages": [["role": "user", "content": prompt]],
            "temperature": 0.7,
            "response_format": ["type": "json_object"] // Corrected this line
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            let serializationError = NSError(domain: "MathSolver", code: 3, userInfo: [NSLocalizedDescriptionKey: "JSON serialization failed"])
            completion(.failure(serializationError))
            return
        }
        
        request.httpBody = httpBody
   
        // Make network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                // Handle network error
                guard let data = data, error == nil else {
                    let networkError = error ?? NSError(domain: "MathSolver", code: 2, userInfo: [NSLocalizedDescriptionKey: "Network error"])
                    return completion(.failure(networkError))
                }
                // Handle HTTP errors
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 429:
                        let rateLimitError = NSError(domain: "MathSolver", code: 429, userInfo: [NSLocalizedDescriptionKey: "API request limit exceeded. Please try again later."])
                        return completion(.failure(rateLimitError))
                    case 500...599:
                        let serverError = NSError(domain: "MathSolver", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error. Please try again later."])
                        return completion(.failure(serverError))
                    default:
                        break
                    }
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                   // print("AI Test Raw API response: \(responseString)")
                }
                
               
                do {
                    
                      let apiResponse = try JSONDecoder().decode(AIResponse.self, from: data)
                      
                      guard let contentString = apiResponse.choices.first?.message.content else {
                          print("Error: No content found in API response")
                          completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content found"])))
                          return
                      }
                      
                      guard let contentData = contentString.data(using: .utf8) else {
                          print("Error: Unable to convert content to Data")
                          completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid content format"])))
                          return
                      }
                      
                      let solution = try JSONDecoder().decode(Solution.self, from: contentData)
                      print("Solution: \(solution)")
                      completion(.success(solution))

                   
                } catch {
                    print("Error decoding response: \(error)")  // Log decoding error
                    completion(.failure(error))  // Return decoding error
                }
            }
        }.resume()  // Start the network task
        
    }

}
