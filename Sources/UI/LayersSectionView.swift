import SwiftUI

/// Conteudo da secao de camadas (layers).
struct LayersSectionView: View {
    /// Altura visual de cada item de camada em pontos.
    private let layerRowHeight: CGFloat = 32

    /// Cor do indicador de camada ativa.
    private let activeLayerColor: Color = .blue

    /// Corpo da secao de camadas.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Camadas")
                .font(.subheadline)

            ForEach(0..<3, id: \.self) { index in
                HStack {
                    Circle()
                        .fill(index == 0 ? activeLayerColor : .gray)
                        .frame(width: 10, height: 10)

                    Text("Camada \(index + 1)")
                        .font(.caption)

                    Spacer()
                }
                .frame(height: layerRowHeight)
            }
        }
    }
}
