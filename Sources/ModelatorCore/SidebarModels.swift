import Foundation

/// Lados possiveis para as barras laterais.
public enum SidebarSide: String, CaseIterable, Identifiable, Codable {
    /// Identificador unico para SwiftUI.
    public var id: String { rawValue }

    /// Barra lateral esquerda.
    case left

    /// Barra lateral direita.
    case right
}

/// Tipos de secao que podem existir nas barras laterais.
public enum SidebarSectionType: String, CaseIterable, Identifiable, Codable {
    /// Identificador unico para SwiftUI.
    public var id: String { rawValue }

    /// Secao de ambiente (luz, HDRI, sombras).
    case environment

    /// Secao de camadas (layers).
    case layers
}

/// Representa uma secao movel dentro de uma barra lateral.
public struct SidebarSection: Identifiable, Equatable, Codable {
    /// Identificador unico da secao.
    public let id: UUID

    /// Titulo exibido na UI da secao.
    public var title: String

    /// Tipo da secao (ambiente ou camadas).
    public var type: SidebarSectionType

    /// Define se a secao esta visivel ou nao.
    public var isVisible: Bool

    /// Inicializa uma secao com valores padrao.
    public init(title: String, type: SidebarSectionType, isVisible: Bool = true) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.isVisible = isVisible
    }
}

/// Define a organizacao das secoes em cada barra lateral.
public struct SidebarLayout: Codable, Equatable {
    /// Lista de secoes na barra esquerda (ordem de cima para baixo).
    public var leftSections: [SidebarSection]

    /// Lista de secoes na barra direita (ordem de cima para baixo).
    public var rightSections: [SidebarSection]

    /// Inicializa o layout com ambiente a esquerda e camadas a direita.
    public init() {
        self.leftSections = [SidebarSection(title: "Ambiente", type: .environment)]
        self.rightSections = [SidebarSection(title: "Camadas", type: .layers)]
    }

    /// Move uma secao dentro da mesma barra lateral.
    ///
    /// O `destinationIndex` segue a semantica de `onMove` do SwiftUI: e o
    /// indice de destino no referencial da lista *antes* da remocao.
    /// - Parameters:
    ///   - sourceIndex: Indice de origem na lista.
    ///   - destinationIndex: Indice de destino na lista original.
    ///   - side: Lado da barra lateral.
    public mutating func moveSection(sourceIndex: Int, destinationIndex: Int, side: SidebarSide) {
        switch side {
        case .left:
            moveWithinList(&leftSections, from: sourceIndex, to: destinationIndex)
        case .right:
            moveWithinList(&rightSections, from: sourceIndex, to: destinationIndex)
        }
    }

    /// Transfere uma secao de uma barra para outra.
    /// - Parameters:
    ///   - sourceIndex: Indice de origem no lado atual.
    ///   - destinationIndex: Indice de destino no outro lado.
    ///   - fromSide: Lado de origem.
    ///   - toSide: Lado de destino.
    public mutating func transferSection(sourceIndex: Int, destinationIndex: Int, fromSide: SidebarSide, toSide: SidebarSide) {
        switch (fromSide, toSide) {
        case (.left, .right):
            guard leftSections.indices.contains(sourceIndex) else { return }
            let item = leftSections.remove(at: sourceIndex)
            rightSections.insert(item, at: clamp(destinationIndex, upperBound: rightSections.count))
        case (.right, .left):
            guard rightSections.indices.contains(sourceIndex) else { return }
            let item = rightSections.remove(at: sourceIndex)
            leftSections.insert(item, at: clamp(destinationIndex, upperBound: leftSections.count))
        default:
            return
        }
    }

    /// Move um item dentro da mesma lista usando a semantica de `onMove`.
    /// - Parameters:
    ///   - list: Lista a ser reordenada (modificada no lugar).
    ///   - source: Indice de origem.
    ///   - destination: Indice de destino no referencial da lista original.
    private func moveWithinList(_ list: inout [SidebarSection], from source: Int, to destination: Int) {
        guard list.indices.contains(source) else { return }
        // Equivalente a `move(fromOffsets:toOffset:)` (SwiftUI) sem depender de SwiftUI.
        let target = clamp(destination, upperBound: list.count)
        let item = list.remove(at: source)
        list.insert(item, at: target > source ? target - 1 : target)
    }

    /// Limita um indice ao intervalo valido de insercao `[0, upperBound]`.
    /// - Parameters:
    ///   - index: Indice informado pelo chamador.
    ///   - upperBound: Maior posicao de insercao permitida.
    /// - Returns: Indice ajustado dentro do intervalo valido.
    private func clamp(_ index: Int, upperBound: Int) -> Int {
        min(max(0, index), upperBound)
    }
}
