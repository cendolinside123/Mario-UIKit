//
//  Mario.swift
//  Mario
//
//  Created by Jan Sebastian on 03/06/24.
//

import Foundation
import UIKit

enum MarioDirection {
    case left
    case right
}

class Mario: UIView {
    
    // MARK: - Subviews
    private let hitBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let imgChar: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        // Enable nearest-neighbor filtering for crisp retro pixel art
        imageView.layer.magnificationFilter = .nearest
        imageView.layer.minificationFilter = .nearest
        return imageView
    }()
    
    // MARK: - Cached Textures
    private let idleImage = UIImage(named: "MarioIdle")
    private let runImage1 = UIImage(named: "MarioRun1")
    private let runImage2 = UIImage(named: "MarioRun2")
    private let runImage3 = UIImage(named: "MarioRun3")
    
    private lazy var runFrames: [UIImage?] = [runImage1, runImage2, runImage3]
    
    // MARK: - State Properties
    private var countingStep: Int = 0
    private var isJump: Bool = false
    private(set) var facingDirection: MarioDirection = .right
    
    // Animation timing
    private var animationTimer: TimeInterval = 0.0
    private var currentFrameIndex: Int = 0
    private let animationFrameDuration: TimeInterval = 0.09
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    // MARK: - Layout Setup
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(hitBoxView)
        hitBoxView.addSubview(imgChar)
        imgChar.image = idleImage
    }
    
    private func setupConstraints() {
        hitBoxView.translatesAutoresizingMaskIntoConstraints = false
        imgChar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hitBoxView.topAnchor.constraint(equalTo: self.topAnchor),
            hitBoxView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hitBoxView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hitBoxView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            imgChar.topAnchor.constraint(equalTo: hitBoxView.topAnchor),
            imgChar.bottomAnchor.constraint(equalTo: hitBoxView.bottomAnchor),
            imgChar.leadingAnchor.constraint(equalTo: hitBoxView.leadingAnchor),
            imgChar.trailingAnchor.constraint(equalTo: hitBoxView.trailingAnchor)
        ])
    }
}

// MARK: - Public API & Movement Animations
extension Mario {
    
    func getImgChar() -> UIImageView {
        return imgChar
    }
    
    @available(*, deprecated, renamed: "getImgChar")
    func getImgCahr() -> UIImageView {
        return getImgChar()
    }
    
    func resetPosition() {
        countingStep = 0
        animationTimer = 0
        currentFrameIndex = 0
        imgChar.image = idleImage
    }
    
    /// Updates Mario's sprite animation smoothly based on movement state and delta time
    func updateMovementAnimation(isMoving: Bool, isGrounded: Bool, deltaTime: TimeInterval) {
        if !isGrounded {
            imgChar.image = runImage3 // Standard jump pose
            return
        }
        
        guard isMoving else {
            imgChar.image = idleImage
            animationTimer = 0
            currentFrameIndex = 0
            return
        }
        
        animationTimer += deltaTime
        if animationTimer >= animationFrameDuration {
            animationTimer = 0
            currentFrameIndex = (currentFrameIndex + 1) % runFrames.count
            imgChar.image = runFrames[currentFrameIndex] ?? idleImage
        }
    }
    
    /// Discrete step animation (backward compatible)
    func doWalking() {
        if isJump {
            imgChar.image = runImage3
            return
        }
        
        countingStep += 1
        let frameIndex = countingStep % runFrames.count
        imgChar.image = runFrames[frameIndex] ?? idleImage
    }
    
    /// Set facing direction with proper transform flipping
    func setFacingDirection(_ direction: MarioDirection) {
        facingDirection = direction
        switch direction {
        case .left:
            self.transform = CGAffineTransform(scaleX: -1, y: 1)
        case .right:
            self.transform = .identity
        }
    }
    
    func togglePosition() {
        setFacingDirection(facingDirection == .left ? .right : .left)
    }
    
    func isLeftStatus() -> Bool {
        return facingDirection == .left
    }
    
    func doJumping() {
        isJump = true
        imgChar.image = runImage3
    }
    
    func endJump() {
        isJump = false
        imgChar.image = idleImage
    }
}
