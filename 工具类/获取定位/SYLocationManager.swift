//
//  SYLocationManager.swift
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/6/28.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit
import SVProgressHUD
typealias SYLocationManagerBlock = ([SYBaseLocationSelectedModel])->()
class SYLocationManager: NSObject,CLLocationManagerDelegate {
    static let syLocationManager = SYLocationManager()
    var locationManager : AMapLocationManager!
    var searchManager : AMapSearchAPI!
    var locationManagerBlock : SYLocationManagerBlock!
    
    func location(text:String,locationManagerBlock:@escaping ([SYBaseLocationSelectedModel])->()) {
        
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setImageViewSize(CGSize.zero)
            SVProgressHUD.setMinimumDismissTimeInterval(5)
            SVProgressHUD.showError(withStatus: "请在设置中允许定位")
            return
        }
        
        
        XYProgressHUD.showLoding()
        locationManager = AMapLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.locationTimeout = 2
        locationManager.reGeocodeTimeout = 2
        locationManager.delegate = self
        searchManager = AMapSearchAPI()
        searchManager.delegate = self
        locationManager.requestLocation(withReGeocode: false) {[weak self] (location, reGeocode, error) in
            if let error = error {
                let error = error as NSError
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    XYProgressHUD.dissmiss()
                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
            }
            if let location = location {
                let request = AMapPOIAroundSearchRequest()
                request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
                request.keywords = text
                request.requireExtension = true
                self?.locationManagerBlock = locationManagerBlock
                self?.searchManager.aMapPOIAroundSearch(request)
            }
        }
    }
    
   
}
extension SYLocationManager : AMapSearchDelegate,AMapLocationManagerDelegate{
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        XYProgressHUD.dissmiss()
        if response.count == 0 {
            return
        }
        let poisArray = response.pois.map({SYBaseLocationSelectedModel(model: $0)})
        self.locationManagerBlock?(poisArray)
    }
    func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
}
