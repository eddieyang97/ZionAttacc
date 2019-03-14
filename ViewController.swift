//
//  ViewController.swift
//  game1
//
//  Created by Eddie Yang on 3/13/19.
//  Copyright © 2019 Duke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var bricks = Array<Brick>()
    @IBOutlet weak var ball: UIImageView!
    @IBOutlet weak var paddle: UIImageView!
    @IBOutlet weak var gameAreaView: UIView!
    @IBAction func leftButton(_ sender: Any) {
        if (Int(self.paddle.center.x) > Int(paddle.frame.width) / 2 + Int(gameAreaView.frame.minX)) {
            paddle.center.x -= paddleShift
        }
    }
    @IBAction func rightButton(_ sender: Any) {
        if (Int(self.paddle.center.x) < Int(gameAreaView.frame.width) - Int(paddle.frame.width) / 2 - Int(gameAreaView.frame.minX)) {
            paddle.center.x += paddleShift
        }
    }
    
    let fps: Double = 500
    let paddleShift: CGFloat = 30
    let brickWidth: Int = 101
    let brickHeight: Int = 100
    let brickDrop: Int = 10
    let defaultBDInterval: Double = 1.5
    var brickDropInterval: Double = 0
    var paddleY: Int = 0
    var paddleX: Int = 0
    var ballX: Int = 0
    var ballY: Int = 0
    var ballXVelo: Int = -1
    var ballYVelo: Int = -1
    var brickLeft: Int = 0
    
    var timeElapsed: Double = 0
    
//    var hitCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ballX = Int(ball.center.x)
        ballY = Int(ball.center.y)
        paddleX = Int(paddle.center.x)
        paddleY = Int(paddle.center.y)
        
        ballXVelo = 1 - 2 * Int.random(in: 0...1)
        print(ballXVelo)
        
        setupBricks()
        
        let gameTimer = Timer.scheduledTimer(timeInterval: 1 / fps, target: self, selector: #selector(runMainLoop), userInfo: nil, repeats: true)
    }
    
    func setupBricks() {
        brickDropInterval = defaultBDInterval
        for i in 0...4 {
            let brickImage = UIImage(named: "brick")
            let brickView = Brick(image: brickImage)
            
            brickView.hitLeft = 5 - i
            brickView.maxHit = 5 - i
            brickView.frame = CGRect(x: 0, y: i * brickHeight, width: Int(gameAreaView.frame.width), height: brickHeight)
            gameAreaView.addSubview(brickView)
            bricks.append(brickView)
            brickLeft += 1
        }
    }
    
    func updateBall() {
        // check if ball touches paddle
        if (ball.frame.intersects(paddle.frame)) {
            reverseYVelo
            // change picture here
        }
        
        // check if ball touches sides
        if (Int(ball.center.x) > Int(gameAreaView.frame.width) -  Int(ball.frame.width) / 2 || Int(ball.center.x) < Int(ball.frame.width) / 2) {
            reverseXVelo
        }
        
        // check if ball touches top
        if (Int(ball.center.y) < Int(ball.frame.width) / 2) {
            reverseYVelo
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
                        brickDropInterval *= 0.6
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
        // implement losing end here
    }
    
    func winning() {
        // implement winning end here
    }
    
    @objc func runMainLoop() {
        ball.center.x = CGFloat(ballX)
        ball.center.y = CGFloat(ballY)
        
        updateBall()
        
        ballX = Int(ball.center.x)
        ballY = Int(ball.center.y)
        
        if (Int(timeElapsed * fps) % Int(brickDropInterval * fps) == 0) {
            shiftBricks()
        }
        
        if (brickLeft == 0) {
            setupBricks()
//            winning()
        }
        timeElapsed += 1 / fps
    }
    
    func printBall() {
        print("X: " + String(Int(ball.center.x)))
        print("Y: " + String(Int(ball.center.y)))
        print("XVelo: " + String(ballXVelo))
        print("YVelo: " + String(ballYVelo))
    }
    
}

