import XCTest
@testable import ModelatorCore

/// Testes das operacoes de layout das barras laterais.
final class SidebarLayoutTests: XCTestCase {
    /// Monta um layout com tres secoes na esquerda e uma na direita.
    private func makeLayout() -> SidebarLayout {
        var layout = SidebarLayout()
        layout.leftSections = [
            SidebarSection(title: "A", type: .environment),
            SidebarSection(title: "B", type: .layers),
            SidebarSection(title: "C", type: .environment)
        ]
        layout.rightSections = [
            SidebarSection(title: "D", type: .layers)
        ]
        return layout
    }

    /// Mover uma secao para o fim reordena a lista corretamente (semantica onMove).
    func testMoveSectionReordersWithinSameSide() {
        var layout = makeLayout()

        // Move "A" (indice 0) para o fim. onMove usa destino no referencial original.
        layout.moveSection(sourceIndex: 0, destinationIndex: 3, side: .left)

        XCTAssertEqual(layout.leftSections.map(\.title), ["B", "C", "A"])
    }

    /// Mover uma secao para cima reordena corretamente.
    func testMoveSectionUpwards() {
        var layout = makeLayout()

        // Move "C" (indice 2) para o topo (destino 0).
        layout.moveSection(sourceIndex: 2, destinationIndex: 0, side: .left)

        XCTAssertEqual(layout.leftSections.map(\.title), ["C", "A", "B"])
    }

    /// Indice de origem invalido nao altera a lista nem causa crash.
    func testMoveSectionWithInvalidIndexIsNoOp() {
        var layout = makeLayout()

        layout.moveSection(sourceIndex: 99, destinationIndex: 0, side: .left)

        XCTAssertEqual(layout.leftSections.map(\.title), ["A", "B", "C"])
    }

    /// Transferir da esquerda para a direita remove da origem e insere no destino.
    func testTransferSectionLeftToRight() {
        var layout = makeLayout()

        layout.transferSection(sourceIndex: 1, destinationIndex: 0, fromSide: .left, toSide: .right)

        XCTAssertEqual(layout.leftSections.map(\.title), ["A", "C"])
        XCTAssertEqual(layout.rightSections.map(\.title), ["B", "D"])
    }

    /// Transferir da direita para a esquerda funciona no sentido inverso.
    func testTransferSectionRightToLeft() {
        var layout = makeLayout()

        layout.transferSection(sourceIndex: 0, destinationIndex: 3, fromSide: .right, toSide: .left)

        XCTAssertEqual(layout.rightSections.isEmpty, true)
        XCTAssertEqual(layout.leftSections.map(\.title), ["A", "B", "C", "D"])
    }

    /// Transferir com destino fora do intervalo e ajustado sem crash.
    func testTransferSectionClampsDestination() {
        var layout = makeLayout()

        layout.transferSection(sourceIndex: 0, destinationIndex: 999, fromSide: .left, toSide: .right)

        XCTAssertEqual(layout.rightSections.map(\.title), ["D", "A"])
    }

    /// Transferir com indice de origem invalido e um no-op seguro.
    func testTransferSectionWithInvalidSourceIsNoOp() {
        var layout = makeLayout()

        layout.transferSection(sourceIndex: 50, destinationIndex: 0, fromSide: .left, toSide: .right)

        XCTAssertEqual(layout.leftSections.count, 3)
        XCTAssertEqual(layout.rightSections.count, 1)
    }

    /// O layout sobrevive a uma ida e volta por JSON (Codable).
    func testLayoutCodableRoundTrip() throws {
        let original = makeLayout()

        let data = try JSONEncoder().encode(original)
        let restored = try JSONDecoder().decode(SidebarLayout.self, from: data)

        XCTAssertEqual(original, restored)
        XCTAssertEqual(restored.leftSections.map(\.title), ["A", "B", "C"])
        XCTAssertEqual(restored.rightSections.map(\.title), ["D"])
    }
}
