//import SwiftUI
//import RealityKit
//
//struct RotationDragView: View {
//    @State private var myEntity: Entity?
//    @State private var isDragging = false
//    @State private var initialRotation: simd_quatf = .identity
//    @State private var previousTime: CFAbsoluteTime = 0
//    @State private var previousTotalX: Float = 0
//    @State private var angularVelocity: Float = 0
//    let sensitivity: Float = 0.1 // Adjust sensitivity as needed
//    let deceleration: Float = 0.5 // Adjust deceleration for inertia
//
//    var body: some View {
//        RealityView { content in
//            // Create or load the entity
//            let entity = ModelEntity(
//                mesh: .generateBox(size: 0.1),
//                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
//            )
//            // Ensure entity can receive gestures
//            entity.components.set(InputTargetComponent())
//            entity.components.set(CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])]))
//            content.add(entity)
//            self.myEntity = entity
//        }
//        .gesture(dragGesture)
//    }
//
//    var dragGesture: some Gesture {
//        DragGesture()
//            .targetedToEntity(myEntity!)
//            .onChanged { value in
//                let currentTime = CFAbsoluteTimeGetCurrent()
//                if !isDragging {
//                    isDragging = true
//                    initialRotation = myEntity!.transform.rotation
//                    previousTotalX = 0
//                    previousTime = currentTime
//                }
//                let worldTranslation = value.convert(value.gestureValue.translation3D, from: .local, to: .scene)
//                let totalTranslationX = worldTranslation.x
//                let rotationAngle = totalTranslationX * sensitivity
//                let newRotation = initialRotation * simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
//                myEntity!.transform.rotation = newRotation
//
//                // Calculate angular velocity for inertia
//                let deltaTotalX = totalTranslationX - previousTotalX
//                let deltaTime = currentTime - previousTime
//                if deltaTime > 0 {
//                    angularVelocity = (deltaTotalX / Float(deltaTime)) * sensitivity
//                }
//                previousTotalX = totalTranslationX
//                previousTime = currentTime
//            }
//            .onEnded { value in
//                isDragging = false
//                let currentRotation = myEntity!.transform.rotation
//                let t = abs(angularVelocity) / deceleration
//                let totalInertiaAngle = (angularVelocity * angularVelocity) / (2 * deceleration) * angularVelocity.signum()
//                let targetRotation = currentRotation * simd_quatf(angle: totalInertiaAngle, axis: [0, 1, 0])
//                let targetTransform = Transform(
//                    scale: myEntity!.transform.scale,
//                    rotation: targetRotation,
//                    translation: myEntity!.transform.translation
//                )
//                if t > 0 {
//                    myEntity!.move(
//                        to: targetTransform,
//                        relativeTo: myEntity!.parent,
//                        duration: Double(t),
//                        timingFunction: .easeOut
//                    )
//                }
//            }
//    }
//}
//
//#Preview {
//    RotationDragView()
//}
