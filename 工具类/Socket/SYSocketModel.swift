//
//  SYSocketModel.swift
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/12/5.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit

class SYSocketModel:NSObject {
    var cId : String!
    var status : Int!
    var isopen : Bool!
    var type : Int!
    init(dict: [String : Any]) {
       super.init()
       cId = dict["cId"] as? String
       status = dict["status"] as? Int
       isopen = dict["isopen"] as? Bool
       type = dict["isopen"] as? Int
    }
}
