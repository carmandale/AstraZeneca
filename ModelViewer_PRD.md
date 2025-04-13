# Product Requirements Document (PRD)

## visionOS 2 Oncology Model Viewer

### Overview
This project will create a visionOS 2 SwiftUI-based application for Apple Vision Pro. It features a detailed informational 2D window that seamlessly transitions to a 3D interactive viewer, allowing users to explore and manipulate an oncology-related molecular model (specifically HER2-Trastuzumab). The app is designed primarily for AstraZeneca stakeholders, combining educational content, interactive 3D visualization, and links to further oncology research.

### Features

#### 1. Detail View (2D Window)
- **UI:** Based on Apple's "Hello World" visionOS 2 example project.
- **Content:**
  - Title: HER2 and Trastuzumab Interaction
  - Concise description of the molecular structure and its significance in breast cancer treatment.
  - Links to AstraZeneca's oncology research: [AstraZeneca Oncology](https://www.astrazeneca.com/our-therapy-areas/oncology.html)
  - "View Model" Button: Opens the interactive 3D view.

#### 2. Interactive 3D Model Viewer
- **Launch:** Activated by tapping "View Model" button in the 2D view.
- **Model:**
  - High-quality HER2-Trastuzumab molecular structure
  - Blender-compatible format, optimized for real-time rendering
  - Smooth, realistic shading and materials for clarity
- **Interaction:**
  - Rotate the model freely (360-degree interaction)
  - Zoom in/out for detail exploration
  - Tap annotations or parts of the model for additional information

#### 3. Optional Model Stages/Configurations
- Provide multiple views or stages to visualize different states:
  - HER2 protein alone
  - Trastuzumab antibody alone
  - Combined interaction view (binding)
  - Exploded view highlighting specific interaction points

### Technical Implementation
- **Platform:** Apple Vision Pro (visionOS 2)
- **Development Framework:** SwiftUI and RealityKit
- **3D Model Formats:**
  - Primary format: USDZ (for optimal compatibility with visionOS)
  - Original Blender-compatible formats (OBJ, FBX) as source
- **External Resources:**
  - AstraZeneca Oncology research links embedded within SwiftUI

### User Experience
- Seamless transition from 2D information to immersive 3D model interaction
- Intuitive gestures and UI indicators for interactive manipulation
- Consistent visual and interaction design based on Apple's recommended guidelines for visionOS 2

### Reference Example
- Apple's "Hello World" visionOS project is a core reference for UI layout, style, and interaction patterns.

### Deliverables
- SwiftUI-based visionOS 2 application
- Fully interactive HER2-Trastuzumab model viewer
- Source assets (3D models, textures)
- Comprehensive inline documentation and comments
- Instructions for compiling, deploying, and testing on Vision Pro hardware

### Goals
- Enhance understanding of HER2-positive breast cancer treatments
- Demonstrate AstraZeneca’s advancements in oncology through interactive AR experiences
- Provide engaging, educational interactions tailored specifically for medical professionals and executives.

