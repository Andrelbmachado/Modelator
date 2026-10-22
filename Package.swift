// swift-tools-version: 5.9
import PackageDescription

// Manifesto SwiftPM do Modelator.
//
// O app completo (SwiftUI + SceneKit + ARKit) continua sendo um projeto Xcode
// Multiplataforma, criado conforme o PLANO.md. Este pacote existe para tornar a
// *lógica pura* do app compilável e testável pela linha de comando com
// `swift build` e `swift test`, sem depender de um host de app gráfico.
//
// O alvo `ModelatorCore` reúne os modelos e as regras que não dependem de
// UIKit/AppKit/ARKit (modelos de cena, layout das barras, configurações de
// render). O alvo de testes exercita essas regras de forma determinística.
let package = Package(
    name: "Modelator",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "ModelatorCore", targets: ["ModelatorCore"])
    ],
    targets: [
        .target(
            name: "ModelatorCore",
            path: "Sources/ModelatorCore"
        ),
        .testTarget(
            name: "ModelatorCoreTests",
            dependencies: ["ModelatorCore"],
            path: "Tests/ModelatorCoreTests"
        )
    ]
)
