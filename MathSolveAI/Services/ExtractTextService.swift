//
//  ExtractTextService.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import Vision
import UIKit

class ExtractTextService {
   
    static func extractText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
            // Create a request handler from the image
            guard let cgImage = image.cgImage else {
                completion(.failure(NSError(domain: "ExtractTextService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])))
                return
            }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            // Create the text recognition request
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Get recognized text from the request
                if let result = request.results as? [VNRecognizedTextObservation], !result.isEmpty {
                    let extractedText = result.map { $0.topCandidates(1).first?.string ?? "" }.joined(separator: "\n")
                    completion(.success(extractedText))  // Pass the text back
                } else {
                    completion(.failure(NSError(domain: "ExtractTextService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No text found in image"])))
                }
            }
            
            request.recognitionLevel = .accurate  // Set to accurate for better results
            request.usesLanguageCorrection = true // Enable language correction to improve accuracy
            
            // Perform the request
            do {
                try requestHandler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
}
