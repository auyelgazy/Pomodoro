//
//  ViewController.swift
//  Pomodoro
//
//  Created by Kuanysh al-Khattab Auyelgazy on 25.02.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController, CAAnimationDelegate {

    private var isWorkTime = true
    private var isStarted = false
    private var isAnimationStarted = false
    private var timer = Timer()
    private var time = 5

    private let foregroundProgressLayer = CAShapeLayer()
    private let backgroundProgressLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")

    // MARK: - Outlets

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:05"
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
        drawBackgroundLayer()
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

    /// Background circle progress bar
    private func drawBackgroundLayer() {
        backgroundProgressLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
            radius: 100,
            startAngle: -90.degreesToRadians,
            endAngle: 270.degreesToRadians,
            clockwise: true
        ).cgPath
        backgroundProgressLayer.strokeColor = UIColor.white.cgColor
        backgroundProgressLayer.fillColor = UIColor.clear.cgColor
        backgroundProgressLayer.lineWidth = 4
        view.layer.addSublayer(backgroundProgressLayer)
    }

    /// Foreground circle progress bar
    private func drawForegroundLayer() {
        foregroundProgressLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
            radius: 100,
            startAngle: -90.degreesToRadians,
            endAngle: 270.degreesToRadians,
            clockwise: true
        ).cgPath
        foregroundProgressLayer.strokeColor = UIColor.red.cgColor
        foregroundProgressLayer.fillColor = UIColor.clear.cgColor
        foregroundProgressLayer.lineWidth = 4
        view.layer.addSublayer(foregroundProgressLayer)
    }

    private func startResumeAnimation() {
        !isAnimationStarted ? startAnimation() : resumeAnimation()
    }

    private func startAnimation() {
        resetAnimation()
        foregroundProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = Double(time)
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        foregroundProgressLayer.add(animation, forKey: "strokeEnd")
        isAnimationStarted = true
    }

    private func resetAnimation() {
        foregroundProgressLayer.speed = 1.0
        foregroundProgressLayer.timeOffset = 0.0
        foregroundProgressLayer.beginTime = 0.0
        foregroundProgressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }

    private func pauseAnimation() {
        let pausedTime = foregroundProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foregroundProgressLayer.speed = 0.0
        foregroundProgressLayer.timeOffset = pausedTime
    }

    private func resumeAnimation() {
        let pausedTime = foregroundProgressLayer.timeOffset
        foregroundProgressLayer.speed = 1.0
        foregroundProgressLayer.timeOffset = 0.0
        foregroundProgressLayer.beginTime = 0.0
        let timeSincePaused = foregroundProgressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        foregroundProgressLayer.beginTime = timeSincePaused
    }

    private func stopAnimation() {
        foregroundProgressLayer.speed = 1.0
        foregroundProgressLayer.timeOffset = 0.0
        foregroundProgressLayer.beginTime = 0.0
        foregroundProgressLayer.strokeEnd = 0.0
        foregroundProgressLayer.removeAllAnimations()
        isAnimationStarted = false
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.time <= 1 {
                timer.invalidate()
                self.startPauseButton.setTitle("Start", for: .normal)
                self.stopAnimation()
                self.time = 5
                self.isStarted = false
                self.timerLabel.text = "00:05"
            } else {
                self.time -= 1
                self.timerLabel.text = self.formatTime()
            }
        }
    }

    private func formatTime() -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }

    @objc private func startPausePressed() {
        if !isStarted {
            drawForegroundLayer()
            startResumeAnimation()
            startTimer()
            startPauseButton.setTitle("Pause", for: .normal)
            isStarted = true
        } else {
            pauseAnimation()
            timer.invalidate()
            startPauseButton.setTitle("Start", for: .normal)
            isStarted = false
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
}

// MARK: - Extensions

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
}

extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 100
    }
}

