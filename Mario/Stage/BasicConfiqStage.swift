//
//  BasicConfiqStage.swift
//  Mario
//
//  Created by Jan Sebastian on 03/06/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

typealias BasicConfigStage = BasicConfiqStage

protocol MarioMovingRule {
    func doMoveLeft()
    func doMoveRight()
    func doJump()
    func stillFall()
}

class BasicConfiqStage: UIViewController {
    
    // MARK: - Core Mario Character
    let marioChar: Mario = Mario()
    
    // MARK: - Game Controls UI
    let stackViewBtnArrow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 14
        stackView.isMultipleTouchEnabled = true
        return stackView
    }()
    
    let btnLeft: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        button.setTitle("◀", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.layer.borderWidth = 1.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.isExclusiveTouch = false
        return button
    }()
    
    let btnRight: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        button.setTitle("▶", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.layer.borderWidth = 1.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.isExclusiveTouch = false
        return button
    }()
    
    let btnJump: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.88, green: 0.20, blue: 0.20, alpha: 0.8)
        button.setTitle("JUMP", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .black)
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        button.layer.borderWidth = 1.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.isExclusiveTouch = false
        return button
    }()
    
    // MARK: - Stage & Collision State
    var viewLimit: [RectInfo] = []
    weak var stageContainerView: UIView?
    
    // MARK: - Reactive Movement State
    let bag: DisposeBag = DisposeBag()
    let marioMoveAct: PublishSubject<MoveType> = PublishSubject()
    var currentMoveType: MoveType = .Idle
    
    var curentMoveType: MoveType {
        get { return currentMoveType }
        set { currentMoveType = newValue }
    }
    
    // MARK: - Physics & Engine Properties
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0.0
    
    private var isLeftInputActive: Bool = false
    private var isRightInputActive: Bool = false
    private var isJumpInputActive: Bool = false
    
    private var velocityX: CGFloat = 0.0
    private var velocityY: CGFloat = 0.0
    private var isGrounded: Bool = false
    private var isJumping: Bool = false
    private var coyoteTimer: TimeInterval = 0.0
    
    // Physics Constants
    private let walkSpeed: CGFloat = 180.0             // points/second
    private let acceleration: CGFloat = 950.0          // points/second^2
    private let friction: CGFloat = 1100.0             // points/second^2
    private let jumpSpeed: CGFloat = -420.0            // instantaneous upward velocity
    private let minJumpCutoffSpeed: CGFloat = -160.0   // early release variable jump cutoff
    private let gravity: CGFloat = 1100.0              // downward acceleration
    private let terminalVelocity: CGFloat = 550.0      // max fall speed
    private let coyoteDuration: TimeInterval = 0.08    // edge jump grace window
    
    // Haptics
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isMultipleTouchEnabled = true
        setupButtonActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPhysicsLoop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPhysicsLoop()
    }
    
    deinit {
        stopPhysicsLoop()
    }
    
    // MARK: - Public Configuration
    func configureMario(positionX: Int, positionY: Int, container: UIView) {
        stageContainerView = container
        container.addSubview(marioChar)
        marioChar.frame = CGRect(x: CGFloat(positionX), y: CGFloat(positionY - (65 + 1)), width: 50, height: 65)
        marioChar.layoutIfNeeded()
        isGrounded = true
        velocityX = 0.0
        velocityY = 0.0
        coyoteTimer = coyoteDuration
    }
    
    func setupController() {
        self.view.addSubview(stackViewBtnArrow)
        stackViewBtnArrow.addArrangedSubview(btnLeft)
        stackViewBtnArrow.addArrangedSubview(btnRight)
        self.view.addSubview(btnJump)
        
        stackViewBtnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnJump.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackViewBtnArrow.heightAnchor.constraint(equalToConstant: 64),
            stackViewBtnArrow.widthAnchor.constraint(equalToConstant: 160),
            stackViewBtnArrow.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stackViewBtnArrow.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            
            btnJump.heightAnchor.constraint(equalToConstant: 64),
            btnJump.widthAnchor.constraint(equalToConstant: 72),
            btnJump.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            btnJump.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    func initCollision(listRect: [RectInfo]) {
        viewLimit = listRect
    }
    
    func initColition(listRect: [RectInfo]) {
        initCollision(listRect: listRect)
    }
    
    func doIdle() {
        isLeftInputActive = false
        isRightInputActive = false
        velocityX = 0
        marioChar.resetPosition()
    }
}

// MARK: - Game Loop & Physics Simulation
private extension BasicConfiqStage {
    
    func startPhysicsLoop() {
        guard displayLink == nil else { return }
        lastTimestamp = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(physicsStep(link:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }
    
    func stopPhysicsLoop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func physicsStep(link: CADisplayLink) {
        let currentTime = CACurrentMediaTime()
        var dt = currentTime - lastTimestamp
        lastTimestamp = currentTime
        
        // Prevent spiral of death / teleportation on frame drops
        if dt > 0.033 {
            dt = 0.033
        } else if dt < 0.001 {
            dt = 0.001
        }
        
        updatePhysics(dt: dt)
    }
    
    func updatePhysics(dt: TimeInterval) {
        guard marioChar.superview != nil else { return }
        
        let delta = CGFloat(dt)
        
        // 1. Horizontal Acceleration & Friction
        if isLeftInputActive && !isRightInputActive {
            velocityX = max(velocityX - acceleration * delta, -walkSpeed)
            marioChar.setFacingDirection(.left)
        } else if isRightInputActive && !isLeftInputActive {
            velocityX = min(velocityX + acceleration * delta, walkSpeed)
            marioChar.setFacingDirection(.right)
        } else {
            // Apply friction towards 0
            if velocityX > 0 {
                velocityX = max(0, velocityX - friction * delta)
            } else if velocityX < 0 {
                velocityX = min(0, velocityX + friction * delta)
            }
        }
        
        // 2. Vertical Gravity
        if !isGrounded {
            velocityY += gravity * delta
            if velocityY > terminalVelocity {
                velocityY = terminalVelocity
            }
            if coyoteTimer > 0 {
                coyoteTimer -= dt
            }
        } else {
            coyoteTimer = coyoteDuration
        }
        
        // 3. Resolve Collisions against Stage Bounds & Obstacles
        resolveCollisions(dt: delta)
        
        // 4. Update Animations & State
        marioChar.updateMovementAnimation(
            isMoving: abs(velocityX) > 10.0,
            isGrounded: isGrounded,
            deltaTime: dt
        )
        
        updateMoveTypeState()
    }
    
    func resolveCollisions(dt: CGFloat) {
        var currentFrame = marioChar.frame
        
        // Determine Stage Boundaries
        var stageBounds = stageContainerView?.bounds ?? (marioChar.superview?.bounds ?? self.view.bounds)
        for item in viewLimit where item.type == .Background {
            stageBounds = CGRect(x: 0, y: 0, width: item.rect.width, height: item.rect.height)
            break
        }
        
        let solidObstacles = viewLimit.filter { $0.type == .HardItem || $0.type == .SemiHardItem }
        
        // --- HORIZONTAL RESOLUTION (X-Axis) ---
        let deltaX = velocityX * dt
        var nextX = currentFrame.origin.x + deltaX
        
        // Clamp to left/right stage walls
        let minX = stageBounds.minX
        let maxX = stageBounds.maxX - currentFrame.width
        if nextX < minX {
            nextX = minX
            velocityX = 0
        } else if nextX > maxX {
            nextX = maxX
            velocityX = 0
        }
        
        // Test horizontal collisions with solid obstacles (HardItem)
        // Inset vertically by 4 points so standing on top of an obstacle doesn't cause a side collision
        let xHitBox = CGRect(x: nextX, y: currentFrame.origin.y + 4, width: currentFrame.width, height: currentFrame.height - 8)
        for obstacle in solidObstacles where obstacle.type == .HardItem {
            if xHitBox.intersects(obstacle.rect) {
                if deltaX > 0 { // Moving Right -> hit left wall of obstacle
                    nextX = min(nextX, obstacle.rect.minX - currentFrame.width)
                    velocityX = 0
                } else if deltaX < 0 { // Moving Left -> hit right wall of obstacle
                    nextX = max(nextX, obstacle.rect.maxX)
                    velocityX = 0
                }
            }
        }
        currentFrame.origin.x = nextX
        
        // --- VERTICAL RESOLUTION (Y-Axis) ---
        let deltaY = velocityY * dt
        var nextY = currentFrame.origin.y + deltaY
        var landed = false
        
        // Ground floor collision
        let floorY = stageBounds.maxY - currentFrame.height
        if nextY >= floorY {
            nextY = floorY
            velocityY = 0
            landed = true
        }
        
        // Test vertical collisions with obstacles (landing on top or bonking head)
        // Inset horizontally by 3 points so Mario doesn't snag while brushing against the side
        let yHitBox = CGRect(x: currentFrame.origin.x + 3, y: nextY, width: currentFrame.width - 6, height: currentFrame.height)
        for obstacle in solidObstacles {
            if yHitBox.intersects(obstacle.rect) {
                if obstacle.type == .HardItem {
                    // Moving Upwards -> bonk ceiling
                    if deltaY < 0 && currentFrame.origin.y >= obstacle.rect.maxY - 8 {
                        nextY = obstacle.rect.maxY
                        velocityY = 0
                    }
                    // Moving Downwards -> land on top
                    else if deltaY >= 0 && currentFrame.maxY <= obstacle.rect.minY + max(14.0, deltaY + 4.0) {
                        nextY = obstacle.rect.minY - currentFrame.height
                        velocityY = 0
                        landed = true
                    }
                } else if obstacle.type == .SemiHardItem {
                    // SemiHardItem: only land from above
                    if deltaY >= 0 && currentFrame.maxY <= obstacle.rect.minY + max(14.0, deltaY + 4.0) {
                        nextY = obstacle.rect.minY - currentFrame.height
                        velocityY = 0
                        landed = true
                    }
                }
            }
        }
        
        currentFrame.origin.y = min(nextY, floorY)
        marioChar.frame = currentFrame
        
        // Check grounded status & edge walk-off
        if landed {
            isGrounded = true
            isJumping = false
        } else {
            // If we didn't land this frame, check if Mario is still resting on an obstacle or floor
            if isGrounded && velocityY == 0 {
                let checkFeetBox = CGRect(x: currentFrame.minX + 4, y: currentFrame.maxY, width: currentFrame.width - 8, height: 2)
                var hasSolidGround = (currentFrame.maxY >= floorY - 0.5)
                if !hasSolidGround {
                    for obstacle in solidObstacles {
                        if checkFeetBox.intersects(obstacle.rect) {
                            hasSolidGround = true
                            break
                        }
                    }
                }
                if !hasSolidGround {
                    // Walked off an edge!
                    isGrounded = false
                }
            } else {
                isGrounded = false
            }
        }
    }
    
    func updateMoveTypeState() {
        let newMoveType: MoveType
        
        if isGrounded {
            if velocityX > 10.0 {
                newMoveType = .Right
            } else if velocityX < -10.0 {
                newMoveType = .Left
            } else {
                newMoveType = .Idle
            }
        } else {
            let horizontalDir: MoveType?
            if velocityX > 10.0 {
                horizontalDir = .Right
            } else if velocityX < -10.0 {
                horizontalDir = .Left
            } else {
                horizontalDir = nil
            }
            
            if velocityY < 0 {
                if let dir = horizontalDir {
                    newMoveType = .JumpMove(dir: dir)
                } else {
                    newMoveType = .Jump
                }
            } else {
                if let dir = horizontalDir {
                    newMoveType = .FallMove(dir: dir)
                } else {
                    newMoveType = .Fall
                }
            }
        }
        
        if newMoveType != currentMoveType {
            currentMoveType = newMoveType
            marioMoveAct.onNext(newMoveType)
        }
    }
}

// MARK: - Input & Touch Handling
extension BasicConfiqStage {
    
    private func setupButtonActions() {
        btnLeft.addTarget(self, action: #selector(leftButtonDown), for: [.touchDown, .touchDragEnter])
        btnLeft.addTarget(self, action: #selector(leftButtonUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        
        btnRight.addTarget(self, action: #selector(rightButtonDown), for: [.touchDown, .touchDragEnter])
        btnRight.addTarget(self, action: #selector(rightButtonUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        
        btnJump.addTarget(self, action: #selector(jumpButtonDown), for: .touchDown)
        btnJump.addTarget(self, action: #selector(jumpButtonUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func leftButtonDown() {
        isLeftInputActive = true
        animateButtonPress(btnLeft, isPressed: true)
    }
    
    @objc private func leftButtonUp() {
        isLeftInputActive = false
        animateButtonPress(btnLeft, isPressed: false)
    }
    
    @objc private func rightButtonDown() {
        isRightInputActive = true
        animateButtonPress(btnRight, isPressed: true)
    }
    
    @objc private func rightButtonUp() {
        isRightInputActive = false
        animateButtonPress(btnRight, isPressed: false)
    }
    
    @objc private func jumpButtonDown() {
        isJumpInputActive = true
        animateButtonPress(btnJump, isPressed: true)
        performJump()
    }
    
    @objc private func jumpButtonUp() {
        isJumpInputActive = false
        animateButtonPress(btnJump, isPressed: false)
        endVariableJump()
    }
    
    private func animateButtonPress(_ button: UIButton, isPressed: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            button.transform = isPressed ? CGAffineTransform(scaleX: 0.92, y: 0.92) : .identity
            button.alpha = isPressed ? 0.75 : 1.0
        }, completion: nil)
    }
    
    func performJump() {
        // Can jump if on ground or within coyote time
        if isGrounded || coyoteTimer > 0 {
            velocityY = jumpSpeed
            isGrounded = false
            isJumping = true
            coyoteTimer = 0
            marioChar.doJumping()
            impactFeedback.impactOccurred()
        }
    }
    
    func endVariableJump() {
        // If releasing jump early while still ascending rapidly, cut jump height for responsive short hops
        if velocityY < minJumpCutoffSpeed {
            velocityY = minJumpCutoffSpeed
        }
    }
    
    // MARK: - Backward-Compatible Selectors
    @objc func moveLeft() {
        isLeftInputActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.isLeftInputActive = false
        }
    }
    
    @objc func holdMoveLeft(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            isLeftInputActive = true
        case .ended, .cancelled, .failed:
            isLeftInputActive = false
        default:
            break
        }
    }
    
    @objc func moveRight() {
        isRightInputActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.isRightInputActive = false
        }
    }
    
    @objc func holdMoveRight(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            isRightInputActive = true
        case .ended, .cancelled, .failed:
            isRightInputActive = false
        default:
            break
        }
    }
    
    @objc func doJumping() {
        performJump()
    }
}

// MARK: - Hardware & Simulator Keyboard Support
extension BasicConfiqStage {
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }
            switch key.keyCode {
            case .keyboardLeftArrow, .keyboardA:
                isLeftInputActive = true
            case .keyboardRightArrow, .keyboardD:
                isRightInputActive = true
            case .keyboardUpArrow, .keyboardSpacebar, .keyboardW:
                performJump()
            default:
                super.pressesBegan(presses, with: event)
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }
            switch key.keyCode {
            case .keyboardLeftArrow, .keyboardA:
                isLeftInputActive = false
            case .keyboardRightArrow, .keyboardD:
                isRightInputActive = false
            case .keyboardUpArrow, .keyboardSpacebar, .keyboardW:
                endVariableJump()
            default:
                super.pressesEnded(presses, with: event)
            }
        }
    }
}

// MARK: - MarioMovingRule Protocol Conformance
extension BasicConfiqStage: MarioMovingRule {
    
    func doMoveLeft() {
        velocityX = -walkSpeed
        marioChar.setFacingDirection(.left)
    }
    
    func doMoveRight() {
        velocityX = walkSpeed
        marioChar.setFacingDirection(.right)
    }
    
    func doJump() {
        performJump()
    }
    
    func stillFall() {
        if isGrounded {
            isGrounded = false
        }
    }
}
