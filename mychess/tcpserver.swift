//
//  tcpserver.swift
//  mychess
//
//  Created by 陶侃 on 5/8/16.
//  Copyright © 2016 taokan. All rights reserved.
//

import Foundation

let server = tcpserver()

let waitingImage = "Image/ChessSet.jpg"

let playingImage = "Image/playing.jpg"

class tcpserver:NSObject,GCDAsyncSocketDelegate{
    
    var socket:GCDAsyncSocket!
    
    var dataSource:Array<Dictionary<String,String>>?
    
    var timer:NSTimer!
    
    var waitflag:Bool = false
    
    var roomindex:Int = -1
    
    override init(){
        super.init()
        self.dataSource = Array<Dictionary<String,String>>();
        socket = GCDAsyncSocket(delegate:self,delegateQueue:dispatch_get_main_queue())
    }
    
    class var serverInstance: tcpserver {
        return server
    }
    
    func connectToserver(){
        self.initialSourceData()
        do {
            try self.socket.connectToHost("127.0.0.1",onPort: 8080)
        }catch let error as NSError{
            print(error)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1,target: self,selector: #selector(tcpserver.changeSourceData),userInfo:nil,repeats: true)
        //timer.invalidate()

    }
    
    func sendmes(message:String){
        let messageData = message.dataUsingEncoding(NSUTF8StringEncoding)
        socket.writeData(messageData,withTimeout:0,tag:0)
        socket.readDataWithTimeout(30, tag: 0)
        
    }
    
    func sendTypeOne(roomindex:Int){
        let jsonObj = ["type":"1","name":"playerone","roomindex":"\(roomindex)"]
        do{
                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: NSJSONWritingOptions.PrettyPrinted)
                let jsonString = NSString(data:jsonData,encoding:NSUTF8StringEncoding)
                let messageData = jsonString!.dataUsingEncoding(NSUTF8StringEncoding)
                socket.writeData(messageData, withTimeout: 0, tag: 0)
                socket.readDataWithTimeout(30, tag: 0)
        }catch let error as NSError{
            print("failed to load: \(error.localizedDescription)")
        }
    }
    
    func sendTypeFour(roomNum:Int,action:String){
        let jsonObj = ["type":"4","action":action,"roomindex":"\(roomNum)"]
        do{
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonString = NSString(data:jsonData,encoding:NSUTF8StringEncoding)
            let messageData = jsonString!.dataUsingEncoding(NSUTF8StringEncoding)
            socket.writeData(messageData, withTimeout: 0, tag: 0)
        }catch let error as NSError{
            print("failed to load: \(error.localizedDescription)")
        }
    }
    
    @objc func socket(socket:GCDAsyncSocket,didConnectToHost host:String,port p:UInt16){
       /*let message = "hello world"
        let messageData = message.dataUsingEncoding(NSUTF8StringEncoding)
        socket.writeData(messageData,withTimeout:0,tag:0)
        socket.readDataWithTimeout(30, tag: 0)*/
    }
    
    @objc func socket(socket:GCDAsyncSocket,didReadData data:NSData, withTag tag:Int){
        /*let receivemessage = NSString(data:data,encoding: NSUTF8StringEncoding)
        print(receivemessage!)
        socket.readDataWithTimeout(30, tag: 0)*/
        let jsonObj:NSDictionary
        do{
            jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            //print(jsonObj["type"]!)
            switch(jsonObj["type"] as! Int){
            case 1:
                receiveTypeOne(jsonObj)
                /*self.dataSource?.removeAll()
                print(jsonObj["roomstatus1"])
                for _ in 0 ..< 2{
                    let labelimage = "Image/ChessSet.jpg"
                    let playerone = "chair one: full"
                    let playertwo = "chair two: full"
                    self.dataSource?.append([IMAGE_NAME:labelimage,PLAY_ONE:playerone,PLAY_TWO:playertwo])
                }*/
                break
            default:
                break
            }
        }catch let error as NSError{
             print("failed to load: \(error.localizedDescription)")
        }
        
    }
    
    func initialSourceData(){
        self.dataSource?.removeAll()
        for _ in 0 ..< 2{
            let labelimage = "Image/ChessSet.jpg"
            let playerone = "chair one: empty"
            let playertwo = "chair two: empty"
            self.dataSource?.append([IMAGE_NAME:labelimage,PLAY_ONE:playerone,PLAY_TWO:playertwo])
        }
        
    }
    
    func changeSourceData(){
        self.sendTypeOne(roomindex)
    }
    
    func heartbeat(){
        let jsonObj = ["type":"3","name":"playerone"]
        do{
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonString = NSString(data:jsonData,encoding:NSUTF8StringEncoding)
            let messageData = jsonString!.dataUsingEncoding(NSUTF8StringEncoding)
            socket.writeData(messageData, withTimeout: 0, tag: 0)
            socket.readDataWithTimeout(30, tag: 0)
        }catch let error as NSError{
            print("failed to load: \(error.localizedDescription)")
        }
    }
    
    func receiveTypeOne(jsonObj:NSDictionary){
        self.dataSource?.removeAll()
        var labelimage:String = "Image/ChessSet.jpg"
        var playerone:String = "chair one: empty"
        var playertwo:String = "chair two: empty"
        for i in 0 ..< 2{
            print(jsonObj["roompeople"+"\(i+1)"]!)
            if(jsonObj["roomstatus"+"\(i+1)"] as! String != "full"){
                labelimage = waitingImage
            }else{
                labelimage = playingImage
            }
            if(jsonObj["roompeople"+"\(i+1)"] as! Int == 2){
                playerone = "chair one: playing"
                playertwo = "chair two: playing"
            }else if(jsonObj["roompeople"+"\(i+1)"] as! Int == 1){
                playerone = "chair one: ready"
                playertwo = "chair two: empty"
            }else{
                playerone = "chair one: empty"
                playertwo = "chair two: empty"
            }
            self.dataSource?.append([IMAGE_NAME:labelimage,PLAY_ONE:playerone,PLAY_TWO:playertwo])
        }
    }

    
}


