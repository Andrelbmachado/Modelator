import SwiftUI

/// Container para uma secao especifica dentro da sidebar.
struct SectionContainerView: View {
    /// Dados da secao exibida.
    let section: SidebarSection

    /// Callback para mover a secao para a outra barra.
    let onMoveToOtherSide: () -> Void

    /// Altura minima da secao em pontos.
    private let minSectionHeight: CGFloat = 180

    /// Cor de fundo da secao para destaque visual.
    private let sectionBackgroundColor: Color = Color.gray.opacity(0.08)

    /// Raio de borda da secao para visual suave.
    private let cornerRadius: CGFloat = 10

    /// Corpo da secao.
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.title)
                    .font(.headline)
                Spacer()
                Button("Mover") {
                    onMoveToOtherSide()
                }
                .buttonStyle(.bordered)
            }

            Group {
                switch section.type {
                case .environment:
                    EnvironmentSectionView()
                case .layers:
                    LayersSectionView()
                }
            }
        }
        .padding(12)
        .frame(minHeight: minSectionHeight)
        .background(sectionBackgroundColor)
        .cornerRadius(cornerRadius)
    }
}
