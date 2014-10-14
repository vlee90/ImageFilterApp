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
    
    
}