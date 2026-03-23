//
//  HapticManager.swift
//  LenticularSampleApp
//
//  Created by 길지훈 on 2026-03-23.
//

// ┌──────────────────────────────────────────┐
// │           조정 가능한 값들                │
// ├──────────────────────────────────────────┤
// │ edgeLow  : 끝점 판정 하한 (0.01)         │
// │ edgeHigh : 끝점 판정 상한 (0.99)         │
// │ style    : 햅틱 강도 (.light)            │
// └──────────────────────────────────────────┘

import UIKit

/// tilt가 끝점(0.0 또는 1.0)에 도달했을 때 가벼운 햅틱 피드백을 제공
final class HapticManager {

    private var wasAtEdge = false
    private let generator = UIImpactFeedbackGenerator(style: .light)

    func checkEdge(tilt: CGFloat) {
        let isAtEdge = tilt <= 0.01 || tilt >= 0.99

        if isAtEdge && !wasAtEdge {
            generator.impactOccurred()
        }
        wasAtEdge = isAtEdge
    }

    func prepare() {
        generator.prepare()
    }
}
