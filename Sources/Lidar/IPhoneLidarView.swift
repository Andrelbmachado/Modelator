import SwiftUI

#if os(iOS)
import ARKit
import RealityKit
#endif

/// Tela simplificada para iPhone com LiDAR e analise de midias.
struct IPhoneLidarView: View {
    /// Index do picker para alternar entre LiDAR, fotos e videos.
    @State private var selectedTabIndex: Int = 0

    /// Altura do seletor superior em pontos.
    private let pickerHeight: CGFloat = 36

    /// Corpo principal da tela do iPhone.
    var body: some View {
        VStack(spacing: 0) {
            Picker("Modo", selection: $selectedTabIndex) {
                Text("LiDAR").tag(0)
                Text("Fotos").tag(1)
                Text("Videos").tag(2)
            }
            .pickerStyle(.segmented)
            .frame(height: pickerHeight)
            .padding(12)

            Group {
                switch selectedTabIndex {
                case 0:
                    LidarScanView()
                case 1:
                    MediaPlaceholderView(title: "Analise de fotos")
                default:
                    MediaPlaceholderView(title: "Analise de videos")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#if os(iOS)
/// View que encapsula a captura de LiDAR usando ARKit/RealityKit.
struct LidarScanView: View {
    /// Corpo da area de captura.
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

/// Container UIKit para integrar ARView no SwiftUI.
struct ARViewContainer: UIViewRepresentable {
    /// Cria o ARView e inicia a sessao de captura.
    /// - Parameter context: Contexto do SwiftUI.
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }

        arView.session.run(configuration)
        return arView
    }

    /// Atualiza o ARView quando o SwiftUI altera o estado.
    /// - Parameters:
    ///   - uiView: Instancia atual do ARView.
    ///   - context: Contexto do SwiftUI.
    func updateUIView(_ uiView: ARView, context: Context) {
        // Sem atualizacoes dinamicas por enquanto.
    }
}
#endif

/// Placeholder para telas de analise de midia no iPhone.
struct MediaPlaceholderView: View {
    /// Texto exibido no centro da tela.
    let title: String

    /// Cor do texto de placeholder.
    private let titleColor: Color = .secondary

    /// Corpo do placeholder.
    var body: some View {
        ZStack {
            Color.black
            Text(title)
                .foregroundColor(titleColor)
                .font(.headline)
        }
    }
}
