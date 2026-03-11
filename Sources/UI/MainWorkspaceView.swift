import SwiftUI

/// Tela principal do editor completo (iPad e macOS).
struct MainWorkspaceView: View {
    /// Modo de renderizacao ativo (cinza, textura ou sombra).
    @State private var renderMode: RenderMode = .grayModel

    /// Configuracoes de luz e sombra do renderer.
    @State private var renderSettings: RenderSettings = RenderSettings()

    /// Layout atual das secoes das barras laterais.
    @State private var sidebarLayout: SidebarLayout = SidebarLayout()

    /// Largura visual da barra esquerda em pontos.
    @State private var leftSidebarWidth: CGFloat = 260

    /// Largura visual da barra direita em pontos.
    @State private var rightSidebarWidth: CGFloat = 300

    /// Altura da barra superior em pontos.
    @State private var topBarHeight: CGFloat = 48

    /// Largura minima para considerar a barra esquerda colapsada.
    @State private var leftCollapseThreshold: CGFloat = 60

    /// Largura minima para considerar a barra direita colapsada.
    @State private var rightCollapseThreshold: CGFloat = 60

    /// Estado que indica se a barra esquerda esta minimizada.
    @State private var isLeftCollapsed: Bool = false

    /// Estado que indica se a barra direita esta minimizada.
    @State private var isRightCollapsed: Bool = false

    /// Largura inicial da barra esquerda durante o gesto de arraste.
    @State private var leftDragStartWidth: CGFloat = 260

    /// Largura inicial da barra direita durante o gesto de arraste.
    @State private var rightDragStartWidth: CGFloat = 300

    /// Cor de fundo das barras laterais para separar do canvas.
    private var sidebarBackgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(.secondarySystemBackground)
        #endif
    }

    /// Cor de fundo do canvas principal do editor.
    private var canvasBackgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .black)
        #else
        return Color(.black)
        #endif
    }

    /// Corpo principal da tela do editor.
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                if !isLeftCollapsed {
                    SidebarView(
                        side: .left,
                        sections: $sidebarLayout.leftSections,
                        width: leftSidebarWidth,
                        backgroundColor: sidebarBackgroundColor,
                        onMove: handleSectionMove,
                        onTransfer: handleSectionTransfer,
                        onDragResize: handleLeftResize
                    )
                } else {
                    CollapsedSidebarTab(
                        side: .left,
                        onRestore: { isLeftCollapsed = false }
                    )
                }

                ModelatorSceneView(
                    renderMode: $renderMode,
                    renderSettings: $renderSettings
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(canvasBackgroundColor)

                if !isRightCollapsed {
                    SidebarView(
                        side: .right,
                        sections: $sidebarLayout.rightSections,
                        width: rightSidebarWidth,
                        backgroundColor: sidebarBackgroundColor,
                        onMove: handleSectionMove,
                        onTransfer: handleSectionTransfer,
                        onDragResize: handleRightResize
                    )
                } else {
                    CollapsedSidebarTab(
                        side: .right,
                        onRestore: { isRightCollapsed = false }
                    )
                }
            }

            TopModeBar(
                selectedMode: $renderMode,
                barHeight: topBarHeight
            )
        }
    }

    /// Reordena uma secao dentro da mesma barra lateral.
    /// - Parameters:
    ///   - source: Indice de origem.
    ///   - destination: Indice de destino.
    ///   - side: Lado da barra lateral.
    private func handleSectionMove(source: Int, destination: Int, side: SidebarSide) {
        sidebarLayout.moveSection(sourceIndex: source, destinationIndex: destination, side: side)
    }

    /// Transfere uma secao de um lado para o outro.
    /// - Parameters:
    ///   - source: Indice de origem.
    ///   - destination: Indice de destino.
    ///   - fromSide: Lado de origem.
    ///   - toSide: Lado de destino.
    private func handleSectionTransfer(source: Int, destination: Int, fromSide: SidebarSide, toSide: SidebarSide) {
        sidebarLayout.transferSection(sourceIndex: source, destinationIndex: destination, fromSide: fromSide, toSide: toSide)
    }

    /// Atualiza a largura da barra esquerda durante o arraste.
    /// - Parameters:
    ///   - translation: Deslocamento horizontal do gesto.
    ///   - isEnded: Indica se o gesto terminou.
    private func handleLeftResize(translation: CGFloat, isEnded: Bool) {
        if isEnded {
            leftDragStartWidth = leftSidebarWidth
        }

        let newWidth = max(0, leftDragStartWidth + translation)
        leftSidebarWidth = min(newWidth, 420)
        isLeftCollapsed = leftSidebarWidth <= leftCollapseThreshold
    }

    /// Atualiza a largura da barra direita durante o arraste.
    /// - Parameters:
    ///   - translation: Deslocamento horizontal do gesto.
    ///   - isEnded: Indica se o gesto terminou.
    private func handleRightResize(translation: CGFloat, isEnded: Bool) {
        if isEnded {
            rightDragStartWidth = rightSidebarWidth
        }

        let newWidth = max(0, rightDragStartWidth - translation)
        rightSidebarWidth = min(newWidth, 420)
        isRightCollapsed = rightSidebarWidth <= rightCollapseThreshold
    }
}
