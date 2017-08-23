//
//  Constants.swift
//  RealmToDoList
//
//  Created by Kanstantsin Linou on 8/23/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

struct Constants {
    static let CellId = "cellId"
    static let HomeTitle = "My Tasks"
    struct Add {
        static let Placeholder = "Task Name"
        static let NewTask = "New Task"
        static let Message = "Enter Task Name"
        static let AlertTitle = "Task Name"
        static let Add = "Add"
        static let Text = "text"
    }
    struct Server {
        static let Url = "http://127.0.0.1:9080"
        static let RealmUrl = "realm://127.0.0.1:9080/~/realmtasks"
    }
}
