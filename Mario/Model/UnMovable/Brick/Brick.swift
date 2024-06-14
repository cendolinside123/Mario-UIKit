//
//  Brick.swift
//  Mario
//
//  Created by Jan Sebastian on 03/06/24.
//

import UIKit

class Brick: UIView {
    
    private let hitBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.001)
        return view
    }()
    
    private let softHitBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.001)
        return view
    }()
    
    private let brickImg: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 1, alpha: 0.001)
        imageView.image = UIImage(named: "Brick")
        return imageView
    }()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
        self.addSubview(softHitBoxView)
        self.addSubview(brickImg)
    }
    
    private func setupConstraints() {
        let views: [String: Any] = ["hitBoxView": hitBoxView,
                                          "brickImg": brickImg,
                                    "softHitBoxView": softHitBoxView]
        var constraints: [NSLayoutConstraint] = []
        
        hitBoxView.translatesAutoresizingMaskIntoConstraints = false
        softHitBoxView.translatesAutoresizingMaskIntoConstraints = false
        let h_hitBoxView = "H:|-0-[hitBoxView]-0-|"
        let h_softHitBoxView = "H:|-0-[softHitBoxView]-0-|"
        let v_hitBoxContent = "V:|-0-[hitBoxView]-0-[softHitBoxView]-0-|"
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_hitBoxView, options: .alignAllTop, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_softHitBoxView, options: .alignAllTop, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: v_hitBoxContent, options: .alignAllLeading, metrics: nil, views: views)
        
        brickImg.translatesAutoresizingMaskIntoConstraints = false
        let h_brickImg = "H:|-0-[brickImg]-0-|"
        let v_brickImg = "V:|-0-[brickImg]-0-|"
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_brickImg, options: .alignAllTop, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: v_brickImg, options: .alignAllLeading, metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
    }

}
