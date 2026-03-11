import Foundation

/// Lados possiveis para as barras laterais.
enum SidebarSide: String, CaseIterable, Identifiable {
    /// Identificador unico para SwiftUI.
    var id: String { rawValue }

    /// Barra lateral esquerda.
    case left

    /// Barra lateral direita.
    case right
}

/// Tipos de secao que podem existir nas barras laterais.
enum SidebarSectionType: String, CaseIterable, Identifiable {
    /// Identificador unico para SwiftUI.
    var id: String { rawValue }

    /// Secao de ambiente (luz, HDRI, sombras).
    case environment

    /// Secao de camadas (layers).
    case layers
}

/// Representa uma secao movel dentro de uma barra lateral.
struct SidebarSection: Identifiable, Equatable {
    /// Identificador unico da secao.
    let id: UUID

    /// Titulo exibido na UI da secao.
    var title: String

    /// Tipo da secao (ambiente ou camadas).
    var type: SidebarSectionType

    /// Define se a secao esta visivel ou nao.
    var isVisible: Bool

    /// Inicializa uma secao com valores padrao.
    init(title: String, type: SidebarSectionType, isVisible: Bool = true) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.isVisible = isVisible
    }
}

/// Define a organizacao das secoes em cada barra lateral.
struct SidebarLayout {
    /// Lista de secoes na barra esquerda (ordem de cima para baixo).
    var leftSections: [SidebarSection]

    /// Lista de secoes na barra direita (ordem de cima para baixo).
    var rightSections: [SidebarSection]

    /// Inicializa o layout com ambiente a esquerda e camadas a direita.
    init() {
        self.leftSections = [SidebarSection(title: "Ambiente", type: .environment)]
        self.rightSections = [SidebarSection(title: "Camadas", type: .layers)]
    }

    /// Move uma secao dentro da mesma barra lateral.
    /// - Parameters:
    ///   - sourceIndex: Indice de origem na lista.
    ///   - destinationIndex: Indice de destino na lista.
    ///   - side: Lado da barra lateral.
    mutating func moveSection(sourceIndex: Int, destinationIndex: Int, side: SidebarSide) {
        switch side {
        case .left:
            let item = leftSections.remove(at: sourceIndex)
            leftSections.insert(item, at: destinationIndex)
        case .right:
            let item = rightSections.remove(at: sourceIndex)
            rightSections.insert(item, at: destinationIndex)
        }
    }

    /// Transfere uma secao de uma barra para outra.
    /// - Parameters:
    ///   - sourceIndex: Indice de origem no lado atual.
    ///   - destinationIndex: Indice de destino no outro lado.
    ///   - fromSide: Lado de origem.
    ///   - toSide: Lado de destino.
    mutating func transferSection(sourceIndex: Int, destinationIndex: Int, fromSide: SidebarSide, toSide: SidebarSide) {
        switch (fromSide, toSide) {
        case (.left, .right):
            let item = leftSections.remove(at: sourceIndex)
            rightSections.insert(item, at: destinationIndex)
        case (.right, .left):
            let item = rightSections.remove(at: sourceIndex)
            leftSections.insert(item, at: destinationIndex)
        default:
            return
        }
    }
}
