
import Foundation
import SceneKit
import ARKit

class AnimatedModel: SCNScene {
	
	// Special nodes used to control animations of the model
	fileprivate let contentRootNode = SCNNode()
    let lightNode2 = SCNNode()
    let lightNode = SCNNode()
    let ambientLightNode = SCNNode()
	
	// State variables
	private var modelLoaded: Bool = false
	fileprivate var lastColorFromEnvironment = SCNVector3(130.0 / 255.0, 196.0 / 255.0, 174.0 / 255.0)
    
	// MARK: - Initialization and Loading
	
	override init() {
		super.init()
		
		// Load the environment map
		self.lightingEnvironment.contents = UIImage(named: "art.scnassets/environment_blur.exr")!
		
		// Load the chameleon
		loadModel()
	}
    
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func loadModel() {
        guard let virtualObjectScene = SCNScene(named:"art.scnassets/RooTee.dae") else {
            return
        }
        //Ahlam_position.dae
        //art.scnassets/man/DAE.dae
        
		let wrapperNode = SCNNode()
		for child in virtualObjectScene.rootNode.childNodes {
			wrapperNode.addChildNode(child)
		}
		self.rootNode.addChildNode(contentRootNode)
        wrapperNode.scale = SCNVector3(0.009, 0.009, 0.009)
		contentRootNode.addChildNode(wrapperNode)
        
        let plane = SCNPlane(width: 4.5, height: 4.5)
        plane.materials.first?.colorBufferWriteMask = SCNColorMask(rawValue:0)

        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.1
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        contentRootNode.addChildNode(planeNode)
        
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 1, z: 1)//SCNVector3(x: 0, y: 1, z: 1)
        contentRootNode.addChildNode(lightNode)
        // create main light that cast shadow
        lightNode2.light = SCNLight()
        lightNode2.light!.type = .directional
        lightNode2.position = SCNVector3(x: -1, y: 10, z: 1)
        lightNode2.eulerAngles = SCNVector3(self.rad(-136.458), self.rad(190), self.rad(338)) //136 190 338
        lightNode2.light?.intensity = 1
        lightNode2.light?.shadowColor = UIColor.black.withAlphaComponent(0.5)
        lightNode2.light?.shadowRadius = 0
        lightNode2.light?.castsShadow = true // to cast shadow
        lightNode2.light?.shadowMode = .deferred // to render shadow in transparent plane
        lightNode2.light?.shadowSampleCount = 1  //remove flickering of shadow and soften shadow
        //lightNode2.light?.shadowMapSize = CGSize(width: 2048, height: 2048) //sharpen or detail shadow
        contentRootNode.addChildNode(lightNode2)
        
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        contentRootNode.addChildNode(ambientLightNode)
        
		hide()
		modelLoaded = true
	}
	
	// MARK: - Public API
	
	func show() {
		contentRootNode.isHidden = false
	}
	
	func hide() {
		contentRootNode.isHidden = true
		//resetState()
	}
	
	func isVisible() -> Bool {
		return !contentRootNode.isHidden
	}
	
	func setTransform(_ transform: simd_float4x4) {
		contentRootNode.simdTransform = transform
	}
    
    func setPosition(_ transform: float3) {
        contentRootNode.simdPosition = transform
    }
    
    func applyLight(estimate : ARLightEstimate) {
        lightNode2.light?.intensity = estimate.ambientIntensity
        lightNode2.light?.temperature = estimate.ambientColorTemperature
        lightNode.light?.intensity = estimate.ambientIntensity/3
        lightNode.light?.temperature = estimate.ambientColorTemperature
    }
	
}

// MARK: - React To Placement and Tap

extension AnimatedModel {
    
	func reactToPositionChange(in view: ARSCNView) {
		self.reactToPlacement(in: view)
	}
	
	func reactToInitialPlacement(in view: ARSCNView) {
		self.reactToPlacement(in: view, isInitial: true)
	}
	
	private func reactToPlacement(in sceneView: ARSCNView, isInitial: Bool = false) {

        let constraint = SCNLookAtConstraint(target:sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
//        constraint.localFront = SCNVector3(x: 0, y: 0.5, z: 1)
         constraint.localFront = SCNVector3(x: 0, y: 0.5, z: 1)
        contentRootNode.constraints = [constraint]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {                 
            self.contentRootNode.constraints = []
        })
        
		if isInitial {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
				self.getColorFromEnvironment(sceneView: sceneView)
				//self.activateCamouflage(true)
		    	})
		} else {
			DispatchQueue.main.async {
				//self.updateCamouflage(sceneView: sceneView)
			}
		}
	}
	
	func reactToTap(in sceneView: ARSCNView) {
		//self.activateCamouflage(false)
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
			//self.activateCamouflage(true)
		}
    )
}
    
    func getDistanceFromScene(_ sceneView : ARSCNView, _ location : CGPoint) -> CGFloat {
        
        let arHitTestResult = sceneView.hitTest(location, types: .existingPlane)
        if !arHitTestResult.isEmpty {
            let hit = arHitTestResult.first!
            return hit.distance
        }
        return 0.0
    }
    
	private func getColorFromEnvironment(sceneView: ARSCNView) {
		let worldPos = sceneView.projectPoint(contentRootNode.worldPosition)
		let colorVector = sceneView.averageColorFromEnvironment(at: worldPos)
		lastColorFromEnvironment = colorVector
	}
}

// MARK: - Helper functions

extension AnimatedModel {
	
	fileprivate func rad(_ deg: Float) -> Float {
		return deg * Float.pi / 180
	}
	
	fileprivate func randomlyUpdate(_ vector: inout simd_float3) {
		switch arc4random() % 400 {
		case 0: vector.x = 0.1
		case 1: vector.x = -0.1
		case 2: vector.y = 0.1
		case 3: vector.y = -0.1
		case 4, 5, 6, 7: vector = simd_float3()
		default: break
		}
	}
}
