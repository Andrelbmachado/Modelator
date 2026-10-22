import Foundation

/// Define os modos de visualizacao do renderer.
public enum RenderMode: String, CaseIterable, Identifiable, Codable {
    /// Identificador unico para listas SwiftUI.
    public var id: String { rawValue }

    /// Modo com modelo cinza, sem textura e sem sombra.
    case grayModel

    /// Modo apenas com textura, sem sombras.
    case textureOnly

    /// Modo apenas com sombra, com direcao ajustavel.
    case shadowOnly

    /// Nome exibido na UI para cada modo.
    public var displayName: String {
        switch self {
        case .grayModel:
            return "Modelo cinza"
        case .textureOnly:
            return "Textura"
        case .shadowOnly:
            return "Sombra"
        }
    }
}
