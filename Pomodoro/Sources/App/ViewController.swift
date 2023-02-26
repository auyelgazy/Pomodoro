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
    private var timer = Timer()
    private var time = 1500

    // MARK: - Outlets

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "25:00"
        return label
    }()

    private lazy var startPauseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startPausePressed), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering

        return stackView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupStackView()
        setupHierarchy()
        setupLayout()
    }

    // MARK: - Setup

    private func setupStackView() {
        stackView.addArrangedSubview(timerLabel)
        stackView.addArrangedSubview(startPauseButton)
    }

    private func setupHierarchy() {
        view.addSubviews(stackView)
    }

    private func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }

    // MARK: - Actions

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.time -= 1
            self.timerLabel.text = self.formatTime()
        }
    }

    private func formatTime() -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String("\(minutes):\(seconds)")
    }

    @objc private func startPausePressed() {
        if !isStarted {
            startTimer()
            startPauseButton.setTitle("Pause", for: .normal)
            isStarted = true
        } else {
            timer.invalidate()
            startPauseButton.setTitle("Start", for: .normal)
            isStarted = false
        }
    }
    
}

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
}

