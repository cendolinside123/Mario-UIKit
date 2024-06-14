//
//  MouthPipe.swift
//  Mario
//
//  Created by Jan Sebastian on 13/06/24.
//

import UIKit

class MouthPipe: UIView {
    
    private let viewBody: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0.20, blue: 0.13, alpha: 1)
        return view
    }()
    
    static let height = 15

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
        self.addSubview(viewBody)
    }
    
    private func setupConstraints() {
        let views: [String: Any] = ["viewBody": viewBody]
        
        var constraints: [NSLayoutConstraint] = []
        
        viewBody.translatesAutoresizingMaskIntoConstraints = false
        let v_viewBody = "V:|-0-[viewBody]-0-|"
        let h_viewBody = "H:|-0-[viewBody]-0-|"
        constraints += NSLayoutConstraint.constraints(withVisualFormat: v_viewBody, options: .alignAllLeading, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_viewBody, options: .alignAllTop, metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
    }

}
