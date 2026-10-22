import SwiftUI
import ModelatorCore

/// Conteudo da secao de ambiente (luz, sombras, HDRI).
struct EnvironmentSectionView: View {
    /// Configuracoes de luz e sombra ligadas ao renderer.
    @Binding var settings: RenderSettings

    /// Altura de cada slider em pontos.
    private let sliderHeight: CGFloat = 28

    /// Cor do texto de titulo para contraste no painel.
    private let titleColor: Color = .primary

    /// Corpo da secao de ambiente.
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Luz e Sombra")
                .font(.subheadline)
                .foregroundColor(titleColor)

            // Intensidade da sombra (0 a 1).
            VStack(alignment: .leading, spacing: 2) {
                Text("Intensidade: \(Int(settings.shadowIntensity * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Slider(value: $settings.shadowIntensity, in: 0...1)
                    .frame(height: sliderHeight)
            }

            Text("Direcao da sombra 360°")
                .font(.caption)
                .foregroundColor(.secondary)

            // Tres sliders de 0 a 360 graus para os eixos X, Y e Z (Blender).
            angleSlider(label: "X (elevacao)", value: angleBinding(for: .x))
            angleSlider(label: "Y (inclinacao)", value: angleBinding(for: .y))
            angleSlider(label: "Z (azimute)", value: angleBinding(for: .z))
        }
    }

    /// Eixo da direcao da sombra ajustado por um slider.
    private enum ShadowAxis {
        case x, y, z
    }

    /// Monta um slider de angulo com rotulo e valor em graus.
    /// - Parameters:
    ///   - label: Texto descritivo do eixo.
    ///   - value: Binding do angulo em graus.
    /// - Returns: View do slider com rotulo.
    private func angleSlider(label: String, value: Binding<Float>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(label): \(Int(value.wrappedValue))°")
                .font(.caption2)
                .foregroundColor(.secondary)
            Slider(value: value, in: 0...360)
                .frame(height: sliderHeight)
        }
    }

    /// Cria um binding de angulo que escreve pela API `updateShadowDirection`,
    /// preservando os outros dois eixos.
    /// - Parameter axis: Eixo controlado pelo binding.
    /// - Returns: Binding em graus para o eixo informado.
    private func angleBinding(for axis: ShadowAxis) -> Binding<Float> {
        Binding(
            get: {
                switch axis {
                case .x: return settings.angleXDegrees
                case .y: return settings.angleYDegrees
                case .z: return settings.angleZDegrees
                }
            },
            set: { newValue in
                switch axis {
                case .x:
                    settings.updateShadowDirection(xDegrees: newValue, yDegrees: settings.angleYDegrees, zDegrees: settings.angleZDegrees)
                case .y:
                    settings.updateShadowDirection(xDegrees: settings.angleXDegrees, yDegrees: newValue, zDegrees: settings.angleZDegrees)
                case .z:
                    settings.updateShadowDirection(xDegrees: settings.angleXDegrees, yDegrees: settings.angleYDegrees, zDegrees: newValue)
                }
            }
        )
    }
}
