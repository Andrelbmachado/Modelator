import SwiftUI
import ModelatorCore

/// Barra superior invisivel com botoes de modo de visualizacao.
struct TopModeBar: View {
    /// Modo de renderizacao selecionado pelo usuario.
    @Binding var selectedMode: RenderMode

    /// Altura da barra em pontos.
    let barHeight: CGFloat

    /// Tamanho do botao de modo em pontos (largura e altura).
    private let buttonSize: CGSize = CGSize(width: 120, height: 32)

    /// Cor de fundo do botao ativo.
    private let activeButtonColor: Color = .white.opacity(0.18)

    /// Raio de borda do botao para visual suave.
    private let buttonCornerRadius: CGFloat = 8

    /// Corpo da barra superior.
    var body: some View {
        HStack(spacing: 12) {
            ForEach(RenderMode.allCases) { mode in
                Button(mode.displayName) {
                    selectedMode = mode
                }
                .frame(width: buttonSize.width, height: buttonSize.height)
                .background(selectedMode == mode ? activeButtonColor : .clear)
                .cornerRadius(buttonCornerRadius)
            }
        }
        .frame(height: barHeight)
        .padding(.top, 6)
    }
}
