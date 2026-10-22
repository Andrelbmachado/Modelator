import SwiftUI

#if os(iOS)
import UIKit
#endif

/// Decide qual interface exibir conforme a plataforma e o tipo de dispositivo.
struct RootView: View {
    /// Corpo da interface raiz.
    var body: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            IPhoneLidarView()
        } else {
            IPadWorkspaceView()
        }
        #else
        MacWorkspaceView()
        #endif
    }
}
