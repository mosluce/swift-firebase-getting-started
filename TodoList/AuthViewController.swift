//
//  AuthViewController.swift
//  TodoList
//
//  Created by 默司 on 2018/2/22.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {
    
    lazy var emailField: UITextField = {
        let f = UITextField()
        f.autocorrectionType = .no
        f.autocapitalizationType = .none
        f.keyboardType = .emailAddress
        f.placeholder = "EMAIL"
        return f
    }()
    
    lazy var passwordField: UITextField = {
        let f = UITextField()
        f.isSecureTextEntry = true
        f.placeholder = "PASSWORD"
        return f
    }()
    
    lazy var registerBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("REGISTER", for: .normal)
        return b
    }()
    
    lazy var loginBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("LOGIN", for: .normal)
        b.tintColor = UIColor.orange
        return b
    }()
    
    lazy var stackView = UIStackView(arrangedSubviews: [self.emailField, self.passwordField, self.registerBtn, self.loginBtn])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        self.view.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 32
        self.stackView.axis = .vertical
        
        self.registerBtn.addTarget(self, action: #selector(register), for: .touchUpInside)
        self.loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func register() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Register failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK!", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } else {
                user?.sendEmailVerification(completion: {[weak self] (error) in
                    if let error = error {
                        let alert = UIAlertController(title: "Register failed", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK!", style: .default, handler: {[weak self] (_) in
                            self?.dismiss(animated: true, completion: nil)
                        }))
                        self?.present(alert, animated: true, completion: nil)
                    } else {
                        let vc = UIAlertController(title: "Success", message: "Please Check Email", preferredStyle: .alert)
                        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(vc, animated: true, completion: nil)
                    }
                })
            }
        }
    }

    @objc func login() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Login failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK!", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
