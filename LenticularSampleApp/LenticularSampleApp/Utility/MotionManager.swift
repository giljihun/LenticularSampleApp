//
//  MotionManager.swift
//  LenticularSampleApp
//
//  Created by 길지훈 on 2026-03-23.
//

// ┌──────────────────────────────────────────┐
// │           조정 가능한 값들                │
// ├──────────────────────────────────────────┤
// │ range          : 전환 범위 라디안 (0.87≈50°)│
// │ updateInterval : 센서 갱신 주기 (1/60초)  │
// └──────────────────────────────────────────┘

import CoreMotion
import Foundation

/// 자이로센서에서 기울기를 읽어 정규화하는 래퍼
@Observable
final class MotionManager {

    /// 렌티큘러 전환용 (0.0~1.0, 부호 없음)
    private(set) var tilt: CGFloat = 0.0

    /// 3D 회전용 (-1.0~+1.0, 부호 유지)
    private(set) var signedTilt: CGFloat = 0.0

    /// 디버그 표시용 원본 값
    private(set) var rawPitch: Double = 0.0
    private(set) var rawRoll: Double = 0.0

    enum Direction: String, CaseIterable, Identifiable {
        case leftRight = "좌우"
        case upDown = "상하"
        var id: String { rawValue }
    }

    var direction: Direction = .leftRight

    // MARK: - Private

    private let manager = CMMotionManager()
    private var calibrationPitch: Double = 0.0
    private var calibrationRoll: Double = 0.0

    /// 0~range 라디안을 0~1로 매핑. 약 50도
    private let range: Double = 0.87
    private let updateInterval: TimeInterval = 1.0 / 60.0
    private var isRunning = false

    // MARK: - Lifecycle

    func start() {
        guard !isRunning, manager.isDeviceMotionAvailable else { return }
        isRunning = true
        manager.deviceMotionUpdateInterval = updateInterval

        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let pitch = motion.attitude.pitch
            let roll = motion.attitude.roll
            self.rawPitch = pitch
            self.rawRoll = roll

            if self.calibrationPitch == 0.0 && self.calibrationRoll == 0.0 {
                self.calibrationPitch = pitch
                self.calibrationRoll = roll
            }

            let value: Double = switch self.direction {
            case .leftRight: roll - self.calibrationRoll
            case .upDown:    pitch - self.calibrationPitch
            }

            let normalized = value / self.range
            self.tilt = CGFloat(min(abs(normalized), 1.0))
            self.signedTilt = CGFloat(max(min(normalized, 1.0), -1.0))
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        isRunning = false
    }

    func recalibrate() {
        calibrationPitch = rawPitch
        calibrationRoll = rawRoll
    }
}
