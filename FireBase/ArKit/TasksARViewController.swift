import ARKit
import UIKit

class TasksARViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AR Тапсырмалар"
        view.backgroundColor = .systemBackground

        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)

        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true

        // Қарапайым AR сценаға сфера қосу
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIColor.systemBlue
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, 0, -0.5) // камерадан 0.5 метр алда

        sceneView.scene.rootNode.addChildNode(node)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
