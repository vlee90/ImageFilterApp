//
//  GalleryViewController.swift
//  PhotoFilterApp
//
//  Created by Vincent Lee on 10/13/14.
//  Copyright (c) 2014 VincentLee. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
//  MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    var imageArray = [UIImage]()
    var imageDelegate: ImageDelegate?
    var flowLayout: UICollectionViewFlowLayout!
    var filteredThumbnailArray = [FilteredThumbnail]()
    var originalThumbnailSize: CGSize!
    
//  MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        loadPhotoArray(8)
        
        
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.collectionView.addGestureRecognizer(pinchGestureRecogniser)
        self.originalThumbnailSize = self.flowLayout.itemSize
    }

//  MARK: Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.cellImageView.image = self.imageArray[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let image = self.imageArray[indexPath.row]
        self.imageDelegate?.clickImage(image)
        self.dismissViewControllerAnimated(true, completion: nil)
    }


//  MARK: Helpers
    func loadPhotoArray(numberOfPhotos: Int) {
        for var i = 1; i <= numberOfPhotos; i++ {
            self.imageArray.append(UIImage(named: "photo\(i)"))
        }
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