//
//  ViewController.swift
//  RealmToDoList
//
//  Created by Kanstantsin Linou on 8/23/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import UIKit
import RealmSwift
import Keys

class ViewController: UITableViewController {
    var items = List<Task>()
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRealm()
    }
    
    func setupUI() {
        title = Constants.HomeTitle
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func setupRealm() {
        let keys = RealmToDoListKeys()
        // Log in existing user with username and password
        SyncUser.logIn(with: .usernamePassword(username: keys.uSERNAME, password: keys.pASSWORD, register: false), server: URL(string: Constants.Server.Url)!) { user, error in
            guard let user = user else {
                fatalError(String(describing: error))
            }
            
            DispatchQueue.main.async {
                // Open Realm
                let configuration = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: Constants.Server.RealmUrl)!)
                )
                self.realm = try! Realm(configuration: configuration)
                
                // Show initial tasks
                func updateList() {
                    if self.items.realm == nil, let list = self.realm.objects(TaskList.self).first {
                        self.items = list.items
                    }
                    self.tableView.reloadData()
                }
                updateList()
                
                // Notify us when Realm changes
                self.notificationToken = self.realm.addNotificationBlock { _ in
                    updateList()
                }
            }
        }
    }
    
    deinit {
        notificationToken.stop()
    }
    
    // MARK: Functions
    func add() {
        let alertController = UIAlertController(title: Constants.Add.NewTask, message: Constants.Add.Message, preferredStyle: .alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = Constants.Add.Placeholder
        }
        alertController.addAction(UIAlertAction(title: Constants.Add.Add, style: .default) { _ in
            guard let text = alertTextField.text, !text.isEmpty else { return }
            
            let items = self.items
            try! items.realm?.write {
                items.insert(Task(value: [Constants.Add.Text: text]), at: items.filter("completed = false").count)
            }
        })
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: UITableView
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellId, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.alpha = item.completed ? 0.5 : 1
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! items.realm?.write {
            items.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let item = items[indexPath.row]
                realm.delete(item)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        try! item.realm?.write {
            item.completed = !item.completed
            let destinationIndexPath: IndexPath
            if item.completed {
                // move cell to bottom
                destinationIndexPath = IndexPath(row: items.count - 1, section: 0)
            } else {
                // move cell just above the first completed item
                let completedCount = items.filter("completed = true").count
                destinationIndexPath = IndexPath(row: items.count - completedCount - 1, section: 0)
            }
            items.move(from: indexPath.row, to: destinationIndexPath.row)
        }
    }
}
