//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 06/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheatersMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!    
    var theaters: [Theater] = []
    var theater: Theater!
    var currentElement: String!
    lazy var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadXML()
        requestUserLocationAuthorization()
    }
    
    func requestUserLocationAuthorization(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = true
            
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways, .authorizedWhenInUse:
                print("Liberaado")
            case .denied:
                print("fudeu")
            case .notDetermined:
                print("Ainda não liberou")
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Não tem acesso a bagaça toda")
            }
        }
    }
    
    func addTheaters(){
        for theater in theaters{
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            let annotation = TheaterAnnotation(coordinate: coordinate)
            annotation.title = theater.name
            annotation.subtitle = theater.address
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadXML() {
       if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser =
        XMLParser(contentsOf: xmlURL){
            xmlParser.delegate = self
            xmlParser.parse()
        }
    }

}
    extension TheatersMapViewController: XMLParserDelegate{
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            //print("Inicio:",elementName)
            
            currentElement = elementName
            if(elementName == "Theater"){
                theater = Theater()
            }
            
        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            //print("Conteudo",string)
            let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if !content.isEmpty{
            switch currentElement {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)!
            case "longitude":
                theater.longitude = Double(content)!
            case "url":
                theater.url = content
            default:
                break
                }
            }
        }
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            //print ("Fim:", elementName)
            
            if(elementName == "Theater"){
                theaters.append(theater)
            }
            
        }
        
        func parserDidEndDocument(_ parser: XMLParser) {
            addTheaters()
        }
}
extension TheatersMapViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView : MKAnnotationView!
        
        if annotation is TheaterAnnotation{
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annotationView.image = UIImage(named: "theaterIcon")
                annotationView.canShowCallout = true
            }
            else{
                annotationView.annotation = annotation
            }
        }
        
        return annotationView
    }
}

extension TheatersMapViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            break
        }
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.location!.speed)
    }
    
}
