//
//  ViewController.swift
//  PhotoFilterApp
//
//  Created by Vincent Lee on 10/13/14.
//  Copyright (c) 2014 VincentLee. All rights reserved.
//

import UIKit
import CoreData
import OpenGLES

class ViewController: UIViewController, GalleryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

//  MARK: Properties:
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!

    var managedObjectContext: NSManagedObjectContext!
    var filterArray = [Filter]()
    var filteredThumbnailArray = [FilteredThumbnail]()
    var originalImage: UIImage?
    var originalImageBool: Bool = true
    var originalImageThumbnail: UIImage?
    let imageViewRescaleFactor = CGFloat(2)
    var gpuContext: CIContext?
    let imageQueue = NSOperationQueue()
    
    
//  MARK: Constraints
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
//  MARK: Setup - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // CoreImage Setup
        var appDelegateObject = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegateObject.managedObjectContext
        self.fetchFilters()
        
        
        // CollectionView Setup
        self.thumbnailCollectionView.dataSource = self
        var options = [kCIContextOutputColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.gpuContext = CIContext(EAGLContext: myEAGLContext, options: options)
        self.thumbnailCollectionView.delegate = self
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
            self.resetFilterThumbnails()
            
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
        return self.filteredThumbnailArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilteredThumbnailPhotoCell
        let thumbnail = self.filteredThumbnailArray[indexPath.row]
        if thumbnail.filteredImage != nil {
            cell.thumbnailImageView.image = thumbnail.filteredImage
        }
        else {
            cell.thumbnailImageView.image = thumbnail.originalImage
            thumbnail.generateThumbnails({ (image) -> Void in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilteredThumbnailPhotoCell {
                    cell.thumbnailImageView.image = image
                }
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var selectedThumbnail = self.filteredThumbnailArray[indexPath.row]
        let selectedFilter = selectedThumbnail.filterName
        if originalImageBool == true {
            self.originalImage = selectedThumbnail.originalImage
            self.photoImageView.image = selectedThumbnail.filteredImage
            self.originalImageBool = false
        }
        else {
            self.photoImageView.image = selectedThumbnail.filteredImage
        }
        
    }

//  MARK: Functions
    func seedCoreData() {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
        
        var guassianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        guassianBlur.name = "CIGaussianBlur"
        
        var photoEffectTransfer = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTransfer.name = "CIPhotoEffectTransfer"
        
        var photoEffectNoir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext)as Filter
        photoEffectNoir.name = "CIPhotoEffectNoir"
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        
        var photoEffectChrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectChrome.name = "CIPhotoEffectChrome"
        
        var photoEffectTonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTonal.name = "CIPhotoEffectTonal"
        
        var temperatureAndTint = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        temperatureAndTint.name = "CITemperatureAndTint"
        
        var hueAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        hueAdjust.name = "CIHueAdjust"
        
        var photoEffectMono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectMono.name = "CIPhotoEffectMono"
        
        var error: NSError?
        self.managedObjectContext.save(&error)
        if error != nil {
            println(error?.localizedDescription)
        }
    }

    func fetchFilters() {
        let fetchRequest = NSFetchRequest(entityName: "Filter")
        var error: NSError?
        if let filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter] {
            if filters.isEmpty == true {
                self.seedCoreData()
                self.filterArray = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [Filter]
            }
            else {
                self.filterArray = filters
            }
        }
        self.thumbnailCollectionView.dataSource = self
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let photo = info[UIImagePickerControllerEditedImage] as UIImage
        self.photoImageView.image = photo
        self.originalImage = photo
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func enterFilterMode() {
        self.collectionViewBottomConstraint.constant = 30
        self.imageViewHeightConstraint.constant = 350
        self.imageViewTrailingConstraint.constant *= self.imageViewRescaleFactor
        self.imageViewLeadConstraint.constant *= self.imageViewRescaleFactor
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
        var getOriginalImageButton = UIBarButtonItem(title: "Original Image", style: UIBarButtonItemStyle.Bordered, target: self, action: "getOriginalImage")
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = getOriginalImageButton
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func exitFilterMode() {
        self.collectionViewBottomConstraint.constant = -200
        self.imageViewHeightConstraint.constant = 415
        self.imageViewLeadConstraint.constant /= self.imageViewRescaleFactor
        self.imageViewTrailingConstraint.constant /= self.imageViewRescaleFactor
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func getOriginalImage() {
        exitFilterMode()
        self.originalImageBool = true
        self.photoImageView.image = self.originalImage
    }
    
    //  Creates the filtered thumbnail images
    func resetFilterThumbnails() {
        //  GOAL 1) Resize the image on screen into a thumbnail
            //  Generate thumbnail from the image on screen
        var size = CGSize(width: 100, height: 100)
            //  Sets a "drawing board" bit-map of size: "size" in memory
        UIGraphicsBeginImageContext(size)
            //  Draws the image from the screen onto the "drawing board" bit-map in memory.
        self.photoImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
            //  Sets the original image as to what is currently on the "drawing board" bit-map.
        self.originalImageThumbnail = UIGraphicsGetImageFromCurrentImageContext()
            //  Resets the "drawing board" bit-map.
        UIGraphicsEndImageContext()
        //  GOAL 2) Setup thumbnail containers
            //  Create new array to hold filtered thumbnails
        var newThumbnailArray = [FilteredThumbnail]()
            //  Loop over the filters in the filerArray and create instances of them with different filters
        for filter in self.filterArray {
            let currentFilter = filter
            var filteredThumbnail = FilteredThumbnail(name: filter.name, thumbnail: self.originalImageThumbnail!, queue: self.imageQueue, context: self.gpuContext!)
            newThumbnailArray.append(filteredThumbnail)
        }
        self.filteredThumbnailArray = newThumbnailArray
        self.thumbnailCollectionView.reloadData()
    }
    
        
//  MARK: GalleryDelegateAction
    func clickImage(image: UIImage) {
        self.photoImageView.image = image
        self.originalImage = image
        resetFilterThumbnails()
    }

}

