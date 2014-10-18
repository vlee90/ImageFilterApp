//
//  FilteredThumbnail.swift
//  PhotoFilterApp
//
//  Created by Vincent Lee on 10/14/14.
//  Copyright (c) 2014 VincentLee. All rights reserved.
//

import Foundation
import UIKit

class FilteredThumbnail {
    var originalImage: UIImage
    var filteredImage: UIImage?
    var filter: CIFilter?
    var imageQueue: NSOperationQueue
    var gpuContext: CIContext
    var filterName: String
    
    
    init(name: String, thumbnail: UIImage, queue: NSOperationQueue, context: CIContext) {
        self.filterName = name
        self.originalImage = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }
    
    func generateThumbnails (completionHandler: (image: UIImage) -> Void) {
        self.imageQueue.addOperationWithBlock { () -> Void in
                //  Set up Filter with CIImage.
            var image = CIImage(image: self.originalImage)
                    //  Initialize CIFilter with specified name.
            var imageFilter = CIFilter(name: self.filterName)
                    //  Sets Filter to default input values
            imageFilter.setDefaults()
                    //  Alters Filter's effect with kCIInputImageKey
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            if imageFilter.name() == "CITwirlDistortion" {
                imageFilter.setValue(CIVector(x: 50, y: 50), forKey: "inputCenter")
                imageFilter.setValue(NSNumber(int: 40), forKey: "inputRadius")
                imageFilter.attributes()
            }
            println(imageFilter.name())
                //  Generate the filtered image
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
                    //  Sets up rectangular shape for image to be formed in.
            var extent = result.extent()
                    //  gpuContext finally creates the filtered Image.
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.filter = imageFilter
                    //  Convert CGImage too UIImage
            self.filteredImage = UIImage(CGImage: imageRef)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: self.filteredImage!)
            })
        }
    }
}