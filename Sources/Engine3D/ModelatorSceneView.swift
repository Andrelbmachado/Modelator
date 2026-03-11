import SwiftUI
import SceneKit

/// View SwiftUI que exibe a cena 3D do Modelator.
struct ModelatorSceneView: View {
    /// Modo de renderizacao selecionado.
    @Binding var renderMode: RenderMode

    /// Configuracoes de sombra e luz.
    @Binding var renderSettings: RenderSettings

    /// Cena 3D atual exibida no canvas.
    @State private var scene: SCNScene = ModelatorSceneFactory.makeScene()

    /// Corpo do canvas 3D.
    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: ModelatorSceneFactory.defaultCamera(for: scene),
            options: [.allowsCameraControl]
        )
        .onAppear {
            ModelatorSceneFactory.apply(renderMode: renderMode, settings: renderSettings, to: scene)
        }
        .onChange(of: renderMode) { _, newMode in
            ModelatorSceneFactory.apply(renderMode: newMode, settings: renderSettings, to: scene)
        }
        .onChange(of: renderSettings.shadowDirection) { _, _ in
            ModelatorSceneFactory.apply(renderMode: renderMode, settings: renderSettings, to: scene)
        }
    }
}

/// Fatoria responsavel por criar e atualizar a cena 3D.
enum ModelatorSceneFactory {
    /// Cria uma cena basica com um cubo para teste visual.
    static func makeScene() -> SCNScene {
        let scene = SCNScene()

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 2, 6)
        scene.rootNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.eulerAngles = SCNVector3(-0.7, 0.2, 0)
        scene.rootNode.addChildNode(lightNode)

        let boxNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.02))
        boxNode.geometry?.firstMaterial = defaultMaterial()
        scene.rootNode.addChildNode(boxNode)

        return scene
    }

    /// Retorna a camera padrao da cena para o SceneView.
    /// - Parameter scene: Cena onde a camera foi criada.
    static func defaultCamera(for scene: SCNScene) -> SCNNode? {
        return scene.rootNode.childNodes.first { $0.camera != nil }
    }

    /// Aplica o modo de renderizacao e as configuracoes na cena atual.
    /// - Parameters:
    ///   - renderMode: Modo de visualizacao escolhido pelo usuario.
    ///   - settings: Configuracoes de luz e sombra.
    ///   - scene: Cena a ser atualizada.
    static func apply(renderMode: RenderMode, settings: RenderSettings, to scene: SCNScene) {
        let material = defaultMaterial()

        switch renderMode {
        case .grayModel:
            material.diffuse.contents = NSColor.gray
            material.lightingModel = .blinn
            material.isDoubleSided = true
            setShadow(enabled: false, settings: settings, in: scene)
        case .textureOnly:
            material.diffuse.contents = NSColor.white
            material.lightingModel = .constant
            material.isDoubleSided = true
            setShadow(enabled: false, settings: settings, in: scene)
        case .shadowOnly:
            material.diffuse.contents = NSColor.lightGray
            material.lightingModel = .blinn
            material.isDoubleSided = true
            setShadow(enabled: true, settings: settings, in: scene)
        }

        scene.rootNode.childNodes.forEach { node in
            node.geometry?.materials = [material]
        }
    }

    /// Cria o material padrao usado no modelo de teste.
    private static func defaultMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.gray
        material.isDoubleSided = true
        return material
    }

    /// Ajusta a sombra conforme as configuracoes do usuario.
    /// - Parameters:
    ///   - enabled: Define se a sombra esta ativa.
    ///   - settings: Configuracoes de direcao e intensidade.
    ///   - scene: Cena que contem a luz principal.
    private static func setShadow(enabled: Bool, settings: RenderSettings, in scene: SCNScene) {
        let lightNodes = scene.rootNode.childNodes.compactMap { $0.light != nil ? $0 : nil }

        lightNodes.forEach { lightNode in
            lightNode.light?.castsShadow = enabled
            lightNode.light?.shadowIntensity = CGFloat(settings.shadowIntensity)
            lightNode.eulerAngles = SCNVector3(
                settings.shadowDirection.x,
                settings.shadowDirection.y,
                settings.shadowDirection.z
            )
        }
    }
}
