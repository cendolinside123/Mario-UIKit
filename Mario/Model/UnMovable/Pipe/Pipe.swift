//
//  Pipe.swift
//  Mario
//
//  Created by Jan Sebastian on 13/06/24.
//

import UIKit

class Pipe: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var countTotal: Int = 0
    
    private lazy var totalHeight: Int = {
        let bodyTotal = countTotal * BodyPipe.height
        return MouthPipe.height + bodyTotal
    }()
    
    private let stackViewBody: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.backgroundColor = UIColor(white: 1, alpha: 0.001)
        
        return stackView
    }()
    
    private let mouthPipe = MouthPipe()
    private var listBoyPipe: [BodyPipe] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(countTotal: Int) {
        super.init(frame: .zero)
        self.countTotal = countTotal
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor(white: 1, alpha: 0.001)
        self.addSubview(stackViewBody)
        stackViewBody.addArrangedSubview(mouthPipe)
        
        for _ in 0...countTotal {
            let viewBody = BodyPipe()
            stackViewBody.addArrangedSubview(viewBody)
            listBoyPipe.append(viewBody)
        }
    }
    
    private func setupConstraints() {
        let views: [String: Any] = ["stackViewBody": stackViewBody]
        
        var constraints: [NSLayoutConstraint] = []
        
        stackViewBody.translatesAutoresizingMaskIntoConstraints = false
        let v_stackViewBody = "V:|-0-[stackViewBody]-0-|"
        let h_stackViewBody = "H:|-0-[stackViewBody]-0-|"
        constraints += NSLayoutConstraint.constraints(withVisualFormat: v_stackViewBody, options: .alignAllLeading, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_stackViewBody, options: .alignAllLeading, metrics: nil, views: views)
        
        mouthPipe.translatesAutoresizingMaskIntoConstraints = false
        constraints += [NSLayoutConstraint(item: mouthPipe, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(MouthPipe.height))]
        
        for item in listBoyPipe {
            item.translatesAutoresizingMaskIntoConstraints = false
            constraints += [NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(BodyPipe.height))]
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func getTotalHeight() -> Int {
        return totalHeight
    }
}
