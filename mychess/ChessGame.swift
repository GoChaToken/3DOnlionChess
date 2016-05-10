//
//  ChessGame.swift
//  Chess
//
//  Created by afei on 5/8/16.
//  Copyright © 2016 Bo. All rights reserved.
//

import Foundation
import SceneKit

struct ChessSquare {
    let _row: Int
    let _col: Int
    
    init() {
        _row = 0
        _col = 0
    }
    
    init(row: String, col: String) {
        _col = Int(col.unicodeScalars.first!.value) - 65
        _row = 8 - Int(row)!
    }
    
    func isDark() -> Bool {
        return (_row + _col) % 2 == 1
    }
}

class PosSCNNode: SCNNode {
    var _square = ChessSquare()
    var _type: String = ""
    var _picked: Bool = false
    
    init(geometry: SCNGeometry, row: String, col: String, type: String) {
        super.init()
        self.geometry = geometry
        _square = ChessSquare(row: row, col: col)
        _type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func pick() {
        _picked = true
    }
    
    func unpick() {
        _picked = false
    }
    
    func moveTo(row: String, col: String) {
        let c_x = position.x
        let c_z = position.z
        let square = ChessSquare(row: row, col: col)
        position = SCNVector3Make(c_x + Float(square._col - _square._col), position.y, c_z + Float(square._row - _square._row))
        _square = square
    }
}

let PawnType   = "Pawn";
let RookType   = "Rook";
let KnightType = "Knight";
let BishopType = "Bishop";
let QueenType  = "Queen";
let KingType   = "King";
let FlatType   = "Flat"

class ChessGameSceneView : SCNView {
    
    let pieces = SCNScene(named: "chess pieces")
    let camera = SCNCamera()
    let spotLightL = SCNLight()
    let spotLightR = SCNLight()
    let omniLight = SCNLight()
    
    let cameraNode = SCNNode()
    let boardNode = SCNNode()
    let piecesNode = SCNNode()
    
    var IsDark = false
    let lightColor = UIColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0)
    let darkColor = UIColor(white: 0.25, alpha: 1.0)
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        scene = SCNScene()
        // setup camera
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 9, 6)
        
        let ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = UIColor(white: 0.1, alpha: 1.0)
        cameraNode.light = ambientLight
        
        // setup 4 lights on each corner
        let spotLightNodeL = setupSpotLight(spotLightL)
        spotLightNodeL.position = SCNVector3Make(-8, 8, 8)
        let spotLightNodeR = setupSpotLight(spotLightR)
        spotLightNodeR.position = SCNVector3Make(8, 8, 8)
        let omniLightNode = setupOmniLight(omniLight)
        omniLightNode.position = SCNVector3Make(0, 6, 0)
        
        // setup board
        addChessBoard(boardNode)
        if IsDark {
            boardNode.rotation = SCNVector4Make(0, 1, 0, Float(M_PI))
        }
        
        // setup pieces
        let piecesNode = SCNNode()
        addPieces(piecesNode)
        
        // constraint
        let constraint = SCNLookAtConstraint(target: scene!.rootNode)
        constraint.gimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        spotLightNodeL.constraints = [constraint]
        spotLightNodeR.constraints = [constraint]
        
        scene!.rootNode.addChildNode(spotLightNodeL)
        scene!.rootNode.addChildNode(spotLightNodeR)
        scene!.rootNode.addChildNode(omniLightNode)
        scene!.rootNode.addChildNode(cameraNode)
        scene!.rootNode.addChildNode(boardNode)
        scene!.rootNode.addChildNode(piecesNode)
        
        backgroundColor = UIColor.blackColor()
        antialiasingMode = SCNAntialiasingMode.Multisampling4X
    }
    
    override init(frame: CGRect, options: [String : AnyObject]?) {
        super.init(frame: frame, options: options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // set the property of the lights, and create a node containing the light
    func setupSpotLight(light: SCNLight) -> SCNNode {
        light.type = SCNLightTypeSpot
        light.spotInnerAngle = 30
        light.spotOuterAngle = 80
        light.color = UIColor(white: 0.2, alpha: 1.0)
        light.castsShadow = true
        
        let lightNode = SCNNode()
        lightNode.light = light
        
        return lightNode
    }
    
    func setupOmniLight(light: SCNLight) -> SCNNode {
        light.type = SCNLightTypeOmni
        let lightNode = SCNNode()
        lightNode.light = light
        
        return lightNode
    }
    
    // only one chess board in the scene, so only call it once
    func addChessBoard(boardNode: SCNNode) {
        let lightSquare = SCNBox(width: 1, height: 0.2, length: 1, chamferRadius: 0)
        let darkSquare = SCNBox(width: 1, height: 0.2, length: 1, chamferRadius: 0)
        
        let lightMaterial = SCNMaterial()
        lightMaterial.diffuse.contents = lightColor
        
        let darkMaterial = SCNMaterial()
        darkMaterial.diffuse.contents = darkColor
        
        lightSquare.materials = [lightMaterial]
        darkSquare.materials = [darkMaterial]
        

        for col in ["A", "B", "C", "D", "E", "F", "G", "H"] {
            for row in ["1", "2", "3", "4", "5", "6", "7", "8"] {
                let square = ChessSquare(row: row, col: col)
                let flat = square.isDark() ? darkSquare : lightSquare
                let squareNode = PosSCNNode(geometry: flat, row: row, col: col, type: FlatType)
                
                squareNode.position = positionForRowCol(row: row, col: col)
                boardNode.addChildNode(squareNode)
            }
        }
    }
    
    func addPieces(parentNode: SCNNode) {
        
        parentNode.addChildNode(pieceOfType(RookType, isDark: false, rrow: "1", ccol: "A"))
        parentNode.addChildNode(pieceOfType(KnightType, isDark: false, rrow: "1", ccol: "B"))
        parentNode.addChildNode(pieceOfType(BishopType, isDark: false, rrow: "1", ccol: "C"))
        parentNode.addChildNode(pieceOfType(QueenType, isDark: false, rrow: "1", ccol: "D"))
        parentNode.addChildNode(pieceOfType(KingType, isDark: false, rrow: "1", ccol: "E"))
        parentNode.addChildNode(pieceOfType(BishopType, isDark: false, rrow: "1", ccol: "F"))
        parentNode.addChildNode(pieceOfType(KnightType, isDark: false, rrow: "1", ccol: "G"))
        parentNode.addChildNode(pieceOfType(RookType, isDark: false, rrow: "1", ccol: "H"))
        
        for col in ["A", "B", "C", "D", "E", "F", "G", "H"] {
            parentNode.addChildNode(pieceOfType(PawnType, isDark: false, rrow: "2", ccol: col))
            parentNode.addChildNode(pieceOfType(PawnType, isDark: true, rrow: "7", ccol: col))
        }
        
        parentNode.addChildNode(pieceOfType(RookType, isDark: true, rrow: "8", ccol: "A"))
        parentNode.addChildNode(pieceOfType(KnightType, isDark: true, rrow: "8", ccol: "B"))
        parentNode.addChildNode(pieceOfType(BishopType, isDark: true, rrow: "8", ccol: "C"))
        parentNode.addChildNode(pieceOfType(QueenType, isDark: true, rrow: "8", ccol: "D"))
        parentNode.addChildNode(pieceOfType(KingType, isDark: true, rrow: "8", ccol: "E"))
        parentNode.addChildNode(pieceOfType(BishopType, isDark: true, rrow: "8", ccol: "F"))
        parentNode.addChildNode(pieceOfType(KnightType, isDark: true, rrow: "8", ccol: "G"))
        parentNode.addChildNode(pieceOfType(RookType, isDark: true, rrow: "8", ccol: "H"))
    }
    
    func pieceOfType(type: String, isDark: Bool, rrow: String, ccol: String) -> SCNNode {
        let tmpNode = pieces!.rootNode.childNodeWithName(type, recursively: true)!
        let pieceNode: PosSCNNode
        
        if isDark {
            pieceNode = PosSCNNode(geometry: tmpNode.geometry!.copy() as! SCNGeometry, row: rrow, col: ccol, type: type)
            let geometry = pieceNode.geometry!
            let material = geometry.materials[0].copy() as! SCNMaterial
            material.diffuse.contents = darkColor
            geometry.materials[0] = material
        }
        else {
            pieceNode = PosSCNNode(geometry: tmpNode.geometry!, row: rrow, col: ccol, type: type)
        }
        
        pieceNode.position = positionForRowCol(row: rrow, col: ccol)
        pieceNode.rotation = SCNVector4Make(0, 1, 0, Float(isDark ? 0 : M_PI))
        
        pieceNode.scale = SCNVector3Make(0.67, 0.67, 0.67)
        
        return pieceNode
    }
    
    func positionForRowCol(row aRow: String, col: String) -> SCNVector3 {
        let square = ChessSquare(row: aRow, col: col)
        let pos = boardNode.position
        let firstRow = pos.x - 3.5
        let firstCol = pos.z - 3.5
        
        return SCNVector3Make(firstRow + Float(square._col), pos.y+0.1, firstCol + Float(square._row))
    }
    
}