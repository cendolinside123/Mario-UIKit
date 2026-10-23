//
//  MouthPipe.swift
//  Mario
//
//  Created by Jan Sebastian on 13/06/24.
//

import UIKit

class MouthPipe: UIView {
    
    static let height: Int = 15
    
    private let viewBody: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.0, green: 0.55, blue: 0.15, alpha: 1.0)
        view.layer.borderColor = UIColor(red: 0.0, green: 0.25, blue: 0.08, alpha: 1.0).cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 2
        return view
    }()
    
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
        self.addSubview(viewBody)
    }
    
    private func setupConstraints() {
        viewBody.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewBody.topAnchor.constraint(equalTo: self.topAnchor),
            viewBody.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            viewBody.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            viewBody.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
