//
//  DragRotationModifier.swift
//  AstraZeneca
//
//  Created on 4/14/25.
//

import SwiftUI
import RealityKit

extension View {
    /// Enables people to drag an entity to rotate it, with continuous rotation on the Y axis
    /// and limited rotation on the X axis (pitch).
    func dragRotation(
        pitchLimit: Angle = .degrees(45),
        sensitivity: Double = 5,
        friction: Double = 0.98,
        axRotateClockwise: Bool = false,
        axRotateCounterClockwise: Bool = false
    ) -> some View {
        self.modifier(
            DragRotationModifier(
                pitchLimit: pitchLimit,
                sensitivity: sensitivity,
                friction: friction,
                axRotateClockwise: axRotateClockwise,
                axRotateCounterClockwise: axRotateCounterClockwise
            )
        )
    }
}

/// A modifier that converts drag gestures into continuous rotation with momentum.
private struct DragRotationModifier: ViewModifier {
    var pitchLimit: Angle
    var sensitivity: Double
    var friction: Double
    var axRotateClockwise: Bool
    var axRotateCounterClockwise: Bool

    @State private var yaw: Double = 0
    @State private var pitch: Double = 0
    @State private var yawVelocity: Double = 0
    @State private var pitchVelocity: Double = 0
    @State private var isDragging: Bool = false
    @State private var lastDragTime: Date = Date()
    @State private var lastYaw: Double = 0
    @State private var lastPitch: Double = 0
    
    // Timer for continuing rotation after drag
    @State private var timer: Timer?

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(yaw), axis: .y)
            .rotation3DEffect(.degrees(pitch), axis: .x)
            .gesture(DragGesture(minimumDistance: 0.0)
                .targetedToAnyEntity()
                .onChanged { value in
                    // Get time delta for velocity calculation
                    let now = Date()
                    let timeDelta = now.timeIntervalSince(lastDragTime)
                    
                    // Calculate the drag delta
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D
                    
                    // Update yaw (no limits)
                    let newYaw = yaw + Double(delta.x) * sensitivity
                    
                    // Update pitch (with limits)
                    let newPitch = max(-pitchLimit.degrees, min(pitchLimit.degrees, 
                                                               pitch + Double(delta.y) * sensitivity))
                    
                    // Calculate velocities
                    if timeDelta > 0.001 {
                        yawVelocity = (newYaw - lastYaw) / timeDelta
                        pitchVelocity = (newPitch - lastPitch) / timeDelta
                    }
                    
                    // Stop any existing animation timer
                    timer?.invalidate()
                    timer = nil
                    
                    // Update state
                    withAnimation(.interactiveSpring) {
                        yaw = newYaw
                        pitch = newPitch
                    }
                    
                    // Store values for next frame
                    lastYaw = newYaw
                    lastPitch = newPitch
                    lastDragTime = now
                    isDragging = true
                }
                .onEnded { _ in
                    // Begin continuous rotation with initial velocity
                    isDragging = false
                    
                    // Apply slight damping to initial velocity
                    yawVelocity *= 0.8
                    pitchVelocity *= 0.8
                    
                    // Start the physics timer to continue rotation
                    startContinuousRotation()
                }
            )
            .onChange(of: axRotateClockwise) {
                withAnimation(.spring) {
                    yaw -= 30
                }
            }
            .onChange(of: axRotateCounterClockwise) {
                withAnimation(.spring) {
                    yaw += 30
                }
            }
            .onDisappear {
                // Clean up timer when view disappears
                timer?.invalidate()
                timer = nil
            }
    }
    
    /// Starts the continuous rotation with momentum physics
    private func startContinuousRotation() {
        // Clean up any existing timer
        timer?.invalidate()
        
        // Check if we have enough velocity to bother with animation
        if abs(yawVelocity) < 1.0 && abs(pitchVelocity) < 1.0 {
            return
        }
        
        // Set up a timer for physics-based animation
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            // Apply friction to gradually reduce velocity
            yawVelocity *= friction
            pitchVelocity *= friction
            
            // Update rotation values
            yaw += yawVelocity * 0.016  // Multiply by time step
            
            // Apply pitch limits
            let newPitch = pitch + pitchVelocity * 0.016
            pitch = max(-pitchLimit.degrees, min(pitchLimit.degrees, newPitch))
            
            // If velocity is very small, stop the animation
            if abs(yawVelocity) < 0.1 && abs(pitchVelocity) < 0.1 {
                timer?.invalidate()
                timer = nil
            }
        }
    }
}
