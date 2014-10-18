//
//  AFFoundationViewController.swift
//  PhotoFilterApp
//
//  Created by Vincent Lee on 10/16/14.
//  Copyright (c) 2014 VincentLee. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore

class AFFoundationViewController: UIViewController {

    @IBOutlet weak var capturePreviewImage: UIImageView!
    
    var stillImageOutput = AVCaptureStillImageOutput()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        if input == nil {
            println("Error in input")
        }
        captureSession.addInput(input)
        var outputSetting = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSetting
        captureSession.addOutput(self.stillImageOutput)
        captureSession.startRunning()
    }
    
    @IBAction func capturePressed(sender: AnyObject) {
        var videoConnnection: AVCaptureConnection?
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnnection = cameraConnection
                            break;
                        }
                    }
                }
            }
            if videoConnnection != nil {
                break;
            }
        }
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnnection, completionHandler: { (buffer: CMSampleBuffer!, error: NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            self.capturePreviewImage.image = image
            println(image.size)
        })
    }

}
