//
//  TaskList.swift
//  RealmToDoList
//
//  Created by Kanstantsin Linou on 8/23/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import RealmSwift

final class TaskList: Object {
    dynamic var text = ""
    dynamic var id = ""
    let items = List<Task>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
