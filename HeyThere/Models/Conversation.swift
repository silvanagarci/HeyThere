//
//  ChatRoom.swift
//  HeyThere
//
//  Created by Silvana Garcia on 10/10/19.
//  Copyright © 2019 Silvana Garcia. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

protocol ConversationDelegate: class {
    func messageReceived(message: String)
    
}

class Conversation: NSObject {
    weak var delegate: ConversationDelegate?
    var inputStream: InputStream!
    var outputStream: OutputStream!
    var username = kEmptyString
    var password = kEmptyString
    var host = "164.107.113.65"
    let port = 1025

    
    func closeStreams() {
        inputStream.close()
        outputStream.close()
    }
    
    func enterChat(username_text: String, password_text: String) {
        self.username = username_text
        self.password = password_text
        let message = "USER \(username_text) \(password_text)"
        let data = message.data(using: .utf8)!
        print(message)
        print(username)
        print(password)
        print(data)
        
        _ = data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error joining chat")
          return
        }
        outputStream.write(pointer, maxLength: data.count)
        }
        print("message sent!")
 
 }
    
    func readInputStream(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        
        var numberBytes  = 0
        while stream.hasBytesAvailable {
            numberBytes = stream.read(buffer, maxLength: 1024)
        }
        
        guard let stringMessage = String(bytesNoCopy: buffer, length: numberBytes, encoding: .utf8,freeWhenDone: true)?.components(separatedBy: ""),
           let name = stringMessage.first,
           let message = stringMessage.last
        else {
            print("error occurred")
            return
        }
        delegate?.messageReceived(message: message)
    }
    
    func sendToOutputStream(message: String, receiver_username: String) {
        let data = "TEXT \(receiver_username) \(message)".data(using: .utf8)!
        
        _ = data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error sending message")
          return
        }
        outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    //Create connection between my app and server at given port and host number
    func setupConnectionSocket() {
        //create an NSInput and NSOutput stream
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        //keep running loop in order to keep communication with server socket
        inputStream.schedule(in: .main, forMode: .common)
        outputStream.schedule(in: .main, forMode: .common)
        
        inputStream!.open()
        outputStream!.open()
        
        inputStream.delegate = self
        
    }
}

extension Conversation: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case .hasBytesAvailable:
                print("new message received")
                readInputStream(stream: aStream as! InputStream)
            case .endEncountered:
                print("connection was closed")
                closeStreams()
            case .errorOccurred:
                print("error occurred")
                closeStreams()
            default:
                print("other")
            
    }
  }
}

