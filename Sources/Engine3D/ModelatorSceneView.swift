import SwiftUI
import SceneKit
import simd
import ModelatorCore

#if os(macOS)
import AppKit
/// Cor multiplataforma: usa `NSColor` no macOS.
typealias PlatformColor = NSColor
#else
import UIKit
/// Cor multiplataforma: usa `UIColor` no iOS/iPadOS.
typealias PlatformColor = UIColor
#endif

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
        .onChange(of: renderSettings) { _, _ in
            ModelatorSceneFactory.apply(renderMode: renderMode, settings: renderSettings, to: scene)
        }
    }
}

/// Fatoria responsavel por criar e atualizar a cena 3D.
enum ModelatorSceneFactory {
    /// Nome do no raiz do conteudo (Z para cima, padrao Blender).
    private static let contentRootName = "modelator.contentRoot"

    /// Nome do no do modelo de teste (o cubo).
    private static let modelNodeName = "modelator.model"

    /// Nome do no do plano que recebe a sombra.
    private static let shadowPlaneName = "modelator.shadowPlane"

    /// Nome do no da luz direcional principal.
    private static let keyLightName = "modelator.keyLight"

    /// Cria uma cena basica com grade XY, eixos coloridos e um cubo em pe.
    static func makeScene() -> SCNScene {
        let scene = SCNScene()

        // No raiz do conteudo rotacionado -90 graus em X: assim os filhos usam
        // Z para cima (padrao Blender), enquanto o SceneKit continua Y para cima.
        let contentRoot = SCNNode()
        contentRoot.name = contentRootName
        contentRoot.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        scene.rootNode.addChildNode(contentRoot)

        // Camera posicionada como no Blender: olhando a origem de (7, -7, 5).
        // Fica no mundo Y-up do SceneKit, com uma constraint apontando a origem.
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 500
        cameraNode.position = blenderToWorld(SCNVector3(7, -7, 5))
        let lookAtOrigin = SCNLookAtConstraint(target: scene.rootNode)
        lookAtOrigin.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAtOrigin]
        scene.rootNode.addChildNode(cameraNode)

        // Luz ambiente suave para o modelo nao ficar totalmente preto na sombra.
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.intensity = 250
        scene.rootNode.addChildNode(ambientNode)

        // Luz direcional principal (key light), orientada por `shadowDirection`.
        let keyLight = SCNNode()
        keyLight.name = keyLightName
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.castsShadow = false
        scene.rootNode.addChildNode(keyLight)

        // Conteudo sob o no Z-up: grade, eixos, plano de sombra e modelo.
        contentRoot.addChildNode(makeGrid())
        makeAxes().forEach { contentRoot.addChildNode($0) }
        contentRoot.addChildNode(makeShadowPlane())

        let boxNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.02))
        boxNode.name = modelNodeName
        // Em Z-up o cubo sobe em Z; eleva meia altura para apoiar no chao.
        boxNode.position = SCNVector3(0, 0, 0.5)
        boxNode.geometry?.firstMaterial = defaultMaterial()
        contentRoot.addChildNode(boxNode)

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
        guard let modelNode = scene.rootNode.childNode(withName: modelNodeName, recursively: true) else {
            return
        }

        let material = SCNMaterial()
        material.isDoubleSided = true

        switch renderMode {
        case .grayModel:
            material.diffuse.contents = PlatformColor.gray
            material.lightingModel = .blinn
            setShadow(enabled: false, settings: settings, in: scene)
        case .textureOnly:
            // Sem textura carregada ainda: mostra um checker padrao.
            material.diffuse.contents = checkerImage()
            material.diffuse.wrapS = .repeat
            material.diffuse.wrapT = .repeat
            material.lightingModel = .constant
            setShadow(enabled: false, settings: settings, in: scene)
        case .shadowOnly:
            material.diffuse.contents = PlatformColor.lightGray
            material.lightingModel = .blinn
            setShadow(enabled: true, settings: settings, in: scene)
        }

        modelNode.geometry?.materials = [material]
    }

    /// Cria o material padrao usado no modelo de teste.
    private static func defaultMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = PlatformColor.gray
        material.isDoubleSided = true
        return material
    }

    /// Ajusta a sombra e a orientacao da luz conforme as configuracoes.
    ///
    /// Converte o vetor `shadowDirection` em orientacao da luz com uma matriz
    /// de "look", em vez de usar angulos de Euler diretos.
    /// - Parameters:
    ///   - enabled: Define se a sombra esta ativa.
    ///   - settings: Configuracoes de direcao e intensidade.
    ///   - scene: Cena que contem a luz principal.
    private static func setShadow(enabled: Bool, settings: RenderSettings, in scene: SCNScene) {
        guard let keyLight = scene.rootNode.childNode(withName: keyLightName, recursively: true) else {
            return
        }

        keyLight.light?.castsShadow = enabled
        keyLight.light?.shadowMode = .deferred
        keyLight.light?.shadowIntensity = CGFloat(settings.shadowIntensity)

        // `shadowDirection` esta em Z-up (Blender); converte para o mundo Y-up.
        let worldDirection = simd_normalize(blenderVectorToWorld(settings.shadowDirection))
        keyLight.simdOrientation = lookRotation(forward: worldDirection)

        // O plano de chao so recebe sombra quando ha sombra para mostrar.
        if let shadowPlane = scene.rootNode.childNode(withName: shadowPlaneName, recursively: true) {
            shadowPlane.isHidden = !enabled
        }
    }

    /// Converte uma posicao em coordenadas Blender (Z-up) para o mundo (Y-up).
    /// - Parameter v: Vetor no referencial Blender.
    /// - Returns: Vetor equivalente no referencial Y-up do SceneKit.
    private static func blenderToWorld(_ v: SCNVector3) -> SCNVector3 {
        // Blender (x, y, z) -> SceneKit (x, z, -y).
        return SCNVector3(v.x, v.z, -v.y)
    }

    /// Converte um vetor de direcao Blender (Z-up) para o mundo (Y-up).
    /// - Parameter v: Vetor de direcao no referencial Blender.
    /// - Returns: Vetor de direcao no referencial Y-up.
    private static func blenderVectorToWorld(_ v: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3<Float>(v.x, v.z, -v.y)
    }

    /// Calcula a rotacao (quaternion) que aponta o -Z local de um no (a direcao
    /// padrao de uma luz direcional) para um dado vetor.
    /// - Parameter forward: Direcao desejada (vetor unitario no mundo).
    /// - Returns: Quaternion de orientacao.
    private static func lookRotation(forward: SIMD3<Float>) -> simd_quatf {
        let defaultForward = SIMD3<Float>(0, 0, -1)
        let f = simd_normalize(forward)
        let dot = simd_dot(defaultForward, f)

        // Vetores quase opostos: gira 180 graus em torno de um eixo perpendicular.
        if dot < -0.9999 {
            return simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
        }
        // Vetores quase iguais: sem rotacao.
        if dot > 0.9999 {
            return simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        }

        let axis = simd_normalize(simd_cross(defaultForward, f))
        let angle = acos(max(-1, min(1, dot)))
        return simd_quatf(angle: angle, axis: axis)
    }

    /// Cria a grade do chao no plano XY (eixo Blender).
    /// - Returns: No contendo as linhas da grade.
    private static func makeGrid() -> SCNNode {
        let gridNode = SCNNode()
        gridNode.name = "modelator.grid"

        let halfSize = 10
        let spacing: Float = 1
        let color = PlatformColor.gray.withAlphaComponent(0.35)

        for i in -halfSize...halfSize {
            let offset = Float(i) * spacing
            let extent = Float(halfSize) * spacing

            // Linhas paralelas ao eixo X.
            gridNode.addChildNode(lineNode(
                from: SCNVector3(-extent, offset, 0),
                to: SCNVector3(extent, offset, 0),
                color: color
            ))
            // Linhas paralelas ao eixo Y.
            gridNode.addChildNode(lineNode(
                from: SCNVector3(offset, -extent, 0),
                to: SCNVector3(offset, extent, 0),
                color: color
            ))
        }

        return gridNode
    }

    /// Cria os tres eixos coloridos (X vermelho, Y verde, Z azul).
    /// - Returns: Lista de nos, um por eixo.
    private static func makeAxes() -> [SCNNode] {
        let length: Float = 3
        return [
            lineNode(from: SCNVector3(0, 0, 0), to: SCNVector3(length, 0, 0), color: .systemRed),
            lineNode(from: SCNVector3(0, 0, 0), to: SCNVector3(0, length, 0), color: .systemGreen),
            lineNode(from: SCNVector3(0, 0, 0), to: SCNVector3(0, 0, length), color: .systemBlue)
        ]
    }

    /// Cria um no de linha entre dois pontos usando uma geometria de segmento.
    /// - Parameters:
    ///   - from: Ponto inicial.
    ///   - to: Ponto final.
    ///   - color: Cor da linha.
    /// - Returns: No contendo a linha.
    private static func lineNode(from: SCNVector3, to: SCNVector3, color: PlatformColor) -> SCNNode {
        let source = SCNGeometrySource(vertices: [from, to])
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geometry = SCNGeometry(sources: [source], elements: [element])

        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .constant
        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }

    /// Cria o plano de chao que recebe a sombra, no plano XY.
    /// - Returns: No do plano de sombra.
    private static func makeShadowPlane() -> SCNNode {
        let plane = SCNPlane(width: 40, height: 40)
        let material = SCNMaterial()
        // `shadow`/write-depth: material que so mostra a sombra projetada.
        material.lightingModel = .constant
        material.writesToDepthBuffer = true
        material.colorBufferWriteMask = []
        plane.materials = [material]

        let node = SCNNode(geometry: plane)
        node.name = shadowPlaneName
        node.isHidden = true
        // O SCNPlane fica no plano XY local por padrao; sob o contentRoot vira o chao.
        return node
    }

    /// Gera uma textura checker padrao para o modo "Textura" sem imagem.
    ///
    /// Desenha um tabuleiro via Core Graphics, portavel entre macOS e iOS.
    /// - Returns: `CGImage` do checkerboard, ou cinza solido se falhar.
    private static func checkerImage() -> Any {
        let side = 256
        let tiles = 8
        let tileSize = side / tiles

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: side,
            height: side,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return PlatformColor.gray
        }

        let light = CGColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        let dark = CGColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1)

        for row in 0..<tiles {
            for column in 0..<tiles {
                let isDark = (row + column) % 2 == 0
                context.setFillColor(isDark ? dark : light)
                context.fill(CGRect(
                    x: column * tileSize,
                    y: row * tileSize,
                    width: tileSize,
                    height: tileSize
                ))
            }
        }

        return context.makeImage() ?? PlatformColor.gray
    }
}
