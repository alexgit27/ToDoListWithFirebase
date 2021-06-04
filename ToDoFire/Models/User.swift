//
//  User.swift
//  ToDoFire
//
//  Created by Alexandr on 23.03.2021.
//

import Foundation
import Firebase

struct CustomUser {
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }
}
