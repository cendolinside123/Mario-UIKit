//
//  BasicStageViewController.swift
//  Mario
//
//  Created by Jan Sebastian on 06/06/24.
//

import UIKit

class BasicStageViewController: BasicConfiqStage {
    
    // MARK: - Views
    private let stackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let groundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.80, green: 0.42, blue: 0.16, alpha: 1.0)
        return view
    }()
    
    private let grassView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.36, green: 0.72, blue: 0.18, alpha: 1.0)
        return view
    }()
    
    private let interactionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.36, green: 0.58, blue: 0.99, alpha: 1.0) // Classic Mario Sky Blue
        view.tag = 999
        view.clipsToBounds = true
        return view
    }()
    
    @available(*, deprecated, renamed: "interactionView")
    var interationView: UIView {
        return interactionView
    }
    
    private let pipeOne: Pipe = Pipe(countTotal: 2)
    private let pipeTwo: Pipe = Pipe(countTotal: 3)
    private let pipeThree: Pipe = Pipe(countTotal: 0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollisionBoundaries()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !marioChar.isDescendant(of: interactionView) {
            interactionView.layoutIfNeeded()
            updateCollisionBoundaries()
            self.configureMario(
                positionX: 30,
                positionY: Int(interactionView.bounds.height),
                container: interactionView
            )
        }
    }
    
    func updateCollisionBoundaries() {
        guard interactionView.bounds.width > 0 && interactionView.bounds.height > 0 else { return }
        initCollision(listRect: [
            RectInfo(rect: interactionView.bounds, type: .Background),
            RectInfo(rect: pipeOne.frame, type: .HardItem),
            RectInfo(rect: pipeTwo.frame, type: .HardItem),
            RectInfo(rect: pipeThree.frame, type: .HardItem)
        ])
    }
    
    // MARK: - UI & Constraints Setup
    private func setupView() {
        self.view.backgroundColor = .black
        self.view.addSubview(stackViewContainer)
        
        stackViewContainer.addArrangedSubview(interactionView)
        stackViewContainer.addArrangedSubview(grassView)
        stackViewContainer.addArrangedSubview(groundView)
        
        interactionView.addSubview(pipeOne)
        interactionView.addSubview(pipeTwo)
        interactionView.addSubview(pipeThree)
    }
    
    func setupConstraints() {
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        grassView.translatesAutoresizingMaskIntoConstraints = false
        groundView.translatesAutoresizingMaskIntoConstraints = false
        pipeOne.translatesAutoresizingMaskIntoConstraints = false
        pipeTwo.translatesAutoresizingMaskIntoConstraints = false
        pipeThree.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Full screen container
            stackViewContainer.topAnchor.constraint(equalTo: self.view.topAnchor),
            stackViewContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            stackViewContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stackViewContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            // Grass separator bar
            grassView.heightAnchor.constraint(equalToConstant: 10),
            
            // Ground layer height
            groundView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1.0 / 3.8),
            
            // Pipe One (height 55)
            pipeOne.leadingAnchor.constraint(equalTo: interactionView.leadingAnchor, constant: 100),
            pipeOne.bottomAnchor.constraint(equalTo: interactionView.bottomAnchor),
            pipeOne.widthAnchor.constraint(equalToConstant: 50),
            pipeOne.heightAnchor.constraint(equalToConstant: CGFloat(pipeOne.getTotalHeight())),
            
            // Pipe Two (height 75)
            pipeTwo.leadingAnchor.constraint(equalTo: pipeOne.trailingAnchor, constant: 28),
            pipeTwo.bottomAnchor.constraint(equalTo: interactionView.bottomAnchor),
            pipeTwo.widthAnchor.constraint(equalToConstant: 50),
            pipeTwo.heightAnchor.constraint(equalToConstant: CGFloat(pipeTwo.getTotalHeight())),
            
            // Pipe Three (height 15)
            pipeThree.leadingAnchor.constraint(equalTo: pipeTwo.trailingAnchor, constant: 75),
            pipeThree.bottomAnchor.constraint(equalTo: interactionView.bottomAnchor),
            pipeThree.widthAnchor.constraint(equalToConstant: 50),
            pipeThree.heightAnchor.constraint(equalToConstant: CGFloat(pipeThree.getTotalHeight()))
        ])
    }
    
    @available(*, deprecated, renamed: "setupConstraints")
    func setupCoinstraints() {
        setupConstraints()
    }
}
