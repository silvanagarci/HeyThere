//
//  LoginViewController.swift
//  HeyThere
//
//  Created by Silvana Garcia on 10/10/19.
//  Copyright © 2019 Silvana Garcia. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    

    @IBAction func loginButtonTapped(_ sender: Any) {
        //verify data user
        let username = usernameTextField.text ?? kEmptyString
        let password = passwordTextField.text ?? kEmptyString
        verifyUserCredentials(username: username, password: password)
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let username = usernameTextField.text ?? kEmptyString
        let password = passwordTextField.text ?? kEmptyString
        let userExists = userDictionary[usernameTextField.text ?? kEmptyString] != nil
        
        if userExists {
            let alertController = UIAlertController(title: "Error", message: "Username already exists" , preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Done", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            userDictionary[username] = password
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()

    }
    
    func configureVC() {
            loginButton.layer.cornerRadius = 5
            signUpButton.layer.cornerRadius = 5
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
            self.view.addGestureRecognizer(tapGesture)
    }

    /**
     Hide keyboard
     */
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
    }
    
    /**
     Navigate to ChatRoomVC
     */
    func navigateToChatRoomVC(username: String, password: String) {
        let chatRoomVC = ChatRoomViewController()
        chatRoomVC.username = username
        chatRoomVC.password = password
        let navigationController = UINavigationController(rootViewController: chatRoomVC)
        present(navigationController, animated: false, completion: nil)
    }
    
    func verifyUserCredentials(username: String, password: String) {
        if let storedPassword = userDictionary[username]{
            if storedPassword == password {
                navigateToChatRoomVC(username: username, password: storedPassword)
            }
            else {
                let alertController = UIAlertController(title: "Incorrect Password", message: "Incorrect Pasword/Username" , preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            }
        }
    }

}
