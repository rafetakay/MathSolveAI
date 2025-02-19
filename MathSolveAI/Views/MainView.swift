//
//  MainView.swift
//  ProblemSolveAISwiftUI
//
//  Created by Rafet Can AKAY on 12.02.2025.
//

import SwiftUI
import AVFoundation

struct MainView: View {
    @StateObject private var cameraManager = CameraManager()
    
    @State private var showImagePicker = false
    @StateObject private var viewModel = ProblemSolverViewModel()

    @State private var isPhotoPreviewPresented = false
    
    // CROP
    @State private var capturedCroppedImage: UIImage? = nil

    @State private var cropWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    @State private var cropHeight: CGFloat = UIScreen.main.bounds.height * 0.2
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    
    @State private var cropBorderSize: CGFloat = 10
    // Computed according to bordersize to not dismiss corners when changing size ,need to be less than
    // after we cleared red border
    private var cropAreaBorderCornerRadius: CGFloat {
           return cropBorderSize * 0.99
    }
    
    @State private var cropBorderSizeRedPath: CGFloat = 5
    private var cropAreaRedPathsCornerRadius: CGFloat {
        return cropBorderSize * 1.5
    }
    //CROP
    
    //Carousel
    var carouselHeight = UIScreen.main.bounds.height * 0.05
    var carouselTextHeight = UIScreen.main.bounds.height * 0.025
    @State private var currentCarouselIndex = 0
    @State private var carouselTimer: Timer?
    @State private var carouselItems = [
        "1.EQUATIONS",
        "2.STATISTICS",
        "3.PROBLEMS",
        
        "4.TRIGONOMETRY",
        "5.ALGEBRA",
        "6.CALCULUS",
        "7.GEOMETRY",
        
        "1.EQUATIONS",
        "2.STATISTICS",
        "3.PROBLEMS"]
    // last three and three are same when from EQUATIONS when it goes to lastindex-1 item
    private let carouselTimerDuration = 1.0
    //Carousel
    
    @State private var isFlashOn = false
    
    var body: some View {
        
        NavigationStack { 
            
           ZStack {
               
            Color(kcameraviewbgColor).edgesIgnoringSafeArea(.all)
               
               if cameraManager.isCameraAuthorized && cameraManager.isCameraRunning {
            
                   ZStack {  
                       
                    CameraPreview(session: cameraManager.session)
                           .edgesIgnoringSafeArea(.all)
                   
                    Color(kcameraViewShadowBgMainColor)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.47)
                        .mask(
                            ZStack {
                               
                                Color.white
                                Rectangle()
                                    .frame(width: cropWidth + cropBorderSize * 2, height: cropHeight + cropBorderSize * 2)
                                    // adding + cropBorderSize *2 to have better view cropped are remains same
                                    .blendMode(.destinationOut)
                                    .clipShape(RoundedRectangle(cornerRadius: cropAreaBorderCornerRadius * 2))
                                    // this clipShape work for detination out and also cropAreaBorderCornerRadius *2 is only for better view
                            }
                            .compositingGroup()
                        )
                        .overlay(
                            ZStack {
                                // Blur effect with gradient opacity
                                Rectangle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color(kcameraViewShadowBgBlurColor).opacity(0.90), Color(kcameraViewShadowBgMainColor).opacity(0)]), startPoint: .bottom, endPoint: .top))
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.21) // 30% of screen height
                                    .clipped() // Ensures the blur is confined to the specified size
                            }
                            .compositingGroup()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Aligning to the bottom of the parent view
                        )
                        .edgesIgnoringSafeArea(.all)
                    
                  
                    Rectangle()
                        .frame(width: cropWidth, height: cropHeight)
                        .foregroundColor(Color.clear)
                        .overlay(
                            ZStack {   
                                
                                // Draw each corner with radius
                                RoundedOnlyCornerPath(width: cropWidth, height: cropHeight, cornerRadius: cropAreaRedPathsCornerRadius)
                                    .stroke(Color(kcameraCropColor), lineWidth: cropBorderSizeRedPath)
                                
                            
                                // circle handles
                                ResizeCircleHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, handlePosition: .bottomRight)
                                    .position(x: cropWidth - 10, y: cropHeight - 10)
                                
                                // Bottom-Left Handle
                                ResizeCircleHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, handlePosition: .bottomLeft)
                                    .position(x: 10, y: cropHeight - 10)
                                
                                // Top-Right Handle
                                ResizeCircleHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, handlePosition: .topRight)
                                    .position(x: cropWidth - 10, y: 10)
                                
                                // Top-Left Handle
                                ResizeCircleHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, handlePosition: .topLeft)
                                    .position(x: 10, y: 10)
                                //Resizable circle handles 
                                
                                //Resizable side handles
                                // Top Side Handle
                                ResizableSideHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, sidePosition: .top)
                                    .position(x: cropWidth / 2, y: 10)
                                
                                // Bottom Side Handle
                                ResizableSideHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, sidePosition: .bottom)
                                    .position(x: cropWidth / 2, y: cropHeight - 10)
                                
                                // Left Side Handle
                                ResizableSideHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, sidePosition: .left)
                                    .position(x: 10, y: cropHeight / 2)
                                
                                // Right Side Handle
                                ResizableSideHandle(cropWidth: $cropWidth, cropHeight: $cropHeight, sidePosition: .right)
                                    .position(x: cropWidth - 10, y: cropHeight / 2)
                                //Resizable side handles
                                
                                // Small Arrow (Triangle)
                                Image(karrowiconimage)
                                    .resizable()
                                    .renderingMode(.template) // Enables tinting
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color(kcameraCropColor))
                                    .rotationEffect(.degrees(0))
                                    .position(x: cropWidth - 20, y: cropHeight - 20)
                                // Small Arrow (Triangle)

                            }
                        )
                   }
                   .edgesIgnoringSafeArea(.all)
              
            }
               
            if viewModel.isLoading {
                      Color.white
                          .edgesIgnoringSafeArea(.all)
                          .opacity(0.2)
            }
               
            // Custom modal: ResultView
            if viewModel.isSolutionReceived {
                ResultView(viewModel: viewModel)
                    .zIndex(1) // Make sure it’s above other content
                    .transition(.move(edge: .bottom)) // Transition for the view appearing from the bottom
            }
               
            VStack {
                
                Spacer()
                // New header section
                VStack(spacing: 8) {
                    
                    HStack {
                        Button(action: { /* Handle settings */ }) {
                            Image(ksettingiconimage) // Use your actual asset name
                                .resizable()
                                .renderingMode(.template) // Allows tinting
                                .foregroundColor(.white) // Sets the tint color to white
                                .scaledToFit()
                                .frame(width: kcircleSubButtonHeight, height: kcircleSubButtonHeight)
                                .padding(kcircleSubButtonPadding) // Same padding for consistent circle size
                                .background(Color(ksettingiconbgcolor)) // Sets background color
                                .clipShape(Circle()) // Makes it a circle
                                .disabled(isPhotoPreviewPresented)
                            
                        }
                        
                        Spacer()
                        
                        Button(action: { /* Handle info */ }) {
                            Image(kinfoiconimage) // Use your actual asset name
                                .resizable()
                                .renderingMode(.template) // Allows tinting
                                .foregroundColor(.white) // Sets the tint color to white
                                .scaledToFit()
                                .frame(width: kcircleSubButtonHeight, height: kcircleSubButtonHeight)
                                .padding(kcircleSubButtonPadding) // Same padding for consistent circle size
                                .background(Color(kinfoiconbgcolor)) // Sets background color
                                .clipShape(Circle()) // Makes it a circle
                                .disabled(isPhotoPreviewPresented)
                        }
                    }
                    .padding(.horizontal)
                
                    VStack(spacing: 0) {
                        
                        Text("😊 Turtle AI")
                            .font(.subheadline)
                            .foregroundColor(Color(kcameraviewtitletextcolor))
                            .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.025)
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .background(Color(kcameraviewtitlebgcolor))
                            .clipShape(RoundedRectangle(cornerRadius: UIScreen.main.bounds.width * 0.09))
                            
                    //hstack
                    HStack {
                        Text("🐢")
                            .font(.system(size: 19))
                            .frame(width: UIScreen.main.bounds.width * 0.1)
                            .padding(.leading, UIScreen.main.bounds.width * 0.05) // add left padding

                        GeometryReader { geometry in
                            ScrollViewReader { scrollView in
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        ForEach(carouselItems.indices, id: \.self) { index in
                                            Text(carouselItems[index])
                                                .font(currentCarouselIndex == index ? .system(size: 13, weight: .bold) : .system(size: 11, weight: .bold))
                                                .foregroundColor(Color(kcameraviewtitletextcolor))
                                                .frame(width: geometry.size.width, height: carouselTextHeight)
                                                .opacity(currentCarouselIndex == index ? 1.0 : 0.5)
                                                .scaleEffect(currentCarouselIndex == index ? 1.2 : 1.0)
                                                .id(index) // Assign ID for smooth scrolling
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .gesture(DragGesture().onChanged { _ in }) // Prevent scrolling by overriding the drag gesture
                                .disabled(true)
                                .frame(height: carouselHeight)
                                .onAppear {
                                    DispatchQueue.main.async { 
                                        
                                        currentCarouselIndex = 1
                                        scrollView.scrollTo(currentCarouselIndex, anchor: .center)// at first need to start from index 1
                                        carouselTimer = Timer.scheduledTimer(withTimeInterval: carouselTimerDuration, repeats: true) { _ in
                                            
                                                if currentCarouselIndex == carouselItems.count - 3 {
                                                    
                                                    withAnimation(.easeInOut(duration: 0.2991)) {
                                                        currentCarouselIndex += 1 // passing to carouselItems.count - 2 which is fake end
                                                        scrollView.scrollTo(currentCarouselIndex, anchor: .center)
                                                    }
                                                    //before above animation complete we setscroll  back to index 1 to create a looplike act
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2990) {
                                                        currentCarouselIndex = 1
                                                        scrollView.scrollTo(currentCarouselIndex, anchor: .center)
                                                    }
                                                }else {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        currentCarouselIndex += 1
                                                        scrollView.scrollTo(currentCarouselIndex, anchor: .center)
                                                    }
                                                }
                                                
                                        }
                                        
                                    }
                                }
                                .onDisappear {
                                    carouselTimer?.invalidate()
                                    carouselTimer = nil
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.55,height: carouselHeight)

                        Text("🐢")
                            .font(.system(size: 19))
                            .frame(width: UIScreen.main.bounds.width * 0.1)
                            .padding(.trailing, UIScreen.main.bounds.width * 0.05) // add padding to right
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.76)
                    .background(Color(kcameraviewtitlebgcolor))
                    .clipShape(RoundedRectangle(cornerRadius: UIScreen.main.bounds.width * 0.072))
                    //hstack
                        
                   }
                }
                // New header section
                
                
                VStack {
                    Spacer()
                   
                    ZStack {
                        
                        if isPhotoPreviewPresented {
                                          
                            PhotoPreviewView(viewModel: viewModel, isPresented: $isPhotoPreviewPresented,
                                             cropWidthOfCapturedImage : cropWidth * 0.8, cropHeightOfCapturedImage : cropHeight * 0.8)
                                .frame(width:  UIScreen.main.bounds.width * 0.9, height:  cropHeight * 0.8 +  UIScreen.main.bounds.height * 0.3)
                               
                        }else if !cameraManager.isCameraAuthorized{
                            VStack {
                                Text("Camera access is needed to take photos.")
                                    .foregroundColor(.white)
                                    .padding()
                                Button("Grant Camera Access") {
                                    cameraManager.requestCameraPermission()
                                }
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            }
                        }
                        
                    }
                    Spacer()
                }
               
                //camera
                Spacer()
                
                HStack(spacing: UIScreen.main.bounds.width * 0.10) {
                
                    //flash light icon
                    Button(action: toggleFlash) {
                        Image(kflashlighticonimage)
                            .resizable()
                            .renderingMode(.template) // Allows tinting
                            .foregroundColor(.white)
                            .scaledToFit() 
                            .frame(width: kcircleSubButtonHeight, height: kcircleSubButtonHeight)
                            .padding(kcircleSubButtonPadding) // Adds padding to make the button larger
                            .background(isFlashOn ? Color(kflashoffbgcolor) : Color(kflashonbgcolor))
                            .clipShape(Circle()) // Makes it a circle
                    }
                    .disabled(!cameraManager.isCameraRunning || !cameraManager.isCameraAuthorized || isPhotoPreviewPresented)
                    //flash light icon
                    
                    //capture image icon
                    Button(action: capturePhotoPressed) {
                        ZStack {
                            // Outer White Circle
                            Circle()
                                .fill(Color.white)
                                .frame(width: kcircleCamMainButtonHeight, height: kcircleCamMainButtonHeight) // Adjust as needed
                            
                            // Inner Empty Circle with Black Border
                            Circle()
                                .stroke(Color.black, lineWidth: kcircleCamInnnerButtonLineWidthHeight) // Black border
                                .frame(width: kcircleCamInnnerButtonHeight, height: kcircleCamInnnerButtonHeight) // Smaller than outer circle
                        }
                    }
                    .disabled(!cameraManager.isCameraRunning || isPhotoPreviewPresented)
                    //capture image icon
                    
                    //imagepicker icon
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(kimagepickericonimage) // Using asset image instead of system image
                            .resizable()
                            .renderingMode(.template) // Allows tinting
                            .foregroundColor(.white) // Sets the tint color to white
                            .scaledToFit()
                            .frame(width: kcircleSubButtonHeight, height: kcircleSubButtonHeight) // Same size as flash icon
                            .padding(kcircleSubButtonPadding) // Same padding for consistent circle size
                            .background(Color(kimagepickerbgcolor)) // Sets background color
                            .clipShape(Circle()) // Makes it a circle
                    }
                    .disabled(isPhotoPreviewPresented)
                    //imagepicker icon
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
               
          
        }.alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }

        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $viewModel.capturedImage, showPreview: $isPhotoPreviewPresented, showImagePicker: $showImagePicker,cropWidthForPickedImage:$cropWidth ,cropHeightForPickedImage: $cropHeight)
        }
            /*
        .sheet(isPresented: $viewModel.isSolutionReceived) {
            ResultView(viewModel: viewModel)
        }*/
            
        }
      
    }
    
    func capturePhotoPressed() {
        
        if !cameraManager.isCameraAuthorized {
            cameraManager.requestCameraPermission()
            return
        }
        
       
        
        cameraManager.capturePhoto { image in
            capturedCroppedImage = cropImage(image: image, cropWidth: cropWidth, cropHeight: cropHeight)
            viewModel.capturedImage = capturedCroppedImage
            isPhotoPreviewPresented = true
            
            //close flash if opened
            if isFlashOn {
                toggleFlash()
            }
        }
    }
    
    func toggleFlash() {
         guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
         
         do {
             try device.lockForConfiguration()
             if device.torchMode == .on {
                 device.torchMode = .off
                 isFlashOn = false
             } else {
                 try device.setTorchModeOn(level: 1.0)
                 isFlashOn = true
             }
             device.unlockForConfiguration()
         } catch {
             print("Error toggling flash: \(error)")
         }
     }
    
    private func cropImage(image: UIImage, cropWidth: CGFloat, cropHeight: CGFloat) -> UIImage? {
        // Ensure the image is correctly oriented
        guard let fixedImage = fixOrientationForCropImage(image: image) else { return nil }
        
        let imageSize = fixedImage.size
        let screenSize = UIScreen.main.bounds.size
        
        // Calculate the scale factor for aspect fill
        let scale = max(screenSize.width / imageSize.width, screenSize.height / imageSize.height)
        
        // Determine the scaled image size after aspect fill
        let scaledImageSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        
        // Calculate the offset to center the visible area in the scaled image
        let offsetX = (scaledImageSize.width - screenSize.width) / 2
        let offsetY = (scaledImageSize.height - screenSize.height) / 2
        
        // Overlay's center position on screen
        let overlayScreenX = (screenSize.width - cropWidth) / 2
        let overlayScreenY = (screenSize.height - cropHeight) / 2
        
        // Convert overlay position to scaled image coordinates (including offset)
        let scaledOverlayX = overlayScreenX + offsetX
        let scaledOverlayY = overlayScreenY + offsetY
        
        // Convert scaled coordinates back to original image coordinates
        let originalX = scaledOverlayX / scale
        let originalY = scaledOverlayY / scale
        let originalWidth = cropWidth / scale
        let originalHeight = cropHeight / scale
        
        let cropRect = CGRect(
            x: originalX,
            y: originalY,
            width: originalWidth,
            height: originalHeight
        )
        
        guard let cgImage = fixedImage.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    private func fixOrientationForCropImage(image: UIImage) -> UIImage? {
        guard image.imageOrientation != .up else { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
}

// CROP AREA STRUCTS
//rounded corner path
struct RoundedOnlyCornerPath: Shape {
    
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let shortLine: CGFloat = UIScreen.main.bounds.height * 0.1 / 2 // Length of visible side parts
        
        // Top-Left Corner
        path.move(to: CGPoint(x: 0, y: shortLine)) // Visible part of the left side
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0), control: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: shortLine, y: 0)) // Visible part of the top side

        // Top-Right Corner
        path.move(to: CGPoint(x: width - shortLine, y: 0))
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: cornerRadius), control: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: shortLine))
        
        // Bottom-Right Corner
        path.move(to: CGPoint(x: width, y: height - shortLine))
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: height), control: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width - shortLine, y: height))
        
        // Bottom-Left Corner
        path.move(to: CGPoint(x: shortLine, y: height))
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        path.addQuadCurve(to: CGPoint(x: 0, y: height - cornerRadius), control: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: height - shortLine))
        
        return path
    }
}

//rounded corner path

//const for handle and side
let handlecircleHeight = UIScreen.main.bounds.height * 0.07

let maxWidthOfCrop = UIScreen.main.bounds.width * 0.8
let maxHeightOfCrop = UIScreen.main.bounds.height * 0.4

let minForCropAreaWidth = UIScreen.main.bounds.height * 0.1
let minForCropAreaHeight = UIScreen.main.bounds.height * 0.1

//resizable circle handle
enum ResizeCircleHandlePosition {
    case bottomRight
    case bottomLeft
    case topRight
    case topLeft
}
struct ResizeCircleHandle: View {
    @Binding var cropWidth: CGFloat
    @Binding var cropHeight: CGFloat
    let handlePosition: ResizeCircleHandlePosition
    var body: some View {
        Circle()
            .frame(width: handlecircleHeight, height: handlecircleHeight)
            .foregroundColor(.clear) // Make it visually transparent
            .contentShape(Circle()) // Keep the shape interactive
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let scaleFactor: CGFloat = 1.5  // Controls how fast it grows
                        // Increase width/height based on drag translation 
                        
                        // Compute new values while ensuring they remain within valid bounds
                        // Ensure translation values are finite
                        let validTranslationWidth = value.translation.width.isFinite ? value.translation.width : 0
                        let validTranslationHeight = value.translation.height.isFinite ? value.translation.height : 0

                        // Ensure crop values are finite before modifying
                        var newCropWidth = cropWidth.isFinite ? cropWidth : minForCropAreaWidth
                        var newCropHeight = cropHeight.isFinite ? cropHeight : minForCropAreaHeight

                        switch handlePosition {
                        case .bottomRight:
                            newCropWidth += (validTranslationWidth * scaleFactor)
                            newCropHeight += (validTranslationHeight * scaleFactor)
                        case .bottomLeft:
                            newCropWidth -= (validTranslationWidth * scaleFactor)
                            newCropHeight += (validTranslationHeight * scaleFactor)
                        case .topRight:
                            newCropWidth += (validTranslationWidth * scaleFactor)
                            newCropHeight -= (validTranslationHeight * scaleFactor)
                        case .topLeft:
                            newCropWidth -= (validTranslationWidth * scaleFactor)
                            newCropHeight -= (validTranslationHeight * scaleFactor)
                        }

                        // Ensure values are within allowed range
                        newCropWidth = max(minForCropAreaWidth, min(newCropWidth, maxWidthOfCrop))
                        newCropHeight = max(minForCropAreaHeight, min(newCropHeight, maxHeightOfCrop))

                        // Update safely
                        cropWidth = newCropWidth
                        cropHeight = newCropHeight
                    }
            )
    }
}
// resizable circle handle

//resizable side handle
enum ResizableSideHandlePosition {
    case top
    case bottom
    case left
    case right
}

struct ResizableSideHandle: View {
    @Binding var cropWidth: CGFloat
    @Binding var cropHeight: CGFloat
    let sidePosition: ResizableSideHandlePosition
    
    var widthOfSideHandle: CGFloat {
            switch sidePosition {
            case .top, .bottom:
                // Ensure width is not negative
                return max(0, cropWidth - (handlecircleHeight * 2))
            case .left, .right:
                return handlecircleHeight  // Narrow width for left and right handles
            }
    }

    var heightOfSideHandle: CGFloat {
            switch sidePosition {
            case .top, .bottom:
                return handlecircleHeight  // Same height for top and bottom handles
            case .left, .right:
                // Ensure height is not negative
                return max(0, cropHeight - (handlecircleHeight * 2))
            }
    }

    var body: some View {
        Rectangle()
            .frame(width: widthOfSideHandle, height: heightOfSideHandle)
            .foregroundColor(.clear) // Make it visually transparent
            .contentShape(Rectangle()) // Keep the shape interactive
            .gesture(
                DragGesture()
                    .onChanged { value in
                       
                        // Adjust size based on the side position
                        switch sidePosition {
                        case .top:
                            let newHeight = cropHeight - value.translation.height
                            cropHeight = min(max(minForCropAreaHeight, newHeight), maxHeightOfCrop)
                            // Update width to ensure no resizing horizontally
                            cropWidth = min(max(minForCropAreaWidth, cropWidth), maxWidthOfCrop)
                            
                        case .bottom:
                            let newHeight = cropHeight + value.translation.height
                            cropHeight = min(max(minForCropAreaHeight, newHeight), maxHeightOfCrop)
                            // Update width to ensure no resizing horizontally
                            cropWidth = min(max(minForCropAreaWidth, cropWidth), maxWidthOfCrop)
                            
                        case .left:
                            let newWidth = cropWidth - value.translation.width
                            cropWidth = min(max(minForCropAreaWidth, newWidth), maxWidthOfCrop)
                            // Update height to ensure no resizing vertically
                            cropHeight = min(max(minForCropAreaHeight, cropHeight), maxHeightOfCrop)
                            
                        case .right:
                            let newWidth = cropWidth + value.translation.width
                            cropWidth = min(max(minForCropAreaWidth, newWidth), maxWidthOfCrop)
                            // Update height to ensure no resizing vertically
                            cropHeight = min(max(minForCropAreaHeight, cropHeight), maxHeightOfCrop)
                        }
                    }
            )
    }
}
//resizable side handle

// CROP AREA STRUCTS


// Camera Manager
class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var isCameraRunning = false  // Track if the camera is running
      
    @Published var isCameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    @Published var capturedImage: UIImage?  // ✅ Store captured image

    
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var captureCompletion: ((UIImage) -> Void)?

    override init() {
        super.init()
        
        isCameraRunning = false
        
        checkPermission()
    }

    func checkPermission() {
        DispatchQueue.main.async {
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                self.setupCamera()
            }
        }
    }

    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            isCameraRunning = false
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            isCameraRunning = false
            showCameraSettingsAlert()
        case .authorized:
            self.isCameraAuthorized = true
            self.setupCamera()
        @unknown default:
            break
        }
    }

    private func showCameraSettingsAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else { return }

        let alert = UIAlertController(
            title: "Camera Access Needed",
            message: "Please enable camera access in Settings to take photos.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })

        rootViewController.present(alert, animated: true)
    }


    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                
                self.output.isLivePhotoCaptureEnabled = false
                
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                
                self.session.sessionPreset = .photo
                self.session.startRunning()
                
                // Move UI updates to the main thread
                DispatchQueue.main.async {
                    self.isCameraRunning = true
                }
                
            } catch {
                print("Error setting up camera: \(error)")
                
                DispatchQueue.main.async {
                    self.isCameraRunning = false
                }
            }
        }
    }


    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        self.captureCompletion = completion
              
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else { return }
    
        DispatchQueue.main.async {
            self.captureCompletion?(image)
        }
        
    }
}
// Camera Manager

// Camera Cam Preview
struct CameraPreview: UIViewControllerRepresentable {
    let session: AVCaptureSession

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
    
           previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
           previewLayer.masksToBounds = true
        
        viewController.view.layer.addSublayer(previewLayer)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
// Camera Cam Preview

// Image Picker for Gallery
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var showPreview: Bool

    @Binding var showImagePicker: Bool
    
    @Binding var cropWidthForPickedImage: CGFloat
    @Binding var cropHeightForPickedImage: CGFloat
    func makeCoordinator() -> Coordinator {
          return Coordinator(self)
      }

      func makeUIViewController(context: Context) -> UIImagePickerController {
          let picker = UIImagePickerController()
          picker.sourceType = .photoLibrary
          picker.delegate = context.coordinator
          return picker
      }

      func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

      class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
          var parent: ImagePicker

          init(_ parent: ImagePicker) {
              self.parent = parent
          }

          func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
              if let image = info[.originalImage] as? UIImage { 
                  
                  DispatchQueue.main.async {
                      self.parent.selectedImage = image
                      self.parent.calculateCropSize(for: image)

                      // Add a slight delay before presenting preview
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                          self.parent.showImagePicker = false
                          self.parent.showPreview = true
                      }
                  }
                 
              }
              // Ensure the picker is dismissed properly
              DispatchQueue.main.async {
                  picker.dismiss(animated: true)
                  self.parent.showImagePicker = false
              }
          }
          
          func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                DispatchQueue.main.async {
                    picker.dismiss(animated: true) {
                        self.parent.showImagePicker = false
                    }
                }
          }

          
      }
    
       
      // Function to calculate crop area width and height
      func calculateCropSize(for image: UIImage) {
          
          let photoPreviewWidth = UIScreen.main.bounds.width * 0.9
          let photoPreviewHeight = UIScreen.main.bounds.height * 0.6

          let imageWidth = image.size.width / 3
          let imageHeight = image.size.height / 3
          
          let aspectRatio = imageWidth / imageHeight
          DispatchQueue.main.async { 
              
              if imageWidth > imageHeight {
                  cropWidthForPickedImage = photoPreviewWidth * 0.5
                  cropHeightForPickedImage = cropWidthForPickedImage / aspectRatio
              } else {
                  cropHeightForPickedImage = photoPreviewHeight * 0.5
                  cropWidthForPickedImage = cropHeightForPickedImage * aspectRatio
              }
          }
          // Determine crop dimensions maintaining aspect ratio
         
      }
}
// Image Picker for Gallery
