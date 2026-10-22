# Modelator 🧊

**Um "segundo Blender" pensado para agentes de IA: modelagem 3D nativa para Mac e iPad, com escaneamento LiDAR no iPhone.**

O Modelator quer ser um modelador 3D em que você e um agente de IA trabalham na mesma cena. Você modela com mouse, trackpad ou Apple Pencil. O agente faz o mesmo por uma API estruturada: cria objetos, aplica operações, vê um preview renderizado e corrige o próprio trabalho.

> ⚠️ **Estado atual: protótipo de interface (pré-alfa).** O repositório tem o esqueleto em SwiftUI mais um alvo `ModelatorCore` (lógica pura) testável via `swift test`. Ainda não há projeto Xcode do app gráfico (veja [Limitações conhecidas](#limitações-conhecidas)). Tudo marcado como **planejado** ainda não existe.

---

## ✨ Visão

| Plataforma | Papel |
|---|---|
| **macOS (Apple Silicon)** | Editor completo: modelagem, materiais, texturas, luz, camadas |
| **iPad (chip M)** | O mesmo editor, com toque e Apple Pencil |
| **iPhone com LiDAR (12 Pro ou mais novo)** | Escanear objetos e ambientes e mandar a malha para o Mac/iPad |
| **Agentes de IA** | Controlar a cena por um servidor MCP local |

Princípios:
- **Eixos no padrão Blender**: Z para cima, X para a direita, Y para frente/trás.
- **Backend 3D trocável**: começa em SceneKit/RealityKit e pode migrar para Metal sem quebrar a UI.
- **Cena serializável e operações reversíveis**: um pré-requisito para a IA modelar com segurança.

## 📦 O que existe hoje vs. o que está planejado

| Recurso | Estado | Onde |
|---|---|---|
| Entrada do app e roteamento por dispositivo (iPhone → LiDAR, iPad/Mac → editor) | ✅ Implementado | `Sources/App/` |
| Canvas 3D com cubo de teste e câmera orbital (SceneKit) | ✅ Implementado | `Sources/Engine3D/ModelatorSceneView.swift` |
| Barra superior com 3 modos: **Modelo cinza**, **Textura**, **Sombra** | 🟡 Parcial: troca material, tem chão de sombra e checker padrão, mas ainda não carrega texturas do disco | `TopModeBar.swift`, `ModelatorSceneView.swift` |
| Duas barras laterais (Ambiente à esquerda, Camadas à direita) | ✅ Implementado | `Sources/UI/` |
| Redimensionar barras arrastando a borda e minimizar ao arrastar até ≤ 60 pt | ✅ Implementado | `MainWorkspaceView.swift` |
| Reordenar seções e trocá-las de barra com o botão "Mover" | ✅ Implementado (arrastar de uma barra para a outra ainda não) | `SidebarView.swift`, `SidebarModels.swift` |
| Painel de Ambiente (luz e sombra) | ✅ Ligado ao `RenderSettings`: intensidade + 3 sliders de 0–360° que giram a sombra | `EnvironmentSectionView.swift` |
| Painel de Camadas | 🟡 Só visual: 3 camadas fixas de exemplo | `LayersSectionView.swift` |
| Persistência do layout das barras | ✅ Modelos `Codable`, salvos/carregados em `MainWorkspaceView` | `LayoutPersistenceService.swift` |
| iPhone: sessão AR com reconstrução de malha LiDAR | 🟡 Parcial: mostra a captura ao vivo, mas não salva nem exporta | `Sources/Lidar/IPhoneLidarView.swift` |
| iPhone: análise de fotos e vídeos | ⏳ Planejado (só placeholder) | `IPhoneLidarView.swift` |
| Eixos Z-up (padrão Blender) | ✅ Nó raiz rotacionado −90° em X, grade XY e eixos coloridos | `ModelatorSceneView.swift` |
| Projeto Xcode / targets macOS, iPadOS e iOS | 🟡 Parcial: `Package.swift` do `ModelatorCore` (lógica + testes); falta o projeto Xcode do app gráfico | `Package.swift` |
| Ferramentas de modelagem (primitivas, edição de malha, booleanas, extrusão) | ⏳ Planejado | — |
| Import/export (glTF, OBJ, USDZ) | ⏳ Planejado | — |
| Materiais, texturas e HDRI | ⏳ Planejado | — |
| Histórico de operações (undo/redo) | ⏳ Planejado | — |
| **Servidor MCP para agentes de IA** | ⏳ Planejado | — |

## 🗂️ Estrutura

```
Sources/
├── App/            Modelator3DApp (@main) e RootView (escolhe a UI por dispositivo)
├── Engine3D/       ModelatorSceneView + ModelatorSceneFactory (cena SceneKit e modos de render)
├── Lidar/          IPhoneLidarView (ARView com reconstrução de malha + placeholders de mídia)
├── ModelatorCore/  Lógica pura, independente de UI: RenderMode, RenderSettings, SidebarModels
├── Services/       LayoutPersistenceService (UserDefaults)
└── UI/             Workspace principal, barras laterais, seções, TopModeBar
Tests/
└── ModelatorCoreTests/   Testes do ModelatorCore (layout das barras, render settings)
Package.swift            Alvo SwiftPM ModelatorCore para `swift build`/`swift test` no CLI
```

## 🛠️ Como rodar (por enquanto)

**Testes da lógica (CLI):** com o toolchain do Xcode instalado, rode na raiz do repositório:

```sh
swift build
swift test
```

Isso compila e testa o alvo `ModelatorCore` (modelos e regras puras). É o que o CI executa.

**App gráfico (Xcode):** ainda não há `.xcodeproj`. Para experimentar a UI:

1. No Xcode 15 ou mais novo, crie um projeto **Multiplatform App** (SwiftUI) chamado `Modelator3D`.
2. Apague os arquivos gerados (`ContentView.swift` e o `App` padrão) e arraste a pasta `Sources/` para dentro do projeto.
3. Garanta que o módulo `ModelatorCore` esteja disponível (como pacote local via `Package.swift` ou adicionando os arquivos de `Sources/ModelatorCore/` ao target).
4. Escolha o destino **My Mac** ou um simulador de iPad.
5. Para o iPhone, adicione `NSCameraUsageDescription` ao Info.plist e rode num aparelho com LiDAR.

Criar o projeto Xcode de verdade é a primeira tarefa do [PLANO.md](PLANO.md).

## Limitações conhecidas

- **Ainda não há projeto Xcode do app gráfico**: existe apenas `Package.swift` com o alvo `ModelatorCore` (lógica pura), que compila e roda testes via `swift build`/`swift test`. O app SwiftUI completo (SceneKit/ARKit) depende da criação do projeto Xcode Multiplatform — primeira tarefa do [PLANO.md](PLANO.md).
- O modo **Textura** mostra um checker padrão gerado via Core Graphics, mas ainda não carrega imagens do disco.
- As abas **Fotos/Vídeos** do iPhone continuam placeholders.

Já corrigido nesta rodada: `ModelatorSceneFactory` usa `PlatformColor` (compila no iOS); `SidebarLayout`/`SidebarSection` agora são `Codable`; o layout é carregado/salvo em `MainWorkspaceView`; a direção da sombra vira orientação da luz via `simd` e o painel de Ambiente chama `updateShadowDirection`; `MacWorkspaceView`/`IPadWorkspaceView` são usadas pelo `RootView`; a barra minimizada volta à largura padrão.

## 🧭 Roteiro

O plano por fases, com tarefas e critérios de pronto, está em **[PLANO.md](PLANO.md)**. A especificação original da interface está em [Informacoes projeto.txt](Informacoes%20projeto.txt).

## Convenções do código

- SwiftUI como base da UI. Preferir `async/await` a Combine.
- Comentários em português em toda função e variável. Variáveis de UI documentam tamanho, cor e função.

---

<sub>README revisado em 22/10/2026 e conferido contra o código, após implementar itens das Fases 0 e 1. Itens ⏳ **planejado** ainda não existem no repositório.</sub>
