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
        view.backgroundColor = .clear
        return view
    }()
    
    private let softHitBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let brickImg: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Brick")
        imageView.layer.magnificationFilter = .nearest
        imageView.layer.minificationFilter = .nearest
        return imageView
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 32, height: 32)
    }
    
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
    
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(hitBoxView)
        self.addSubview(softHitBoxView)
        self.addSubview(brickImg)
    }
    
    private func setupConstraints() {
        hitBoxView.translatesAutoresizingMaskIntoConstraints = false
        softHitBoxView.translatesAutoresizingMaskIntoConstraints = false
        brickImg.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hitBoxView.topAnchor.constraint(equalTo: self.topAnchor),
            hitBoxView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hitBoxView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            softHitBoxView.topAnchor.constraint(equalTo: hitBoxView.bottomAnchor),
            softHitBoxView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            softHitBoxView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            softHitBoxView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            brickImg.topAnchor.constraint(equalTo: self.topAnchor),
            brickImg.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            brickImg.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            brickImg.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
