//
//  GameScene.swift
//  Snake
//
//  Created by Jean-Charles Moussé on 14/02/2019.
//  Copyright © 2019 Jean-Charles Moussé. All rights reserved.
//

import SpriteKit
import GameplayKit

class Point {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

class GameScene: SKScene {
    var gameLogo: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    
    var game: GameManager!
    
    var currentScore: SKLabelNode!
    var playerPositions: [Point] = []
    var gameBG: SKShapeNode!
    var gameArray: [(node: SKShapeNode, point: Point)] = []
    
    override func didMove(to view: SKView) {
        initializeMenu()
        game = GameManager(scene: self, numRows: 40, numCols: 20)
        initializeGameView()
        
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipeR() {
        self.game.playerDirection = .RIGHT
    }
    @objc func swipeL() {
        self.game.playerDirection = .LEFT
    }
    @objc func swipeU() {
        self.game.playerDirection = .UP
    }
    @objc func swipeD() {
        self.game.playerDirection = .DOWN
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.game.update(time: currentTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    startGame()
                }
            }
        }
    }
    
    private func startGame() {
        //1
        gameLogo.run(SKAction.move(by: CGVector(dx: 0, dy: 600), duration: 0.4)) {
            self.gameLogo.isHidden = true
        }
        //2
        playButton.run(SKAction.scale(to: 0, duration: 0.2)) {
            self.playButton.isHidden = true
        }
        //3
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.3)) {
                self.gameBG.setScale(0)
                self.currentScore.setScale(0)
                self.gameBG.isHidden = false
                self.currentScore.isHidden = false
                self.gameBG.run(SKAction.scale(to: 1, duration: 0.4))
                self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
                // Init game
                self.game.initGame()
        }
    }
    
    //3
    private func initializeMenu() {
        //Create game title
        gameLogo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameLogo.fontSize = 60
        gameLogo.text = "SNAKE"
        gameLogo.fontColor = SKColor.red
        self.addChild(gameLogo)
        //Create best score label
        bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 50)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: 0"
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
        //Create play button
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.cyan
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
    }
    
    private func initializeGameView() {
        currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        self.addChild(currentScore)
        
        let width = frame.size.width - 200
        let height = width * 2

        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true
        self.addChild(gameBG)

        createGameBoard(width: width, height: height)
    }
    
    //create a game board, initialize array of cells
    private func createGameBoard(width: CGFloat, height: CGFloat) {
        let cellWidth = width / CGFloat(game.numCols)
        let cellHeight = height / CGFloat(game.numRows)
        
        var x = -width / 2 + cellWidth / 2
        var y = height / 2 - cellHeight / 2
        //loop through rows and columns, create cells
        for i in 0...game.numRows - 1 {
            for j in 0...game.numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellHeight))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                //add to array of cells -- then add to game board
                gameArray.append((node: cellNode, point: Point(j, i)))
                gameBG.addChild(cellNode)
                //iterate x
                x += cellWidth
            }
            //reset x, iterate y
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellHeight
        }
    }
}
