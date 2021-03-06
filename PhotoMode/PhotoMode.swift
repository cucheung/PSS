//  ViewController.swift
//  Sources used: https://github.com/appcoda/FullScreenCamera, https://gist.github.com/halgatewood/0f77604d41a457ae0ec208ae6cccb220 (Rotate Button), https://stackoverflow.com/a/47402811/10498067 (Rotate UIImage)

//  Description: Camera Controller for Photo Mode
//  This file sets up the UI buttons for Photo Mode

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  10/19/2018 - Added HVAA Button placeholder
//  10/25/2018 - Code Cleanup (comments), Added View transition to ProcessPhotos
//  10/25/2018 - Added Photo Instruction Alert (Placeholder), Added Back button (in Storyboard)
//  10/25/2018 - Added Alert Dialog when Camera is not detected
//  10/27/2018 - Shutter button can now be only pressed once to avoid multiple function calls,
//               Added Error Handling when saving photos
//  11/04/2018 - Request Gallery Access along with Photo Access to fix access issue in ProcessPhotos() (Issue #1)
//  11/17/2018 - Added HVAA Implementation
//  11/22/2018 - Added Input/Output Comments to Code
//  11/24/2018 - Fixed Warnings in code
//  11/24/2018 - Added Landscape support for Viewfinder
//  11/25/2018 - Fixed Viewfinder issue (Issue #5)


import UIKit
import Photos
import CoreMotion

var cameraDetected = true
var pictureTaken = false
var HVAA_test = false
var x_accel: Double!
var y_accel: Double!

// Photo Mode View Controller class
class ViewController: UIViewController {
    
    @IBOutlet weak var captureButton: UIButton!
    
    // Displays a preview of the video output generated by the device's cameras.
    @IBOutlet fileprivate var capturePreviewView: UIView!
    
    // Allows the user to put the camera in photo mode.
    @IBOutlet fileprivate var photoModeButton: UIButton!
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    @IBOutlet weak var HVAA_Button: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    
    let cameraController = CameraController()
    
    // CMPT275 - Alias for Core Motion Library (Accelerometer / Gyroscope)
    let motion = CMMotionManager()
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // Function below runs when the view is shown to the user
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // CMPT 275 - Photo Mode Instructions Alert
        if (cameraDetected == true)
        {
            let alertController = UIAlertController(title: "Instructions", message: "Capture Button (bottom): Captures 6 photos\nFlash button (Lightning Bolt): Turn On/Off Flash\nSwitch Camera: Switch between Front/Rear Camera\nHVAA Button: Turn On/Off Horizontal Alignment Assistance", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        else
        {
            let alertController = UIAlertController(title: "Error", message: "No Camera Detected", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        //Request Photo Access
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                } else {
                    let alertController = UIAlertController(title: "Error", message: "No Gallery Access", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
}

extension ViewController {
    
    // Configure Camera Controller
    // Input/Output: NULL
    override func viewDidLoad() {
        // Observer to detect orientation change of Device to rotate icons
        NotificationCenter.default.addObserver(self, selector: #selector(rotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        // Setup Camera Viewfinder Preview
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                    cameraDetected = false
                    self.dismiss(animated: true)
                }
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        // Setup Shutter Button style
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
    
    }
    // Rotate buttons when device orientation is rotated
    @objc func rotate()
    {
        var rotation_angle: CGFloat = 0
        
        switch UIDevice.current.orientation
        {
        case .landscapeLeft:
            rotation_angle = (CGFloat(Double.pi) / 2)
        case .landscapeRight:
            rotation_angle = (CGFloat(-Double.pi) / 2)
        case .portraitUpsideDown:
            rotation_angle = CGFloat(Double.pi)
        case .unknown, .portrait, .faceUp, .faceDown:
            rotation_angle = 0
        }
        
        UIView.animate(withDuration: 0.2, animations:
            {
                // CMPT275 - Rotate buttons on screen
                self.HVAA_Button.transform = CGAffineTransform(rotationAngle: rotation_angle)
                self.captureButton.transform = CGAffineTransform(rotationAngle: rotation_angle)
                self.toggleCameraButton.transform = CGAffineTransform(rotationAngle: rotation_angle)
                self.toggleFlashButton.transform = CGAffineTransform(rotationAngle: rotation_angle)
                self.BackButton.transform = CGAffineTransform(rotationAngle: rotation_angle)
                
        }, completion: nil)
    }
}

extension UIImage {
    // Input: UIImage
    // Output: rotated UIImage based on radian value
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension ViewController {
    // Toggle Flash Button Functionality
    // Input: Flash button
    // Output: Corresponding Flash image (on/off) (type UIImage) to Flash button
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    // CMPT275 - HVAA Feature
    // Input: HVAA button
    // Output: Corresponding HVAA text (HVAA ON / HVAA OFF) to HVAA button
    @IBAction func HVAA_toggle(_ sender: UIButton) {
        if cameraController.HVAA == false {
            cameraController.HVAA = true
            HVAA_Button.setTitle("HVAA ON", for: .normal)
        }
        else {
            cameraController.HVAA = false
            HVAA_Button.setTitle("HVAA OFF", for: .normal)
        }
    }
    
    // Switch Camera Button Functionality
    // Input: HVAA button
    // Output: NULL
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
            
        case .none:
            return
        }
    }
    
    // CMPT275 - Function used to obtain x,y accelerometer data
    // Input: NULL
    // Output: double array of x and y accelerometer data
    func HVAA_Check() -> [Double?] {
        self.motion.accelerometerUpdateInterval = 0.5
        self.motion.startAccelerometerUpdates()
        sleep(1)
        x_accel = self.motion.accelerometerData?.acceleration.x
        y_accel = self.motion.accelerometerData?.acceleration.y
        self.motion.stopAccelerometerUpdates()
        let xy_data = [x_accel,y_accel]
        return xy_data
    }
    
    
    // CMPT275 - Capture Button Functionality
    // Input: "User presses button to trigger this function"
    // Output: Present ProcessPhotos View Controller
    @IBAction func captureImage(_ sender: UIButton) {
        // CMPT 275 - Disable button after single button
        captureButton.isEnabled = false
        // Determine Orientation of device to correctly save photo in landscape/portrait mode:
        var rotation_angle: Float = 0
        switch UIDevice.current.orientation
        {
        case .landscapeLeft:
            rotation_angle = (Float(-Double.pi) / 2)
        case .landscapeRight:
            rotation_angle = (Float(Double.pi) / 2)
        case .portraitUpsideDown:
            rotation_angle = Float(Double.pi)
        case .unknown, .portrait, .faceUp, .faceDown:
            rotation_angle = 0
        }
        // Check if HVAA flag is enabled
        if (cameraController.HVAA == false)
        {
            cameraController.captureImage {(image, error) in
                guard let image = image else {
                    print(error ?? "Image capture error")
                    return
                }
                let image_rotated = image.rotate(radians: rotation_angle) // Rotate 90 degrees
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image_rotated!)
                }, completionHandler: { success, error in
                    if success {
                        NSLog("Saved Photo")
                    } else {
                        NSLog("Failed Saving Photo")
                    }
                })
            }
            // CMPT275 - Present Process Photos View Controller after capturing photos
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "processphotos")
            self.present(viewController!, animated: true)
            captureButton.isEnabled = true
        }
        // Perform HVAA Analysis if HVAA is enabled
        else
        {
            // Run HVAA test for 5 seconds and error if alignment fails
            for _ in 1...5
            {
                var result = HVAA_Check()
                if (abs(result[0]!) < 0.08 || abs(result[1]!) < 0.08)
                {
                    HVAA_test = true
                    break
                }
            }
            // Check whether HVAA passed
            if (HVAA_test == true)
            {
                cameraController.captureImage {(image, error) in
                    guard let image = image else {
                        print(error ?? "Image capture error")
                        return
                    }
                    let image_rotated = image.rotate(radians: rotation_angle) // Rotate 90 degrees
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image_rotated!)
                    }, completionHandler: { success, error in
                        if success {
                            NSLog("Saved Photo")
                        } else {
                            NSLog("Failed Saving Photo")
                        }
                    })
                }
                // CMPT275 - Present Process Photos View Controller after capturing photos
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "processphotos")
                self.present(viewController!, animated: true)
                HVAA_test = false // Reset Flag
                captureButton.isEnabled = true
            }
            else
            {
                let alertController = UIAlertController(title: "Error", message: "HVAA Failed. Please Try Again", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
                captureButton.isEnabled = true
            }
        }

    

        }

    }

