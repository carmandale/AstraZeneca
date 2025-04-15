//import SwiftUI
//import RealityKit
//import RealityKitContent
//
//struct ProximityTapView: View {
//    @State private var scene: Entity?
//    @State private var selectableEntities: [Entity] = []
//
//    var body: some View {
//        RealityView { content in
//            // Load the scene from the bundle
//            if let scene = try? await Entity(named: "SpatialTapLab", in: realityKitContentBundle) {
//                content.add(scene)
//                self.scene = scene
//                self.selectableEntities = findSelectableEntities(in: scene)
//            }
//        }
//        .gesture(spatialTapGesture)
//    }
//
//    // Function to find all selectable entities (those with CollisionComponent and InputTargetComponent)
//    private func findSelectableEntities(in entity: Entity) -> [Entity] {
//        var result: [Entity] = []
//        if entity.components.has(CollisionComponent.self) && entity.components.has(InputTargetComponent.self) {
//            result.append(entity)
//        }
//        for child in entity.children {
//            result.append(contentsOf: findSelectableEntities(in: child))
//        }
//        return result
//    }
//
//    // Define the spatial tap gesture
//    private var spatialTapGesture: some Gesture {
//        SpatialTapGesture()
//            .onEnded { value in
//                // Get the tap location in world space
//                let worldPosition = value.location3D
//                
//                // Find the nearest selectable entity to the tap location
//                if let nearestEntity = findNearestEntity(to: worldPosition, in: selectableEntities) {
//                    // Move the selected entity with animation
//                    moveEntity(nearestEntity)
//                }
//            }
//    }
//
//    // Function to find the nearest entity to a given position
//    private func findNearestEntity(to position: SIMD3<Float>, in entities: [Entity]) -> Entity? {
//        var nearest: Entity?
//        var minDistance: Float = .greatestFiniteMagnitude
//        for entity in entities {
//            let entityWorldPos = entity.convertPosition(.zero, to: nil)
//            let distance = length(entityWorldPos - position)
//            if distance < minDistance {
//                minDistance = distance
//                nearest = entity
//            }
//        }
//        return nearest
//    }
//
//    // Function to move the selected entity with animation
//    private func moveEntity(_ entity: Entity) {
//        // Define the new position (move up by 0.1 meters)
//        let currentTransform = entity.transform
//        var newTransform = currentTransform
//        newTransform.translation += SIMD3<Float>(0, 0.1, 0)
//        
//        // Animate the entity's position with ease-in and ease-out
//        entity.move(to: newTransform, relativeTo: entity.parent, duration: 0.5, timingFunction: .easeInOut)
//    }
//}
//
////#Preview {
////    ProximityTapView()
////}
