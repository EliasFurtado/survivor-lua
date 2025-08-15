# Jogo Top-Down 2D com Lua/LÖVE2D

Um jogo top-down 2D feito em **Lua** usando o framework **LÖVE2D**, com geração procedural de mapas por **autômatos celulares**, sistema de **tiles**, **player**, **inimigos**, **câmera** e **HUD de experiência**.

---

## Features

- Sistema de **mapa por tiles** (PNG) com diferentes tipos de terreno: TERRA, GRAMA, AGUA.
- **Geração procedural** de mapas com **autômatos celulares**, criando cavernas e terrenos naturais.
- **Câmera** que segue o jogador.
- Player com movimentação, dash e troca de armas.
- Inimigos com IA básica, colisão e drop de experiência.
- Sistema de **tiros/balas** e **loot table**.
- HUD de experiência.

---

## Estrutura de Pastas

/assets
tileset.png # Tiles para o mapa
/entities
player.lua
enemy.lua
/core
mapa.lua # Mapa por tiles aleatório
mapaAutonomoCelulares.lua # Mapa gerado por autômatos celulares
camera.lua
collision.lua
/hud
hudExperience.lua
main.lua
core/game.lua

Rode com LÖVE:
 Tecla de task configurada para VCCode crtl+shift+b

Uso
Teclas de movimento: W, A, S, D

Dash: SPACE

Trocar arma: Q

Atirar: clique do mouse

Personalização do Mapa
Modifique o fillProb no MapaAC:new(width, height, fillProb, tileSize) para ajustar a densidade de TERRA/GRAMA.

Modifique os tiles no tileset.png para alterar a aparência do mapa.

Use mais ou menos passos de step() para suavizar o mapa.
