//
//  Pipe.swift
//  Mario
//
//  Created by Jan Sebastian on 13/06/24.
//

import UIKit

class Pipe: UIView {
    
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
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private let mouthPipe = MouthPipe()
    private var listBodyPipe: [BodyPipe] = []
    
    @available(*, deprecated, renamed: "listBodyPipe")
    var listBoyPipe: [BodyPipe] {
        return listBodyPipe
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 50, height: CGFloat(getTotalHeight()))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(countTotal: Int) {
        super.init(frame: .zero)
        self.countTotal = max(0, countTotal)
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(stackViewBody)
        stackViewBody.addArrangedSubview(mouthPipe)
        
        if countTotal > 0 {
            for _ in 0..<countTotal {
                let viewBody = BodyPipe()
                stackViewBody.addArrangedSubview(viewBody)
                listBodyPipe.append(viewBody)
            }
        }
    }
    
    private func setupConstraints() {
        stackViewBody.translatesAutoresizingMaskIntoConstraints = false
        mouthPipe.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = [
            stackViewBody.topAnchor.constraint(equalTo: self.topAnchor),
            stackViewBody.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackViewBody.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackViewBody.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            mouthPipe.heightAnchor.constraint(equalToConstant: CGFloat(MouthPipe.height))
        ]
        
        for item in listBodyPipe {
            item.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(item.heightAnchor.constraint(equalToConstant: CGFloat(BodyPipe.height)))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func getTotalHeight() -> Int {
        return totalHeight
    }
}
