//
//  ChatViewController.swift
//  HeyThere
//
//  Created by Silvana Garcia on 10/10/19.
//  Copyright © 2019 Silvana Garcia. All rights reserved.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
    
    var conversation = Conversation()
    var currentUser = Sender(id: "0", displayName: "User 1")
    let dispatchGroup =  DispatchGroup()
    var messages: [Message] = []
    var receiver_username = kEmptyString
    var sender_username = kEmptyString

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        conversation.closeStreams()
    }
    
    func addMessage(message: Message) {
        messages.append(message)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    /**
     Configure VC
     */
    func configureVC() {
        navigationItem.hidesBackButton = true  
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        // remove avatar from message view
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        conversation.delegate = self
    }
 
    /**
     Go back to menu
     */
    @objc func navigateToLoginRoomVC() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ChatRoomViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    /**
     Go back
     */
    @objc func popVC() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return currentUser
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}
// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let kSenderColor = UIColor(red: 85/255.0, green: 136/255.0, blue: 225/255.0, alpha: 1)
        let kReceiverColor = UIColor(red: 245/255.0, green: 94/255.0, blue: 97/255.0, alpha: 0.5)
        return isFromCurrentSender(message: message) ? kSenderColor : kReceiverColor
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        conversation.sendToOutputStream(message: text, receiver_username: receiver_username)
        let messageSender = Sender(id: "0", displayName: sender_username)
        let messageObject = Message(sender: messageSender, messageId: "0", text: text, username: sender_username)
        addMessage(message: messageObject)
        inputBar.inputTextView.text = ""
        
    }
}
extension ChatViewController: ConversationDelegate {    
    func messageReceived(message: String) {
        let messageSender = Sender(id: "1", displayName: receiver_username)
        let newMessage = Message(sender: messageSender, messageId: "0", text: message, username: receiver_username)
        addMessage(message: newMessage)
  }
}
