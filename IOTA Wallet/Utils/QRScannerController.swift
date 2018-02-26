//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerView: UIView {
	
	var onString: ((String)->())?
	
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
	
	func start() {
		// Get the back-facing camera for capturing videos
		let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
		
		guard let captureDevice = deviceDiscoverySession.devices.first else {
			print("Failed to get the camera device")
			return
		}
		
		do {
			// Get an instance of the AVCaptureDeviceInput class using the previous device object.
			let input = try AVCaptureDeviceInput(device: captureDevice)
			
			// Set the input device on the capture session.
			captureSession.addInput(input)
			
			// Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
			let captureMetadataOutput = AVCaptureMetadataOutput()
			captureSession.addOutput(captureMetadataOutput)
			
			// Set delegate and use the default dispatch queue to execute the call back
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
			//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
			
		} catch {
			// If any error occurs, simply print it out and don't continue any more.
			print(error)
			return
		}
		
		// Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		videoPreviewLayer?.frame = self.layer.bounds
		self.layer.addSublayer(videoPreviewLayer!)
		
		// Start video capture.
		captureSession.startRunning()
		
		// Initialize QR Code Frame to highlight the QR code
		
	}
    
    // MARK: - Helper methods

    func launchApp(decodedURL: String) {
		print(decodedURL)
		self.onString?(decodedURL)
    }

}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            if metadataObj.stringValue != nil {
                launchApp(decodedURL: metadataObj.stringValue!)
            }
        }
    }
    
}
