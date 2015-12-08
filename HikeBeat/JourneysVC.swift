//
//  JourneyVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 12/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire
import MapKit

class JourneysVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
/*
    Variables
*/
    var stack: CoreDataStack!
//    var activeJourney: NSFetchedResultsController?
    var journeys: NSFetchedResultsController?
    var beats: [DataBeat]!
//    var beats: NSFetchedResultsController?
//    var journeys: [DataJourney]? = [DataJourney]()
//    var activeJourney: DataJourney?
    

/*
    IBOutlets and IBActions
*/
    

    @IBOutlet weak var tableView: UITableView!
    @IBAction func toJourneys(sender: UIStoryboardSegue) {
        
    }
//    @IBAction func addJourney(sender: AnyObject) {
//        self.createNewJourney()
//        
//    }

    
/*
    View Functions
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(1)
        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        let factory = CoreDataStackFactory(model: model)
        
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                print("Created stack! Journeys")
                self.stack = s
                let beatEntity = entity(name: EntityType.DataBeat, context: self.stack.mainContext)
                let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
                do {
                    self.beats = try fetch(request: fetchRequest, inContext: self.stack.mainContext)
                } catch {
                    
                }
                self.setupFRC()
                
            case .Failure(let err):
                print("Failed creating the stack Journeys")
                print(err)
            }
        }
//        self.createThreeJourneys()
//        setJourneys()
        
//        for journey in journeys! {
//            print(journey.userId)
//            print(journey.headline)
//        }
        
//        print("active journey")
//        print(activeJourney?.userId)
//        print(activeJourney?.headline)
//        self.activeJourney?.headline = "Climbing Mount Everest"
//        print(activeJourney?.headline)
//        self.createThreeJourneys()
//        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupFRC() {
//        print(2)
//        let beatEntity = entity(name: EntityType.DataBeat, context: self.stack.mainContext)
        let e = entity(name: EntityType.DataJourney, context: self.stack.mainContext)
//        let requestBeat = FetchRequest<DataBeat>(entity: e)
        let requestJourneys = FetchRequest<DataJourney>(entity: e)
        let firstDesc = NSSortDescriptor(key: "activeString", ascending: true)
        let secondDesc = NSSortDescriptor(key: "headline", ascending: true)
        requestJourneys.sortDescriptors = [firstDesc, secondDesc]
//        print(3)
//        let requestActive = FetchRequest<DataJourney>(entity: e)
//        requestActive.predicate = NSPredicate(format: "active == %@", true)
//        requestActive.sortDescriptors = [NSSortDescriptor(key: "active", ascending: true)]
        
        self.journeys = NSFetchedResultsController(fetchRequest: requestJourneys, managedObjectContext: self.stack.mainContext, sectionNameKeyPath: "activeString", cacheName: nil)
//        self.beats = NSFetchedResultsController(fetchRequest: requestJourneys, managedObjectContext: self.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
//        self.activeJourney = NSFetchedResultsController(fetchRequest: requestActive, managedObjectContext:self.stack.mainContext, sectionNameKeyPath: "active", cacheName: nil)
        
        self.journeys?.delegate = self
//        self.activeJourney?.delegate = self
        
        do {
            try self.journeys?.performFetch()
//            try self.beats?.performFetch()
            tableView.reloadData()
//            print(4)
        } catch {
//            print("failed in fetching data")
            assertionFailure("Failed to fetch: \(error)")
        }
        
    }
    
    
    func zoomToFitMapAnnotations(aMapView: MKMapView) {
        if aMapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in aMapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = aMapView.regionThatFits(region)
        aMapView.setRegion(region, animated: true)
    }
    
    
/*
    TableView Functions
*/
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        print(5)
        let cell = tableView.dequeueReusableCellWithIdentifier("JourneysCell") as! JourneysCell
        
        let journey = self.journeys?.objectAtIndexPath(indexPath) as! DataJourney
        var journeyBeats = [DataBeat]()
        for beat in beats {
            if beat.journey == journey {
                journeyBeats.append(beat)
            }
        }
//        print(5.1)
//        cell.setupCell(self.stack, journey: journey, active: (indexPath.section == 0))
        cell.setupCell2(journeyBeats)
//        print(5.11)
        cell.headline.text = journey.headline
//        print(5.12)
        if indexPath.section == 0 {
            cell.bgImage.alpha = 0.7
            cell.bgImage.image = UIImage(named: "CellImage1")!
        } else {
            cell.bgImage.alpha = 0.4
            switch indexPath.row {
            case 0:
                print("case 0")
                cell.bgImage.image = UIImage(named: "CellImage2")!
            default:
                print("case 1")
                cell.bgImage.image = UIImage(named: "CellImage3")!
            }
        }
//        print(5.2)
        print("indexpath row: ", indexPath.row)
        print("indexpath section: ", indexPath.section)
//        if indexPath.section == 0 {
//            print("section 0, row " + indexPath.row.description)
//            let active = self.activeJourney?.objectAtIndexPath(indexPath) as! DataJourney
//            cell.headLine.text = active.headline
//        } else {
//            print("section 1, row " + indexPath.row.description)
//            let journey = self.journeys?.objectAtIndexPath(indexPath) as! DataJourney
//            cell.headLine.text = journey.headline
//        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(6)
        return (journeys?.sections?[section].numberOfObjects)!
//        if section == 0 {
//            if activeJourney != nil {
//                print("setting number of rows in section 0 to: " + (activeJourney?.fetchedObjects?.count)!.description)
//                return (activeJourney?.fetchedObjects?.count)!
//            } else {
//                print("setting section 0 to 0 rows")
//                return 0
//            }
//        } else {
//            if journeys != nil {
//                print("setting number of rows in section 1 to " + (journeys?.fetchedObjects?.count)!.description)
//                return (journeys?.fetchedObjects?.count)!
//            } else {
//                return 0
//            }
//        }
        
//        if journeys != nil {
//            if section == 0 {
//                if activeJourney != nil {
//                    return 1
//                } else {
//                    return 0
//                }
//            } else {
//                return (self.journeys?.count)!
//            }
//        } else {
//            return 0
//        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = journeys!.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
        
//        switch section {
//        case 0: return "Active Journey"
//        case 1: return "Finnished and Planned Journeys"
//        default: return "Something is wrong here"
//        }
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        print(8)
        return self.journeys!.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        return self.journeys!.sectionIndexTitles
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if journeys != nil {
            return (journeys?.sections?.count)!
        } else {
            return 0
        }
        
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            let obj = journeys?.objectAtIndexPath(indexPath) as! DataJourney
//            deleteObjects([obj], inContext: self.stack.mainContext)
//            saveContext(self.stack.mainContext)
//        }

    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        print(7)
        
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { (UITableViewRowAction, NSIndexPath) -> Void in
            let obj = self.journeys?.objectAtIndexPath(indexPath) as! DataJourney
            deleteObjects([obj], inContext: self.stack.mainContext)
            saveContext(self.stack.mainContext)
        }
        
        if self.journeys?.sections?.count == 2 {
            if indexPath.section == 0 {
                let deactivate = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Deactivate") { (action: UITableViewRowAction, indexpath: NSIndexPath) -> Void in
                    let journey = self.journeys?.objectAtIndexPath(indexpath) as! DataJourney
                    journey.setActiveStatus(false)
                    saveContext(self.stack.mainContext)
                }
                return [delete, deactivate]
            } else {
                let activate = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Activate") { (action: UITableViewRowAction, indexpath: NSIndexPath) -> Void in
                    let journey = self.journeys?.objectAtIndexPath(indexpath) as! DataJourney
                    journey.setActiveStatus(true)
                    saveContext(self.stack.mainContext)
                }
                return [delete, activate]
            }
        } else {
            let activate = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Activate") { (action: UITableViewRowAction, indexpath: NSIndexPath) -> Void in
                let journey = self.journeys?.objectAtIndexPath(indexpath) as! DataJourney
                journey.setActiveStatus(true)
                saveContext(self.stack.mainContext)
            }
            return [delete, activate]
        }

        
        
    }
    
    
/*
    FetchedResultControllerDelegate functions
*/
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                break
            }
    }
    
    func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                print("update")
                //configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
/*
    CoreData Functions
*/
    
    // Utility function to create and save new random Journey.
    func createNewJourney() {
        
        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
        
        saveContext(stack.mainContext)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toJourney" || segue.identifier == "toJourney2" {
            let vc = segue.destinationViewController as! JourneyVC
            let journey = journeys?.objectAtIndexPath(tableView.indexPathForSelectedRow!) as! DataJourney
            print(journey.headline)
            vc.stack = self.stack
            vc.journey = journey
        } else if segue.identifier == "addJourney" {
            let vc = segue.destinationViewController as! NewJourneyVC
            vc.stack = self.stack
        }
        
    }
}




// Old Code
//func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    
//    return (journeys?.sections?[section].numberOfObjects)!
//    //        if section == 0 {
//    //            if activeJourney != nil {
//    //                print("setting number of rows in section 0 to: " + (activeJourney?.fetchedObjects?.count)!.description)
//    //                return (activeJourney?.fetchedObjects?.count)!
//    //            } else {
//    //                print("setting section 0 to 0 rows")
//    //                return 0
//    //            }
//    //        } else {
//    //            if journeys != nil {
//    //                print("setting number of rows in section 1 to " + (journeys?.fetchedObjects?.count)!.description)
//    //                return (journeys?.fetchedObjects?.count)!
//    //            } else {
//    //                return 0
//    //            }
//    //        }
//    
//    //        if journeys != nil {
//    //            if section == 0 {
//    //                if activeJourney != nil {
//    //                    return 1
//    //                } else {
//    //                    return 0
//    //                }
//    //            } else {
//    //                return (self.journeys?.count)!
//    //            }
//    //        } else {
//    //            return 0
//    //        }
//}




//    func setJourneys() {
//
//        let model = CoreDataModel(name: ModelName, bundle: Bundle)
////        let stack = CoreDataStack(model: model)
//        let beatEntity = entity(name: EntityType.DataJourney, context: self.stack.mainContext)
//        let fetchRequest = FetchRequest<DataJourney>(entity: beatEntity)
//
//        do {
//            var result = try fetch(request: fetchRequest, inContext: stack.mainContext)
//            print("Fetch success")
//            print(result.count)
//            for journey in result {
////                print("has entered forloop")
////                print(journey.userId)
////                print(journey.headline)
//                if journey.active == true {
////                    print("has found true one")
//                    self.activeJourney = journey
//                } else {
////                    print("not true one")
//                    self.journeys?.append(journey)
//                }
//            }
//        } catch {
//            print("The fetch failed")
//            self.journeys = nil
//        }
//    }
//