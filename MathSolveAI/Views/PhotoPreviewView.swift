//
//  PhotoPreviewView.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import Foundation
import SwiftUI
struct PhotoPreviewView: View {
    @ObservedObject var viewModel: ProblemSolverViewModel
    @Binding var isPresented: Bool
    
    var cropWidthOfCapturedImage : CGFloat = 0
    var cropHeightOfCapturedImage : CGFloat = 0
    
    //Scanner
    @State private var scannerOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var isMovingRight = true // Track movement direction

   
    private var scannerGradient: LinearGradient {
        let colors: [Color]
        
        if isMovingRight {
            colors = [Color(kscannerFillColor).opacity(0), Color(kscannerFillColor).opacity(0.3), Color(kscannerFillColor).opacity(0.95)]
        } else {
            colors = [Color(kscannerFillColor).opacity(0.95), Color(kscannerFillColor).opacity(0.3), Color(kscannerFillColor).opacity(0)]
        }
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var scannerCornerRadius =  UIScreen.main.bounds.width * 0.007

    var scannerWidth = UIScreen.main.bounds.width * 0.05
    
    private var spaceforstartendpointofScanner: CGFloat {
        return 5.0
    }
    
    // Computed property for scanner height
    private var scannerHeight: CGFloat {
        return cropHeightOfCapturedImage * 1.05
    }

    private var startOfScannerOffSet: CGFloat {
        return scannerOffset - (cropWidthOfCapturedImage / 2) - CGFloat(spaceforstartendpointofScanner)
    }
    
    //Scanner
    
    var body: some View {
        
        VStack {
            // Exit button at the top-left corner
            HStack {
                Button(action: {
                    viewModel.resetViewModel()
                    isPresented = false
                }) {
                   
                    ZStack {
                        Circle()
                            .fill(Color(kexiticonbgcolor)) // Black background
                            .frame(width: 40, height: 40) // Adjust size

                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20) // Icon size
                            .foregroundColor(Color(kexiticontintcolor)) // White "X"
                    }
                    .padding()
                }
                .disabled(viewModel.isLoading)
                
                Spacer()
            }

            Spacer()
            
            if let image = viewModel.capturedImage {
                
                ZStack {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: cropWidthOfCapturedImage ,height: cropHeightOfCapturedImage )
                        .clipShape(RoundedRectangle(cornerRadius: cropHeightOfCapturedImage * 0.05))
                        .shadow(radius: UIScreen.main.bounds.height * 0.7)
                    
                    // Always present a transparent rectangle with scannerHeight and scannerWidth to not change height
                    Rectangle()
                        .fill(Color.clear) // Transparent placeholder
                        .frame(width: scannerWidth, height: scannerHeight)
                    
                    if viewModel.isLoading {
                        // Scanner animation overlay
                        Rectangle().fill(scannerGradient)
                            .frame(width: scannerWidth, height: scannerHeight)
                            .clipShape(RoundedRectangle(cornerRadius: scannerCornerRadius))
                            .offset(x: startOfScannerOffSet)//when scanneroffset is 0 it start from center remember that is why we - (cropWidthOfCapturedImage / 2)
                            .onAppear {
                                startScannerAnimation()
                            }.onDisappear {
                                stopScannerAnimation()
                            }
                            .opacity(isAnimating ? 1 : 0) // Control visibility based on isAnimating
                    }
                
                }
            }

            Spacer()
            
            // Find Answer Button
            Button("Find Answer") {
                if let image = viewModel.capturedImage {
                    viewModel.extractMathFromImage(image: image)
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.capturedImage == nil || viewModel.isLoading)
            
            Spacer()
        }
        .background(Color(kphotopreviewcontainerbgcolor)) 
        .cornerRadius(UIScreen.main.bounds.height * 0.5 / 20)
        .onAppear {
            if viewModel.capturedImage == nil {
                isPresented = false
            }
        }
        .onChange(of: viewModel.capturedImage) { _, newImage in
            if newImage == nil {
                isPresented = false
            }
        }
        .onChange(of: viewModel.isLoading) { _, isLoading in
            if !isLoading {
                stopScannerAnimation()  // Stop animation when loading is false
            }
        }
        
       
    }
    
    @State private var scannerTimer: Timer? // Store the timer reference

    private func startScannerAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        var animationDuration = 0.0
        
        if cropWidthOfCapturedImage > UIScreen.main.bounds.width * 0.5 {
            animationDuration = 1.25
        } else if cropWidthOfCapturedImage > UIScreen.main.bounds.width * 0.3 {
            animationDuration = 1
        }else {
            animationDuration = 0.5
        }

        // Immediately start the animation to move in one direction
        withAnimation(Animation.linear(duration: animationDuration).repeatCount(1, autoreverses: false)) {
            scannerOffset = cropWidthOfCapturedImage + CGFloat(spaceforstartendpointofScanner * 2) // Move immediately to the right
        }
        
        // Set up the timer to toggle direction every animation cycle
        scannerTimer?.invalidate() // Stop any existing timer
        scannerTimer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
            // Toggle direction after the animation finishes
            isMovingRight.toggle()

            // Adjust the offset for the new direction
            withAnimation(Animation.linear(duration: animationDuration).repeatCount(1, autoreverses: false)) {
                // If moving right, set offset to the right side, otherwise, move it back
                if isMovingRight {
                    scannerOffset = cropWidthOfCapturedImage + CGFloat(spaceforstartendpointofScanner * 2)
                } else {
                    scannerOffset =  scannerOffset - cropWidthOfCapturedImage - CGFloat(spaceforstartendpointofScanner * 2)
                }
            }
        }
    }

    private func stopScannerAnimation() {
        isAnimating = false
        withAnimation {
            scannerOffset = startOfScannerOffSet
        }
        
        scannerTimer?.invalidate() // Stop the timer when animation is stopped
        scannerTimer = nil
    }


    
}
