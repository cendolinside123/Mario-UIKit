//
//  Mario.swift
//  Mario
//
//  Created by Jan Sebastian on 03/06/24.
//

import Foundation
import UIKit


class Mario: UIView {
    
    private let hitBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.001)
        return view
    }()
    
    private let imgChar: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 1, alpha: 0.001)
        imageView.image = UIImage(named: "MarioIdle")
        return imageView
    }()
    
    private var countingStep: Int = 0
    private var isJump: Bool = false
    private var isLeft: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        self.backgroundColor = UIColor(white: 1, alpha: 0.001)
        self.addSubview(hitBoxView)
        hitBoxView.addSubview(imgChar)
    }
    
    private func setupConstraints() {
        let views: [String: Any] = ["hitBoxView": hitBoxView,
                                          "imgChar": imgChar]
        var constraints: [NSLayoutConstraint] = []
        
        hitBoxView.translatesAutoresizingMaskIntoConstraints = false
        let h_hitBoxView = "H:|-0-[hitBoxView]-0-|"
        let v_hitBoxView = "V:|-0-[hitBoxView]-0-|"
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_hitBoxView, options: .alignAllTop, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: v_hitBoxView, options: .alignAllLeading, metrics: nil, views: views)
        
        imgChar.translatesAutoresizingMaskIntoConstraints = false
        let h_imgChar = "H:|-0-[imgChar]-0-|"
        let v_imgChar = "V:|-0-[imgChar]-0-|"
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_imgChar, options: .alignAllTop, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: v_imgChar, options: .alignAllLeading, metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

extension Mario {
    
    func getImgCahr() -> UIImageView {
        return imgChar
    }
    
    func resetPosition() {
        countingStep = 0
        imgChar.image = UIImage(named: "MarioIdle")
    }
    
    func doWalking() {
        
        if isJump {
            imgChar.image = UIImage(named: "MarioRun3")
            return
        }
        
//        if countingStep % 9 == 0 {
//            imgChar.image = UIImage(named: "MarioRun1")
//        } else if countingStep % 9 == 5 {
//            imgChar.image = UIImage(named: "MarioRun2")
//        } else if countingStep % 9 == 8 {
//            imgChar.image = UIImage(named: "MarioRun3")
//        } else {
//            imgChar.image = UIImage(named: "MarioIdle")
//        }
        
        if countingStep % 3 == 0 {
            imgChar.image = UIImage(named: "MarioRun1")
        } else if countingStep % 3 == 1 {
            imgChar.image = UIImage(named: "MarioRun2")
        } else if countingStep % 3 == 2 {
            imgChar.image = UIImage(named: "MarioRun3")
        } else {
            imgChar.image = UIImage(named: "MarioIdle")
        }
        
        countingStep += 1
    }
    
    func togglePosition() {
        isLeft.toggle()
    }
    
    func isLeftStatus() -> Bool {
        return isLeft
    }
    
    func doJumping() {
        isJump = true
        imgChar.image = UIImage(named: "MarioRun3")
    }
    
    func endJump() {
        isJump = false
        imgChar.image = UIImage(named: "MarioIdle")
    }
}
