//
//  FPSCounter.swift
//  LenticularSampleApp
//
//  Created by 길지훈 on 2026-03-23.
//

import QuartzCore
import UIKit

/// CADisplayLink 기반 FPS 측정기
@Observable
final class FPSCounter {

    private(set) var fps: Int = 0

    private var displayLink: CADisplayLink?
    private var frameCount: Int = 0
    private var lastTimestamp: CFTimeInterval = 0

    func start() {
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        self.displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        frameCount += 1

        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        let elapsed = link.timestamp - lastTimestamp
        if elapsed >= 1.0 {
            fps = Int(Double(frameCount) / elapsed)
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
