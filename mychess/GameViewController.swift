//
//  GameViewController.swift
//  mychess
//
//  Created by afei on 5/9/16.
//  Copyright © 2016 taokan. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let gameSceneView = ChessGameSceneView()
        gameSceneView.frame = self.view.frame
        self.view.addSubview(gameSceneView)
    }
    
    override func viewDidDisappear(animated: Bool) {
        print("leaving")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
