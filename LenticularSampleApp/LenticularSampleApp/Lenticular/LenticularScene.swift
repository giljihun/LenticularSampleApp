//
//  LenticularScene.swift
//  LenticularSampleApp
//
//  Created by 길지훈 on 2026-03-23.
//

import SpriteKit
import UIKit

/// 렌티큘러 셰이더를 적용하는 SpriteKit 씬
final class LenticularScene: SKScene {

    var tilt: CGFloat = 0.0
    var direction: Float = 0.0

    private var spriteNode: SKSpriteNode?
    private var lenticularShader: SKShader?
    private var uniformTilt: SKUniform?
    private var uniformDirection: SKUniform?

    override func didMove(to view: SKView) {
        backgroundColor = .black
        scaleMode = .resizeFill
        setupShader()
        setupSprite()
    }

    func updateTexture(_ texture: SKTexture) {
        spriteNode?.texture = texture
        resizeSprite()
    }

    override func update(_ currentTime: TimeInterval) {
        uniformTilt?.floatValue = Float(tilt)
        uniformDirection?.floatValue = direction
    }

    override func didChangeSize(_ oldSize: CGSize) {
        resizeSprite()
    }

    // MARK: - Setup

    private func setupShader() {
        guard let path = Bundle.main.path(forResource: "LenticularShader", ofType: "fsh"),
              let source = try? String(contentsOfFile: path, encoding: .utf8) else { return }

        let uTilt = SKUniform(name: "u_tilt", float: 0.0)
        let uDirection = SKUniform(name: "u_direction", float: 0.0)
        self.uniformTilt = uTilt
        self.uniformDirection = uDirection

        lenticularShader = SKShader(source: source, uniforms: [uTilt, uDirection])
    }

    private func setupSprite() {
        let node = SKSpriteNode(color: .darkGray, size: self.size)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        node.shader = lenticularShader
        addChild(node)
        spriteNode = node
    }

    private func resizeSprite() {
        guard let spriteNode else { return }
        spriteNode.size = self.size
        spriteNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
