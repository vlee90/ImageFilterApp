//
//  PhotoFrameworkViewController.swift
//  PhotoFilterApp
//
//  Created by Vincent Lee on 10/15/14.
//  Copyright (c) 2014 VincentLee. All rights reserved.
//

import UIKit
import Photos

class PhotoFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!

    var assetFetchResult: PHFetchResult!
    var assetCollection: PHAssetCollection!
    var imageManager = PHCachingImageManager()
    var assetCellSize: CGSize!
    var imageDelegate: ImageDelegate?
    var flowLayout: UICollectionViewFlowLayout!
    var originalThumbnailSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.registerNib(UINib(nibName: "ThumbnailCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "THUMBNAIL_CELL")

        self.assetFetchResult = PHAsset.fetchAssetsWithOptions(nil)
        
        var scale = UIScreen.mainScreen().scale
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        
        self.originalThumbnailSize = self.flowLayout.itemSize
        var pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.collectionView.addGestureRecognizer(pinchGestureRecogniser)
        
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("THUMBNAIL_CELL", forIndexPath: indexPath) as ThumbnailCell
        
        var asset = self.assetFetchResult[indexPath.row] as PHAsset
        
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedAsset = self.assetFetchResult[indexPath.row] as PHAsset
        var selectedImage = UIImage()
        self.imageManager.requestImageDataForAsset(selectedAsset, options: nil) { (data, dataUTI, orientation, info) -> Void in
            selectedImage = UIImage(data: data)
            self.imageDelegate?.clickImage(selectedImage)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func pinchAction(pinch: UIPinchGestureRecognizer) {
        if pinch.state == UIGestureRecognizerState.Changed || pinch.state == UIGestureRecognizerState.Began {
            if pinch.scale <= 2 && pinch.scale >= 0.2 {
                self.flowLayout.itemSize.width = self.originalThumbnailSize!.width * pinch.scale
                self.flowLayout.itemSize.height = self.originalThumbnailSize!.height * pinch.scale
            }
        }
    }
}