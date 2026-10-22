import XCTest
import simd
@testable import ModelatorCore

/// Testes das configuracoes de render (direcao e intensidade da sombra).
final class RenderSettingsTests: XCTestCase {
    /// A direcao inicial e um vetor unitario valido.
    func testInitialDirectionIsNormalized() {
        let settings = RenderSettings()
        let length = simd_length(settings.shadowDirection)
        XCTAssertEqual(length, 1, accuracy: 1e-4)
    }

    /// Atualizar a direcao mantem o vetor unitario.
    func testUpdateKeepsDirectionNormalized() {
        var settings = RenderSettings()
        settings.updateShadowDirection(xDegrees: 30, yDegrees: 10, zDegrees: 120)
        let length = simd_length(settings.shadowDirection)
        XCTAssertEqual(length, 1, accuracy: 1e-4)
    }

    /// Angulos sao normalizados para o intervalo [0, 360).
    func testAnglesAreWrappedIntoRange() {
        var settings = RenderSettings()
        settings.updateShadowDirection(xDegrees: 400, yDegrees: -30, zDegrees: 720)

        XCTAssertEqual(settings.angleXDegrees, 40, accuracy: 1e-3)
        XCTAssertEqual(settings.angleYDegrees, 330, accuracy: 1e-3)
        XCTAssertEqual(settings.angleZDegrees, 0, accuracy: 1e-3)
    }

    /// Angulos diferentes produzem direcoes diferentes.
    func testDifferentAnglesProduceDifferentDirections() {
        var a = RenderSettings()
        a.updateShadowDirection(xDegrees: 10, yDegrees: 0, zDegrees: 0)
        var b = RenderSettings()
        b.updateShadowDirection(xDegrees: 80, yDegrees: 0, zDegrees: 180)

        XCTAssertNotEqual(a.shadowDirection, b.shadowDirection)
    }

    /// As configuracoes sobrevivem a uma ida e volta por JSON (Codable).
    func testCodableRoundTrip() throws {
        var original = RenderSettings()
        original.updateShadowDirection(xDegrees: 55, yDegrees: 15, zDegrees: 200)
        original.shadowIntensity = 0.8

        let data = try JSONEncoder().encode(original)
        let restored = try JSONDecoder().decode(RenderSettings.self, from: data)

        XCTAssertEqual(original, restored)
        XCTAssertEqual(restored.shadowIntensity, 0.8, accuracy: 1e-4)
    }
}
