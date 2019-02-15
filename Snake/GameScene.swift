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
    
    func equals(_ other: Point) -> Bool {
        return self.x == other.x && self.y == other.y
    }
}

class GameScene: SKScene {
    // Main screen
    private var gameLogo: SKLabelNode!
    private var bestScore: SKLabelNode!
    private var playButton: SKShapeNode!
    // Died screen
    private var youDiedText: SKLabelNode!
    
    // Game screen
    private var game: GameManager!
    var currentScore: SKLabelNode!
    private var gameBG: SKShapeNode!
    var gameArray: [(node: SKShapeNode, point: Point)] = []
    
    private var scaleOutAction: SKAction!
    private var scaleInAction: SKAction!
    private var moveOutsideTopAction: SKAction!
    private var moveBackFromTopAction: SKAction!
    
    override func didMove(to view: SKView) {
        scaleInAction = SKAction.init(named: "ScaleIn")
        scaleOutAction = SKAction.init(named: "ScaleOut")
        moveOutsideTopAction = SKAction.init(named: "MoveOutsideTop")
        moveBackFromTopAction = SKAction.init(named: "MoveBackFromTop")
        
        initializeMenu()
        game = GameManager(scene: self, numRows: 30, numCols: 20)
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
    
    @objc func swipeR() { game.changeDirection(.RIGHT) }
    @objc func swipeL() { game.changeDirection(.LEFT) }
    @objc func swipeU() { game.changeDirection(.UP) }
    @objc func swipeD() {  game.changeDirection(.DOWN) }
    
    override func update(_ currentTime: TimeInterval) {
        game.update(time: currentTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" { startGame() }
            }
        }
    }
    
    private func startGame() {
        self.gameBG.setScale(0)
        self.currentScore.setScale(0)
        
        playButton.run(scaleOutAction) {
            self.playButton.isHidden = true
        }

        gameLogo.run(moveOutsideTopAction) {
            self.gameLogo.isHidden = true
            self.gameBG.isHidden = false
            self.currentScore.isHidden = false
            self.currentScore.run(self.scaleInAction)
            self.gameBG.run(self.scaleInAction) {
                // Init game
                self.game.initGame()
            }
        }
    }
    
    private func initializeMenu() {
        //Create game title
        gameLogo = SKLabelNode(fontNamed: "Avenir Next")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameLogo.fontSize = 60
        gameLogo.text = "SNAKE"
        gameLogo.fontColor = SKColor.red
        self.addChild(gameLogo)
        //Create play button
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.green
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
        currentScore = SKLabelNode(fontNamed: "Avenir Next")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        self.addChild(currentScore)
        
        let width = frame.size.width - 200
        let cellSize = width  / CGFloat(game.numCols)
        let height = cellSize * CGFloat(game.numRows)

        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true
        self.addChild(gameBG)

        createGameBoard(width: width, height: height, cellSize: cellSize)
    }
    
    //create a game board, initialize array of cells
    private func createGameBoard(width: CGFloat, height: CGFloat, cellSize: CGFloat) {
        var x = -width / 2 + cellSize / 2
        var y = height / 2 - cellSize / 2
        //loop through rows and columns, create cells
        for i in 0...game.numRows - 1 {
            for j in 0...game.numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                //add to array of cells -- then add to game board
                gameArray.append((node: cellNode, point: Point(j, i)))
                gameBG.addChild(cellNode)
                //iterate x
                x += cellSize
            }
            //reset x, iterate y
            x = CGFloat(width / -2) + (cellSize / 2)
            y -= cellSize
        }
    }
    
    func finishAnimation() {
        currentScore.run(scaleOutAction) {
            self.currentScore.isHidden = true
        }
        gameBG.run(scaleOutAction) {
            self.gameBG.isHidden = true
            self.gameLogo.isHidden = false
            self.gameLogo.run(self.moveBackFromTopAction) {
                self.playButton.isHidden = false
                self.playButton.run(self.scaleInAction)
            }
        }
    }

}
