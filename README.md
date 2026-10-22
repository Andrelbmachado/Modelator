# Modelator 🧊

**Um "segundo Blender" pensado para agentes de IA: modelagem 3D nativa para Mac e iPad, com escaneamento LiDAR no iPhone.**

O Modelator quer ser um modelador 3D em que você e um agente de IA trabalham na mesma cena. Você modela com mouse, trackpad ou Apple Pencil. O agente faz o mesmo por uma API estruturada: cria objetos, aplica operações, vê um preview renderizado e corrige o próprio trabalho.

> ⚠️ **Estado atual: protótipo de interface (pré-alfa).** O repositório tem só o esqueleto em SwiftUI. Ainda não há projeto Xcode e o código ainda não compila em todas as plataformas (veja [Limitações conhecidas](#limitações-conhecidas)). Tudo marcado como **planejado** ainda não existe.

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
| Barra superior com 3 modos: **Modelo cinza**, **Textura**, **Sombra** | 🟡 Parcial: troca material e liga/desliga sombra, mas não carrega texturas e não há chão para a sombra aparecer | `TopModeBar.swift`, `ModelatorSceneView.swift` |
| Duas barras laterais (Ambiente à esquerda, Camadas à direita) | ✅ Implementado | `Sources/UI/` |
| Redimensionar barras arrastando a borda e minimizar ao arrastar até ≤ 60 pt | ✅ Implementado | `MainWorkspaceView.swift` |
| Reordenar seções e trocá-las de barra com o botão "Mover" | ✅ Implementado (arrastar de uma barra para a outra ainda não) | `SidebarView.swift`, `SidebarModels.swift` |
| Painel de Ambiente (luz e sombra) | 🟡 Só visual: o slider não está ligado ao renderer | `EnvironmentSectionView.swift` |
| Painel de Camadas | 🟡 Só visual: 3 camadas fixas de exemplo | `LayersSectionView.swift` |
| Persistência do layout das barras | 🟡 Esboço: o serviço existe, mas não compila (os modelos não são `Codable`) e não é chamado | `LayoutPersistenceService.swift` |
| iPhone: sessão AR com reconstrução de malha LiDAR | 🟡 Parcial: mostra a captura ao vivo, mas não salva nem exporta | `Sources/Lidar/IPhoneLidarView.swift` |
| iPhone: análise de fotos e vídeos | ⏳ Planejado (só placeholder) | `IPhoneLidarView.swift` |
| Eixos Z-up (padrão Blender) | ⏳ Planejado (SceneKit usa Y-up) | — |
| Projeto Xcode / targets macOS, iPadOS e iOS | ⏳ Planejado | — |
| Ferramentas de modelagem (primitivas, edição de malha, booleanas, extrusão) | ⏳ Planejado | — |
| Import/export (glTF, OBJ, USDZ) | ⏳ Planejado | — |
| Materiais, texturas e HDRI | ⏳ Planejado | — |
| Histórico de operações (undo/redo) | ⏳ Planejado | — |
| **Servidor MCP para agentes de IA** | ⏳ Planejado | — |

## 🗂️ Estrutura

```
Sources/
├── App/        Modelator3DApp (@main) e RootView (escolhe a UI por dispositivo)
├── Engine3D/   ModelatorSceneView + ModelatorSceneFactory (cena SceneKit e modos de render)
├── Lidar/      IPhoneLidarView (ARView com reconstrução de malha + placeholders de mídia)
├── Models/     RenderMode, RenderSettings, SidebarModels
├── Services/   LayoutPersistenceService (UserDefaults)
└── UI/         Workspace principal, barras laterais, seções, TopModeBar
```

## 🛠️ Como rodar (por enquanto)

Ainda não há `.xcodeproj` nem `Package.swift`. Para experimentar:

1. No Xcode 15 ou mais novo, crie um projeto **Multiplatform App** (SwiftUI) chamado `Modelator3D`.
2. Apague os arquivos gerados (`ContentView.swift` e o `App` padrão) e arraste a pasta `Sources/` para dentro do projeto.
3. Escolha o destino **My Mac**. Hoje só o macOS tem chance de compilar, e mesmo assim só depois de corrigir a persistência (veja abaixo).
4. Para o iPhone, adicione `NSCameraUsageDescription` ao Info.plist e rode num aparelho com LiDAR.

Criar o projeto de verdade é a primeira tarefa do [PLANO.md](PLANO.md).

## Limitações conhecidas

- **Não compila no iOS/iPadOS**: `ModelatorSceneFactory` usa `NSColor`, que só existe no macOS.
- **Não compila em nenhuma plataforma**: `LayoutPersistenceService` codifica `SidebarLayout` com `JSONEncoder`, mas `SidebarLayout` e `SidebarSection` não são `Codable`.
- A direção da sombra (`RenderSettings.shadowDirection`) é um vetor, mas é aplicada como ângulos de Euler. Além disso, `updateShadowDirection` nunca é chamada.
- `MacWorkspaceView` e `IPadWorkspaceView` só embrulham `MainWorkspaceView` e não são usadas.
- Ao restaurar uma barra minimizada, ela volta com a largura de quando foi minimizada (≤ 60 pt), e não com a largura padrão.

## 🧭 Roteiro

O plano por fases, com tarefas e critérios de pronto, está em **[PLANO.md](PLANO.md)**. A especificação original da interface está em [Informacoes projeto.txt](Informacoes%20projeto.txt).

## Convenções do código

- SwiftUI como base da UI. Preferir `async/await` a Combine.
- Comentários em português em toda função e variável. Variáveis de UI documentam tamanho, cor e função.

---

<sub>README revisado em 21/10/2026 e conferido contra o código. Itens ⏳ **planejado** ainda não existem no repositório.</sub>
