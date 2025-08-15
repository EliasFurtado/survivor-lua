--[[
ScreenManager.lua — Gerenciador genérico de telas (scenes) com títulos para LÖVE 2D

Recursos:
- Registrar telas com callbacks (load, enter, leave, update, draw, keypressed, etc.)
- Pilha de telas: push/pop/set para trocar cenas
- Títulos por tela + barra de título opcional com alinhamento e fonte customizável
- Transições simples (fade) entre telas
- Atalho F11 para alternar fullscreen; Alt+Enter também
- Compatível com forward de callbacks do LÖVE (update, draw, keypressed, mousepressed, wheelmoved, textinput, resize)

Uso básico (no seu main.lua):

local SM = require("ScreenManager")

function love.load()
  SM.configure({
    showTitle = true,
    titleAlign = "center", -- "left","center","right"
    titleHeight = 32,
    backgroundColor = {0.08, 0.08, 0.1, 1},
  })

  -- Exemplo de registro de telas
  SM.register("menu", {
    title = "Menu Principal",
    enter = function(self)
      self.msg = "Pressione Enter para jogar"
    end,
    update = function(self, dt) end,
    draw = function(self)
      local w, h = love.graphics.getDimensions()
      local font = love.graphics.getFont()
      local tw = font:getWidth(self.msg)
      love.graphics.print(self.msg, (w - tw)/2, h*0.5)
    end,
    keypressed = function(self, key)
      if key == "return" then
        SM.set("game", {level = 1})
      end
    end,
  })

  SM.register("game", {
    title = "Fase 1",
    enter = function(self, prev, params)
      self.t = 0
      self.level = params and params.level or 1
      SM.setTitle("game", "Fase "..tostring(self.level))
    end,
    update = function(self, dt) self.t = self.t + dt end,
    draw = function(self)
      local w, h = love.graphics.getDimensions()
      love.graphics.print("Jogando... t="..string.format("%.2f", self.t), 16, 56)
      love.graphics.print("ESC: voltar", 16, 80)
    end,
    keypressed = function(self, key)
      if key == "escape" then
        SM.set("menu")
      end
    end,
  })

  -- Começa no menu
  SM.set("menu")
end

function love.update(dt) SM.update(dt) end
function love.draw() SM.draw() end
function love.keypressed(k, sc, rep) SM.keypressed(k, sc, rep) end
function love.mousepressed(x, y, b, istouch, presses) SM.mousepressed(x, y, b, istouch, presses) end
function love.wheelmoved(x, y) SM.wheelmoved(x, y) end
function love.textinput(t) SM.textinput(t) end
function love.resize(w, h) SM.resize(w, h) end

--]]

local SM = {
  _screens = {},
  _stack = {},
  _transition = {
    active = false,
    t = 0,
    duration = 0.25,
    from = nil,
    to = nil,
    type = "fade", -- por enquanto só fade
  },
  _cfg = {
    showTitle = true,
    titleAlign = "center",
    titleHeight = 32,
    titlePadding = 10,
    titleFont = nil, -- use love.graphics.setNewFont() para trocar globalmente
    backgroundColor = {0.1, 0.1, 0.12, 1},
    titleTextColor = {1,1,1,1},
    titleBarColor = {0,0,0,0.25},
    useTitleShadow = true,
  }
}

local function deepcopy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k,v in pairs(t) do r[k] = deepcopy(v) end
  return r
end

-- Configurações globais
function SM.configure(opts)
  if not opts then return end
  for k,v in pairs(opts) do
    if SM._cfg[k] ~= nil then SM._cfg[k] = v end
  end
end

-- Registro de telas
function SM.register(name, screen)
  assert(type(name)=="string" and name ~= "", "Nome da tela inválido")
  assert(type(screen)=="table", "Tela deve ser uma tabela")
  if not screen.title then screen.title = name end
  SM._screens[name] = screen
  -- callback opcional de load por tela
  if screen.load and type(screen.load)=="function" then
    screen:load()
  end
end

-- Utilitários de pilha
function SM.peek()
  return SM._stack[#SM._stack]
end

function SM.currentName()
  local top = SM.peek()
  return top and top.__name or nil
end

function SM.current()
  return SM.peek()
end

function SM.get(name)
  return SM._screens[name]
end

function SM.setTitle(name, newTitle)
  local s = SM._screens[name]
  if s then s.title = newTitle end
  local top = SM.peek()
  if top and top.__name == name then top.title = newTitle end
end

-- Troca direta de tela (substitui topo da pilha)
function SM.set(name, params, transitionDuration)
  assert(SM._screens[name], ("Tela '%s' não registrada"):format(name))
  local to = deepcopy(SM._screens[name])
  to.__name = name

  local from = SM.peek()
  if from and from.leave then from:leave(name, params) end
  if to.enter then to:enter(from and from.__name or nil, params) end

  if transitionDuration and transitionDuration > 0 then
    SM._transition.active = true
    SM._transition.t = 0
    SM._transition.duration = transitionDuration
    SM._transition.from = from
    SM._transition.to = to
  else
    SM._stack[#SM._stack] = to
  end
  if not transitionDuration then -- default fade curto
    SM._transition.active = true
    SM._transition.t = 0
    SM._transition.duration = 0.18
    SM._transition.from = from
    SM._transition.to = to
  end
end

-- Empilha uma nova tela por cima da atual
function SM.push(name, params, transitionDuration)
  assert(SM._screens[name], ("Tela '%s' não registrada"):format(name))
  local to = deepcopy(SM._screens[name])
  to.__name = name
  local from = SM.peek()
  if to.enter then to:enter(from and from.__name or nil, params) end

  if transitionDuration and transitionDuration > 0 then
    SM._transition.active = true
    SM._transition.t = 0
    SM._transition.duration = transitionDuration
    SM._transition.from = from
    SM._transition.to = to
  else
    table.insert(SM._stack, to)
  end
  if not transitionDuration then
    SM._transition.active = true
    SM._transition.t = 0
    SM._transition.duration = 0.18
    SM._transition.from = from
    SM._transition.to = to
  end
end

-- Desempilha a tela atual e volta para a anterior
function SM.pop(params, transitionDuration)
  local from = SM.peek()
  assert(from, "Não há tela para remover")
  table.remove(SM._stack)
  local to = SM.peek()
  if from.leave then from:leave(to and to.__name or nil, params) end
  if transitionDuration and transitionDuration > 0 then
    SM._transition.active = true
    SM._transition.t = 0
    SM._transition.duration = transitionDuration
    SM._transition.from = from
    SM._transition.to = to
  else
    -- sem transição, nada extra
  end
  if not transitionDuration then
    SM._transition.active = true
    SM._transition.t = 0
    SM._transition.duration = 0.18
    SM._transition.from = from
    SM._transition.to = to
  end
end

-- Atualização da transição
local function updateTransition(dt)
  local tr = SM._transition
  if not tr.active then return end
  tr.t = tr.t + dt
  if tr.t >= tr.duration then
    -- finalizar transição
    if tr.to then
      if SM._stack[#SM._stack] and SM._stack[#SM._stack] ~= tr.to then
        -- set/replace topo
        SM._stack[#SM._stack] = tr.to
      elseif not SM._stack[#SM._stack] then
        table.insert(SM._stack, tr.to)
      end
    end
    tr.active = false
    tr.from = nil
    tr.to = nil
  end
end

-- Callback forwarding
function SM.update(dt)
  updateTransition(dt)
  local top = SM.peek()
  if top and top.update then top:update(dt) end
end

local function drawTitleBar(title)
  if not SM._cfg.showTitle then return end
  local w, h = love.graphics.getDimensions()
  local th = SM._cfg.titleHeight
  -- barra
  love.graphics.setColor(SM._cfg.titleBarColor)
  love.graphics.rectangle("fill", 0, 0, w, th)
  -- texto
  love.graphics.setColor(SM._cfg.titleTextColor)
  local font = SM._cfg.titleFont or love.graphics.getFont()
  love.graphics.push("all")
  love.graphics.setFont(font)
  local pad = SM._cfg.titlePadding
  local text = title or ""
  local tw = font:getWidth(text)
  local ty = (th - font:getHeight())/2
  local tx = pad
  if SM._cfg.titleAlign == "center" then
    tx = (w - tw)/2
  elseif SM._cfg.titleAlign == "right" then
    tx = w - tw - pad
  end
  if SM._cfg.useTitleShadow then
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.print(text, tx+1, ty+1)
    love.graphics.setColor(SM._cfg.titleTextColor)
  end
  love.graphics.print(text, tx, ty)
  love.graphics.pop()
end

local function applyBackground()
  local c = SM._cfg.backgroundColor
  love.graphics.clear(c[1], c[2], c[3], c[4] or 1)
end

function SM.draw()
  applyBackground()
  local tr = SM._transition
  local top = SM.peek()

  if tr.active and tr.type == "fade" then
    local a = math.min(1, tr.t / math.max(0.0001, tr.duration))
    -- desenha from com alpha 1-a, to com alpha a
    if tr.from and tr.from.draw then
      love.graphics.push("all")
      love.graphics.setColor(1,1,1,1)
      tr.from:draw()
      love.graphics.pop()
    end
    if tr.to and tr.to.draw then
      love.graphics.push("all")
      love.graphics.setColor(1,1,1,a)
      tr.to:draw()
      love.graphics.pop()
    end
    drawTitleBar((tr.to and tr.to.title) or (top and top.title) or "")
    return
  end

  if top and top.draw then top:draw() end
  drawTitleBar(top and top.title or "")
end

-- Entrada: F11 / Alt+Enter para fullscreen
local function toggleFullscreen()
  local fs = love.window.getFullscreen()
  love.window.setFullscreen(not fs)
end

function SM.keypressed(key, scancode, isrepeat)
  if key == "f11" or (key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt"))) then
    toggleFullscreen()
    return
  end
  local top = SM.peek()
  if top and top.keypressed then top:keypressed(key, scancode, isrepeat) end
end

function SM.mousepressed(x, y, button, istouch, presses)
  local top = SM.peek()
  if top and top.mousepressed then top:mousepressed(x, y, button, istouch, presses) end
end

function SM.mousereleased(x, y, button, istouch, presses)
  local top = SM.peek()
  if top and top.mousereleased then top:mousereleased(x, y, button, istouch, presses) end
end

function SM.wheelmoved(dx, dy)
  local top = SM.peek()
  if top and top.wheelmoved then top:wheelmoved(dx, dy) end
end

function SM.textinput(t)
  local top = SM.peek()
  if top and top.textinput then top:textinput(t) end
end

function SM.gamepadpressed(joy, button)
  local top = SM.peek()
  if top and top.gamepadpressed then top:gamepadpressed(joy, button) end
end

function SM.resize(w, h)
  local top = SM.peek()
  if top and top.resize then top:resize(w, h) end
end

return SM
