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
    
    let conversation = Conversation()
    let dispatchGroup =  DispatchGroup()
    var users_online = [String]()
    

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
        conversation.delegate = self

    }
    
    func configureVC() {
            loginButton.layer.cornerRadius = 5
            signUpButton.layer.cornerRadius = 5
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
            self.view.addGestureRecognizer(tapGesture)
            navigationItem.title = "Login"
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
        
        dispatchGroup.enter()
        conversation.setupConnectionSocket()
        conversation.enterChat(username_text: username, password_text: password)
        
        
        dispatchGroup.notify(queue: .main) {
            print("done with connection socket")
            let chatRoomVC = ChatRoomViewController()
            chatRoomVC.username = username
            chatRoomVC.password = password
            chatRoomVC.conversation = self.conversation
            chatRoomVC.client_list = self.users_online
            let navigationController = UINavigationController(rootViewController: chatRoomVC)
            self.present(navigationController, animated: false, completion: nil)
        }
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
extension LoginViewController: ConversationDelegate {
  func messageReceived(message: String) {
    users_online = message.split(separator: " ").map{ String($0) }
    dispatchGroup.leave()
    }
}
