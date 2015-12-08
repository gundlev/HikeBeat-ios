//
//  JourneysCell.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 30/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import MapKit

class JourneysCell: UITableViewCell,  MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    
    var journey: DataJourney!
    var stack: CoreDataStack!
    var beats = [DataBeat]()
    var active = true
    
    override func awakeFromNib() {
        mapView.delegate = self
    }
    
    func setupCell(stack: CoreDataStack, journey: DataJourney, active: Bool) {
        self.active = active
        let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)
        
        let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
        fetchRequest.predicate = NSPredicate(format: "journey == %@", journey)
        
        do {
            self.beats = try fetch(request: fetchRequest, inContext: stack.mainContext)
            var arr = [BeatPin]()
            for beat in beats {
               // print("Journey: ",journey.headline, ", beat: ", beat.title)
                
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

        } catch {
            print("The fetch failed")
        }
    }
    
    func setupCell2(dataBeats: [DataBeat]) {
//        print(10)
        self.beats = dataBeats
            var arr = [BeatPin]()
            for beat in dataBeats {
                // print("Journey: ",journey.headline, ", beat: ", beat.title)
                
                var title = ""
                var subtitle = ""
                if beat.title != nil {
                    title = beat.title!
                }
                if beat.message != nil {
                    subtitle = beat.message!
                }
                //print(beat)
                let beatPin = BeatPin(
                    title: title,
                    timestamp: beat.timestamp,
                    subtitle: subtitle,
                    locationName: "Some Place",
                    discipline: beat.journeyId,
                    coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(beat.latitude)!), longitude: CLLocationDegrees(Double(beat.longitude)!)),
                    lastPin: false,
                    image: beat.createImageFromBase64())
//                print(12)
                
                arr.append(beatPin)
            }
        
            arr.sortInPlace()
            let lastElement = arr.last
            lastElement?.lastPin = true
//            print(12)
            let oldPins = mapView.annotations
            //        mapView.removeAnnotations(mapView.annotations)
            for pin in arr {
                mapView.addAnnotation(pin)
            }
            mapView.removeAnnotations(oldPins)
            self.createPolyline(self.mapView)
            print(13)
            zoomToFitMapAnnotations(mapView)

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
        aMapView.setRegion(region, animated: false)
    }
    
    func createPolyline(mapView: MKMapView) {
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
    
//    func centerMapOnLocation(location: CLLocation) {
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
//            regionRadius * 2.0, regionRadius * 2.0)
//        mapView.setRegion(coordinateRegion, animated: true)
//    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BeatPin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: 0, y: 0)
//                
//                var button = UIButton(type: .DetailDisclosure)
//                //                button.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//                //                button.hidden = true
//                view.rightCalloutAccessoryView = button as UIView
//                
//                if annotation.image != nil {
//                    let imgView = UIImageView()
//                    let image = annotation.image!
//                    if image.size.height > image.size.width {
//                        let ratio = image.size.width/image.size.height
//                        let newWidth = 40 * ratio
//                        imgView.frame = CGRect(x: 0, y: 0, width: newWidth, height: 40)
//                    } else {
//                        let ratio = image.size.height/image.size.width
//                        let newHeight = 40 * ratio
//                        imgView.frame = CGRect(x: 0, y: 0, width: 40, height: newHeight)
//                    }
//                    
//                    imgView.image = annotation.image!
//                    view.leftCalloutAccessoryView = imgView
//                }
//
//                let pinImage = UIImage(named: "emptyPin")
                view.image = nil
//                view.centerOffset.y = -((pinImage?.size.height)!/2)
                let point = CGPoint(x: view.center.x + view.frame.width/2, y: (view.center.y + (view.frame.height)))
                
                if self.active {
                    if annotation.lastPin == true {
                        let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position:point)
                        pulseEffect.pulseInterval = 0
                        view.layer.insertSublayer(pulseEffect, below: view.layer)
                    }
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
        polylineRenderer.lineWidth = 1
        return polylineRenderer
    }
    
//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("Pin button tapped")
//    }

    
}
