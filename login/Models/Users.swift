//
//  Users.swift
//  login
//
//  Created by 本阪　亮輔 on 2022/06/15.
//

import Foundation
import Firebase

struct User{
    let name :String
    let createdAt:Timestamp
    let email: String
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
    }
}
