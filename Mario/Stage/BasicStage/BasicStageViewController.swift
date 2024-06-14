//
//  BasicStageViewController.swift
//  Mario
//
//  Created by Jan Sebastian on 06/06/24.
//

import UIKit

class BasicStageViewController: BasicConfiqStage {
    
    private let stackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor(white: 1, alpha: 0.001)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let groundView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }()
    
    private let grassView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    private let interationView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.56, green: 0.79, blue: 0.98, alpha: 1.00)
        view.tag = 999
        return view
    }()
    
    private let pipeOne: Pipe = {
        let pipeView = Pipe(countTotal: 2)
        return pipeView
    }()
    
    private let pipeTwo: Pipe = {
        let pipeView = Pipe(countTotal: 3)
        return pipeView
    }()
    
    private let pipeThree: Pipe = {
        let pipeView = Pipe(countTotal: 0)
        return pipeView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        setupCoinstraints()
        setupController()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !marioChar.isDescendant(of: interationView) {
            interationView.layoutIfNeeded()
            initColition(listRect: [
                RectInfo(rect: interationView.frame, type: .Background),
                RectInfo(rect: pipeOne.frame, type: .HardItem),
                RectInfo(rect: pipeTwo.frame, type: .HardItem),
                RectInfo(rect: pipeThree.frame, type: .HardItem)
            ])
            self.configureMario(positionX: Int(interationView.frame.origin.x), positionY: Int(interationView.bounds.height), container: interationView)
        } else {
            print("no need init mario")
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func setupView() {
        self.view.addSubview(stackViewContainer)
        stackViewContainer.addArrangedSubview(interationView)
        stackViewContainer.addArrangedSubview(grassView)
        stackViewContainer.addArrangedSubview(groundView)
        interationView.addSubview(pipeOne)
        interationView.addSubview(pipeTwo)
        interationView.addSubview(pipeThree)
        
    }
    
    private func setupCoinstraints() {
        let views: [String: Any] = ["stackViewContainer": stackViewContainer]
        var constraints: [NSLayoutConstraint] = []
        
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        let v_stackViewContainer = "V:|-0-[stackViewContainer]-0-|"
        let h_stackViewContainer = "H:|-0-[stackViewContainer]-0-|"
        constraints += NSLayoutConstraint.constraints(withVisualFormat: v_stackViewContainer, options: .alignAllLeading, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: h_stackViewContainer, options: .alignAllTop, metrics: nil, views: views)
        
        grassView.translatesAutoresizingMaskIntoConstraints = false
        constraints += [NSLayoutConstraint(item: grassView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 8)]
        
        groundView.translatesAutoresizingMaskIntoConstraints = false
        constraints += [NSLayoutConstraint(item: groundView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1/3.5, constant: 0)]
        
        pipeOne.translatesAutoresizingMaskIntoConstraints = false
        constraints += [NSLayoutConstraint(item: pipeOne, attribute: .leading, relatedBy: .equal, toItem: interationView, attribute: .leading, multiplier: 1, constant: 100)]
        constraints += [NSLayoutConstraint(item: pipeOne, attribute: .bottom, relatedBy: .equal, toItem: interationView, attribute: .bottom, multiplier: 1, constant: 0)]
        constraints += [NSLayoutConstraint(item: pipeOne, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)]
        
        pipeTwo.translatesAutoresizingMaskIntoConstraints = false
        constraints += [NSLayoutConstraint(item: pipeTwo, attribute: .leading, relatedBy: .equal, toItem: pipeOne, attribute: .trailing, multiplier: 1, constant: 20)]
        constraints += [NSLayoutConstraint(item: pipeTwo, attribute: .bottom, relatedBy: .equal, toItem: interationView, attribute: .bottom, multiplier: 1, constant: 0)]
        constraints += [NSLayoutConstraint(item: pipeTwo, attribute: .width, relatedBy: .equal, toItem: pipeOne, attribute: .width, multiplier: 1, constant: 0)]
        
        pipeThree.translatesAutoresizingMaskIntoConstraints = false
        constraints += [NSLayoutConstraint(item: pipeThree, attribute: .leading, relatedBy: .equal, toItem: pipeTwo, attribute: .trailing, multiplier: 1, constant: 80)]
        constraints += [NSLayoutConstraint(item: pipeThree, attribute: .bottom, relatedBy: .equal, toItem: interationView, attribute: .bottom, multiplier: 1, constant: 0)]
        constraints += [NSLayoutConstraint(item: pipeThree, attribute: .width, relatedBy: .equal, toItem: pipeOne, attribute: .width, multiplier: 1, constant: 0)]
        
        NSLayoutConstraint.activate(constraints)
    }

}
