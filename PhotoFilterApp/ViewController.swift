//
//  ViewController.swift
//  PhotoFilterApp
//
//  Created by Vincent Lee on 10/13/14.
//  Copyright (c) 2014 VincentLee. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, GalleryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource {

//  MARK: Properties:
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    var filters = [Filter]()
    var filteredThumbnails = [FilteredThumbnail]()
    let imageViewRescaleFactor = CGFloat(2)
    var imageContext: CIContext?
    let imageQueue = NSOperationQueue()
    
//  MARK: Constraints
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
//  MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // CoreImage Setup
        var appDelegateObject = UIApplication.sharedApplication().delegate as AppDelegate
        var managedObjectContent = appDelegateObject.managedObjectContext
        var coreImageSeeder = CoreDataSeeder(context: managedObjectContent!)
        self.filters = coreImageSeeder.fetchFiltersFromCoreData()!
        
        // CollectionView Setup
        self.thumbnailCollectionView.dataSource = self
        var options = [kCIContextOutputColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.imageContext = CIContext(EAGLContext: myEAGLContext, options: options)
    }

//  MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.galleryDelegate = self
        }
    }

//  MARK: IBActions
    @IBAction func photoButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Options", message: "Grab a photo from...", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePickerObject = UIImagePickerController()
            imagePickerObject.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                println("No camera avalibile")
            }
            else {
                imagePickerObject.delegate = self
                imagePickerObject.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                self.presentViewController(imagePickerObject, animated: true, completion: nil)
            }
        }
        
        let filterAction = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.enterFilterMode()
            self.generateThumbnails()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil) 

        alertController.addAction(galleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        alertController.addAction(filterAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
//  MARK: CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilteredThumbnailPhotoCell
        var selectedThumbnail = self.filteredThumbnails[indexPath.row]
        if selectedThumbnail.filteredImage != nil {
            cell.thumbnailImageView.image = selectedThumbnail.filteredImage
        }
        else {
            cell.thumbnailImageView.image = selectedThumbnail.originalImage
        }
    }

//  MARK: Functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let photo = info[UIImagePickerControllerEditedImage] as UIImage
        self.photoImageView.image = photo
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func enterFilterMode() {
        self.collectionViewBottomConstraint.constant = 70
        self.imageViewBottomConstraint.constant *= self.imageViewRescaleFactor * CGFloat(3)
        self.imageViewTrailingConstraint.constant *= self.imageViewRescaleFactor
        self.imageViewLeadConstraint.constant *= self.imageViewRescaleFactor
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    
//  MARK: GalleryDelegateAction
    func clickImage(image: UIImage) {
        self.photoImageView.image = image
    }

}

