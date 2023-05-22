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
    private let workTime = 25
    private let restTime = 5
    private var time = 25

    private let foregroundProgressLayer = CAShapeLayer()
    private let backgroundProgressLayer = CAShapeLayer()

    // MARK: - Outlets

    private lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.text = "Work"
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        return label
    }()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:25"
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    private lazy var startPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(startPausePressed), for: .touchUpInside)
        button.setImage(getImage("play"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        drawBackgroundLayer()
        setupStackView()
        setupHierarchy()
        setupLayout()
    }

    // MARK: - Setup

    private func setupStackView() {
        stackView.addArrangedSubview(modeLabel)
        stackView.addArrangedSubview(timerLabel)
        stackView.addArrangedSubview(startPauseButton)
    }

    private func setupHierarchy() {
        view.addSubviews(stackView)
    }

    private func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalToSuperview().offset(100)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - Actions

    /// Background circle progress bar
    private func drawBackgroundLayer() {
        backgroundProgressLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
            radius: 150,
            startAngle: -90.degreesToRadians,
            endAngle: 270.degreesToRadians,
            clockwise: true
        ).cgPath
        backgroundProgressLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundProgressLayer.fillColor = UIColor.clear.cgColor
        backgroundProgressLayer.lineWidth = 10
        view.layer.addSublayer(backgroundProgressLayer)
    }

    /// Foreground circle progress bar
    private func drawForegroundLayer() {
        let animationColor = isWorkTime ? UIColor.red : UIColor.green
        foregroundProgressLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
            radius: 150,
            startAngle: -90.degreesToRadians,
            endAngle: 270.degreesToRadians,
            clockwise: true
        ).cgPath
        foregroundProgressLayer.strokeColor = animationColor.cgColor
        foregroundProgressLayer.fillColor = UIColor.clear.cgColor
        foregroundProgressLayer.lineWidth = 8
        view.layer.addSublayer(foregroundProgressLayer)
    }

    private func startResumeAnimation() {
        !isAnimationStarted ? startAnimation() : resumeAnimation()
    }

    private func startAnimation() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        foregroundProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = Double(time)
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = .forwards
        foregroundProgressLayer.add(animation, forKey: "strokeEnd")
        isAnimationStarted = true
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
        foregroundProgressLayer.removeAnimation(forKey: "strokeEnd")
        isAnimationStarted = false
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }

    private func getImage(_ name: String) -> UIImage? {
        let image = UIImage(
            systemName: name,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large))?
            .withTintColor(.red, renderingMode: .alwaysOriginal)
        return image
    }

    @objc private func updateTimer() {
        if time <= 1 {
            modeLabel.text = isWorkTime ? "Rest" : "Work"
            timer.invalidate()
            startPauseButton.setImage(getImage("play"), for: .normal)
            stopAnimation()
            isWorkTime = !isWorkTime
            time = isWorkTime ? workTime : restTime
            isStarted = false
            timerLabel.text = formatTime()
        } else {
            time -= 1
            timerLabel.text = formatTime()
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
            startPauseButton.setImage(getImage("pause"), for: .normal)
            isStarted = true
        } else {
            pauseAnimation()
            timer.invalidate()
            startPauseButton.setImage(getImage("play"), for: .normal)
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
        return CGFloat(self) * .pi / 180
    }
}

