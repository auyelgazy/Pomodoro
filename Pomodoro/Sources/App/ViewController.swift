//
//  ViewController.swift
//  Pomodoro
//
//  Created by Kuanysh al-Khattab Auyelgazy on 25.02.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private var isWorkTime = true
    private var isStarted = false

    // MARK: - Outlets

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var startPauseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startPausePressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupHierarchy()
        setupLayout()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        view.addSubviews(startPauseButton)
    }

    private func setupLayout() {
        startPauseButton.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }

    // MARK: - Actions

    @objc private func startPausePressed() {
        print(!isStarted ? "started timer" : "paused timer")
        startPauseButton.setTitle("\(isStarted ? "Start" : "Pause")", for: .normal)
        isStarted = !isStarted
    }
    
}

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
}

