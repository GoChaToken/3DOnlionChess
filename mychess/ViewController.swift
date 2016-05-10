//
//  ViewController.swift
//  mychess
//
//  Created by 陶侃 on 5/8/16.
//  Copyright © 2016 taokan. All rights reserved.
//

import UIKit

let IMAGE_NAME = "image_name"
let PLAY_ONE = "pleyone"
let PLAY_TWO = "playtwo"

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var hallTabelView: UITableView!
    
    let refreshControl = UIRefreshControl()
    private var selectIndexPath: NSIndexPath?
    
    //private var dataSource:Array<Dictionary<String,String>>?
    ///var server:tcpserver = tcpserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hallTabelView.backgroundColor = UIColor(red: 55/255, green: 186/255, blue: 89/255, alpha: 0.5)
        self.hallTabelView.dataSource = self
        self.hallTabelView.delegate = self
        server.connectToserver()
        refreshControl.addTarget(self, action: #selector(ViewController.refreshtable), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "freshing")
        hallTabelView.addSubview(refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectIndexPath = indexPath
        print("the row number \(indexPath.row)")
        if(server.dataSource![indexPath.row][IMAGE_NAME] == waitingImage){
            print("you can enter")
            server.sendTypeFour(indexPath.row, action: "enter")
        }else{
            print("the room is full")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return server.dataSource!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RoomCell = self.hallTabelView.dequeueReusableCellWithIdentifier("RoomCell",forIndexPath: indexPath) as! RoomCell
        let tempItem:Dictionary! = server.dataSource![indexPath.row]
        if(tempItem != nil){
            let labelimage = tempItem![IMAGE_NAME]!
            let textlabelone = tempItem![PLAY_ONE]!
            let textlabeltwo = tempItem![PLAY_TWO]!
            cell.playerOne.text = textlabelone
            cell.playerTwo.text = textlabeltwo
            cell.labelImage.image = UIImage(named:labelimage)
            
        }
        return cell
    }
    
    func refreshtable(){
        print("fresh")
        //server.changeSourceData()
        self.hallTabelView.reloadData()
        refreshControl.endRefreshing()
    }

}

