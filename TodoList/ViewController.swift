//
//  ViewController.swift
//  TodoList
//
//  Created by 默司 on 2018/2/22.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    lazy var logoutBtn = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logout))
    lazy var titleField: UITextField = {
        let f = UITextField()
        f.placeholder = "title"
        f.font = UIFont.systemFont(ofSize: 18)
        return f
    }()
    lazy var addBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("ADD", for: .normal)
        b.addTarget(self, action: #selector(add), for: .touchUpInside)
        return b
    }()
    lazy var addItemContainerView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleField, self.addBtn])
        v.axis = .horizontal
        v.distribution = .fill
        return v
    }()
    
    lazy var todoList = TodoListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "Realtime TODOs"
        self.navigationItem.rightBarButtonItems = [logoutBtn]
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.addChildViewController(todoList)
        self.view.addSubview(addItemContainerView)
        self.view.addSubview(todoList.view)
        
        self.addItemContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.todoList.view.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            self.addItemContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//            self.todoList.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.todoList.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            self.addItemContainerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
//            self.todoList.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            self.todoList.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        }
        
        self.titleField.leadingAnchor.constraint(equalTo: addItemContainerView.leadingAnchor, constant: 16).isActive = true
        self.addBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.addItemContainerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.addItemContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.addItemContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        self.todoList.view.topAnchor.constraint(equalTo: addItemContainerView.bottomAnchor).isActive = true
        self.todoList.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.todoList.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addBtn.isEnabled = false
        self.logoutBtn.isEnabled = false
        
        guard let user = Auth.auth().currentUser else {
            print("== currentUser is not exsits")
            self.presentAuthViewConttroller()
            return
        }
        
        user.getIDToken {[weak self] (_, err) in
            if let err = err {
                print("== Get IDToken failed: ", err.localizedDescription)
                self?.presentAuthViewConttroller()
            } else {
                self?.addBtn.isEnabled = true
                self?.logoutBtn.isEnabled = true
                self?.todoList.setupObserver()
            }
        }
    }

    func presentAuthViewConttroller() {
        self.present(AuthViewController(), animated: true, completion: nil)
    }
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            self.presentAuthViewConttroller()
        } catch {
            print("== SignOut failed: ", error.localizedDescription)
        }
    }
    
    @objc func add() {
        guard let user = Auth.auth().currentUser else { return }
        guard let title = titleField.text, !title.isEmpty else { return }
        
        self.todoList.add(TodoItem(title: title, creator: user.email!))
        self.titleField.text = ""
    }
}

