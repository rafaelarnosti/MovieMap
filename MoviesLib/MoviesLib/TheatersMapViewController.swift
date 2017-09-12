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
    
    @IBOutlet weak var SerachBar: UISearchBar!
    

    @IBOutlet weak var mapView: MKMapView!    
    var theaters: [Theater] = []
    var theater: Theater!
    var currentElement: String!
    lazy var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        SerachBar.delegate = self
        loadXML()
        requestUserLocationAuthorization()
    }
    
    func getRoute(destination : CLLocationCoordinate2D){
        let request = MKDirectionsRequest()
        request.destination = MKMapItem(placemark : MKPlacemark(coordinate : destination))
        request.source = MKMapItem(placemark : MKPlacemark(coordinate : locationManager.location!.coordinate))
        
        let directions = MKDirections(request: request)
        directions.calculate { (response:MKDirectionsResponse?, error:Error?) in
            if(error == nil){
                guard let response = response else{return}
                let route = response.routes.first!
                
                for step in route.steps{
                    print("Em \(step.distance) metros, \(step.instructions)")
                }
                self.mapView.add(route.polyline, level: .aboveRoads)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                
            }else{
                print(error!.localizedDescription)
            }
        }
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
            annotation.subtitle = theater.url
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
                
                
                let btLeft = UIButton(frame: CGRect(x:0,y:0,width:30,height:30))
                btLeft.setImage(UIImage(named:"car"), for: .normal)
                annotationView.leftCalloutAccessoryView = btLeft
                
                let btRight = UIButton(type: .infoLight)
                annotationView.rightCalloutAccessoryView = btRight
            }
            else{
                annotationView.annotation = annotation
            }
        }else if annotation is MKPointAnnotation{
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "POI")
            
            if annotationView == nil{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "POI")
                (annotationView as! MKPinAnnotationView).pinTintColor = .blue
                (annotationView as! MKPinAnnotationView).animatesDrop = true
                annotationView.canShowCallout = true
            }
            else{
                annotationView.annotation = annotation
            }

        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView{
            getRoute(destination: view.annotation!.coordinate)
            
            mapView.removeOverlays(mapView.overlays)
            mapView.deselectAnnotation(view.annotation!, animated: true)
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.url = view.annotation!.subtitle!
            present(vc, animated: true,completion: nil)
        }
        mapView.deselectAnnotation(view.annotation!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 6.0
            return renderer
        }else{
            return MKOverlayRenderer(overlay: overlay)
        }
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
        
       // let region  = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 100, 100)
       // mapView.setRegion(region, animated: true)
    }
    
}

extension TheatersMapViewController:UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response :MKLocalSearchResponse?, error:Error?) in
            if(error == nil){
                guard let response = response else{return}
                var placeMarks: [MKPointAnnotation] = []
                for item in response.mapItems{
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    placeMarks.append(annotation)
                }
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(placeMarks)
                
            }else{
                print("Deu Erro:", error!.localizedDescription)
            }
            searchBar.resignFirstResponder()
        }
    }
}
