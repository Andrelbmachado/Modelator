import SwiftUI
import ModelatorCore

/// Aba visivel quando a barra lateral esta minimizada.
struct CollapsedSidebarTab: View {
    /// Lado da barra que esta colapsada.
    let side: SidebarSide

    /// Callback para restaurar a barra ao tocar.
    let onRestore: () -> Void

    /// Largura da aba colapsada em pontos.
    private let tabWidth: CGFloat = 18

    /// Cor da aba colapsada para indicar a borda.
    private let tabColor: Color = Color.gray.opacity(0.25)

    /// Corpo da aba colapsada.
    var body: some View {
        Rectangle()
            .fill(tabColor)
            .frame(width: tabWidth)
            .onTapGesture {
                onRestore()
            }
    }
}
