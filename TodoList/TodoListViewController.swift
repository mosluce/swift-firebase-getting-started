//
//  TodoListViewController.swift
//  TodoList
//
//  Created by 默司 on 2018/2/22.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwifterSwift

class TodoListViewController: UITableViewController {

    lazy var db = Database.database().reference().child("demo180306/todo_items")
    
    var todoItems = [TodoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(cellWithClass: TodoListCell.self)
        self.setupObserver()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        db.removeAllObservers()
    }

    func setupObserver() {
        db.observeSingleEvent(of: .value) {[weak self] (snapshot) in
            guard let `self` = self else { return }
            guard let arr = snapshot.value as? [String: [String: Any]] else { return }
            
            let json = arr.map({ (key, dict) -> [String: Any] in
                var dict = dict
                dict["id"] = key
                return dict
            })
            
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) else { return }
            guard let todoItems = try? JSONDecoder().decode([TodoItem].self, from: data) else { return }
            
            self.todoItems = (self.todoItems + todoItems).sorted(by: { $0.timestamp > $1.timestamp })
            self.tableView.reloadData()
        }
        
        db.queryOrdered(byChild: "timestamp")
            .queryStarting(atValue: Date().timeIntervalSince1970, childKey: "timestamp")
            .observe(.childAdded) {[weak self] (snapshot) in
                guard let `self` = self else { return }
                guard var json = snapshot.value as? [String: Any] else { return }
                
                json["id"] = snapshot.key
                
                guard let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) else { return }
                guard let todoItem = try? JSONDecoder().decode(TodoItem.self, from: data) else { return }
                
                self.todoItems.insert(todoItem, at: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
        
        db.observe(.childRemoved) {[weak self] (snapshot) in
            guard let `self` = self else { return }
            
            let id = snapshot.key
            
            guard let index = self.todoItems.index(where: { $0.id == id }) else { return }

            self.todoItems.remove(at: index)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
        
        db.observe(.childChanged) {[weak self] (snapshot) in
            guard let `self` = self else { return }
            guard let json = snapshot.value else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) else { return }
            guard var todoItem = try? JSONDecoder().decode(TodoItem.self, from: data) else { return }
            let id = snapshot.key
            guard let index = self.todoItems.index(where: { $0.id == id }) else { return }
            todoItem.id = id
            
            self.todoItems[index] = todoItem
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func add(_ todo: TodoItem) {
        let newItem = db.childByAutoId()
        let data = try! JSONEncoder().encode(todo)
        let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        newItem.setValue(json)
    }
}

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withClass: TodoListCell.self) else { return UITableViewCell() }
        cell.item = todoItems[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let id = todoItems[indexPath.row].id else { break }
            
            self.db.child(id).setValue(nil)
        case .insert:
            break
        case .none:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = todoItems[indexPath.row]
        guard let id = item.id else { return }
        
        db.child(id).child("state").setValue(!item.state)
    }
}
