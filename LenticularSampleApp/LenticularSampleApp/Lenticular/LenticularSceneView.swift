//
//  LenticularSceneView.swift
//  LenticularSampleApp
//
//  Created by 길지훈 on 2026-03-23.
//

import SpriteKit
import SwiftUI

/// SpriteView 래퍼
struct LenticularSceneView: View {

    let scene: LenticularScene

    var body: some View {
        SpriteView(scene: scene, preferredFramesPerSecond: 60)
            .ignoresSafeArea()
    }
}
