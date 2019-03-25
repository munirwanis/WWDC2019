//
//  ViewController.swift
//  WWDC2019
//
//  Created by Munir Wanis on 2019-03-23.
//  Copyright © 2019 Wanis Co. All rights reserved.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    /// The Label that will appear when the game is running
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.noteworthy.bold(ofSize: 30)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.text = " SCORE: 0 "
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.noteworthy.bold(ofSize: 30)
        label.textColor = .white
        label.numberOfLines = 0
        label.alpha = 0
        label.textAlignment = .center
        label.text = """
        The music notes appear in the rhythm, try to explode all of them by
        tapping on them! Each color has it's own value in points.
        Good luck!
        """
        return label
    }()
    
    private let menuBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: blur)
    }()
    
    private let sceneView: ARSCNView = {
        let view = ARSCNView()
        view.isDebug(enabled: false)
        return view
    }()
    
    /// Stack that holds menu buttons
    private let menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    private let endGameBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: blur)
    }()
    
    /// Stack that holds end game label and button
    private let endGameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.alpha = 0.0
        return stackView
    }()
    
    private let endGameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.noteworthy.bold(ofSize: 25)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0.0
        return label
    }()
    
    private let endGameView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        return view
    }()
    
    
    /// The game score
    private var score: UInt = 0 {
        didSet {
            scoreLabel.text = " SCORE: \(score) "
        }
    }
    
    private let music = Music(fileName: "FellInLoveWithAGirl",
                              ext: "m4a",
                              bpm: 96)
    private var menuViews = [UIView]()
    private var endGameViews = [UIView]()
    private var scoreViews = [UIView]()
    private let sceneViewConfig = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARScene()
        setupMenu()
        music.delegate = self
        setupGestureRecognizer()
        setupScore()
        setupEndGameView()
    }
}

// MARK: - UI methods

extension ViewController {
    
    /// Setups the game scene
    private func setupARScene() {
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.pinEdgesToSuperview()
        sceneView.session.run(sceneViewConfig)
    }
    
    /// Setups the game menu
    private func setupMenu() {
        view.addSubview(menuBlurView)
        menuBlurView.translatesAutoresizingMaskIntoConstraints = false
        menuBlurView.pinEdgesToSuperview()
        
        let startButton = MenuButton(withTitle: "Start",
                                     target: self,
                                     action: #selector(didPressStartButton))
        
        let instructionsAction = #selector(didPressInstructionsButton)
        let instructionsButton = MenuButton(withTitle: "Instructions",
                                            target: self,
                                            action: instructionsAction)
        
        menuStackView.addArrangedSubview(startButton)
        menuStackView.addArrangedSubview(instructionsButton)
        view.addSubview(menuStackView)
        menuStackView.translatesAutoresizingMaskIntoConstraints = false
        menuStackView.centerHorizontally()
        menuStackView.centerVertically()
        menuStackView.pinLeft(20)
        menuStackView.pinRight(20)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        instructionsButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.constraintWidth(120)
        instructionsButton.constraintWidth(120)
        
        menuStackView.addArrangedSubview(instructionsLabel)
        
        menuViews.append(contentsOf: [menuBlurView, menuStackView])
    }
    
    /// Setups the end game menu
    private func setupEndGameView() {
        view.addSubview(endGameView)
        endGameView.translatesAutoresizingMaskIntoConstraints = false
        endGameView.centerHorizontally()
        endGameView.centerVertically()
        endGameView.leadingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor,
                                             constant: 20).isActive = true
        endGameView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                              constant: -10).isActive = true
        
        endGameView.addSubview(endGameBlurView)
        endGameBlurView.translatesAutoresizingMaskIntoConstraints = false
        endGameBlurView.pinEdgesToSuperview()
        
        endGameStackView.addArrangedSubview(endGameLabel)
        endGameLabel.translatesAutoresizingMaskIntoConstraints = false
        endGameLabel.constraintHeight(200)
        endGameLabel.numberOfLines = 0
        let button = MenuButton(withTitle: "OK",
                                target: self,
                                action: #selector(didPressEndGameButton))
        
        endGameStackView.addArrangedSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.constraintWidth(120)
        
        endGameView.addSubview(endGameStackView)
        endGameStackView.translatesAutoresizingMaskIntoConstraints = false
        endGameStackView.pinBottom(20)
        endGameStackView.pinLeft(20)
        endGameStackView.pinRight(20)
        endGameStackView.pinTop(20)
        
        let views = [
            endGameView,
            endGameBlurView,
            endGameLabel,
            endGameStackView,
            button
        ]
        endGameViews.append(contentsOf: views)
    }
    
    /// Setups the in-game information, like Stop button and Score Label
    private func setupScore() {
        view.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                        constant: 20).isActive = true
        scoreLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                            constant: 20).isActive = true
        scoreLabel.alpha = 0.0
        
        
        let endGameStopButton = MenuButton(withTitle: "Stop",
                                           target: self,
                                           action: #selector(didPressStopGame))
        view.addSubview(endGameStopButton)
        endGameStopButton.translatesAutoresizingMaskIntoConstraints = false
        endGameStopButton.alpha = 0.0
        endGameStopButton.centerHorizontally()
        
        endGameStopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -20).isActive = true
        endGameStopButton.constraintWidth(120)
        
        let views = [scoreLabel, endGameStopButton]
        scoreViews.append(contentsOf: views)
    }
    
    /// Adds gesture tap/touch to sceneView so we can recognize when
    /// the user touches the music note
    private func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(sceneTapped))
        sceneView.gestureRecognizers = [tapRecognizer]
    }
    
    /// Adds the music note 3D model to the scene at the given position
    ///
    /// - Parameter position: SCNVector3 position
    private func addMusicNote(to position: SCNVector3) {
        let baseNode: SCNNode
        
        let filePath = "art.scnassets/MusicNote/music_note.dae"
        if let musicNoteScene = SCNScene(named: filePath) {
            let nodeName = "baseNode"
            let rootNode = musicNoteScene.rootNode
            guard let node = rootNode
                .childNode(withName: nodeName, recursively: true) else {
                    fatalError("Could not load 3D Model")
            }
            baseNode = node
        } else {
            let sphere = SCNSphere(radius: 100)
            baseNode = SCNNode(geometry: sphere)
        }
        baseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.random
        baseNode.scale = .init(0.1, 0.1, 0.1)
        baseNode.position = position
        baseNode.opacity = 0.0
        
        if let cameraNode = sceneView.pointOfView {
            updatePositionAndOrientation(of: baseNode,
                                         with: position,
                                         relativeTo: cameraNode)
        }
        
        sceneView.scene.rootNode.addChildNode(baseNode)
        baseNode.runAction(SCNAction.fadeIn(duration: 0.25))
    }
}

// MARK: - Actions

extension ViewController {
    
    /// Prepares to start the game
    @objc private func didPressStartButton() {
        shouldShowScore(true)
        shouldShowMenu(false)
        music.playOrPause()
    }
    
    /// Prepares to show the game instructions
    @objc private func didPressInstructionsButton() {
        instructionsLabel.alpha = instructionsLabel.alpha == 0.0 ? 1.0 : 0.0
    }
    
    /// Prepares to finish game
    @objc private func didPressEndGameButton() {
        shouldShowEndGame(false)
        shouldShowMenu(true)
    }
    
    /// Prepares to show the end game message
    @objc private func didPressStopGame() {
        finishGame()
        music.stop()
    }
    
    
    /// Determines if the menu should be enabled
    ///
    /// - Parameter condition: The boolean condition
    private func shouldShowMenu(_ condition: Bool) {
        shouldShow(menuViews, with: condition)
    }
    
    /// Determines if the score should be enabled
    ///
    /// - Parameter condition: The boolean condition
    private func shouldShowScore(_ condition: Bool) {
        shouldShow(scoreViews, with: condition)
    }
    
    /// Determines if the end game should be enabled
    ///
    /// - Parameter condition: The boolean condition
    private func shouldShowEndGame(_ condition: Bool) {
        endGameLabel.text = "Congratulations, you made \(score) points!"
        shouldShow(endGameViews, with: condition)
    }
    
    /// Generic to determine if the views should be enabled
    ///
    /// - Parameters:
    ///   - views: Collection of views to be enabled/disabled
    ///   - condition: The boolean condition
    private func shouldShow(_ views: [UIView], with condition: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            views.forEach { $0.alpha = condition ? 1.0 : 0.0 }
        }, completion: { _ in
            views.forEach { $0.isHidden = !condition }
        })
    }
    
    /// Identify if the music note was tapped and "explode" it
    /// after the explosion the music note disappears and the score is
    /// applied
    ///
    /// - Parameter recognizer: Gesture Recognizer
    @objc private func sceneTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        guard hitResults.count > 0 else { return }
        let result = hitResults[0]
        let node = result.node
        let explosionNode = SCNNode()
        let particles = SCNParticleSystem(named: "Explosion", inDirectory: nil)
        explosionNode.addParticleSystem(particles!)
        explosionNode.position = node.position
        sceneView.scene.rootNode.addChildNode(explosionNode)
        
        let contents = node.geometry?.firstMaterial?.diffuse.contents
        let nodeColor = contents as? UIColor
        score += getScore(from: nodeColor)
        
        node.removeFromParentNode()
    }
    
    /// Determines the score based on the color of the music note
    ///
    /// - Parameter color: The music note color
    /// - Returns: A multiplied by 5 value given the music color
    private func getScore(from color: UIColor?) -> UInt {
        guard let color = color else { return 50 }
        
        guard let index = UIColor.palette.firstIndex(of: color) else {
            return 50
        }
        
        return UInt((index + 1) * 5)
    }
    
    /// Ends the game and reset stats
    private func finishGame() {
        shouldShowScore(false)
        shouldShowEndGame(true)
        score = 0
        sceneView.scene.rootNode.childNodes.forEach {
            $0.removeFromParentNode()
        }
    }
    
    /// Determines position of the node based on another node location.
    /// It is used in the game to add the music note based on the camera
    /// location.
    ///
    /// - Parameters:
    ///   - node: The node to be transformed
    ///   - position: The position to be applied
    ///   - refNode: The node to be used as base to the first parameter
    private func updatePositionAndOrientation(of node: SCNNode,
                                              with position: SCNVector3,
                                              relativeTo refNode: SCNNode) {
        
        let referenceNodeTransform = matrix_float4x4(refNode.transform)
        
        // Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z
        
        // Combine the configured translation matrix with the referenceNode's
        // transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform,
                                               translationMatrix)
        node.transform = SCNMatrix4(updatedTransform)
    }
}


// MARK: - Music Delegate

extension ViewController: MusicDelegate {
    func musicDidEndPlaying(successfully: Bool) {
        finishGame()
    }
    
    func musicDidPassOneBeat() {
        let x = CGFloat.random(in: -10.0...10.0)
        let y = CGFloat.random(in: -10.0...10.0)
        let z = CGFloat.random(in: 1...10.0) * -1.0
        let position = SCNVector3(x, y, z)
        addMusicNote(to: position)
    }
}
