//
//  ChatRoomViewController.swift
//  HeyThere
//
//  Created by Silvana Garcia on 10/10/19.
//  Copyright © 2019 Silvana Garcia. All rights reserved.
//

import UIKit
import MessageKit

class ChatRoomViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    
    var client_list = [String]()
    let conversation = Conversation()
    var password = kEmptyString
    var username = kEmptyString

    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversation.setupConnectionSocket()
        conversation.enterChat(username_text: username, password_text: password)
        configureVC()
    }
    
    func configureVC() {
        navigationItem.title = "Users Online"
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ChatRoomViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! UITableViewCell
        cell.textLabel?.text = client_list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension ChatRoomViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatViewController()
        chatVC.receiver_username = client_list[indexPath.row]
        chatVC.sender_username = username
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
}

