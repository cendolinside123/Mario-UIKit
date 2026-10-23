//
//  FirstStageViewController.swift
//  Mario
//
//  Created by Jan Sebastian on 13/06/24.
//

import UIKit

class FirstStageViewController: BasicConfiqStage {
    
    private let container: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupController()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.view.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}
