//
//  Task.swift
//  RealmToDoList
//
//  Created by Kanstantsin Linou on 8/23/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import RealmSwift

final class Task: Object {
    dynamic var text = ""
    dynamic var completed = false
}
