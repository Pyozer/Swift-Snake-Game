//
//  GameManager.swift
//  Snake
//
//  Created by Jean-Charles Moussé on 14/02/2019.
//  Copyright © 2019 Jean-Charles Moussé. All rights reserved.
//

import SpriteKit

enum PlayerDirection {
    case LEFT
    case RIGHT
    case UP
    case DOWN
}

class GameManager {
    
    var scene: GameScene!
    var numRows: Int!
    var numCols: Int!
    
    var nextTime: Double?
    var timeExtension: Double = 0.15
    var playerDirection: PlayerDirection = .LEFT
    
    init(scene: GameScene, numRows: Int, numCols: Int) {
        self.scene = scene
        self.numRows = numRows
        self.numCols = numCols
    }
    
    func initGame() {
        //starting player position
        scene.playerPositions.append(Point(10, 10))
        scene.playerPositions.append(Point(10, 11))
        scene.playerPositions.append(Point(10, 12))
        renderChange()
    }

    func update(time: Double) {
        if nextTime == nil {
            nextTime = time + timeExtension
        } else if time >= nextTime! {
            nextTime = time + timeExtension
            updatePlayerPosition()
        }
    }
    
    private func updatePlayerPosition() {
        var xChange = 0
        var yChange = 0
        if playerDirection == .LEFT {
            xChange = -1
        } else if playerDirection == .RIGHT {
            xChange = 1
        } else if playerDirection == .UP {
            yChange = -1
        } else if playerDirection == .DOWN {
            yChange = 1
        }

        if scene.playerPositions.count > 0 {
            var start = scene.playerPositions.count - 1
            while start > 0 {
                scene.playerPositions[start] = scene.playerPositions[start - 1]
                start -= 1
            }
            scene.playerPositions[0] = Point(
                scene.playerPositions[0].x + xChange,
                scene.playerPositions[0].y + yChange
            )
        }
        // Avoid snake go outside screen
        if scene.playerPositions.count > 0 {
            let x = scene.playerPositions[0].x
            let y = scene.playerPositions[0].y
            if y > self.numRows {
                scene.playerPositions[0].y = 0
            } else if y < 0 {
                scene.playerPositions[0].y = self.numRows
            } else if x > self.numCols {
                scene.playerPositions[0].x = 0
            } else if x < 0 {
                scene.playerPositions[0].x = self.numCols
            }
        }
        renderChange()
    }

    func renderChange() {
        for (node, point) in scene.gameArray {
            if contains(allPoint: scene.playerPositions, point: point) {
                node.fillColor = SKColor.cyan
            } else {
                node.fillColor = SKColor.clear
            }
        }
    }

    func contains(allPoint: [Point], point: Point) -> Bool {
        for p in allPoint {
            if point.x == p.x && point.y == p.y { return true }
        }
        return false
    }
}
