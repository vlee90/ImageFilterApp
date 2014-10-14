//
//  CoreDataSeeder.swift
//  PhotoFilterApp
//
//  Created by Vincent Lee on 10/14/14.
//  Copyright (c) 2014 VincentLee. All rights reserved.
//

import Foundation
import CoreData
import UIKit


    //  CoreDataSeeder saves the various Filters into CoreData. Also holds function to fetch filters
class CoreDataSeeder {

    var managedObjectContext: NSManagedObjectContext
        //  Set up the context. In the view controller, the appDelegate's managedObjectContext will be passed. Singleton-like.
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
        //  This function actually saves the filters to CoreData - to a persistent store under the Entity name "Filter"
    func seedCoreData() {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
        
        var guassianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        guassianBlur.name = "CIGaussianBlur"
        
        var gloom = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gloom.name = "CIGloom"
        
        var dotScreen = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext)as Filter
        dotScreen.name = "CIDotScreen"
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        
        var colorInvert = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        colorInvert.name = "CIColorInvert"
        
        var vortexDistortion = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        vortexDistortion.name = "CIVortexDistortion"
        
        var temperatureAndTint = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        temperatureAndTint.name = "CITemperatureAndTint"
        
        var hueAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        hueAdjust.name = "CIHueAdjust"
        
        var starShineGenerator = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        starShineGenerator.name = "CIStarShineGenerator"
    }
    
    
    func fetchFiltersFromCoreData() -> [Filter]? {
            //Setup Managed Object Context
        var appDelegateObject = UIApplication.sharedApplication().delegate as AppDelegate
        var managedObjectContextObject = appDelegateObject.managedObjectContext
        
            //ManagedObjectContext makes a fetch request to the PersistenceStoreCoordinator and gets Entities named "Filter" from a persisted store.
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        let fetchResults = managedObjectContextObject?.executeFetchRequest(fetchRequest, error: nil)
        var filterArrayToReturn = [Filter]()
        if let filters = fetchResults as? [Filter] {
            return filters
        }
        else {
            return nil
        }
    }
}