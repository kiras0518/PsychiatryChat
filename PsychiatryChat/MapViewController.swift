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

class MapViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

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
//        // 設定為最佳精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 詢問使用者是否取得當前位置的授權
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        self.mapView.delegate = self
        self.mapView.showsUserLocation = true   //顯示user位置
        self.mapView.userTrackingMode = .follow  //隨著user移動
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        //checkLocationAuthorizationStatus()
    }

//    func checkLocationAuthorizationStatus() {
//        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            self.mapView.showsUserLocation = true   //顯示user位置
//            self.mapView.userTrackingMode = .follow  //隨著user移動
//        } else {
//            self.locationManager.requestWhenInUseAuthorization()
//            self.locationManager.startUpdatingLocation()
//        }
//    }
    
    
    func setupData() {
        // 1. 檢查系統是否能夠監視 region
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // 2.準備 region 會用到的相關屬性
            let title = "Lorrenzillo's"
            let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735)
            let regionRadius = 300.0
            
            // 3. 設置 region 的相關屬性
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
            longitude: coordinate.longitude), radius: regionRadius, identifier: title)
            locationManager.startMonitoring(for: region)
            // 4. 創建大頭釘(annotation)
            let restaurantAnnotation = MKPointAnnotation()
            restaurantAnnotation.coordinate = coordinate;
            restaurantAnnotation.title = "\(title)";
            mapView.addAnnotation(restaurantAnnotation)
            // 5. 繪製一個圓圈圖形（用於表示 region 的範圍）
            let circle = MKCircle(center: coordinate, radius: regionRadius)
            mapView.addOverlay(circle)
        }
        else {
            print("System can't track regions")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clinicInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ClinicCell", for: indexPath) as? ClinicCell {
            cell.address.text = self.clinicInfo[indexPath.row].address
            cell.name.text = self.clinicInfo[indexPath.row].name
            cell.phone.text = self.clinicInfo[indexPath.row].phone
            return cell
        }
       return UITableViewCell()
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }

    var clinicInfo: [Clinic] = []

    let APIString = "https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=d3041a46-61e0-4d6e-9734-494a0a049e73"

    func fetchAPI() {
        guard let APIUrl = URL(string: APIString) else { print("API ERROR"); return}
        let request = URLRequest(url: APIUrl)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let jsonData = data else { print("URLSession data Error"); return }
            do {
                let json: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let rootDictionary = json as? [String: Any] else { print("rootDictionary"); return }
                guard let result = rootDictionary["result"] as? [String: Any] else { print("results error"); return }
                guard let results = result["results"] as? [[String: Any]] else { print("results error"); return }
                for data in results {
                    //print(data)
                    guard let name = data["診所名稱"] as? String else { print("name error"); return }
                    guard let phone = data["電話"] as? String else { print("phone error"); return }
                    guard let address = data["地址"] as? String else {print("address error"); return}
                    let dataInfo = Clinic.init(name: name, phone: phone, address: address)
                    self.configure(location: address, detailName: name)
                    self.clinicInfo.append(dataInfo)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
        print("加載完成")
    }

    func configure(location: String, detailName: String) {
        let geoCoder = CLGeocoder()
        //print("locationsss", location)
        geoCoder.geocodeAddressString(location, completionHandler: { placemarks, error in
            if let error = error {
                print("Map error", error.localizedDescription)
                return
            }
            if let placemarks = placemarks {
                //取得第一個地點標記
                let placemark = placemarks[0]
                // 加上地圖標註
                let annotation = MKPointAnnotation()
                annotation.title = detailName
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    // Display the annotation
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                    //設定縮放程度
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })
    }
}

extension MapViewController: CLLocationManagerDelegate {
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
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate: MKUserLocation) {
    let gerion = MKCoordinateRegion(center: (didUpdate.location?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.region = gerion
    }
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        var view: MKPinAnnotationView?
//        let identifier = "pin"
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
//        dequeuedView.annotation = annotation
//        } else {
//            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view?.canShowCallout = true
//            view?.calloutOffset = CGPoint(x: -5, y: 5)
//        }
//        return view
//    }
}
