//
//  ContentView.swift
//  LenticularSampleApp
//
//  Created by 길지훈 on 2026-03-23.
//

// ┌──────────────────────────────────────┐
// │          조정 가능한 값들             │
// ├──────────────────────────────────────┤
// │ cardWidthRatio   : 화면 대비 카드 너비 (0.82)
// │ cardAspectRatio  : 카드 세로/가로 비율 (7:5)
// │ cardCornerRadius : 카드 모서리 둥글기 (30)
// │ maxRotationDeg   : 3D 틸트 최대 각도 (12°)
// └──────────────────────────────────────┘

import Combine
import PhotosUI
import SpriteKit
import SwiftUI
import UIKit

struct ContentView: View {

    // MARK: - 조정 가능한 상수

    private let cardWidthRatio: CGFloat = 0.82
    private let cardAspectRatio: CGFloat = 7.0 / 5.0
    private let cardCornerRadius: CGFloat = 30
    private let maxRotationDeg: Double = 12

    // MARK: - State

    @State private var motionManager = MotionManager()
    @State private var hapticManager = HapticManager()
    @State private var fpsCounter = FPSCounter()

    @State private var scene: LenticularScene = {
        let s = LenticularScene(size: CGSize(width: 400, height: 400))
        s.scaleMode = .resizeFill
        return s
    }()

    @State private var pickerItemA: PhotosPickerItem?
    @State private var pickerItemB: PhotosPickerItem?
    @State private var imageA: UIImage?
    @State private var imageB: UIImage?
    @State private var lastComposedA: UIImage?
    @State private var lastComposedB: UIImage?

    @State private var direction: MotionManager.Direction = .leftRight

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width * cardWidthRatio
            let cardHeight = cardWidth * cardAspectRatio

            VStack(spacing: 20) {
                lenticularCard
                    .frame(width: cardWidth, height: cardHeight)
                    .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
                    .padding(.top, 20)

                ScrollView {
                    controlPanel.padding()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            motionManager.start()
            fpsCounter.start()
            hapticManager.prepare()
        }
        .onDisappear {
            motionManager.stop()
            fpsCounter.stop()
        }
        .onReceive(
            Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
        ) { _ in
            updateScene()
        }
        .onChange(of: pickerItemA) {
            Task { imageA = await loadImage(from: pickerItemA) }
        }
        .onChange(of: pickerItemB) {
            Task { imageB = await loadImage(from: pickerItemB) }
        }
        .onChange(of: direction) {
            motionManager.direction = direction
            motionManager.recalibrate()
        }
    }
}

// MARK: - 카드 뷰

extension ContentView {

    private var lenticularCard: some View {
        ZStack {
            Color.black

            if imageA != nil && imageB != nil {
                LenticularSceneView(scene: scene)
            } else {
                placeholderView
            }

            debugOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: rotationAxis,
            perspective: 0.6
        )
        .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.8), value: motionManager.signedTilt)
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("이미지 2장을 선택하세요")
                .foregroundStyle(.secondary)
        }
    }

    private var rotationAngle: Double {
        Double(motionManager.signedTilt) * maxRotationDeg
    }

    private var rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch direction {
        case .leftRight: (x: 0, y: 1, z: 0)
        case .upDown:    (x: 1, y: 0, z: 0)
        }
    }
}

// MARK: - 컨트롤 패널

extension ContentView {

    private var controlPanel: some View {
        VStack(spacing: 16) {
            imagePickerSection

            Divider()

            Picker("방향", selection: $direction) {
                ForEach(MotionManager.Direction.allCases) { dir in
                    Text(dir.rawValue).tag(dir)
                }
            }
            .pickerStyle(.segmented)

            Divider()

            Button("기울기 재설정 (캘리브레이션)") {
                motionManager.recalibrate()
            }
            .buttonStyle(.bordered)
        }
    }

    private var imagePickerSection: some View {
        HStack(spacing: 16) {
            imagePickerButton(label: "이미지 A", image: imageA, selection: $pickerItemA)
            imagePickerButton(label: "이미지 B", image: imageB, selection: $pickerItemB)
        }
    }

    private func imagePickerButton(
        label: String,
        image: UIImage?,
        selection: Binding<PhotosPickerItem?>
    ) -> some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            PhotosPicker(selection: selection, matching: .images) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                }
            }
        }
    }
}

// MARK: - 디버그 오버레이

extension ContentView {

    private var debugOverlay: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("FPS: \(fpsCounter.fps)")
            Text(String(format: "Tilt: %.3f", motionManager.tilt))
            Text(String(format: "Pitch: %.3f", motionManager.rawPitch))
            Text(String(format: "Roll: %.3f", motionManager.rawRoll))
            Text("Direction: \(direction.rawValue)")
        }
        .font(.caption.monospaced())
        .foregroundStyle(.green)
        .padding(8)
        .background(.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
    }
}

// MARK: - Logic

extension ContentView {

    private func updateScene() {
        scene.tilt = motionManager.tilt
        scene.direction = direction == .leftRight ? 0.0 : 1.0
        hapticManager.checkEdge(tilt: motionManager.tilt)
        composeTextureIfNeeded()
    }

    private func composeTextureIfNeeded() {
        guard let a = imageA, let b = imageB else { return }
        if a === lastComposedA && b === lastComposedB { return }

        let composed = TextureComposer.compose(imageA: a, imageB: b)
        scene.updateTexture(SKTexture(image: composed))
        lastComposedA = a
        lastComposedB = b
    }

    private func loadImage(from item: PhotosPickerItem?) async -> UIImage? {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }
        return UIImage(data: data)
    }
}
