import Foundation
import simd

/// Configuracoes de renderizacao relacionadas a luz e sombra.
struct RenderSettings {
    /// Direcao da luz para sombra em eixo Blender (X, Y, Z).
    /// Usado para rotacionar sombra em 360 graus nos tres eixos.
    var shadowDirection: SIMD3<Float>

    /// Intensidade da sombra (0 = sem sombra, 1 = sombra forte).
    var shadowIntensity: Float

    /// Inicia com direcao padrao e intensidade media.
    init() {
        self.shadowDirection = SIMD3<Float>(0, 1, -1)
        self.shadowIntensity = 0.6
    }

    /// Atualiza a direcao da sombra com base em angulos em graus.
    /// - Parameters:
    ///   - xDegrees: Rotacao em graus no eixo X (horizontal).
    ///   - yDegrees: Rotacao em graus no eixo Y (frente/tras).
    ///   - zDegrees: Rotacao em graus no eixo Z (cima/baixo).
    mutating func updateShadowDirection(xDegrees: Float, yDegrees: Float, zDegrees: Float) {
        let xRadians = xDegrees * .pi / 180
        let yRadians = yDegrees * .pi / 180
        let zRadians = zDegrees * .pi / 180

        let xVector = SIMD3<Float>(cos(xRadians), 0, sin(xRadians))
        let yVector = SIMD3<Float>(0, cos(yRadians), sin(yRadians))
        let zVector = SIMD3<Float>(sin(zRadians), cos(zRadians), 0)

        self.shadowDirection = simd_normalize(xVector + yVector + zVector)
    }
}
