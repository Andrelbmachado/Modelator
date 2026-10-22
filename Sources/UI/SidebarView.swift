import SwiftUI
import ModelatorCore

/// Barra lateral com secoes reorganizaveis.
struct SidebarView: View {
    /// Lado da barra (esquerdo ou direito).
    let side: SidebarSide

    /// Lista de secoes exibidas na barra.
    @Binding var sections: [SidebarSection]

    /// Largura visual da barra em pontos.
    let width: CGFloat

    /// Cor de fundo da barra para contraste com o canvas.
    let backgroundColor: Color

    /// Configuracoes de ambiente (luz/sombra) usadas pela secao de ambiente.
    @Binding var environmentSettings: RenderSettings

    /// Callback para mover secao dentro da mesma barra.
    let onMove: (_ source: Int, _ destination: Int, _ side: SidebarSide) -> Void

    /// Callback para transferir secao entre barras.
    let onTransfer: (_ source: Int, _ destination: Int, _ fromSide: SidebarSide, _ toSide: SidebarSide) -> Void

    /// Callback para redimensionar a barra via arraste.
    let onDragResize: (_ translation: CGFloat, _ isEnded: Bool) -> Void

    /// Largura do handle de redimensionamento em pontos.
    private let resizeHandleWidth: CGFloat = 6

    /// Cor do handle de redimensionamento para indicar arraste.
    private let resizeHandleColor: Color = Color.gray.opacity(0.35)

    /// Corpo da barra lateral.
    var body: some View {
        HStack(spacing: 0) {
            if side == .right {
                resizeHandle
            }

            VStack(spacing: 0) {
                List {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        SectionContainerView(
                            section: section,
                            environmentSettings: $environmentSettings,
                            onMoveToOtherSide: {
                                onTransfer(index, 0, side, side == .left ? .right : .left)
                            }
                        )
                    }
                    .onMove { indices, newOffset in
                        if let sourceIndex = indices.first {
                            onMove(sourceIndex, newOffset, side)
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .frame(width: width)
            .background(backgroundColor)

            if side == .left {
                resizeHandle
            }
        }
    }

    /// Handle visual para o usuario arrastar e redimensionar a barra.
    private var resizeHandle: some View {
        Rectangle()
            .fill(resizeHandleColor)
            .frame(width: resizeHandleWidth)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        onDragResize(value.translation.width, false)
                    }
                    .onEnded { value in
                        onDragResize(value.translation.width, true)
                    }
            )
    }
}
