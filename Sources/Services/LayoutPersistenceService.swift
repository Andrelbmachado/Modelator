import Foundation
import ModelatorCore

/// Responsavel por salvar e restaurar o layout das barras laterais.
struct LayoutPersistenceService {
    /// Chave usada no UserDefaults para salvar o layout.
    private let layoutKey: String = "modelator.sidebar.layout"

    /// Salva o layout atual em UserDefaults.
    /// - Parameter layout: Layout atual das barras.
    func save(layout: SidebarLayout) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(layout) {
            UserDefaults.standard.set(data, forKey: layoutKey)
        }
    }

    /// Carrega o layout salvo, se existir.
    /// - Returns: Layout salvo ou nil se nao houver dados.
    func load() -> SidebarLayout? {
        guard let data = UserDefaults.standard.data(forKey: layoutKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(SidebarLayout.self, from: data)
    }
}
