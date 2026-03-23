//
//  TextureComposer.swift
//  LenticularSampleApp
//
//  Created by 길지훈 on 2026-03-23.
//

// ┌──────────────────────────────────────────┐
// │           조정 가능한 값들                │
// ├──────────────────────────────────────────┤
// │ targetSize : 각 이미지 리사이즈 크기      │
// │              (512×512, 아틀라스는 1024×512)│
// └──────────────────────────────────────────┘

import UIKit

/// 두 이미지를 가로로 이어붙여 단일 텍스처 아틀라스를 생성
enum TextureComposer {

    static func compose(
        imageA: UIImage,
        imageB: UIImage,
        targetSize: CGSize = CGSize(width: 512, height: 512)
    ) -> UIImage {
        let atlasSize = CGSize(width: targetSize.width * 2, height: targetSize.height)
        let renderer = UIGraphicsImageRenderer(size: atlasSize)

        return renderer.image { _ in
            imageA.draw(in: CGRect(origin: .zero, size: targetSize))
            imageB.draw(in: CGRect(
                origin: CGPoint(x: targetSize.width, y: 0),
                size: targetSize
            ))
        }
    }
}
