//  MainMenu.swift

//  Description: Main Menu of PSS

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  11/25/2018 - Created (Added Video Player functionality)
//  12/01/2018 - Changed Video path to correct video file

import UIKit
import AVKit
import AVFoundation

class MainMenu: UIViewController {
    
    @IBOutlet weak var VideoPlayer: UIButton!
    
    //  "Video" button in Main Menu
    //  Input: User presses "Video" button
    //  Output: Video Player of Tutorial Video
    @IBAction func VideoPlayer(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "tutorial", ofType:"mp4") else {
            debugPrint("tutorial.mp4 not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
}
