/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's window view.
*/

import SwiftUI
import RealityKit
import RealityKitContent

struct UIPortalView: View {
    /// App-wide state
//    @Environment(AppModel.self) private var appModel

    /// The root entity for other entities within the scene.
    private let root = Entity()

    /// A plane entity representing a portal.
    private let portalPlane = ModelEntity(
        mesh: .generatePlane(width: 0.5, height: 0.5),
        materials: [PortalMaterial()]
    )

    var body: some View {
        ZStack(alignment: .center) {
//            ExecutiveMeetingView()
            portalView
        }
    }

    /// A view that contains a portal and a button that opens the immersive space.
    var portalView: some View {
        GeometryReader3D { geometry in
            RealityView { content in
                try? await createPortal()
                content.add(root)
            } update: { content in
                // Resize the scene based on the size of the reality view content.
                let size = content.convert(geometry.size, from: .local, to: .scene)
                updatePortalSize(width: size.x, height: size.y)
            }
            .frame(depth: 0.6)
        }
        .frame(depth: 0.6)
        .frame(width: 400, height: 600)
    }

    /// Sets up the portal and adds it to the `root.`
    func createPortal() async throws {
        // Create the entity that stores the content within the portal.
        let world = Entity()

        // Shrink the portal world and update the position
        // to make it fit into the portal view.
        world.scale *= 0.55
//        world.position.x -= -0.25
        world.position.y -= -0.025
        world.position.z -= 0.0

        // Allow the entity to be visible only through a portal.
        world.components.set(WorldComponent())
        
        // Create the box environment and add it to the root.
        try await createEnvironment(on: world)
        root.addChild(world)

        // Set up the portal to show the content in the `world`.
        portalPlane.components.set(PortalComponent(target: world))
//        portalPlane.position.x = 0.25
        portalPlane.position.y = 0.025
        root.addChild(portalPlane)
    }

    /// Configures the portal mesh's width and height.
    func updatePortalSize(width: Float, height: Float) {
        portalPlane.model?.mesh = .generatePlane(width: width, height: height, cornerRadius: 0.03)
    }
    
    /// Creates the box environment and applies image-based lighting.
    func createEnvironment(on root: Entity) async throws {
        
        if let welcomeAsset = try? await Entity(named: "welcome", in: realityKitContentBundle) {
            root.addChild(welcomeAsset)
        }
    }
}
