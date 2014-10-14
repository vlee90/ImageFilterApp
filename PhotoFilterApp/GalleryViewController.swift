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
    var galleryDelegate: GalleryDelegate?
    var flowLayout = UICollectionViewFlowLayout()
    var filteredThumbnailArray = [FilteredThumbnail]()
    
//  MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        loadPhotoArray(8)
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
        self.galleryDelegate?.clickImage(image)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView? {
//        if kind == UICollectionElementKindSectionHeader {
//            var reuseableView = collectionView.dequeueReusableCellWithReuseIdentifier("HEADER_VEW", forIndexPath: indexPath) as CollectionHeaderView
//            reuseableView.backgroundColor = UIColor.redColor()
//            return reuseableView
//        }
//        else if kind == UICollectionElementKindSectionFooter {
//            var reuseableView = collectionView.dequeueReusableCellWithReuseIdentifier("FOOTER_VIEW", forIndexPath: indexPath) as CollectionFooterView
//            reuseableView.backgroundColor = UIColor.blueColor()
//            return reuseableView
//        }
//        else {
//            return nil
//        }
//    }


//  MARK: Helpers
    func loadPhotoArray(numberOfPhotos: Int) {
        for var i = 1; i <= numberOfPhotos; i++ {
            self.imageArray.append(UIImage(named: "photo\(i)"))
        }
    }
}