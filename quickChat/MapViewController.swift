//
//  MapViewController.swift
//  quickChat
//
//  Created by Edward Hung on 23/05/2016.
//  Copyright © 2016 Edward Hung. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // Outlet Decleration
    @IBOutlet weak var mapView: MKMapView!
    
    // Variable Decleration
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var region = MKCoordinateRegion()
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        
        mapView.setRegion(region, animated: false)
        
        // Add annotation
        let annotation = MKPointAnnotation()
        mapView.addAnnotation(annotation)
        annotation.coordinate = location.coordinate
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Cancel Button Pressed
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
