//
//  JourneyVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 15/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class JourneyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    var stack: CoreDataStack!
    var journey: DataJourney!
    var frc: NSFetchedResultsController?
    
    let initialLocation = CLLocation(latitude: 55.700746, longitude: 12.551740)
    let regionRadius: CLLocationDistance = 1000
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        setupFRC()
        
        mapView.delegate = self
        
        centerMapOnLocation(initialLocation)
    }
    
    override func viewDidAppear(animated: Bool) {
        do {
            try self.frc?.performFetch()
            self.tableView.reloadData()
        } catch {
            assertionFailure("Failed to fetch: \(error)")
        }
        
        let beats = frc?.fetchedObjects as! [DataBeat]
        var arr = [BeatPin]()
        for beat in beats {
            
            var title = ""
            var subtitle = ""
            if beat.title != nil {
                title = beat.title!
            }
            if beat.message != nil {
                subtitle = beat.message!
            }
            
            let beatPin = BeatPin(
                title: title,
                timestamp: beat.timestamp,
                subtitle: subtitle,
                locationName: "Some Place",
                discipline: beat.journeyId,
                coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(beat.latitude)!), longitude: CLLocationDegrees(Double(beat.longitude)!)),
                lastPin: false)
        
            arr.append(beatPin)
        }

        arr.sortInPlace()
        let lastElement = arr.last
        lastElement?.lastPin = true
        
        mapView.removeAnnotations(mapView.annotations)
        for pin in arr {
            mapView.addAnnotation(pin)
        }
        
        self.createPolyline(self.mapView)
    }
    
    
/*
    Map Functions
*/
    
    func createPolyline(mapView: MKMapView) {
        
        let beats = frc?.fetchedObjects as! [DataBeat]
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for beat in beats {
            let point = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(beat.latitude)!), longitude: CLLocationDegrees(Double(beat.longitude)!))
            points.append(point)
        }
        
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        mapView.addOverlay(polyline)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BeatPin {
            let identifier = "pin"
            //            var view: SVPulsingAnnotationView
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: 0)
                
                //                let meetUp = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                //                meetUp.titleLabel?.text = "Meet Up"
                //                meetUp.imageView?.image = UIImage(named: "iungoAppIcon")
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                //                view.rightCalloutAccessoryView = meetUp as UIView
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                imgView.image = UIImage(named: "ProfileImage")!
                view.leftCalloutAccessoryView = imgView
                let pinImage = UIImage(named: "HBPin")
                view.image = pinImage
                view.centerOffset.y = -((pinImage?.size.height)!/2)
                let point = CGPoint(x: view.center.x + view.frame.width/2, y: (view.center.y + (view.frame.height)))
                
                if annotation.lastPin == true {
                    let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:40, position:point)
                    pulseEffect.pulseInterval = 0
                    view.layer.insertSublayer(pulseEffect, below: view.layer)
                }

            }
            return view
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }

    
/*
    TableView Functions
*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if frc != nil {
            return (frc?.sections?[section].numberOfObjects)!
        } else {
            print("frc nil")
            return 0
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeatCell") as! BeatCell
        let beat = self.frc?.objectAtIndexPath(indexPath) as! DataBeat
        cell.titleLabel.text = beat.title
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let obj = frc?.objectAtIndexPath(indexPath) as! DataBeat
            
            // Deleting the annotation on the map
            var pins = mapView.annotations
            for pin in pins {
                if pin.title! == obj.title {
                    print("Removing pin with title: ", pin.title!!)
                    mapView.removeAnnotation(pin)
                }
            }
            var beatPins = mapView.annotations as! [BeatPin]
            beatPins.sortInPlace()
            let lastPin = beatPins.last
            if lastPin?.lastPin != true {
                lastPin?.lastPin = true
                mapView.removeAnnotation(lastPin!)
                mapView.addAnnotation(lastPin!)
            }


            
            // Deleting the object in the database.
            deleteObjects([obj], inContext: self.stack.mainContext)
            saveContext(self.stack.mainContext)
            
            // Deleting the old polyline and creating a new one.
            let overlays = mapView.overlays
            for overlay in overlays {
                if overlay.isKindOfClass(MKPolyline) {
                    mapView.removeOverlay(overlay)
                }
            }
            self.createPolyline(mapView)
        }
    }
    
    
    func setupFRC() {
        let e = entity(name: EntityType.DataBeat, context: self.stack.mainContext)
        let requestJourneys = FetchRequest<DataBeat>(entity: e)
        let firstDesc = NSSortDescriptor(key: "timestamp", ascending: false)
        requestJourneys.sortDescriptors = [firstDesc]
        
        self.frc = NSFetchedResultsController(fetchRequest: requestJourneys, managedObjectContext: self.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.frc?.delegate = self
        
        do {
            try self.frc?.performFetch()
            self.tableView.reloadData()
        } catch {
            assertionFailure("Failed to fetch: \(error)")
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
}