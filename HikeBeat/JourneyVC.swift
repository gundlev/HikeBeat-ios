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
import Alamofire

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
        self.navigationItem.title = journey.headline
        mapView.delegate = self
        
//        centerMapOnLocation(initialLocation)
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
            if beat.title != nil  && beat.message != nil {
                title = beat.title!
                subtitle = beat.message!
            } else if beat.title != nil  && beat.message == nil {
                title = beat.title!
            } else if beat.title == nil  && beat.message != nil {
                title = beat.message!
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
                lastPin: false,
                image: beat.createImageFromBase64())
        
            arr.append(beatPin)
        }

        arr.sortInPlace()
        let lastElement = arr.last
        lastElement?.lastPin = true
        
        let oldPins = mapView.annotations
//        mapView.removeAnnotations(mapView.annotations)
        for pin in arr {
            mapView.addAnnotation(pin)
        }
        mapView.removeAnnotations(oldPins)
        self.createPolyline(self.mapView)
        
        zoomToFitMapAnnotations(mapView)
    }
    
    
/*
    Map Functions
*/
    
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
    
    func createPolyline(mapView: MKMapView) {
        
        let beats = frc?.fetchedObjects as! [DataBeat]
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for beat in beats {
            let point = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(beat.latitude)!), longitude: CLLocationDegrees(Double(beat.longitude)!))
            points.append(point)
        }
        
//        let polyline = MKPolyline(coordinates: &points, count: points.count)
        let polyline = BeatPolyline(coordinates: &points, count: points.count)
        polyline.color = UIColor.blueColor()
        mapView.addOverlay(polyline)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(localMapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BeatPin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = localMapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: 0)
                
                let button = UIButton(type: .DetailDisclosure)
//                button.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//                button.hidden = true
                view.rightCalloutAccessoryView = button as UIView
                
                if annotation.image != nil {
                    let imgView = UIImageView()
                    let image = annotation.image!
                    if image.size.height > image.size.width {
                        let ratio = image.size.width/image.size.height
                        let newWidth = 40 * ratio
                        imgView.frame = CGRect(x: 0, y: 0, width: newWidth, height: 40)
                    } else {
                        let ratio = image.size.height/image.size.width
                        let newHeight = 40 * ratio
                        imgView.frame = CGRect(x: 0, y: 0, width: 40, height: newHeight)
                    }
                    
                    imgView.image = annotation.image!
                    view.leftCalloutAccessoryView = imgView
                }
               
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
        let polyline = overlay as! BeatPolyline
        polylineRenderer.strokeColor = polyline.color
        polylineRenderer.lineWidth = 3
        return polylineRenderer
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Pin button tapped")
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
            let pins = mapView.annotations
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
 /*
            Ready for beat timestamp implementation.
            
            let url = IPAddress + "journeys/" + obj.journeyId + "/messages/" + obj.timestamp
            
            // Sending deletion to API or saving to Changes Core Data store
            if SimpleReachability.isConnectedToNetwork() {
                Alamofire.request(.DELETE, url, encoding: .JSON, headers: Headers).responseJSON { response in
                    if response.response != nil {
                        switch response.response!.statusCode {
                        case 200:
                            print("It was successfully dealeted")
                            deleteObjects([obj], inContext: self.stack.mainContext)
                            saveContext(self.stack.mainContext)
                        default:
                            print("Unknown error with code: ", response.response?.statusCode)
                            _ = Change(context: self.stack.mainContext, instanceType: InstanceType.beat, timeCommitted: String(CACurrentMediaTime()), stringValue: nil, boolValue: false, property: nil, instanceId: obj.journeyId, changeAction: ChangeAction.delete, timestamp: obj.timestamp)
                            saveContext(self.stack.mainContext)
                        }
                    } else {
                        print("For some reason response is nil")
                    }
                }
            } else {
                // There is no connection so the deletion will be saved in changes.
                
                _ = Change(context: self.stack.mainContext, instanceType: InstanceType.beat, timeCommitted: String(CACurrentMediaTime()), stringValue: nil, boolValue: false, property: nil, instanceId: obj.journeyId, changeAction: ChangeAction.delete, timestamp: obj.timestamp)
                saveContext(self.stack.mainContext)
            }
*/

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
        let requestBeats = FetchRequest<DataBeat>(entity: e)
        let firstDesc = NSSortDescriptor(key: "timestamp", ascending: true)
        requestBeats.sortDescriptors = [firstDesc]
        requestBeats.predicate = NSPredicate(format: "journey == %@", journey)
        
        self.frc = NSFetchedResultsController(fetchRequest: requestBeats, managedObjectContext: self.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
