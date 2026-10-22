# PLANO — Modelator

Plano por fases para a retomada do desenvolvimento. Cada fase tem **tarefas pequenas** (de uma a algumas horas cada) e um **critério de pronto** que dá para verificar. Só comece uma fase quando o critério da anterior estiver cumprido.

Legenda: `[ ]` a fazer · `[x]` feito · 📄 arquivo afetado

---

## Fase 0 — Fazer compilar (pré-requisito)

O objetivo é sair de "pasta de arquivos Swift" para "app que abre".

- [ ] Criar o projeto Xcode Multiplatform `Modelator3D` com os targets macOS 14+, iPadOS 17+ e iOS 17+, apontando para `Sources/`. Bundle id reverse-DNS (por exemplo `com.andremachado.modelator3d`). _(Parcial: criado `Package.swift` com o alvo `ModelatorCore` — lógica pura — para `swift build`/`swift test` no CLI. O projeto Xcode do app gráfico ainda falta.)_
- [x] Trocar `NSColor` por uma cor multiplataforma em `ModelatorSceneFactory` (um typealias `PlatformColor` ou `CGColor`). 📄 `Engine3D/ModelatorSceneView.swift`
- [x] Tornar `SidebarSide`, `SidebarSectionType`, `SidebarSection` e `SidebarLayout` `Codable`. 📄 `ModelatorCore/SidebarModels.swift`
- [x] Carregar o layout no `onAppear` e salvar a cada mudança em `MainWorkspaceView`. 📄 `UI/MainWorkspaceView.swift`, `Services/LayoutPersistenceService.swift`
- [ ] Adicionar `NSCameraUsageDescription` ao Info.plist do iOS. _(Pendente: depende do projeto Xcode, que ainda não existe.)_
- [x] Remover `MacWorkspaceView` e `IPadWorkspaceView` ou passar a usá-las no `RootView`. _(Agora o `RootView` usa `MacWorkspaceView`/`IPadWorkspaceView` por plataforma.)_
- [x] Adicionar um target de testes com um teste para `SidebarLayout.moveSection` e outro para `transferSection`. 📄 `Tests/ModelatorCoreTests/`
- [x] Configurar CI no GitHub Actions rodando `swift build test` do `ModelatorCore`. 📄 `.github/workflows/ci.yml` _(o `xcodebuild build test` entra quando o projeto Xcode existir.)_

**Pronto quando:** o app abre no Mac e no simulador de iPad, o layout das barras sobrevive a um relaunch e o CI passa. _(Parcial: modelos, persistência, testes e CI prontos; falta o projeto Xcode do app gráfico para abrir no Mac/iPad.)_

## Fase 1 — Viewport e modos de visualização

- [x] **Z-up:** criar um nó raiz da cena rotacionado −90° em X, para que o conteúdo use Z para cima. A câmera padrão olha para a origem em (7, −7, 5), como no Blender.
- [x] Desenhar uma grade no chão (plano XY) e os eixos coloridos (X vermelho, Y verde, Z azul).
- [x] **Sombra:** adicionar um plano de chão que recebe sombra. Converter `shadowDirection` (vetor) em orientação da luz com uma matriz de "look" (`simd`) em vez de usar ângulos de Euler.
- [x] Ligar o painel de Ambiente ao `RenderSettings`: slider de intensidade e três sliders de 0 a 360° (X/Y/Z) chamando `updateShadowDirection`. 📄 `UI/EnvironmentSectionView.swift`
- [ ] **Textura:** carregar uma imagem do disco (Files ou drag-and-drop) e aplicá-la como `diffuse`. _(Parcial: o modo "Textura" já mostra um checker padrão gerado via Core Graphics quando não há textura; falta carregar imagem do disco.)_
- [x] Restaurar a barra minimizada com a largura padrão (260/300 pt). 📄 `UI/MainWorkspaceView.swift`

**Pronto quando:** os três modos ficam visualmente diferentes, a sombra gira com os sliders e o cubo aparece "em pé" sobre a grade XY. _(Implementado no código; falta verificação visual no app — depende do projeto Xcode.)_

## Fase 2 — Modelo de cena e camadas

A base para tudo o que vem depois, inclusive a IA.

- [ ] Definir `SceneDocument` (Codable): objetos com id, nome, transform, malha, material e camada.
- [ ] Criar uma camada de sincronização `SceneDocument` → `SCNScene`, para que o backend continue trocável.
- [ ] Criar um histórico de operações com o padrão Command (`apply`/`revert`) e ligar ao undo/redo do sistema (⌘Z / ⇧⌘Z, e o gesto de três dedos no iPad).
- [ ] Trocar as 3 camadas fixas por camadas reais: criar, renomear, mostrar/ocultar, travar e reordenar. 📄 `UI/LayersSectionView.swift`
- [ ] Seleção por clique ou toque com destaque visual. Inspector com posição, rotação e escala.
- [ ] Salvar e abrir `.modelator` (JSON + binários) como `FileDocument`.

**Pronto quando:** dá para criar 3 objetos em 2 camadas, desfazer e refazer tudo, salvar, fechar e reabrir o arquivo idêntico.

## Fase 3 — Modelagem

- [ ] Primitivas: cubo, esfera UV, cilindro, cone, plano e toro.
- [ ] Gizmos de mover, girar e escalar, com snapping opcional.
- [ ] Modos de edição de vértice, aresta e face (estrutura half-edge própria).
- [ ] Extrusão, inset, bevel e loop cut.
- [ ] Booleanas (união, diferença e interseção). Avaliar uma biblioteca, por exemplo Manifold via C++ interop.
- [ ] Import/export de OBJ e USDZ (via ModelIO), e depois glTF.
- [ ] Remesh e retopologia (por último, mais experimental).

**Pronto quando:** dá para modelar uma caneca simples (cilindro + inset + extrusão + booleana para a alça) e exportar em USDZ que abre no Quick Look.

## Fase 4 — Agent-friendly (MCP)

O diferencial do projeto. Depende das Fases 2 e 3.

- [ ] Expor uma API interna de operações idêntica à que a UI usa (todas viram comandos do histórico).
- [ ] Servidor MCP local (stdio ou HTTP em `localhost`), ativado só por opt-in nas Preferências. Ferramentas mínimas:
  - `scene_get` — devolve o `SceneDocument` em JSON
  - `object_create` — cria uma primitiva com transform
  - `object_transform` / `object_delete`
  - `mesh_operation` — extrude, bevel, boolean…
  - `render_preview` — PNG da viewport (ângulo e modo configuráveis)
  - `undo` / `redo`
  - `export` — OBJ, USDZ ou glTF
- [ ] Mostrar as ações do agente no histórico com um rótulo "🤖 agente", desfazíveis como qualquer outra.
- [ ] Documentar o uso com Claude Code e Claude Desktop (exemplo de `mcp.json`).

**Pronto quando:** um agente, sem intervenção humana, cria uma mesa (tampo + 4 pernas), renderiza o preview, corrige uma perna desalinhada e exporta em USDZ.

## Fase 5 — LiDAR no iPhone

- [ ] Juntar os `ARMeshAnchor` em uma malha única e exportar em OBJ/USDZ.
- [ ] Botões Iniciar/Parar/Salvar e um indicador de cobertura.
- [ ] Mandar para o Mac/iPad por AirDrop ou pela pasta do app no iCloud Drive. Abrir direto como objeto na cena.
- [ ] Avaliar Object Capture (fotogrametria) para objetos pequenos.
- [ ] Abas Fotos/Vídeos: definir o escopo de "análise" antes de implementar (hoje é só placeholder).

**Pronto quando:** escanear um cômodo no iPhone e abrir a malha no Mac em menos de 1 minuto.

---

## Decisões em aberto

- **Backend de render:** manter SceneKit (que está em modo de manutenção) ou migrar cedo para RealityKit/Metal? Recomendação: decidir antes da Fase 2, porque o `SceneDocument` isola essa escolha.
- **Estrutura de malha:** half-edge própria ou uma biblioteca externa?
- **Transporte do MCP:** stdio (mais simples para o Claude Code) ou HTTP local (permite vários clientes)?

<sub>Plano revisado em 21/10/2026 a partir do código real e de `Informacoes projeto.txt`. Itens das Fases 0 e 1 implementados em 22/10/2026 (verificação via `swift test` do `ModelatorCore`).</sub>
