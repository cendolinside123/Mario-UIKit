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

protocol MarioMovingRule {
    func doMoveLeft()
    func doMoveRight()
    func doJump()
    func stillFall()
}


class BasicConfiqStage: UIViewController {
    let marioChar: Mario = Mario()
    
    private let stackViewBtnArrow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private let btnLeft: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.setTitle("<--", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let btnRight: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.setTitle("-->", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let btnJump: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.setTitle("Jump", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    
    
    private var viewLimit: [RectInfo] = []
    
    private var curentMoveType: MoveType = .Idle
    
    private let bag: DisposeBag = DisposeBag()
    private let marioMoveAct: PublishSubject<MoveType> = PublishSubject()
    private var gravityAct: Disposable?
    
    private weak var timerLongPressButton: Timer?
    private weak var doJumpAction: Timer?
    private var countJump: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allMarioActions()
        regisButtonAction()
    }
    
    func configureMario(positionX: Int, positionY: Int, container: UIView) {
        container.addSubview(marioChar)
        marioChar.frame = CGRect(x: positionX, y: positionY - (65 + 1), width: 50, height: 65)
        marioChar.layoutIfNeeded()
    }
    
    func setupController() {
        self.view.addSubview(stackViewBtnArrow)
        stackViewBtnArrow.addArrangedSubview(btnLeft)
        stackViewBtnArrow.addArrangedSubview(btnRight)
        self.view.addSubview(btnJump)
        
        stackViewBtnArrow.translatesAutoresizingMaskIntoConstraints = false
        btnJump.translatesAutoresizingMaskIntoConstraints = false
        
        stackViewBtnArrow.heightAnchor.constraint(equalToConstant: 60).isActive = true
        stackViewBtnArrow.widthAnchor.constraint(equalToConstant: 150).isActive = true
        stackViewBtnArrow.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50).isActive = true
        stackViewBtnArrow.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        
        btnJump.heightAnchor.constraint(equalToConstant: 60).isActive = true
        btnJump.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btnJump.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50).isActive = true
        btnJump.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
    }
    
}

extension BasicConfiqStage {
    private func allMarioActions() {
        marioMoveAct
            .observe(on: MainScheduler.instance)
            .map({ [weak self] (moveType) -> (MoveType, (Double, Double, CGFloat, CGFloat)) in
                guard let superSelf = self else {
                    throw CustomError.UnknowError
                }
                
                let marioInfo = superSelf.marioChar
                
                return (moveType, (marioInfo.frame.origin.x, marioInfo.frame.origin.y, marioInfo.frame.height, marioInfo.frame.width))
            })
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .filter({ [weak self] (moveType, arg1) in
                
                let (xMario, yMario, heightMario, widthMario) = arg1
                return self?.doMove(xMario: xMario, yMario: yMario, heightMario: heightMario, widthMario: widthMario, moveType: moveType) ?? false
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (moveType, arg1) in
                switch moveType {
                case .Left:
                    self?.doMoveLeft()
                case .Right:
                    self?.doMoveRight()
                case .Idle:
                    self?.doIdle()
                case .Jump:
                    self?.doJump()
                case .JumpMove(let dir):
                    self?.doJump()
                    switch dir {
                    case .Left:
                        self?.doMoveLeft()
                    case .Right:
                        self?.doMoveRight()
                    default:
                        break
                    }
                case .Fall:
                    self?.stillFall()
                case .FallMove(let dir):
                    self?.stillFall()
                    switch dir {
                    case .Left:
                        self?.doMoveLeft()
                    case .Right:
                        self?.doMoveRight()
                    default:
                        break
                    }
                }
                self?.curentMoveType = moveType
            })
            .disposed(by: bag)
        
        
        gravityAct = Observable<Int>
            .interval(.milliseconds(50), scheduler: MainScheduler.instance)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .filter({ [weak self] _ in
                
                guard let getStatus = self?.curentMoveType else {
                    return true
                }
                
                switch getStatus {
                case .Jump:
                    return false
                case .JumpMove(_):
                    return false
                default:
                    return true
                }
            })
            .observe(on: MainScheduler.instance)
            .map({ [weak self] (_) -> (Double, Double, CGFloat, CGFloat) in
                guard let superSelf = self else {
                    throw CustomError.UnknowError
                }
                
                let marioInfo = superSelf.marioChar
                
                return (marioInfo.frame.origin.x, marioInfo.frame.origin.y, marioInfo.frame.height, marioInfo.frame.width)
            })
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .filter({ [weak self] arg in
                print("do check gravity")
                let (xMario, yMario, heightMario, widthMario) = arg
                return self?.detectGravity(xMario: xMario, yMario: yMario, heightMario: heightMario, widthMario: widthMario) ?? false
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.marioChar.frame.origin.y += 1
                
            })
        gravityAct?.disposed(by: bag)
    }
    
    private func regisButtonAction() {
        let longPressLeftGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdMoveLeft))
        longPressLeftGestureRecognizer.minimumPressDuration = 0.01
        btnLeft.addGestureRecognizer(longPressLeftGestureRecognizer)
        btnLeft.addTarget(self, action: #selector(moveLeft), for: .touchDown)
        
        let longPressRightGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdMoveRight))
        longPressRightGestureRecognizer.minimumPressDuration = 0.01
        btnRight.addGestureRecognizer(longPressRightGestureRecognizer)
        btnRight.addTarget(self, action: #selector(moveRight), for: .touchDown)
        
        btnJump.addTarget(self, action: #selector(doJumping), for: .touchDown)
    }
    
}

extension BasicConfiqStage {
    func initColition(listRect: [RectInfo]) {
        viewLimit = listRect
    }
    
    func doIdle() {
        marioChar.resetPosition()
    }
}

extension BasicConfiqStage: MarioMovingRule {
    func doMoveLeft() {
        marioChar.frame.origin.x -= 1
        
        if !marioChar.isLeftStatus() {
            marioChar.togglePosition()
            marioChar.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        marioChar.doWalking()
    }
    
    func doMoveRight() {
        marioChar.frame.origin.x += 1
        
        if marioChar.isLeftStatus() {
            marioChar.togglePosition()
            marioChar.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        marioChar.doWalking()
    }
    
    func doJump() {
        marioChar.frame.origin.y -= 1
        marioChar.doJumping()
    }
    
    func stillFall() {
        marioChar.doJumping()
    }
}

extension BasicConfiqStage {
    @objc private func moveLeft() {
        
        switch curentMoveType {
        case .Left:
            marioMoveAct.onNext(.Left)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.marioMoveAct.onNext(.Idle)
            })
        case .Jump:
            marioMoveAct.onNext(.JumpMove(dir: .Left))
        case .JumpMove(dir: _):
            marioMoveAct.onNext(.JumpMove(dir: .Left))
        case .Fall:
            marioMoveAct.onNext(.FallMove(dir: .Left))
        case .FallMove(dir: _):
            marioMoveAct.onNext(.FallMove(dir: .Left))
        case .Idle:
            marioMoveAct.onNext(.Left)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.marioMoveAct.onNext(.Idle)
            })
        default:
            break
        }
    }
    
    @objc private func holdMoveLeft(gesture: UILongPressGestureRecognizer) {
        
        print("holdMoveLeft \(gesture.state)")
        
        if gesture.state == .began {
            timerLongPressButton?.invalidate()
            timerLongPressButton = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                switch self.curentMoveType {
                case .Left:
                    self.marioMoveAct.onNext(.Left)
                case .Jump:
                    self.marioMoveAct.onNext(.JumpMove(dir: .Left))
                case .JumpMove(dir: _):
                    self.marioMoveAct.onNext(.JumpMove(dir: .Left))
                case .Fall:
                    self.marioMoveAct.onNext(.FallMove(dir: .Left))
                case .FallMove(dir: _):
                    self.marioMoveAct.onNext(.FallMove(dir: .Left))
                case .Idle:
                    self.marioMoveAct.onNext(.Left)
                default:
                    break
                }
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timerLongPressButton?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard let self = self else {
                    return
                }
                
                switch self.curentMoveType {
                case .Fall:
                    break
                case .FallMove(_):
                    break
                case .Jump:
                    break
                case .JumpMove(_):
                    break
                default:
                    self.marioMoveAct.onNext(.Idle)
                }
            })
        }
    }
    
    @objc private func moveRight() {
        
        switch curentMoveType {
        case .Right:
            marioMoveAct.onNext(.Right)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.marioMoveAct.onNext(.Idle)
            })
        case .Jump:
            marioMoveAct.onNext(.JumpMove(dir: .Right))
        case .JumpMove(dir: _):
            marioMoveAct.onNext(.JumpMove(dir: .Right))
        case .Fall:
            marioMoveAct.onNext(.FallMove(dir: .Right))
        case .FallMove(dir: _):
            marioMoveAct.onNext(.FallMove(dir: .Right))
        case .Idle:
            marioMoveAct.onNext(.Right)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.marioMoveAct.onNext(.Idle)
            })
        default:
            break
        }
    }
    
    @objc private func holdMoveRight(gesture: UILongPressGestureRecognizer) {
        
        print("holdMoveRight \(gesture.state)")
        
        if gesture.state == .began {
            timerLongPressButton?.invalidate()
            timerLongPressButton = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                switch self.curentMoveType {
                case .Right:
                    self.marioMoveAct.onNext(.Right)
                case .Jump:
                    self.marioMoveAct.onNext(.JumpMove(dir: .Right))
                case .JumpMove(dir: _):
                    self.marioMoveAct.onNext(.JumpMove(dir: .Right))
                case .Fall:
                    self.marioMoveAct.onNext(.FallMove(dir: .Right))
                case .FallMove(dir: _):
                    self.marioMoveAct.onNext(.FallMove(dir: .Right))
                case .Idle:
                    self.marioMoveAct.onNext(.Right)
                default:
                    break
                }
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timerLongPressButton?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard let self = self else {
                    return
                }
                
                switch self.curentMoveType {
                case .Fall:
                    break
                case .FallMove(_):
                    break
                case .Jump:
                    break
                case .JumpMove(_):
                    break
                default:
                    self.marioMoveAct.onNext(.Idle)
                }
            })
        }
        
    }
    
    @objc private func doJumping() {
        
        if doJumpAction != nil {
            return
        }
        var countHeight: Int = 0
        doJumpAction = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            countHeight += 1
            
            switch self.curentMoveType {
            case .JumpMove(let dir):
                self.marioMoveAct.onNext(.JumpMove(dir: dir))
            default:
                self.marioMoveAct.onNext(.Jump)
            }
            
            if countHeight == 25 {
                doJumpAction?.invalidate()
                doJumpAction = nil
                self.marioMoveAct.onNext(.Fall)
            }
            
        }
    }
}

extension BasicConfiqStage {
    
    private func doMove(xMario: Double,
                        yMario: Double,
                        heightMario: CGFloat,
                        widthMario: CGFloat,
                        moveType: MoveType) -> Bool {
        var status: Bool = false
        switch moveType {
        case .Left:
            for item in self.viewLimit {
                if item.type == .Background {
                    if (xMario - 1) < item.rect.origin.x {
                        return false
                    } else {
                        status = true
                    }
                } else {
                    if item.type == .HardItem {
                        
                        if Int(xMario - 1) == Int(item.rect.origin.x + item.rect.width) {
                            let isTouch = CGRectIntersectsRect(CGRect(x: xMario, y: yMario, width: widthMario, height: heightMario), item.rect)
                            if  isTouch {
                                return false
                            }
                            status = true
                        } else {
                            status = true
                        }
                    }
                }
            }
        case .Right:
            for item in self.viewLimit {
                if item.type == .Background {
                    if ((xMario + widthMario) + 1) > item.rect.width {
                        return false
                    } else {
                        status = true
                    }
                } else {
                    if item.type == .HardItem {
                        print("move right (xMario + widthMario) + 1): \((xMario + widthMario) + 1) item.rect.origin.x: \(item.rect.origin.x)")
                        if ((xMario + widthMario) + 1) == item.rect.origin.x {
                            let isTouch = CGRectIntersectsRect(CGRect(x: xMario, y: yMario, width: widthMario, height: heightMario), item.rect)
                            if  isTouch {
                                return false
                            }
                            return false
                        } else {
                            status = true
                        }
                    }
//                    status = true
                }
            }
        case .Jump:
            for item in self.viewLimit {
                if item.type == .Background {
                    if Int(yMario - 1) < Int(item.rect.origin.y) {
                        return false
                    } else {
                        status = true
                    }
                } else {
                    status = true
                }
            }
        case .JumpMove(let direction):
            
            for item in self.viewLimit {
                if item.type == .Background {
                    if Int(yMario - 1) < Int(item.rect.origin.y) {
                        return false
                    } else {
                        status = true
                    }
                } else {
                    status = true
                }
            }
            
            switch direction {
            case .Left:
                for item in self.viewLimit {
                    if item.type == .Background {
                        if (xMario - 1) < item.rect.origin.x {
                            return false
                        } else {
                            status = true
                        }
                    } else {
                        if item.type == .HardItem {
                            
                            if Int(xMario - 1) == Int(item.rect.origin.x + item.rect.width) {
                                let isTouch = CGRectIntersectsRect(CGRect(x: xMario, y: yMario, width: widthMario, height: heightMario), item.rect)
                                if  isTouch {
                                    return false
                                }
                                status = true
                            } else {
                                status = true
                            }
                        }
                    }
                }
            case .Right:
                for item in self.viewLimit {
                    if item.type == .Background {
                        if ((xMario + widthMario) + 1) > item.rect.width {
                            return false
                        } else {
                            status = true
                        }
                    } else {
                        
                        if item.type == .HardItem {
                            
                            if ((xMario + widthMario) + 1) > item.rect.origin.x {
                                let isTouch = CGRectIntersectsRect(CGRect(x: xMario, y: yMario, width: widthMario, height: heightMario), item.rect)
                                if  isTouch {
                                    return false
                                }
                                status = true
                            } else {
                                status = true
                            }
                        }
                    }
                }
            default:
                break
            }
        case .Idle:
            status = true
        case .Fall:
            status = true
        case .FallMove(_):
            status = true
        }
        
        return status
    }
    
    private func detectGravity(xMario: Double,
                               yMario: Double,
                               heightMario: CGFloat,
                               widthMario: CGFloat) -> Bool {
        for item in self.viewLimit {
            if item.type == .Background {
                if Int((yMario + 65) + 1) >= Int(item.rect.height) {
                    
                    
                    switch curentMoveType {
                    case .Fall:
                        DispatchQueue.main.async { [weak self] in
                            self?.marioChar.endJump()
                        }
                        self.marioMoveAct.onNext(.Idle)
                    case .FallMove(_):
                        DispatchQueue.main.async { [weak self] in
                            self?.marioChar.endJump()
                        }
                        self.marioMoveAct.onNext(.Idle)
                    default:
                        break
                    }
                    
                    return false
                } else {
                }
            } else {
                if item.type == .HardItem {
                    let isTouch = CGRectIntersectsRect(CGRect(x: xMario, y: yMario, width: widthMario, height: heightMario), item.rect)
                    
                    if isTouch {
                        switch curentMoveType {
                        case .Fall:
                            DispatchQueue.main.async { [weak self] in
                                self?.marioChar.endJump()
                            }
                            self.marioMoveAct.onNext(.Idle)
                        case .FallMove(_):
                            DispatchQueue.main.async { [weak self] in
                                self?.marioChar.endJump()
                            }
                            self.marioMoveAct.onNext(.Idle)
                        default:
                            print("fall status: \(curentMoveType)")
                            break
                        }
                        
                        return false
                    } else {
                    }
                }
            }
        }
        
        switch curentMoveType {
        case .FallMove(let dir):
            self.marioMoveAct.onNext(.FallMove(dir: dir))
        default:
            self.marioMoveAct.onNext(.Fall)
        }
        
        return true
    }
}
