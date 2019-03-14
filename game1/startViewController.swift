//
//  startViewController.swift
//  game1
//
//  Created by Hugh Thomas on 3/14/19.
//  Copyright © 2019 Duke. All rights reserved.
//

import UIKit
import AVFoundation

class startViewController: UIViewController {

    var playerEverytime: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        playSoundSqueak2()
    }
 func playSoundSqueak2() {
    print("yes")
        
            //print ("ues1")
            guard let url = Bundle.main.url(forResource: "startScreen", withExtension: "mp3") else { return }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                playerEverytime = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                guard let playerEverytime = playerEverytime else { return }
                
                playerEverytime.play()
                playerEverytime.volume = 50
                
            } catch let error {
                print(error.localizedDescription)
            }
    
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
       playerEverytime?.stop()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
