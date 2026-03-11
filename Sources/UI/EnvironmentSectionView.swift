import SwiftUI

/// Conteudo da secao de ambiente (luz, sombras, HDRI).
struct EnvironmentSectionView: View {
    /// Altura do slider de intensidade em pontos.
    private let sliderHeight: CGFloat = 30

    /// Cor do texto de titulo para contraste no painel.
    private let titleColor: Color = .primary

    /// Corpo da secao de ambiente.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Luz e Sombra")
                .font(.subheadline)
                .foregroundColor(titleColor)

            Slider(value: .constant(0.6))
                .frame(height: sliderHeight)

            Text("Direcao da sombra 360°")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
