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

class JourneysVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
/*
    Variables
*/
    var stack: CoreDataStack!
    var activeJourney: NSFetchedResultsController?
    var journeys: NSFetchedResultsController?
//    var journeys: [DataJourney]? = [DataJourney]()
//    var activeJourney: DataJourney?
    

/*
    IBOutlets and IBActions
*/
    

    @IBOutlet weak var tableView: UITableView!
    @IBAction func addJourney(sender: AnyObject) {
        self.createNewJourney()
    }

    
/*
    View Functions
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        let factory = CoreDataStackFactory(model: model)
        
        
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                print("Created stack!")
                self.stack = s
                self.setupFRC()
            case .Failure(let err):
                print("Failed creating the stack")
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
        let e = entity(name: EntityType.DataJourney, context: self.stack.mainContext)
        let requestJourneys = FetchRequest<DataJourney>(entity: e)
        let firstDesc = NSSortDescriptor(key: "activeString", ascending: true)
        let secondDesc = NSSortDescriptor(key: "headline", ascending: true)
        requestJourneys.sortDescriptors = [firstDesc, secondDesc]
        
//        let requestActive = FetchRequest<DataJourney>(entity: e)
//        requestActive.predicate = NSPredicate(format: "active == %@", true)
//        requestActive.sortDescriptors = [NSSortDescriptor(key: "active", ascending: true)]
        
        self.journeys = NSFetchedResultsController(fetchRequest: requestJourneys, managedObjectContext: self.stack.mainContext, sectionNameKeyPath: "activeString", cacheName: nil)
        
//        self.activeJourney = NSFetchedResultsController(fetchRequest: requestActive, managedObjectContext:self.stack.mainContext, sectionNameKeyPath: "active", cacheName: nil)
        
        self.journeys?.delegate = self
//        self.activeJourney?.delegate = self
        
        do {
            try self.journeys?.performFetch()
//            try self.activeJourney?.performFetch()
            tableView.reloadData()
        } catch {
            print("failed in fetching data")
            assertionFailure("Failed to fetch: \(error)")
        }
    }
    
    
/*
    TableView Functions
*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JourneyCell") as! JourneyCell
        
        let journey = self.journeys?.objectAtIndexPath(indexPath) as! DataJourney
        cell.headLine.text = journey.headline
        
        
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
        if editingStyle == .Delete {
            let obj = journeys?.objectAtIndexPath(indexPath) as! DataJourney
            deleteObjects([obj], inContext: self.stack.mainContext)
            saveContext(self.stack.mainContext)
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
    
    // Utility function to create and save theww new random Journeys.
    func createNewJourney() {
        // TODO: Should implement a type for the media ias parameter.
        
        // Initialize the Core Data model, this class encapsulates the notion of a .xcdatamodeld file
        // The name passed here should be the name of an .xcdatamodeld file//
//        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        
        // Initialize a default stack
//        let stack = CoreDataStack(model: model)
        
        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
//        getNewJourney(self.stack.mainContext, active: false)
        
        saveContext(stack.mainContext)
    }
}