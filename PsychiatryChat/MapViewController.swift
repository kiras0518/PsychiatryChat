//
//  MapViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/22.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    struct Clinic {
        var name: String
        var phone: String
        var address: String
        //let coordinate: CLLocationCoordinate2D?
        init(name: String, phone: String, address: String) {
            self.name = name
            self.phone = phone
            self.address = address
            //self.coordinate = coordinate
        }
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAPI()
        self.locationManager.delegate = self
        // 設定為最佳精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 詢問使用者是否取得當前位置的授權
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        self.mapView.delegate = self
        //self.mapView.showsUserLocation = true   //顯示user位置
        self.mapView.userTrackingMode = .follow  //隨著user移動

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let studioAnnotation = MKPointAnnotation()
        // 設定大頭針座標
        studioAnnotation.coordinate = CLLocationCoordinate2D(latitude: 22.999613, longitude: 120.212775)
        // 將大頭針的座標位置設為我們的地圖的中心點
        mapView.setCenter(studioAnnotation.coordinate, animated: true)
        // 將大頭針加入 mapView 中
        mapView.addAnnotation(studioAnnotation)
    }
//        func mapView(_ mapView: MKMapView, didUpdate: MKUserLocation) {
//            let gerion = MKCoordinateRegion(center: (didUpdate.location?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//            mapView.region = gerion
//        }
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
////        var view: MKPinAnnotationView?
////        let identifier = "pin"
////        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
////            as? MKPinAnnotationView {
////            dequeuedView.annotation = annotation
////            view = dequeuedView
////        } else {
////            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
////            view?.canShowCallout = true
////            view?.calloutOffset = CGPoint(x: -5, y: 5)
////            //view?.pinTintColor = annotation.pinColor()
////            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
////        }
////        return view
//    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //由於我們的 "startUpdatingLocation()" 會回傳一個陣列的 CLLocation ，而最後回傳的會是最接近於我們當前位置的 CLLocation 。 因此我們要娶的就是這個 CLLocation
        let location = locations[locations.count - 1]  //the method "startUpdatingLocation()" is gonna grab a set of locations that are getting more & more accurate. So we'd want the last location in this array
        //簡單檢查一下取得的值
        if location.horizontalAccuracy > 0 {  //this line will check if the location is available
            // 由於定位功能十分耗電，我們既然已經取得了位置，就該速速把它關掉
            locationManager.stopUpdatingLocation()
            print("latitude: \(location.coordinate.latitude), longtitude: \(location.coordinate.longitude)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "ClinicCell", for: indexPath) as? ClinicCell {
//            cell.address.text = self.clinicInfo[indexPath.row].address
//            return cell
//        }
       return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    var clinicInfo:[Clinic] = []
    let APIString = "https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=d3041a46-61e0-4d6e-9734-494a0a049e73"

    func fetchAPI() {
        guard let APIUrl = URL(string: APIString) else { print("API ERROR"); return}
        var request = URLRequest(url: APIUrl)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let jsonData = data else { print("URLSession data Error"); return }
            do {
                let json: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let rootDictionary = json as? [String: Any] else { print("rootDictionary"); return }
                //print(rootDictionary)
                guard let result = rootDictionary["result"] as? [String: Any] else { print("results error"); return }
                //print(result)
                //guard let count = result["count"] as? Int else { print("count error"); return }
                guard let results = result["results"] as? [[String: Any]] else { print("results error"); return }
                //print(results)
                for data in results {
                    //print(data)
                    guard let name = data["診所名稱"] as? String else { print("name error"); return }
                    guard let phone = data["電話"] as? String else { print("phone error"); return }
                    guard let address = data["地址"] as? String else {print("address error"); return}
                    let dataInfo: Clinic = Clinic.init(name: name, phone: phone, address: address)
                    self.clinicInfo.append(dataInfo)
                    print(self.clinicInfo)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
        print("加載完成")
    }

}
