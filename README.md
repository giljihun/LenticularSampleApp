# LenticularSampleApp

<img src="https://github.com/user-attachments/assets/068bb280-32f1-4d3d-a9b5-60b99c2420ff" width=300>


실물 렌티큘러 카드의 효과 샘플앱.
자이로센서 기반으로 폰을 기울이면 두 이미지가 자연스럽게 전환되며, 3D 틸트 · 고스팅 · 쉬머 효과를 포함합니다.

## 기술 스택

- **SpriteKit + GLSL Fragment Shader** — GPU 기반 실시간 렌티큘러 블렌딩
- **CMMotionManager** — 자이로센서 기울기 → 셰이더 uniform 전달
- **SwiftUI** — UI 구성 및 SpriteView 래퍼

## 구조

```
App/           — 앱 진입점, 메인 화면
Lenticular/    — 셰이더(.fsh), SKScene, 텍스처 합성
Utility/       — 자이로 래퍼, 햅틱, FPS 카운터
```

## 요구 사항

- iOS 26+
- 실기기 필수 (자이로센서 사용)
