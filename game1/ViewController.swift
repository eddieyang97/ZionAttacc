//
//  ViewController.swift
//  game1
//
//  Created by Eddie Yang on 3/13/19.
//  Copyright © 2019 Duke. All rights reserved.
//
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var bricks = Array<Brick>()
    
    @IBOutlet weak var gameLabelView: UIView!
    @IBOutlet weak var Clock: UITextField!
    @IBOutlet weak var ball: UIImageView!
    @IBOutlet weak var paddle: UIImageView!
    @IBOutlet weak var gameAreaView: UIView!
//    @IBAction func leftButton(_ sender: Any) {
//        if (Int(self.paddle.center.x) > Int(paddle.frame.width) / 2 + Int(gameAreaView.frame.minX)) {
//            paddle.center.x -= paddleShift
//        }
//
//        UIView.animate(withDuration: 1, animations:{
//            self.paddle.image = UIImage(named: String(self.plankPositionL))
//        }, completion:nil)
//        if (self.plankPositionL == 4) {
//            self.plankPositionL = 3
//        } else {
//            self.plankPositionL += 1
//        }
//
//    }
    
//    @IBAction func rightButton(_ sender: Any) {
//        if (Int(self.paddle.center.x) < Int(gameAreaView.frame.width) - Int(paddle.frame.width) / 2 - Int(gameAreaView.frame.minX)) {
//            paddle.center.x += paddleShift
//        }
//
//        plankPositionL = 3
//        UIView.animate(withDuration: 1, animations:{
//            self.paddle.image = UIImage(named: String(self.plankPositionR))
//        }, completion:nil)
//        if (self.plankPositionR == 2) {
//            self.plankPositionR = 1
//        } else {
//            self.plankPositionR += 1
//        }
//
//    }
    
    @IBOutlet weak var lbutton: UIButton!
    
    @IBOutlet weak var rbutton: UIButton!
    
    @objc func moveLeft(_ sender: UIGestureRecognizer){
        leftPressed = 1
        //print("Long tap")
        if (rightPressed > 0){
            playSoundSqueak()
            rightPressed = 0
        }
        
        if (Int(self.paddle.center.x) > Int(paddle.frame.width) / 2 + Int(gameAreaView.frame.minX)) {
            paddle.center.x -= paddleShift
        }
        
        UIView.animate(withDuration: 1, animations:{
            self.paddle.image = UIImage(named: String(self.plankPositionL))
        }, completion:nil)
        if (self.plankPositionL == 4) {
            self.plankPositionL = 3
        } else {
            self.plankPositionL += 1
        }
    }
    
    @objc func moveRight(_ sender: UIGestureRecognizer){
        rightPressed = 1
        //print("Long tap")
        if (leftPressed > 0){
            playSoundSqueak()
            leftPressed = 0
        }
        if (Int(self.paddle.center.x) < Int(gameAreaView.frame.width) - Int(paddle.frame.width) / 2 - Int(gameAreaView.frame.minX)) {
            paddle.center.x += paddleShift
        }
        
        plankPositionL = 3
        UIView.animate(withDuration: 1, animations:{
            self.paddle.image = UIImage(named: String(self.plankPositionR))
        }, completion:nil)
        if (self.plankPositionR == 2) {
            self.plankPositionR = 1
        } else {
            self.plankPositionR += 1
        }
    }
    
    let fps: Double = 220
    let paddleShift: CGFloat = 30
    let brickWidth: Int = 101
    let brickHeight: Int = 80
    let brickDrop: Int = 10
    let defaultBDInterval: Double = 10
    var brickDropInterval: Double = 0
    var paddleY: Int = 0
    var paddleX: Int = 0
    var ballX: Int = 0
    var ballY: Int = 0
    var ballXVelo: Int = -1
    var ballYVelo: Int = -1
    var brickLeft: Int = 0
    
    // outside fireTimer, global
    var min:Int = 1
    var second:Int = 0
    let tens:Int = 0
    var counter:Int = 0
    
    //Right/Left declaration
    var plankPositionR:Int = 1
    var plankPositionL:Int = 3

    var gameTimer: Timer? = nil
    var timeElapsed: Double = 0
    
    var leftPressed = 1
    var rightPressed = 1

    //music
    var player: AVAudioPlayer?
    var playerEverytime: AVAudioPlayer?
    var playerSqueak: AVAudioPlayer?
    var playerBackground: AVAudioPlayer?
    var playerLosing: AVAudioPlayer?
    var playerWinning: AVAudioPlayer?
    var playerStartScreen: AVAudioPlayer?
    //    var hitCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ballX = Int(ball.center.x)
        ballY = Int(ball.center.y)
        paddleX = Int(paddle.center.x)
        paddleY = Int(paddle.center.y)
        ballXVelo = 1 - 2 * Int.random(in: 0...1)
        
        let tapLeft = UILongPressGestureRecognizer(target: self, action: #selector(moveLeft(_:)))
        self.lbutton!.addGestureRecognizer(tapLeft)
        let longGestureLeft = UILongPressGestureRecognizer(target: self, action: #selector(moveLeft(_:)))
        longGestureLeft.minimumPressDuration = 0.005
        self.lbutton!.addGestureRecognizer(longGestureLeft)
        
        let tapRight = UILongPressGestureRecognizer(target: self, action: #selector(moveRight(_:)))
        self.rbutton!.addGestureRecognizer(tapRight)
        let longGestureRight = UILongPressGestureRecognizer(target: self, action: #selector(moveRight(_:)))
        longGestureRight.minimumPressDuration = 0.005
        self.rbutton!.addGestureRecognizer(longGestureRight)
        
        setupBricks()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1 / fps, target: self, selector: #selector(runMainLoop), userInfo: nil, repeats: true)
        playBackground()
        
    }
    
    func setupBricks() {
        brickDropInterval = defaultBDInterval
        for i in 0...4 {
            let brickImage = UIImage(named: "brick")
            let brickView = Brick(image: brickImage)
            
            brickView.hitLeft = 5 - i
            brickView.maxHit = 5 - i
            brickView.frame = CGRect(x: 0, y: i * brickHeight + Int(gameLabelView.frame.height), width: Int(gameAreaView.frame.width), height: brickHeight)
            gameAreaView.addSubview(brickView)
            bricks.append(brickView)
            brickLeft += 1
        }
    }
    
    func updateBall() {
        // check if ball touches paddle
        if (ball.frame.intersects(paddle.frame)) {
            ballYVelo = -abs(ballYVelo)
            self.paddle.image = UIImage(named: "default")
        }
        
        // check if ball touches sides
        if (Int(ball.center.x) > Int(gameAreaView.frame.width) -  Int(ball.frame.width) / 2 || Int(ball.center.x) < Int(ball.frame.width) / 2) {
            reverseXVelo()
        }
        
        // check if ball touches top
        if (Int(ball.center.y) < Int(ball.frame.width) / 2 + Int(gameLabelView.frame.height)) {
            reverseYVelo()
        }
        
        // check if ball falls off the screen
        if (Int(ball.center.y) > Int(gameAreaView.frame.height)) {
            losing()
        }
        
        // check if ball touches bricks
        if (bricks.count > 0) {
            for i in 0...(bricks.count - 1) {
                if (ball.frame.intersects(bricks[i].frame)) {
                    bricks[i].isHit()
                    ballYVelo = -ballYVelo
                    if (bricks[i].hitLeft == 0) {
//                        brickDropInterval *= 0.6
                        bricks.remove(at: i)
                        brickLeft -= 1
                    }
                }
            }
        }
        
        // update ball position
        ball.center.x += CGFloat(ballXVelo)
        ball.center.y += CGFloat(ballYVelo)
    }
    
    func reverseXVelo() {
        ballXVelo = -ballXVelo
    }
    
    func reverseYVelo() {
        ballYVelo = -ballYVelo
    }
    //
    //    func updateSpeedX() {
    //        if (Int(ball.center.x) > Int(gameAreaView.frame.width) -  Int(ball.frame.width) / 2 || Int(ball.center.x) < Int(ball.frame.width) / 2 || touchPaddleFromSide()) {
    //            ballXVelo = -ballXVelo
    //        }
    //    }
    //
    //    func updateSpeedY() {
    //        if (!touchPaddleFromSide() && (ball.frame.intersects(paddle.frame) || Int(ball.center.y) < Int(ball.frame.width) / 2 || Int(ball.center.y) > Int(gameAreaView.frame.height))) {
    //            ballYVelo = -ballYVelo
    //        }
    //    }
    //
    //    func touchPaddleFromSide() -> Bool{
    //        if (ball.frame.intersects(paddle.frame)) {
    //            print(ball.center.x)
    //            print(ball.center.y)
    //            print(paddle.center.x)
    //            print(paddle.center.y)
    //        }
    //        return ball.frame.intersects(paddle.frame) && ball.center.y + paddle.frame.height + 4 > paddle.center.y && ball.center.y - paddle.frame.height - 4 < paddle.center.y
    //    }
    
    func shiftBricks() {
        for brick in bricks {
            brick.center.y += CGFloat(brickDrop)
        }
    }
    
    func losing() {
        playerBackground?.stop()
        playerEverytime?.stop()
        playerStartScreen?.stop()
        
        playLosing()
        gameTimer!.invalidate()
        self.performSegue(withIdentifier: "loseSegue", sender: nil)
    }
    
    func winning() {
        playerBackground?.stop()
        playerEverytime?.stop()
        playerStartScreen?.stop()
        
        playWinning()
        gameTimer!.invalidate()
        self.performSegue(withIdentifier: "winSegue", sender: nil)
        
    }
    
    @objc func runMainLoop() {
        ball.center.x = CGFloat(ballX)
        ball.center.y = CGFloat(ballY)
        
        updateBall()
        
        ballX = Int(ball.center.x)
        ballY = Int(ball.center.y)
        
        if (second == 10) {
            playerBackground?.stop()
            playSoundEverytime()
        }
        
        // after fireTimer
        if (counter == Int(fps)) {
            counter = 0
            if (second == 0) {
                second = 59
                min -= 1
                Clock.text = String(min) + ":" + String(second)
            } else {
                second -= 1
                if (second < 10) {
                    Clock.text = String(min) + ":" + String(tens) + String(second)
                } else {
                    Clock.text = String(min) + ":" + String(second)
                }
            }
            if (min < 0) {
                Clock.text = "0:00"
                losing()
            }
        } else {
            counter += 1
        }

        if (Int(timeElapsed * fps) % Int(brickDropInterval * fps) == 0) {
            shiftBricks()
        }
        
        if (brickLeft == 0) {
            setupBricks()
            winning()
        }
        timeElapsed += 1 / fps
    }
    
    func printBall() {
        print("X: " + String(Int(ball.center.x)))
        print("Y: " + String(Int(ball.center.y)))
        print("XVelo: " + String(ballXVelo))
        print("YVelo: " + String(ballYVelo))
    }
    
    //MARK: music
    func playSoundEverytime() {
        //print ("ues1")
        guard let url = Bundle.main.url(forResource: "Everytime", withExtension: "wav") else { return }
        
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
    }
    
    func playSoundSqueak() {
       //print ("ues1Squeak")
        guard let url = Bundle.main.url(forResource: "better shoe squeak", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerSqueak = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let playerSqueak = playerSqueak else { return }
            
            playerSqueak.play()
            playerSqueak.volume = 100
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playBackground() {
//        print ("ues1Back")
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerBackground = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let playerBackground = playerBackground else { return }
            
            playerBackground.play()
            playerBackground.volume = 200
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playLosing() {
        
//        print ("Losing")
        guard let url = Bundle.main.url(forResource: "losing", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerLosing = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let playerLosing = playerLosing else { return }
            
            playerLosing.play()
            playerLosing.volume = 500
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playWinning() {
//        print ("Winning")
        guard let url = Bundle.main.url(forResource: "winning", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerWinning = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let playerWinning = playerWinning else { return }
            
            playerWinning.play()
            playerWinning.volume = 50
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playStartScreen() {
        print ("StartScreen")
        guard let url = Bundle.main.url(forResource: "startScreen", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerStartScreen = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let playerStartScreen = playerStartScreen else { return }
            
            playerStartScreen.play()
            playerStartScreen.volume = 50
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
