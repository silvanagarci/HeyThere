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

protocol ChatRoomDelegate: class {
    func messageReceived(message: Message)
    
}

class ChatRoom: NSObject {
    weak var delegate: ChatRoomDelegate?
    var inputStream: InputStream!
    var outputStream: OutputStream!
    var username = kEmptyString
    var host = "cse-std8.cse.ohio-state.edu"
    let port = 80

    
    func closeStreams() {
        inputStream.close()
        outputStream.close()
    }
    
    func enterChat(username: String) {
        let data = "ENTER- \(username)".data(using: .utf8)!
        self.username = username
        
        _ = data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error joining chat")
          return
        }
        outputStream.write(pointer, maxLength: data.count)
        }
        
    }
    
    func readInputStream(stream: InputStream) {
        var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
        
        var numberBytes  = 0
        while stream.hasBytesAvailable {
            numberBytes = stream.read(buffer, maxLength: 4096)
        }
        
        guard let stringMessage = String(bytesNoCopy: buffer, length: numberBytes, encoding: .utf8,freeWhenDone: true)?.components(separatedBy: "-"),
           let name = stringMessage.first,
           let message = stringMessage.last
        else {
            print("error occurred")
            return
        }
         
        let messageSender = Sender(id: "0", displayName: username)
        let messageObject = Message(sender: messageSender, messageId: message, text: message, username: name)
        
        delegate?.messageReceived(message: messageObject)
    }
    
    func sendToOutputStream(message: String) {
        let data = "TEXT- \(message)".data(using: .utf8)!
        
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
        //Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // 2
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           host as CFString,
                                           UInt32(port),
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.schedule(in: .main, forMode: .common)
        outputStream.schedule(in: .main, forMode: .common)
    
        inputStream.delegate = self
        
        inputStream!.open()
        outputStream!.open()
        
    }
}

extension ChatRoom: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case .hasBytesAvailable:
                print("new message received")
                readInputStream(stream: aStream as! InputStream)
            case .endEncountered:
                print("new message received")
                closeStreams()
            case .errorOccurred:
              print("error occurred")
            case .hasSpaceAvailable:
              print("has space available")
            default:
              print("some other event...")
            
    }
  }
}
