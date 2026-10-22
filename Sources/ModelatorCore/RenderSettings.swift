import Foundation
import simd

/// Configuracoes de renderizacao relacionadas a luz e sombra.
///
/// Os eixos seguem o padrao Blender (Z para cima). A direcao da luz e guardada
/// como um vetor unitario que aponta *da luz para a cena*, pronto para ser
/// convertido em orientacao com `simd` no renderer.
public struct RenderSettings: Equatable, Codable {
    /// Direcao da luz (vetor unitario, da luz em direcao a origem) em eixo Blender.
    public private(set) var shadowDirection: SIMD3<Float>

    /// Intensidade da sombra (0 = sem sombra, 1 = sombra forte).
    public var shadowIntensity: Float

    /// Angulo atual no eixo X em graus (0-360), preservado para a UI.
    public private(set) var angleXDegrees: Float

    /// Angulo atual no eixo Y em graus (0-360), preservado para a UI.
    public private(set) var angleYDegrees: Float

    /// Angulo atual no eixo Z em graus (0-360), preservado para a UI.
    public private(set) var angleZDegrees: Float

    /// Inicia com uma luz vinda de cima e um pouco de lado, e intensidade media.
    public init() {
        self.shadowIntensity = 0.6
        self.angleXDegrees = 45
        self.angleYDegrees = 0
        self.angleZDegrees = 315
        self.shadowDirection = SIMD3<Float>(0, 0, -1)
        recomputeDirection()
    }

    /// Atualiza a direcao da sombra com base em angulos em graus.
    ///
    /// Interpretacao (Blender, Z-up):
    /// - `xDegrees`: elevacao da luz acima do plano XY.
    /// - `zDegrees`: azimute (rotacao em torno do eixo Z, no plano XY).
    /// - `yDegrees`: inclinacao adicional no plano YZ, para ajuste fino.
    ///
    /// - Parameters:
    ///   - xDegrees: Rotacao em graus no eixo X (elevacao).
    ///   - yDegrees: Rotacao em graus no eixo Y (inclinacao frente/tras).
    ///   - zDegrees: Rotacao em graus no eixo Z (azimute).
    public mutating func updateShadowDirection(xDegrees: Float, yDegrees: Float, zDegrees: Float) {
        angleXDegrees = normalizeDegrees(xDegrees)
        angleYDegrees = normalizeDegrees(yDegrees)
        angleZDegrees = normalizeDegrees(zDegrees)
        recomputeDirection()
    }

    /// Recalcula o vetor de direcao a partir dos angulos atuais.
    private mutating func recomputeDirection() {
        let elevation = angleXDegrees * .pi / 180
        let azimuth = angleZDegrees * .pi / 180
        let tilt = angleYDegrees * .pi / 180

        // Posicao da luz numa esfera (Z para cima): elevacao sobe no eixo Z,
        // azimute gira no plano XY. A direcao da luz aponta para a origem.
        let fromLight = SIMD3<Float>(
            cos(elevation) * cos(azimuth),
            cos(elevation) * sin(azimuth) + sin(tilt) * 0.25,
            sin(elevation)
        )

        let direction = -fromLight
        let length = simd_length(direction)
        // Evita vetor degenerado: cai para "de cima" se o resultado for nulo.
        shadowDirection = length > 1e-5 ? direction / length : SIMD3<Float>(0, 0, -1)
    }

    /// Normaliza um angulo para o intervalo `[0, 360)`.
    /// - Parameter degrees: Angulo em graus, possivelmente fora do intervalo.
    /// - Returns: Angulo equivalente dentro de `[0, 360)`.
    private func normalizeDegrees(_ degrees: Float) -> Float {
        let wrapped = degrees.truncatingRemainder(dividingBy: 360)
        return wrapped < 0 ? wrapped + 360 : wrapped
    }
}
