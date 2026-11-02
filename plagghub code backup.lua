print (" SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID")
print (" SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID")
print (" SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID")
print (" SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID SKID")

--[[
    Plagg Hub — Rewritten / Beautified
    Original: https://github.com/jjorginhooondc/Plagg-hub-dw
    Source:   ???

    NOTE: This is an exploit script. Use at your own risk.
          Formatting and deobf — logic unchanged from original.
]]

--==============================================================
-- CONFIG
--==============================================================
local ITEM_LIST = {
    "Research Capsule", "Tapes", "Gumballs", "Chocolate", "Stopwatch",
    "Stamina Candy", "Stealth Candy", "Pop", "Speed Candy", "Protein Bar",
    "Instructions", "Extraction Speed Candy", "Skill Check Candy",
    "Jumper Cable", "Bandage", "Air Horn", "Jawbreaker", "Bonbon",
    "Christmas Cookie", "Dandy Easter Egg", "Dandy Corn", "Bottle o' Pop",
    "Health Kit", "Box o' Chocolates", "Eject Button", "Smoke Bomb",
    "Valve", "Ornament", "Basket", "Pumpkin", "Fake Capsule",
}

local ITEM_INTERNAL = {
    ["Research Capsule"]        = "ResearchCapsule",
    Tapes                       = "Tapes",
    Gumballs                    = "Gumballs",
    Chocolate                   = "Chocolate",
    Stopwatch                   = "Stopwatch",
    ["Stamina Candy"]           = "StaminaCandy",
    ["Stealth Candy"]           = "StealthCandy",
    Pop                         = "Pop",
    ["Speed Candy"]             = "SpeedCandy",
    ["Protein Bar"]             = "ProteinBar",
    Instructions                = "Instructions",
    ["Extraction Speed Candy"]  = "ExtractionSpeedCandy",
    ["Skill Check Candy"]       = "SkillCheckCandy",
    ["Jumper Cable"]            = "JumperCable",
    Bandage                     = "Bandage",
    ["Air Horn"]                = "AirHorn",
    Jawbreaker                  = "Jawbreaker",
    Bonbon                      = "BonBon",
    ["Christmas Cookie"]        = "ChristmasCookie",
    ["Dandy Easter Egg"]        = "DandyEasterEgg",
    ["Dandy Corn"]              = "DandCorn",
    ["Bottle o' Pop"]           = "BottleOPop",
    ["Health Kit"]              = "HealthKit",
    ["Box o' Chocolates"]       = "BoxOChocolates",
    ["Eject Button"]            = "EjectButton",
    ["Smoke Bomb"]              = "SmokeBomb",
    Valve                       = "Valve",
    Ornament                    = "Ornament",
    Basket                      = "Basket",
    Pumpkin                     = "Pumpkin",
    ["Fake Capsule"]            = "FakeCapsule",
}

local C_BLACK   = Color3.new(0, 0, 0)
local C_WHITE   = Color3.new(1, 1, 1)
local C_PURPLE  = Color3.fromRGB(170, 70, 255)
local C_MAGENTA = Color3.fromRGB(230, 50, 220)
local C_GRAY    = Color3.fromRGB(150, 150, 165)
local C_ORANGE  = Color3.fromRGB(255, 140, 0)
local C_RED     = Color3.fromRGB(255, 40, 40)
local C_GREEN   = Color3.fromRGB(60, 255, 120)
local C_YELLOW  = Color3.fromRGB(255, 230, 0)

local V_ZERO    = Vector3.new(0, 0, 0)
local V_OFFSET  = Vector3.new(0, 2.5, 0)

local CFG = {
    esItem = false, esTw = false, esGen = false, esPl = false,
    esTend = false, esHand = false, esPud = false,
    noTags = false, onlyItem = false,
    size = 14, hlMax = 250,
    itemBlacklist = {},

    elev = false,
    elevCond = { instant = false, everyone = false },

    tpNearOn = true, tpNear = 35,

    speed = false, ws = 50,
    tpw = false, tpv = 2,
    fly = false, fs = 30,
    spin = false, spinv = 20,

    rng = false, autoAbility = false,
    tpTool = false,

    noPop = false, noSplot = false,
    autoCal = false,
    fb = false, nofog = false,
    autoCapsule = false,
}

--==============================================================
-- SERVICES
--==============================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local StarterGui        = game:GetService("StarterGui")
local SoundService      = game:GetService("SoundService")
local ContentProvider   = game:GetService("ContentProvider")

if not game:IsLoaded() then game.Loaded:Wait() end

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local GENV = getgenv and getgenv() or {}
GENV.PlaggGen = (GENV.PlaggGen or 0) + 1
local GENERATION = GENV.PlaggGen

-- Cleanup previous run
for _, key in ipairs({
    "PlaggDandyBtn", "PlaggOpenBtn", "PlaggMainGui",
    "PlaggNotifyGui", "PlaggClickSound", "PlaggFluent",
    "PlaggWin", "PlaggTool",
}) do
    pcall(function()
        if GENV[key] then GENV[key]:Destroy() end
    end)
end
pcall(function() RunService:UnbindFromRenderStep("PlaggDandyWorld") end)

local connections = {}
GENV.PlaggConns = connections

local function track(c)
    connections[#connections + 1] = c
    return c
end
local function bind(sig, fn)
    return track(sig:Connect(fn))
end

--==============================================================
-- SCHEDULER / LOOP RUNNER
--==============================================================
local perfStats = {}
local function recordPerf(name, dt)
    local s = perfStats[name]
    if not s then s = { t = 0, n = 0, max = 0 }; perfStats[name] = s end
    s.t, s.n = s.t + dt, s.n + 1
    if dt > s.max then s.max = dt end
end

local notifyFn
local slowestModule
local lastFreezeWarn = 0
local luaMemAtLoad = collectgarbage("count") / 1024

local function memString()
    local lua = collectgarbage("count") / 1024
    local ok, gameMb = pcall(function()
        return game:GetService("Stats"):GetTotalMemoryUsageMb()
    end)
    local s = string.format("memory: Lua %.0f MB (%+.0f since load)", lua, lua - luaMemAtLoad)
    if ok and type(gameMb) == "number" then
        s = s .. string.format(" | game %.0f MB", gameMb)
    end
    return s
end

local function warnFreeze(dt)
    local now = tick()
    if dt > 1 and now - lastFreezeWarn > 15 then
        lastFreezeWarn = now
        local msg
        if slowestModule and now - slowestModule.t < 5 then
            msg = string.format("Freeze %.1fs. Slowest recent module: %s (%.0fms)",
                dt, slowestModule.name, slowestModule.dur * 1000)
        else
            msg = string.format("Freeze %.1fs. No script module was slow - likely the game or the device.", dt)
        end
        if notifyFn then pcall(notifyFn, msg .. "\n" .. memString()) end
    end
end

local loops = {}
local lastHeartbeat, lastRender, lastTick = tick(), tick(), tick()
local heartbeatAccum = 0

local function runLoopBody(l)
    local myToken = l.token
    while GENERATION == GENV.PlaggGen and l.token == myToken do
        local t0 = os.clock()
        l.beat, l.idle = tick(), 0
        local ok, err = pcall(l.fn, l)
        local dur = math.max(0, os.clock() - t0 - l.idle)
        recordPerf(l.name, dur)
        if dur > 0.03 then
            local now = tick()
            if not slowestModule or now - slowestModule.t > 3 or dur > slowestModule.dur then
                slowestModule = { name = l.name, dur = dur, t = now }
            end
        end
        if not ok then warn("[Plagg]", l.name, err) end
        l.beat = tick()
        task.wait(math.max(l.delay, dur * 6))
    end
end

local function startLoop(l)
    l.token = l.token + 1
    l.beat = tick()
    task.spawn(runLoopBody, l)
end

local function addLoop(delay, fn, name)
    local l = {
        delay = delay, fn = fn,
        name  = name or ("loop" .. #loops + 1),
        idle  = 0, beat = tick(), token = 0,
    }
    loops[#loops + 1] = l
    startLoop(l)
    return l
end

local function idleWait(l, seconds)
    local t0 = os.clock()
    task.wait(seconds)
    if l then
        l.idle = l.idle + (os.clock() - t0)
        l.beat = tick()
    end
end

local function tickAllLoops(now)
    for _, l in ipairs(loops) do
        if now - l.beat > math.max(10, l.delay * 3 + 5) then
            startLoop(l)
        end
    end
end

--==============================================================
-- CHARACTER / WORKSPACE HELPERS
--==============================================================
local cachedChar, cachedHRP, cachedHum
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    if char ~= cachedChar then
        cachedChar, cachedHRP, cachedHum = char, nil, nil
    end
    if not (cachedHRP and cachedHRP.Parent) then
        cachedHRP = char:FindFirstChild("HumanoidRootPart")
    end
    if not (cachedHum and cachedHum.Parent) then
        cachedHum = char:FindFirstChildOfClass("Humanoid")
    end
    return cachedHRP, cachedHum
end

local function readValue(parent, name)
    local v = parent and parent:FindFirstChild(name)
    if v and v:IsA("ValueBase") then return v.Value end
end

local function inGamePlayer()
    local root = workspace:FindFirstChild("InGamePlayers")
    return root and root:FindFirstChild(LocalPlayer.Name)
end

local function getPart(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst:FindFirstChild("HumanoidRootPart")
            or inst.PrimaryPart
            or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    return inst:FindFirstChildWhichIsA("BasePart", true)
end

local function getTorso(inst)
    return inst:FindFirstChild("UpperTorso")
        or inst:FindFirstChild("Torso")
        or inst:FindFirstChild("HumanoidRootPart")
        or getPart(inst)
end

local function getGeneratorPart(inst)
    local plate = inst:FindFirstChild("Top_Diamond_Plate", true)
    if plate and not plate:IsA("BasePart") then
        plate = plate:FindFirstChildWhichIsA("BasePart", true)
    end
    return plate or getPart(inst)
end

--==============================================================
-- WORKSPACE SNAPSHOT
--==============================================================
local snapshot = { mon = {}, gen = {}, item = {} }

addLoop(0.4, function()
    local mons, gens, items = {}, {}, {}
    local room = workspace:FindFirstChild("CurrentRoom")
    if room then
        for _, child in ipairs(room:GetChildren()) do
            local m = child:FindFirstChild("Monsters")
            if m then
                for _, v in ipairs(m:GetChildren()) do mons[#mons + 1] = v end
            end
            local g = child:FindFirstChild("Generators")
            if g then
                for _, v in ipairs(g:GetChildren()) do gens[#gens + 1] = v end
            end
            local it = child:FindFirstChild("Items")
            if it then
                for _, v in ipairs(it:GetChildren()) do items[#items + 1] = v end
            end
        end
    end
    snapshot.mon, snapshot.gen, snapshot.item = mons, gens, items
end, "snap")

--==============================================================
-- GENERATOR / ELEVATOR STATE
--==============================================================
local function isBeingExtracted(gen)
    local stats = gen:FindFirstChild("Stats")
    local a  = readValue(stats, "ActivePlayer")
    local a2 = readValue(stats, "ActivePlayer2")
    return (a ~= nil and a ~= "" and a ~= false)
        or (a2 ~= nil and a2 ~= "" and a2 ~= false)
end

local function generatorProgress(gen)
    local stats = gen:FindFirstChild("Stats")
    local cur  = readValue(stats, "CurrentAmount")
    local req  = readValue(stats, "RequiredAmount")
    if type(cur) == "number" and type(req) == "number" and req > 0 then
        return cur, req
    end
end

local function allGeneratorsDone()
    local info = workspace:FindFirstChild("Info")
    local done = readValue(info, "GeneratorsCompleted")
    local req  = readValue(info, "RequiredGenerators")
    if type(done) == "number" and type(req) == "number" and req > 0 then
        return done >= req
    end
    if #snapshot.gen == 0 then return false end
    for _, g in ipairs(snapshot.gen) do
        if readValue(g:FindFirstChild("Stats"), "Completed") ~= true then
            return false
        end
    end
    return true
end

local function elevatorPosition()
    local elevators = workspace:FindFirstChild("Elevators")
    local elevator  = elevators and elevators:FindFirstChild("Elevator")
    if not elevator then return end
    local base = elevator:FindFirstChild("Base")
    if base and base:IsA("BasePart") then
        return base.Position + Vector3.new(0, 4, 0)
    end
    return elevator:GetPivot().Position + Vector3.new(0, 4, 0)
end

--==============================================================
-- TARGET SCANNER (Tendril / Hand / Puddle)
--==============================================================
local targetSets = { tend = {}, hand = {}, pud = {} }

local function belongsToPlayer(inst)
    while inst and inst ~= workspace do
        if inst:IsA("Model") and Players:GetPlayerFromCharacter(inst) then
            return true
        end
        inst = inst.Parent
    end
    return false
end

local function classify(inst, nameOverride)
    local n = nameOverride or inst.Name:lower()
    if n:find("tendril", 1, true) or n:find("tentacle", 1, true) then
        return "tend"
    end
    if n:find("puddle", 1, true) then
        if n:find("ichor", 1, true) then return "pud" end
        local depth, p = 1, inst.Parent
        while p and p ~= workspace do
            if p.Name:lower():find("ichor", 1, true) then return "pud" end
            p = p.Parent
            depth = depth + 1
            if depth > 4 then break end
        end
        return nil
    end
    if n:find("hand", 1, true) and not n:find("handle", 1, true) then
        local depth, cur = 1, inst
        while cur and cur ~= workspace do
            if cur.Name:lower():find("blot", 1, true) then return "hand" end
            cur = cur.Parent
            depth = depth + 1
            if depth > 6 then break end
        end
    end
    return nil
end

local function isDrawable(inst)
    return inst:IsA("BasePart") or inst:IsA("Model")
        or inst:IsA("Decal") or inst:IsA("Texture")
end

local function insideHand(inst)
    local depth = 1
    while inst and inst ~= workspace do
        if classify(inst) == "hand" then return true end
        inst = inst.Parent
        depth = depth + 1
        if depth > 7 then break end
    end
    return false
end

local function registerTarget(inst)
    if not isDrawable(inst) then return end
    local n = inst.Name:lower()
    if not (n:find("tendril", 1, true) or n:find("tentacle", 1, true)
        or n:find("puddle", 1, true) or n:find("hand", 1, true)
        or n:find("ichor", 1, true) or n:find("blot", 1, true)) then
        return
    end
    local owner = (inst:IsA("Decal") or inst:IsA("Texture")) and inst.Parent or inst
    if not (owner and (owner:IsA("BasePart") or owner:IsA("Model"))) then return end
    local kind = classify(inst, n)
    if not kind then return end
    if inst == owner then
        local p = owner.Parent
        if p and (p:IsA("BasePart") or p:IsA("Model")) and classify(p) == kind then
            return
        end
    end
    if kind == "pud" and insideHand(owner) then return end
    if belongsToPlayer(owner) then return end
    targetSets[kind][owner] = true
end

local scanStarted = false
local queue, queueRunning = {}, false

local function enqueueScan(inst)
    if not isDrawable(inst) then return end
    if #queue > 8000 then return end
    queue[#queue + 1] = inst
    if queueRunning then return end
    queueRunning = true
    task.spawn(function()
        local count = 0
        while #queue > 0 do
            local batch = queue
            queue = {}
            for _, v in ipairs(batch) do
                if v.Parent then pcall(registerTarget, v) end
                count = count + 1
                if count % 100 == 0 then task.wait() end
            end
        end
        queueRunning = false
    end)
end

local function startFullScan()
    if scanStarted then return end
    scanStarted = true
    task.spawn(function()
        local n = 0
        for _, inst in ipairs(workspace:GetDescendants()) do
            registerTarget(inst)
            n = n + 1
            if n % 500 == 0 then task.wait() end
        end
    end)
    bind(workspace.DescendantAdded, enqueueScan)
end

addLoop(5, function(l)
    local n = 0
    for _, set in pairs(targetSets) do
        for inst in pairs(set) do
            if not (inst.Parent and inst:IsDescendantOf(workspace)) then
                set[inst] = nil
            end
            n = n + 1
            if n % 300 == 0 then idleWait(l, 0) end
        end
    end
end, "purge")

local function findTendrils()
    local out = {}
    local room = workspace:FindFirstChild("CurrentRoom")
    if not room then return out end
    for _, inst in ipairs(room:GetDescendants()) do
        local n = inst.Name:lower()
        if n:find("tendril", 1, true) or n:find("tentacle", 1, true) then
            local part = getPart(inst)
            if part and not belongsToPlayer(inst) then
                out[#out + 1] = part
            end
        end
    end
    return out
end

local function findHands()
    local out = {}
    for inst in pairs(targetSets.hand) do
        if inst.Parent and inst:IsDescendantOf(workspace) then
            local p = getPart(inst)
            if p then out[#out + 1] = p end
        end
    end
    local room = workspace:FindFirstChild("CurrentRoom")
    if room then
        for _, inst in ipairs(room:GetDescendants()) do
            local n = inst.Name:lower()
            if n:find("hand", 1, true) and classify(inst, n) == "hand" then
                local owner = (inst:IsA("Decal") or inst:IsA("Texture")) and inst.Parent or inst
                if owner and (owner:IsA("BasePart") or owner:IsA("Model"))
                    and not belongsToPlayer(owner) then
                    local p = getPart(owner)
                    if p then out[#out + 1] = p end
                end
            end
        end
    end
    return out
end

--==============================================================
-- ESP STORAGE
--==============================================================
local espStore = { item = {}, twist = {}, gen = {}, plr = {}, tend = {}, hand = {}, pud = {} }
local espAlive = {}
local highlightCount = 0
local sizeCache = {}

local function sizeFor(textSize, lines)
    local key = textSize * 100 + lines
    local s = sizeCache[key]
    if not s then
        s = UDim2.new(0, 400, 0, math.ceil(textSize * 1.25) * lines)
        sizeCache[key] = s
    end
    return s
end

local function makeBillboard(part, offset)
    local gui = Instance.new("BillboardGui")
    gui.Name, gui.AlwaysOnTop, gui.StudsOffset, gui.Adornee = "PlaggESP", true, offset, part
    gui.Parent = part
    local label = Instance.new("TextLabel")
    label.Name, label.Size = "T", UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled, label.TextWrapped = false, false
    label.Font = Enum.Font.FredokaOne
    label.TextStrokeColor3, label.TextStrokeTransparency = C_BLACK, 0
    label.Parent = gui
    return gui, label
end

local function drawESP(kind, key, part, text, textColor, strokeColor, outlineColor, fillColor, fillAlpha, skipHighlight)
    local bucket = espStore[kind]
    local entry  = bucket[key]
    if not entry then entry = {}; bucket[key] = entry end
    espAlive[entry] = true

    if not CFG.noTags or (CFG.onlyItem and kind == "item") then
        local offset = (kind == "plr" or kind == "twist") and V_ZERO or V_OFFSET
        if not entry.gui or not entry.gui.Parent or entry.part ~= part then
            if entry.gui then entry.gui:Destroy() end
            entry.gui, entry.lbl = makeBillboard(part, offset)
            entry.part = part
        end
        if entry.gui.StudsOffset ~= offset then entry.gui.StudsOffset = offset end
        local newSize = sizeFor(CFG.size, text:find("\n", 1, true) and 2 or 1)
        if entry.gui.Size ~= newSize then entry.gui.Size = newSize end
        if entry.lbl.Text ~= text then entry.lbl.Text = text end
        if entry.lbl.TextSize ~= CFG.size then entry.lbl.TextSize = CFG.size end
        local sc = strokeColor or C_BLACK
        if entry.lbl.TextStrokeColor3 ~= sc then entry.lbl.TextStrokeColor3 = sc end
        if entry.lbl.TextColor3 ~= textColor then entry.lbl.TextColor3 = textColor end
    elseif entry.gui then
        entry.gui:Destroy()
        entry.gui, entry.lbl, entry.part = nil, nil, nil
    end

    if skipHighlight then
        if entry.hl then entry.hl:Destroy(); entry.hl = nil end
    elseif highlightCount < CFG.hlMax then
        highlightCount = highlightCount + 1
        if not entry.hl or not entry.hl.Parent then
            local hl = Instance.new("Highlight")
            hl.Name, hl.OutlineTransparency = "PlaggHL", 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = key
            entry.hl = hl
        end
        local oc, fc, fa = outlineColor or textColor, fillColor or textColor, fillAlpha or 1
        if entry.hl.OutlineColor ~= oc then entry.hl.OutlineColor = oc end
        if entry.hl.FillColor    ~= fc then entry.hl.FillColor    = fc end
        if entry.hl.FillTransparency ~= fa then entry.hl.FillTransparency = fa end
    elseif entry.hl then
        entry.hl:Destroy()
        entry.hl = nil
    end
end

local function gcESP()
    for _, bucket in pairs(espStore) do
        for key, entry in pairs(bucket) do
            if not espAlive[entry] or not key.Parent then
                if entry.gui then pcall(function() entry.gui:Destroy() end) end
                if entry.hl  then pcall(function() entry.hl:Destroy()  end) end
                bucket[key] = nil
            end
        end
    end
    espAlive = {}
end

--==============================================================
-- ESP HELPERS
--==============================================================
local camPos = V_ZERO

local function radiusOf(inst, part)
    local ok, size = pcall(function()
        if inst:IsA("Model") then return inst:GetExtentsSize() end
        return part.Size
    end)
    if not ok or not size then size = part.Size end
    return math.max(math.max(size.X, size.Z) / 2, 2)
end

local function rankByDistance(set, limit, dedupe)
    local list = {}
    for inst in pairs(set) do
        if inst.Parent and inst:IsDescendantOf(workspace) then
            local part = getPart(inst)
            if part then
                list[#list + 1] = { inst, (part.Position - camPos).Magnitude, part }
            end
        else
            set[inst] = nil
        end
    end
    if #list > (dedupe and 120 or 400) then
        table.sort(list, function(a, b) return a[3] < b[3] end)
        for i = #list, (dedupe and 121 or 401), -1 do list[i] = nil end
    end
    if dedupe then
        local filtered = {}
        for _, e in ipairs(list) do
            local nested = false
            local depth, p = 0, e[1].Parent
            while p and p ~= workspace and depth < 12 do
                if set[p] then nested = true break end
                p, depth = p.Parent, depth + 1
            end
            if not nested then
                e[4] = radiusOf(e[1], e[2])
                filtered[#filtered + 1] = e
            end
        end
        table.sort(filtered, function(a, b) return a[3] < b[3] end)
        local picked = {}
        for _, e in ipairs(filtered) do
            local collided = false
            local px, pz = e[2].Position.X, e[2].Position.Z
            for _, prev in ipairs(picked) do
                local dx = px - prev[2].Position.X
                local dz = pz - prev[2].Position.Z
                local r  = e[4] + prev[4]
                if dx * dx + dz * dz <= r * r then collided = true break end
            end
            if not collided then
                picked[#picked + 1] = e
                if #picked >= limit then break end
            end
        end
        return picked
    end
    if #list <= limit then return list end
    table.sort(list, function(a, b) return a[3] < b[3] end)
    for i = limit + 1, #list do list[i] = nil end
    return list
end

local function filterOverlap(list, other)
    if #other == 0 then return list end
    local out = {}
    for _, e in ipairs(list) do
        local drop = false
        for _, o in ipairs(other) do
            if e[1] == o[1] or e[1]:IsDescendantOf(o[1]) or o[1]:IsDescendantOf(e[1]) then
                drop = true; break
            end
            if not o[4] then
                o[4] = radiusOf(o[1], o[2])
            end
            local dx = e[2].Position.X - o[2].Position.X
            local dz = e[2].Position.Z - o[2].Position.Z
            local r  = o[4]
            if dx * dx + dz * dz <= r * r then drop = true; break end
        end
        if not drop then out[#out + 1] = e end
    end
    return out
end

--==============================================================
-- ITEM INFO
--==============================================================
local itemCache = {}
local function itemInfo(inst)
    local now = tick()
    local info = itemCache[inst]
    if not info then
        local n = inst.Name:lower()
        info = { t = -100 }
        if n:find("capsule", 1, true) and not n:find("fake", 1, true) then
            info.cap, info.label = true, "Research Capsule"
        elseif n:find("pumpkin", 1, true) then
            info.pump, info.kind, info.label = true, "pumpkin", "Pumpkin"
        end
        itemCache[inst] = info
    end
    if not info.part or not info.part.Parent then
        info.part = getPart(inst)
    end
    if now - info.t >= 3 then
        info.t = now
        if not info.cap and not info.pump then
            local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
            local label = prompt and prompt.ObjectText
            if not (type(label) == "string" and label ~= "") then
                label = (tostring(inst.Name):gsub("(%l)(%u)", "%1 %2"))
            end
            info.label = label
            local ln = inst.Name:lower()
            if ln:find("extraction", 1, true) then info.color = C_PURPLE
            elseif ln:find("candy", 1, true) or ln:find("pop", 1, true)
                or ln:find("gumball", 1, true) or ln:find("chocolate", 1, true) then
                info.color = C_GREEN
            elseif ln:find("bandage", 1, true) or ln:find("horn", 1, true) then
                info.color = C_PURPLE
            elseif ln:find("kit", 1, true) then
                info.color = C_ORANGE
            else
                info.color = C_WHITE
            end
        end
    end
    return info, info.label
end

local function pumpkinColor()
    local t = (math.sin(tick() * 3) + 1) / 2
    return C_ORANGE:Lerp(C_YELLOW, t)
end

--==============================================================
-- ESP MAIN LOOP
--==============================================================
addLoop(0.08, function()
    if not CFG.esItem then return end
    local col = pumpkinColor()
    for _, entry in pairs(espStore.item) do
        if entry.anim == "pumpkin" then
            if entry.lbl then entry.lbl.TextColor3 = col end
            if entry.hl then
                entry.hl.OutlineColor, entry.hl.FillColor = col, col
            end
        end
    end
end, "pumpkin")

local espActive = false

addLoop(0.4, function(l)
    if not (CFG.esTw or CFG.esGen or CFG.esPl or CFG.esTend or CFG.esHand or CFG.esPud or CFG.esItem) then
        if espActive then espActive = false; gcESP() end
        return
    end
    espActive = true
    highlightCount = 0

    if CFG.esTend or CFG.esHand or CFG.esPud then
        local cam = workspace.CurrentCamera
        if cam then camPos = cam.CFrame.Position end
    end

    if CFG.esTw then
        for i, mon in ipairs(snapshot.mon) do
            local part = getTorso(mon)
            if part then
                drawESP("twist", mon, part, tostring(mon.Name):gsub("Monster", ""),
                    C_RED, C_WHITE, C_WHITE, C_RED, 0.5)
            end
            if i % 60 == 0 then idleWait(l, 0) end
        end
    end

    if CFG.esGen then
        for i, gen in ipairs(snapshot.gen) do
            if readValue(gen:FindFirstChild("Stats"), "Completed") ~= true then
                local part = getGeneratorPart(gen)
                if part then
                    local cur, req = generatorProgress(gen)
                    local label = isBeingExtracted(gen) and "Machine | Being Extracted" or "Machine"
                    if cur then
                        label = label .. "\n(" .. math.floor(cur) .. "/" .. math.floor(req) .. ")"
                    end
                    drawESP("gen", gen, part, label, C_GRAY, C_WHITE, C_WHITE, C_GRAY, 0.5)
                end
            end
            if i % 60 == 0 then idleWait(l, 0) end
        end
    end

    if CFG.esPl then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local part = getTorso(plr.Character)
                if hum and part and hum.Health > 0 then
                    drawESP("plr", plr.Character, part, plr.Name, C_GREEN, C_BLACK, C_WHITE)
                end
            end
        end
    end

    if CFG.esTend then
        for _, e in ipairs(rankByDistance(targetSets.tend, 20)) do
            drawESP("tend", e[1], e[2], "Sprout Tendril", C_PURPLE)
        end
    end

    local handList = {}
    if CFG.esHand or CFG.esPud then
        handList = rankByDistance(targetSets.hand, 20)
    end
    if CFG.esHand then
        for _, e in ipairs(handList) do
            drawESP("hand", e[1], e[2], "Blot's Hand", C_WHITE)
        end
    end
    if CFG.esPud then
        local pudList = filterOverlap(rankByDistance(targetSets.pud, 12, true), handList)
        for _, e in ipairs(pudList) do
            drawESP("pud", e[1], e[2], "Ichor Puddle", C_MAGENTA)
        end
    end

    if CFG.esItem then
        local pcol = pumpkinColor()
        for i, item in ipairs(snapshot.item) do
            local info, label = itemInfo(item)
            if info.part and not CFG.itemBlacklist[item.Name] and not CFG.itemBlacklist[label] then
                local col, stroke = info.color or C_WHITE, C_BLACK
                if info.cap then
                    col, stroke = C_GREEN, C_WHITE
                elseif info.kind == "pumpkin" then
                    col = pcol
                end
                drawESP("item", item, info.part, label, col, stroke, col, col, 1, false)
                local e = espStore.item[item]
                if e then
                    e.anim = (info.kind == "pumpkin") and "pumpkin" or nil
                end
            end
            if i % 60 == 0 then idleWait(l, 0) end
        end
    end

    gcESP()
end, "esp")

--==============================================================
-- TELEPORT
--==============================================================
local function teleportTo(pos)
    local hrp = getCharacter()
    if not (hrp and pos) then return false end
    if hrp.Anchored then hrp.Anchored = false end
    hrp.AssemblyLinearVelocity = V_ZERO
    hrp.CFrame = CFrame.new(pos)
    return true
end

local function tpGenerator()
    local hrp = getCharacter()
    if not hrp then return end
    startFullScan()
    local tendrils = findTendrils()
    local hands    = findHands()

    local blockedTend, blockedHand
    local bestGen, bestDist

    for attempt = 1, 2 do
        for _, gen in ipairs(snapshot.gen) do
            local done = readValue(gen:FindFirstChild("Stats"), "Completed") == true
            local skip = not done and (attempt == 2 or not isBeingExtracted(gen))
            if skip then
                local pos = gen:GetPivot().Position
                local blocked = false
                for _, p in ipairs(tendrils) do
                    if p.Parent and (p.Position - pos).Magnitude <= 10 then
                        blocked = true; blockedTend = true; break
                    end
                end
                if not blocked then
                    for _, p in ipairs(hands) do
                        if p.Parent and (p.Position - pos).Magnitude <= 10 then
                            blocked = true; blockedHand = true; break
                        end
                    end
                end
                if not blocked and CFG.tpNearOn then
                    blocked = false
                    for _, mon in ipairs(snapshot.mon) do
                        if mon.Parent then
                            local p = getPart(mon)
                            if p and (p.Position - pos).Magnitude <= CFG.tpNear then
                                blocked = true; break
                            end
                        end
                    end
                end
                if not blocked then
                    local dist = (pos - hrp.Position).Magnitude
                    if not bestDist or dist < bestDist then
                        bestGen, bestDist = gen, dist
                    end
                end
            end
        end
        if bestGen then break end
    end

    if bestGen then
        teleportTo(bestGen:GetPivot().Position + Vector3.new(0, 3, 0))
    elseif blockedTend and blockedHand then
        if notifyFn then pcall(notifyFn, "All machines have a Sprout Tendril or Blot's Hand within 10 studs or less") end
    elseif blockedHand then
        if notifyFn then pcall(notifyFn, "All machines have a Blot's Hand within 10 studs or less") end
    elseif blockedTend then
        if notifyFn then pcall(notifyFn, "All machines have a Sprout Tendril within 10 studs or less") end
    else
        if notifyFn then pcall(notifyFn, "All machines have a twisted less than " .. CFG.tpNear .. " studs away") end
    end
end

--==============================================================
-- TP TOOL
--==============================================================
local tpTool, savedCoreEnabled

local function createTpTool()
    local tool = Instance.new("Tool")
    tool.Name = "TP Tool"
    tool.ToolTip = "Click to teleport"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.Activated:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local mouse = LocalPlayer:GetMouse()
        local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LocalPlayer.Character }
        local hit = workspace:Raycast(ray.Origin, ray.Direction * 3000, params)
        if hit then
            teleportTo(hit.Position + Vector3.new(0, 3, 0))
        end
    end)
    return tool
end

local function ensureTpTool()
    if not tpTool or tpTool.Parent == nil then
        if tpTool then pcall(function() tpTool:Destroy() end) end
        tpTool = createTpTool()
        GENV.PlaggTool = tpTool
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp and tpTool.Parent ~= bp and tpTool.Parent ~= LocalPlayer.Character then
        tpTool.Parent = bp
    end
end

local function setTpTool(on)
    CFG.tpTool = on
    if on then
        if savedCoreEnabled == nil then
            local ok, v = pcall(function()
                return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
            end)
            if ok then savedCoreEnabled = v end
        end
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        end)
        ensureTpTool()
    else
        if tpTool then
            pcall(function() tpTool:Destroy() end)
            tpTool = nil
            GENV.PlaggTool = nil
        end
        if savedCoreEnabled ~= nil then
            local v = savedCoreEnabled
            savedCoreEnabled = nil
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, v)
            end)
        end
    end
end

addLoop(1, function()
    if not CFG.tpTool then return end
    local ok, enabled = pcall(function()
        return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
    end)
    if ok and not enabled then
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        end)
    end
    ensureTpTool()
end, "tptool")

--==============================================================
-- MOVEMENT
--==============================================================
local baseGravity = workspace.Gravity
if baseGravity < 1 then baseGravity = 196.2 end
local defaultWalkSpeed = 16

local function setFly(on)
    CFG.fly = on
    if on then
        if workspace.Gravity > 0 then baseGravity = workspace.Gravity end
        workspace.Gravity = 0
    else
        workspace.Gravity = baseGravity
    end
end

local function moveUpdate(dt)
    local hrp, hum = getCharacter()
    if not (hrp and hum) then return end
    if CFG.speed and hum.WalkSpeed ~= CFG.ws then
        hum.WalkSpeed = CFG.ws
    end
    local md = hum.MoveDirection
    if CFG.fly then
        if workspace.Gravity ~= 0 then workspace.Gravity = 0 end
        local cam = workspace.CurrentCamera
        local look = cam.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        local fwd  = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
        local right = Vector3.new(-fwd.Z, 0, fwd.X)
        local vel
        if md.Magnitude > 0.01 then
            vel = look * md:Dot(fwd) + cam.CFrame.RightVector * md:Dot(right)
        else
            local w = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
            local s = UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
            local d = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
            local a = UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0
            local up   = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0
            local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0
            local cf = cam.CFrame
            vel = look * (w - s) + cf.RightVector * (d - a) + Vector3.new(0, up - down, 0)
        end
        hrp.AssemblyLinearVelocity = V_ZERO
        hrp.AssemblyAngularVelocity = V_ZERO
        if vel.Magnitude > 0.01 and CFG.fs > 0 then
            hrp.CFrame = hrp.CFrame + vel.Unit * (CFG.fs * dt)
        end
    elseif CFG.tpw and CFG.tpv > 0 and md.Magnitude > 0.01 then
        hrp.CFrame = hrp.CFrame + md * (CFG.tpv * 10 * dt)
    end

    if CFG.spin and CFG.spinv > 0 then
        if hum.AutoRotate then hum.AutoRotate = false end
        local v = hrp.AssemblyLinearVelocity
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(CFG.spinv * 20) * dt, 0)
        hrp.AssemblyLinearVelocity = v
    elseif not hum.AutoRotate then
        hum.AutoRotate = true
    end
end

--==============================================================
-- HEARTBEAT / RENDER / TICK BINDINGS
--==============================================================
local hbConn, rsConn

local function setupHeartbeat()
    if hbConn then pcall(function() hbConn:Disconnect() end) end
    hbConn = bind(RunService.Heartbeat, function(dt)
        local now = tick()
        lastHeartbeat = now
        if dt > 0.4 then warnFreeze(dt) end
        if now - heartbeatAccum > 1 then
            heartbeatAccum = now
            tickAllLoops(now)
        end
        if CFG.speed or CFG.tpw or CFG.fly or CFG.spin then
            local t0 = os.clock()
            pcall(moveUpdate, dt)
            recordPerf("move", os.clock() - t0)
        end
    end)
end

local function setupRender()
    if rsConn then pcall(function() rsConn:Disconnect() end) end
    rsConn = bind(RunService.RenderStepped, function()
        local now = tick()
        lastRender = now
        if now - heartbeatAccum > 1 then
            heartbeatAccum = now
            tickAllLoops(now)
        end
    end)
end

local tickToken = 0
local function setupTickLoop()
    tickToken = tickToken + 1
    local my = tickToken
    lastTick = tick()
    task.spawn(function()
        while GENERATION == GENV.PlaggGen and my == tickToken do
            lastTick = tick()
            tickAllLoops(tick())
            task.wait(1)
        end
    end)
end

setupHeartbeat()
setupRender()
setupTickLoop()

--==============================================================
-- NOCLIP
--==============================================================
local noclipConn
local collideCache = setmetatable({}, { __mode = "k" })
local noclipParts = {}
local noclipAccum = 0

local function refreshNoclipParts()
    noclipParts = {}
    local char = LocalPlayer.Character
    if not char then return end
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("BasePart") then
            noclipParts[#noclipParts + 1] = inst
        end
    end
end

local function noclipApply()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("BasePart") then
            if collideCache[inst] == nil then collideCache[inst] = inst.CanCollide end
            inst.CanCollide = false
        end
    end
end

local function setNoclip(on)
    if on then
        noclipApply()
        noclipAccum = 0
        if not noclipConn then
            noclipConn = bind(RunService.Stepped, function()
                local now = tick()
                if now - noclipAccum > 0.5 then
                    noclipAccum = now
                    refreshNoclipParts()
                end
                for i = 1, #noclipParts do
                    local p = noclipParts[i]
                    if p.Parent then
                        if collideCache[p] == nil then collideCache[p] = p.CanCollide end
                        if p.CanCollide then p.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, inst in ipairs(char:GetDescendants()) do
                if inst:IsA("BasePart") then
                    local orig = collideCache[inst]
                    inst.CanCollide = orig ~= nil and orig or true
                end
            end
        end
        collideCache = setmetatable({}, { __mode = "k" })
        noclipParts = {}
    end
end

--==============================================================
-- SKILL CHECK HOOK
--==============================================================
GENV.scinstant = false
if not GENV.PlaggSCHook then
    task.spawn(function()
        pcall(function()
            local events = ReplicatedStorage:FindFirstChild("Events")
            local skillcheck = events and events:FindFirstChild("SkillcheckUpdate")
            if skillcheck and getcallbackvalue then
                local orig = getcallbackvalue(skillcheck, "OnClientInvoke")
                if orig then
                    local new
                    new = hookfunction(orig, function(...)
                        if GENV.scinstant then return "supercomplete" end
                        return new(...)
                    end)
                    GENV.PlaggSCHook = true
                end
            end
        end)
    end)
end

--==============================================================
-- RANGE HOOK
--==============================================================
local RANGE_CHARS = { Shelly = true, Sprout = true, Cosmo = true, Scraps = true, Glisten = true }
local rangeOrigin = setmetatable({}, { __mode = "k" })
local rangeActive = setmetatable({}, { __mode = "k" })
local lastRangeScan = 0

local function scanRangeHooks(restore, l)
    if not (getconnections and getupvalues) then return end
    local n = 0
    for _, conn in pairs(getconnections(RunService.RenderStepped)) do
        n = n + 1
        if n % 25 == 0 then idleWait(l, 0) end
        local fn = conn.Function
        if fn then
            local ok, ups = pcall(getupvalues, fn)
            if ok and ups then
                for _, v in pairs(ups) do
                    if typeof(v) == "table" and v.Name and RANGE_CHARS[v.Name] and v.PlayerRadius then
                        if restore then
                            if rangeOrigin[v] then
                                v.PlayerRadius = rangeOrigin[v]
                                rangeOrigin[v] = nil
                            end
                            rangeActive[v] = nil
                        else
                            if rangeOrigin[v] == nil then rangeOrigin[v] = v.PlayerRadius end
                            v.PlayerRadius = 500
                            rangeActive[v] = true
                        end
                    end
                end
            end
        end
    end
end

addLoop(1, function(l)
    if not CFG.rng then return end
    if tick() - lastRangeScan > 10 then
        lastRangeScan = tick()
        scanRangeHooks(false, l)
    end
    for t in pairs(rangeActive) do
        if t.PlayerRadius ~= 500 then t.PlayerRadius = 500 end
    end
end, "range")

--==============================================================
-- AUTO ABILITY
--==============================================================
local abilityBusy = false
addLoop(1, function()
    if not CFG.autoAbility or abilityBusy then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local events = ReplicatedStorage:FindFirstChild("Events")
    local evt = events and events:FindFirstChild("AbilityEvent")
    if char and hrp and evt then
        abilityBusy = true
        task.delay(3, function() abilityBusy = false end)
        task.spawn(function()
            pcall(function() evt:InvokeServer(char, hrp.CFrame, false) end)
            abilityBusy = false
        end)
    end
end, "ability")

--==============================================================
-- LIGHTING
--==============================================================
local function makePropMemo()
    local cache = setmetatable({}, { __mode = "k" })
    return function(obj, prop, val)
        local c = cache[obj]
        if not c then c = {}; cache[obj] = c end
        if c[prop] == nil then c[prop] = obj[prop] end
        if obj[prop] ~= val then obj[prop] = val end
    end, function()
        for obj, props in pairs(cache) do
            for prop, orig in pairs(props) do
                pcall(function() obj[prop] = orig end)
            end
        end
        cache = setmetatable({}, { __mode = "k" })
    end
end

local setFog, restoreFog = makePropMemo()
local setBright, restoreBright = makePropMemo()
local atmosphereList = {}
local lastAtmoScan = 0

local function lightingUpdate()
    if CFG.nofog then
        local now = tick()
        if now - lastAtmoScan > 2 then
            lastAtmoScan, atmosphereList = now, {}
            for _, inst in ipairs(Lighting:GetChildren()) do
                if inst:IsA("Atmosphere") then atmosphereList[#atmosphereList + 1] = inst end
            end
        end
        setFog(Lighting, "FogEnd", 1e9)
        setFog(Lighting, "FogStart", 1e9)
        for _, atm in ipairs(atmosphereList) do
            setFog(atm, "Density", 0)
            setFog(atm, "Offset", 0)
            setFog(atm, "Haze", 0)
            setFog(atm, "Glare", 0)
        end
    end
    if CFG.fb then
        setBright(Lighting, "Brightness", 2)
        setBright(Lighting, "ClockTime", 14)
        setBright(Lighting, "GlobalShadows", false)
        setBright(Lighting, "Ambient", C_WHITE)
        setBright(Lighting, "OutdoorAmbient", C_WHITE)
    end
end

local function rebindLighting()
    pcall(function() RunService:UnbindFromRenderStep("PlaggDandyWorld") end)
    lastAtmoScan = 0
    if CFG.nofog or CFG.fb then
        RunService:BindToRenderStep("PlaggDandyWorld", Enum.RenderPriority.Last.Value, lightingUpdate)
    end
end

--==============================================================
-- UI HELPERS
--==============================================================
local UI = {
    bg = Color3.fromRGB(14, 10, 36),
    bar = Color3.fromRGB(34, 18, 78),
    side = Color3.fromRGB(20, 11, 50),
    row = Color3.fromRGB(34, 18, 78),
    rowHi = Color3.fromRGB(64, 26, 116),
    accent = Color3.fromRGB(255, 60, 200),
    cyan = Color3.fromRGB(0, 220, 255),
    sub = Color3.fromRGB(180, 140, 255),
    off = Color3.fromRGB(78, 56, 130),
}

local function make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(inst, r)
    local u = Instance.new("UICorner")
    u.CornerRadius = UDim.new(0, r)
    u.Parent = inst
    return u
end

local function padding(inst, l, t, r, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft, p.PaddingTop = UDim.new(0, l), UDim.new(0, t)
    p.PaddingRight, p.PaddingBottom = UDim.new(0, r), UDim.new(0, b)
    p.Parent = inst
    return p
end

local function gradient(inst, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    g.Parent = inst
    return g
end

local function listLayout(inst, gap)
    local ll = Instance.new("UIListLayout")
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, gap or 0)
    ll.Parent = inst
    return ll
end

local function newGui(name, order)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = name, false, true
    gui.DisplayOrder, gui.ZIndexBehavior = order, Enum.ZIndexBehavior.Sibling
    local ok = pcall(function()
        gui.Parent = gethui and gethui() or PlayerGui
    end)
    if not ok or not gui.Parent then gui.Parent = PlayerGui end
    return gui
end

local function label(props, parent)
    local base = {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium, TextColor3 = C_WHITE,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }
    for k, v in pairs(props) do base[k] = v end
    return make("TextLabel", base, parent)
end

-- Click sound
local clickSound = Instance.new("Sound")
clickSound.Name = "PlaggClick"
clickSound.SoundId = "rbxassetid://8919449656"
clickSound.Volume = 0.6
clickSound.Parent = SoundService
GENV.PlaggClickSound = clickSound
task.spawn(function() pcall(function() ContentProvider:PreloadAsync({ clickSound }) end) end)

local function playClick()
    pcall(function()
        if clickSound and clickSound.Parent then
            clickSound.TimePosition = 0
            clickSound:Play()
        end
    end)
end

local function makeDraggable(gui, onClick)
    local dragging, moved, startPos, startPos2 = false, false, nil, nil
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            startPos = input.Position
            startPos2 = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onClick then pcall(onClick) end
                end
            end)
        end
    end)
    bind(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            if delta.Magnitude > 8 then moved = true end
            if moved then
                gui.Position = UDim2.new(
                    startPos2.X.Scale, startPos2.X.Offset + delta.X,
                    startPos2.Y.Scale, startPos2.Y.Offset + delta.Y
                )
            end
        end
    end)
end

--==============================================================
-- NOTIFICATIONS
--==============================================================
local notifyGui = newGui("PlaggNotify", 30)
GENV.PlaggNotifyGui = notifyGui
local notifyList = make("Frame", {
    Size = UDim2.fromOffset(250, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.fromOffset(12, 70),
    BackgroundTransparency = 1,
}, notifyGui)
listLayout(notifyList, 6)
local notifyCounter = 0

notifyFn = function(text)
    notifyCounter = notifyCounter + 1
    local existing = {}
    for _, c in ipairs(notifyList:GetChildren()) do
        if c:IsA("Frame") then existing[#existing + 1] = c end
    end
    table.sort(existing, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
    while #existing >= 4 do
        existing[1]:Destroy()
        table.remove(existing, 1)
    end
    local box = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = UI.bar,
        BorderSizePixel = 0,
        LayoutOrder = notifyCounter,
    }, notifyList)
    corner(box, 8)
    make("UIStroke", { Thickness = 1, Color = UI.accent, Transparency = 0.3 }, box)
    padding(box, 10, 6, 10, 8)
    listLayout(box, 2)
    label({
        Size = UDim2.new(1, 0, 0, 14),
        Text = "Plagg Hub", TextColor3 = UI.accent,
        Font = Enum.Font.FredokaOne, TextSize = 13, LayoutOrder = 1,
    }, box)
    label({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = tostring(text), TextWrapped = true, LayoutOrder = 2,
    }, box)
    task.delay(5, function()
        if box.Parent then box:Destroy() end
    end)
end

--==============================================================
-- TP GENERATOR FLOATING BUTTON
--==============================================================
local tpGenGui = newGui("PlaggTpGen", 22)
tpGenGui.Enabled = false
GENV.PlaggDandyBtn = tpGenGui

local tpGenBtn = make("TextButton", {
    Size = UDim2.fromOffset(132, 40),
    Position = UDim2.new(0.75, 0, 0.6, 0),
    BackgroundColor3 = UI.bar,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "TP Generator",
    Font = Enum.Font.FredokaOne,
    TextColor3 = C_WHITE,
    TextScaled = true,
    Active = true,
}, tpGenGui)
padding(tpGenBtn, 10, 7, 10, 7)
corner(tpGenBtn, 8)
gradient(
    make("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C_WHITE }, tpGenBtn),
    UI.cyan, UI.accent, 45
)
makeDraggable(tpGenBtn, function()
    playClick()
    tpGenerator()
end)

--==============================================================
-- MAIN UI
--==============================================================
local MAIN_SIZE = UDim2.fromOffset(480, 290)
local MAIN_BIG  = UDim2.new(0.94, 0, 0.92, 0)

local mainGui = newGui("PlaggHub", 20)
GENV.PlaggMainGui = mainGui

local mainFrame = make("Frame", {
    Name = "Main",
    Size = MAIN_SIZE,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundColor3 = UI.bg,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
}, mainGui)
corner(mainFrame, 10)
gradient(
    make("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C_WHITE }, mainFrame),
    UI.cyan, UI.accent, 45
)

local topBar = make("Frame", {
    Name = "Top",
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = UI.bar,
    BorderSizePixel = 0,
}, mainFrame)
gradient(label({
    Size = UDim2.new(0, 220, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    Text = "PLAGG HUB",
    Font = Enum.Font.FredokaOne,
    TextSize = 20,
}, topBar), UI.cyan, UI.accent, 0)
gradient(make("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.fromOffset(0, 36),
    BackgroundColor3 = C_WHITE,
    BorderSizePixel = 0,
}, mainFrame), UI.cyan, UI.accent, 0)

local windowButtons = make("Frame", {
    Size = UDim2.fromOffset(84, 36),
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 0),
    BackgroundTransparency = 1,
}, topBar)
local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
btnLayout.Padding = UDim.new(0, 8)
btnLayout.Parent = windowButtons

local function miniButton(color, text, order)
    local b = make("TextButton", {
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Text = text,
        TextColor3 = Color3.fromRGB(20, 10, 40),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        LayoutOrder = order,
    }, windowButtons)
    corner(b, 10)
    return b
end

local btnMax = miniButton(Color3.fromRGB(60, 220, 90), "+", 1)
local btnMin = miniButton(Color3.fromRGB(255, 200, 40), "-", 2)
local btnClose = miniButton(Color3.fromRGB(255, 70, 70), "x", 3)

-- Drag main window
local draggingMain, dragStart, frameStart = false, nil, nil
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStart = input.Position
        frameStart = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMain = false
            end
        end)
    end
end)
bind(UserInputService.InputChanged, function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + d.X,
            frameStart.Y.Scale, frameStart.Y.Offset + d.Y
        )
    end
end)

-- Sidebar
local sidebar = make("Frame", {
    Name = "Side",
    Position = UDim2.fromOffset(0, 38),
    Size = UDim2.new(0, 118, 1, -38),
    BackgroundColor3 = UI.side,
    BorderSizePixel = 0,
}, mainFrame)
local sidebarList = make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, sidebar)
listLayout(sidebarList, 0)
gradient(make("Frame", {
    Size = UDim2.new(0, 2, 1, -38),
    Position = UDim2.fromOffset(118, 38),
    BackgroundColor3 = C_WHITE,
    BorderSizePixel = 0,
}, mainFrame), UI.accent, UI.cyan, 90)

local content = make("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(122, 38),
    Size = UDim2.new(1, -122, 1, -38),
    BackgroundTransparency = 1,
}, mainFrame)

--==============================================================
-- PAGE BUILDER
--==============================================================
local function buildPage()
    local frame = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = UI.accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
    }, content)
    listLayout(frame, 6)
    padding(frame, 8, 8, 12, 8)
    local order = 0

    local page = { sf = frame }

    function page.section(text)
        order = order + 1
        local box = make("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            LayoutOrder = order,
        }, frame)
        label({
            Size = UDim2.new(1, 0, 1, -4),
            Text = string.upper(text),
            TextColor3 = UI.accent,
            Font = Enum.Font.FredokaOne,
            TextSize = 14,
        }, box)
        make("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = UI.rowHi,
            BorderSizePixel = 0,
        }, box)
    end

    function page.toggle(text, default, callback)
        order = order + 1
        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = UI.row,
            AutoButtonColor = false,
            Text = "",
            BorderSizePixel = 0,
            LayoutOrder = order,
        }, frame)
        corner(row, 6)
        label({
            Size = UDim2.new(1, -62, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            Text = text, TextWrapped = true,
        }, row)

        local track = make("Frame", {
            Size = UDim2.fromOffset(38, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            BackgroundColor3 = UI.off,
            BorderSizePixel = 0,
        }, row)
        corner(track, 10)
        local knob = make("Frame", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromOffset(2, 2),
            BackgroundColor3 = C_WHITE,
            BorderSizePixel = 0,
        }, track)
        corner(knob, 8)

        local state = default and true or false
        local function render()
            track.BackgroundColor3 = state and UI.accent or UI.off
            knob.Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
        end
        render()

        local function set(v, silent)
            state = v and true or false
            render()
            if not silent then pcall(callback, state) end
        end

        row.Activated:Connect(function()
            playClick()
            set(not state)
        end)

        return { Set = set }
    end

    function page.slider(text, min, max, default, step, callback)
        order = order + 1
        local box = make("Frame", {
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = UI.row,
            BorderSizePixel = 0,
            LayoutOrder = order,
        }, frame)
        corner(box, 6)
        label({ Size = UDim2.new(1, -80, 0, 22), Position = UDim2.fromOffset(10, 4), Text = text }, box)
        local valueLabel = label({
            Size = UDim2.fromOffset(64, 22),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 4),
            Text = "", TextColor3 = UI.sub,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, box)
        local track = make("Frame", {
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 0, 34),
            BackgroundColor3 = UI.off,
            BorderSizePixel = 0,
        }, box)
        corner(track, 3)
        local fill = make("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = UI.accent,
            BorderSizePixel = 0,
        }, track)
        corner(fill, 3)
        local knob = make("Frame", {
            Size = UDim2.fromOffset(14, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = C_WHITE,
            BorderSizePixel = 0,
        }, track)
        corner(knob, 7)
        local hit = make("TextButton", {
            Size = UDim2.new(1, -10, 0, 26),
            Position = UDim2.new(0, 5, 0, 22),
            BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false,
        }, box)

        local function fmt(v)
            if step < 1 then return string.format("%.1f", v) end
            return tostring(math.floor(v + 0.5))
        end
        local function draw(v)
            local a = math.clamp((v - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(a, 0, 1, 0)
            knob.Position = UDim2.new(a, 0, 0.5, 0)
            valueLabel.Text = fmt(v)
        end
        draw(default)

        local function updateFromX(x)
            local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local raw = min + a * (max - min)
            local snapped = min + math.floor((raw - min) / step + 0.5) * step
            local clamped = math.clamp(snapped, min, max)
            local rounded = tonumber(string.format("%.3f", clamped))
            if rounded ~= default then
                default = rounded
                draw(rounded)
                pcall(callback, rounded)
            end
        end

        local sliding = false
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                frame.ScrollingEnabled = false
                updateFromX(input.Position.X)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        sliding = false
                        frame.ScrollingEnabled = true
                    end
                end)
            end
        end)
        bind(UserInputService.InputChanged, function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(input.Position.X)
            end
        end)
    end

    function page.button(text, callback)
        order = order + 1
        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = UI.rowHi,
            AutoButtonColor = true,
            Text = text,
            TextColor3 = C_WHITE,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            BorderSizePixel = 0,
            LayoutOrder = order,
        }, frame)
        corner(btn, 6)
        make("UIStroke", { Thickness = 1, Color = UI.accent, Transparency = 0.5 }, btn)
        btn.Activated:Connect(function()
            playClick()
            pcall(callback)
        end)
    end

    function page.multi(text, options, callback)
        order = order + 1
        local box = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = UI.row,
            BorderSizePixel = 0,
            LayoutOrder = order,
        }, frame)
        corner(box, 6)
        listLayout(box, 0)

        local header = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = 1,
        }, box)
        label({ Size = UDim2.new(1, -100, 1, 0), Position = UDim2.fromOffset(10, 0), Text = text, TextWrapped = true }, header)
        local countLabel = label({
            Size = UDim2.fromOffset(90, 36),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -8, 0, 0),
            Text = "0  +", TextColor3 = UI.sub,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, header)

        local body = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible = false,
            LayoutOrder = 2,
        }, box)
        listLayout(body, 0)
        padding(body, 0, 0, 0, 6)

        local expanded = false
        local count = 0
        local selected = {}

        header.Activated:Connect(function()
            playClick()
            expanded = not expanded
            body.Visible = expanded
            countLabel.Text = tostring(count) .. (expanded and "  -" or "  +")
        end)

        for i, opt in ipairs(options) do
            local row = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                LayoutOrder = i,
            }, body)
            local chk = make("Frame", {
                Size = UDim2.fromOffset(14, 14),
                Position = UDim2.new(0, 12, 0.5, -7),
                BackgroundColor3 = UI.off,
                BorderSizePixel = 0,
            }, row)
            corner(chk, 3)
            label({ Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(34, 0), Text = opt }, row)

            row.Activated:Connect(function()
                playClick()
                if selected[opt] then
                    selected[opt] = nil
                    count = count - 1
                else
                    selected[opt] = true
                    count = count + 1
                end
                chk.BackgroundColor3 = selected[opt] and UI.accent or UI.off
                countLabel.Text = tostring(count) .. (expanded and "  -" or "  +")
                local list = {}
                for _, o in ipairs(options) do
                    if selected[o] then list[#list + 1] = o end
                end
                pcall(callback, list)
            end)
        end
    end

    return page
end

--==============================================================
-- TAB MANAGEMENT
--==============================================================
local tabs = {}

local function selectTab(index)
    for i, t in ipairs(tabs) do
        local on = i == index
        t.page.sf.Visible = on
        t.btn.BackgroundTransparency = on and 0.15 or 1
        t.btn.TextColor3 = on and C_WHITE or UI.sub
        t.bar.Visible = on
    end
end

local function addTab(name)
    local idx = #tabs + 1
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = UI.rowHi,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = name,
        TextColor3 = UI.sub,
        Font = Enum.Font.FredokaOne,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        LayoutOrder = idx,
    }, sidebarList)
    padding(btn, 14, 0, 4, 0)

    local bar = make("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.fromOffset(0, 6),
        BackgroundColor3 = UI.accent,
        BorderSizePixel = 0,
        Visible = false,
    }, btn)
    make("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = UI.rowHi,
        BorderSizePixel = 0,
    }, btn)

    local page = buildPage()
    tabs[idx] = { btn = btn, bar = bar, page = page }

    btn.Activated:Connect(function()
        playClick()
        selectTab(idx)
    end)

    return page
end

--==============================================================
-- BUILD TABS
--==============================================================
local tabPlayer  = addTab("Player")
local tabVisual  = addTab("Visuals")
local tabAuto    = addTab("Automations")
local tabTp      = addTab("Teleport")

-- Player
tabPlayer.section("Speed")
tabPlayer.toggle("Speed", false, function(on)
    CFG.speed = on
    local _, hum = getCharacter()
    if on then
        if hum and hum.WalkSpeed ~= CFG.ws then defaultWalkSpeed = hum.WalkSpeed end
    elseif hum then
        hum.WalkSpeed = defaultWalkSpeed > 0 and defaultWalkSpeed or 16
    end
end)
tabPlayer.slider("Walk Speed", 0, 100, 50, 1, function(v) CFG.ws = v end)
tabPlayer.toggle("TP Walk", false, function(on) CFG.tpw = on end)
tabPlayer.slider("TP Walk Speed", 0, 10, 2, 0.1, function(v) CFG.tpv = v end)

tabPlayer.section("Movement")
tabPlayer.toggle("Fly", false, setFly)
tabPlayer.slider("Fly Speed", 0, 50, 30, 1, function(v) CFG.fs = v end)
tabPlayer.toggle("Noclip", false, setNoclip)
tabPlayer.toggle("Spin", false, function(on)
    CFG.spin = on
    local _, hum = getCharacter()
    if hum then hum.AutoRotate = not on end
end)
tabPlayer.slider("Spin Speed", 0, 67, 20, 1, function(v) CFG.spinv = v end)

tabPlayer.section("Abilities")
tabPlayer.toggle("Infinite Ability Range", false, function(on)
    CFG.rng = on
    if on then lastRangeScan = 0 else pcall(scanRangeHooks, true) end
end)

-- Visuals
tabVisual.section("ESP")
tabVisual.toggle("ESP Items", false, function(on) CFG.esItem = on end)
tabVisual.toggle("ESP Twisteds", false, function(on) CFG.esTw = on end)
tabVisual.toggle("ESP Generators", false, function(on) CFG.esGen = on end)
tabVisual.toggle("ESP Players", false, function(on) CFG.esPl = on end)

tabVisual.section("Twisted Attacks")
tabVisual.toggle("Sprout Tendril ESP", false, function(on)
    CFG.esTend = on
    if on then startFullScan() end
end)
tabVisual.toggle("Blot Hands ESP", false, function(on)
    CFG.esHand = on
    if on then startFullScan() end
end)
tabVisual.toggle("Ichor Puddles ESP", false, function(on)
    CFG.esPud = on
    if on then startFullScan() end
end)

tabVisual.section("ESP Settings")
tabVisual.toggle("Remove ESP Nametags", false, function(on) CFG.noTags = on end)
tabVisual.toggle("Only Item Nametag On Disable ESP Nametag", false, function(on) CFG.onlyItem = on end)
tabVisual.slider("ESP Text Size", 8, 60, 14, 1, function(v) CFG.size = v end)
tabVisual.slider("Highlight Limit", 0, 250, 250, 5, function(v) CFG.hlMax = v end)

tabVisual.section("ESP Items Blacklist")
tabVisual.multi("Blacklisted Items", ITEM_LIST, function(list)
    CFG.itemBlacklist = {}
    for _, name in ipairs(list) do
        local internal = ITEM_INTERNAL[name]
        if internal then CFG.itemBlacklist[internal] = true end
    end
end)

tabVisual.section("Lighting")
tabVisual.toggle("Full Bright", false, function(on)
    CFG.fb = on
    if not on then restoreBright() end
    rebindLighting()
end)
tabVisual.toggle("No Fog", false, function(on)
    CFG.nofog = on
    if not on then restoreFog() end
    rebindLighting()
end)

tabVisual.section("Screen")
tabVisual.toggle("No Pop-ups (Vee)", false, function(on)
    CFG.noPop = on
    if on then
        for _, e in pairs(tbl9) do e.apply() end
        task.spawn(cleanupScreen)
    end
end)
tabVisual.toggle("Anti Splotches", false, function(on)
    CFG.noSplot = on
    if on then
        for _, e in pairs(tbl9) do e.apply() end
        task.spawn(cleanupScreen)
    end
end)

-- Automations
tabAuto.section("Abilities")
tabAuto.toggle("Auto Use Ability", false, function(on) CFG.autoAbility = on end)

tabAuto.section("Machines")
tabAuto.toggle("Auto Calibration", false, function(on)
    CFG.autoCal = on
    GENV.scinstant = on
end)
tabAuto.button("AutoBarnaby", function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/christmas-cookie/extensions/refs/heads/main/arcademachine",
        true
    ))()
end)

tabAuto.section("Elevator")
tabAuto.toggle("Auto TP Elevator", false, function(on) CFG.elev = on end)
tabAuto.multi("Auto TP Elevator Conditions", { "Instant", "Everyone At Elevator" }, function(list)
    CFG.elevCond = { instant = false, everyone = false }
    for _, v in ipairs(list) do
        if v == "Instant" then CFG.elevCond.instant = true
        elseif v == "Everyone At Elevator" then CFG.elevCond.everyone = true end
    end
end)

tabAuto.section("Items")
tabAuto.toggle("Auto Pick Up Research Capsules", false, function(on) CFG.autoCapsule = on end)

-- Teleport
tabTp.section("Generators")
tabTp.button("TP To Generator", tpGenerator)
tabTp.toggle("Skip Machines With Twisted Near", true, function(on) CFG.tpNearOn = on end)
tabTp.slider("Twisted Distance", 5, 150, 35, 1, function(v) CFG.tpNear = v end)
tabTp.toggle("TP Generator Button", false, function(on) tpGenGui.Enabled = on end)

tabTp.section("Tools")
tabTp.toggle("Teleport Tool", false, setTpTool)

selectTab(1)

--==============================================================
-- SCREEN CLEANUP (No Pop-ups / Anti Splotches)
--==============================================================
local screenTags = {}

local function classifyScreen(inst)
    if not (inst:IsA("GuiObject") or inst:IsA("ScreenGui")) then return end
    local n = inst.Name:lower()
    if n:find("splotch", 1, true) or n:find("stain", 1, true) or n:find("splat", 1, true)
        or (n:find("ichor", 1, true) and (n:find("screen", 1, true)
            or n:find("overlay", 1, true) or n:find("vignette", 1, true))) then
        return "splot"
    end
    if n:find("popup", 1, true) or n:find("pop_up", 1, true) or n:find("pop-up", 1, true)
        or n:find("pop up", 1, true) or n:find("advert", 1, true) or n == "ad" or n == "ads"
        or n:find("^ad[%d_]") or n:find("^vee") then
        return "pop"
    end
end

local function clickCloseButtons(inst)
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("GuiButton") then
            local n = d.Name:lower()
            local txt = d:IsA("TextButton") and d.Text:lower()
            if n:find("close", 1, true) or n == "x" or (txt or "") == "x" then
                -- Simulate click
                if getconnections then
                    for _, sig in ipairs({ "Activated", "MouseButton1Click", "TouchTap", "MouseButton1Down" }) do
                        local ok, conns = pcall(getconnections, d[sig])
                        if ok and conns and #conns > 0 then
                            for _, c in ipairs(conns) do
                                pcall(function() c:Fire() end)
                            end
                            break
                        end
                    end
                elseif firesignal then
                    pcall(firesignal, d.Activated)
                end
            end
        end
    end
end

local function nearestTopGui(inst)
    while inst and inst.Parent and inst.Parent ~= PlayerGui do
        inst = inst.Parent
    end
    return inst
end

local function isPlaggGui(inst)
    local top = nearestTopGui(inst)
    return top and top.Name:lower():find("plagg", 1, true) ~= nil
end

local function applyScreenHide(inst, tag)
    if screenTags[inst] then
        screenTags[inst].apply()
        return
    end
    local prop = inst:IsA("ScreenGui") and "Enabled" or "Visible"
    local function apply()
        if ((tag == "pop" and CFG.noPop) or (tag == "splot" and CFG.noSplot)) and inst[prop] then
            inst[prop] = false
        end
    end
    screenTags[inst] = { apply = apply }
    if tag == "pop" then pcall(clickCloseButtons, inst) end
    apply()
    inst:GetPropertyChangedSignal(prop):Connect(apply)
end

bind(PlayerGui.DescendantAdded, function(inst)
    if not (CFG.noPop or CFG.noSplot) then return end
    local tag = classifyScreen(inst)
    if tag and ((tag == "pop" and CFG.noPop) or (tag == "splot" and CFG.noSplot))
        and not isPlaggGui(inst) then
        pcall(applyScreenHide, inst, tag)
    end
end)

function cleanupScreen()
    local n = 0
    for _, inst in ipairs(PlayerGui:GetDescendants()) do
        local tag = classifyScreen(inst)
        if tag and ((tag == "pop" and CFG.noPop) or (tag == "splot" and CFG.noSplot))
            and not isPlaggGui(inst) then
            pcall(applyScreenHide, inst, tag)
        end
        n = n + 1
        if n % 400 == 0 then task.wait() end
    end
end

--==============================================================
-- AUTO ELEVATOR
--==============================================================
local PANIC_KEYS = { "panic", "countdown", "timer", "timeleft", "remaining" }
local panicRef
local lastPanicScan = 0
local elevatorDone = false
local panicMissing = false

local function parseTimer(s)
    if type(s) ~= "string" then return nil end
    local m, sec = s:match("(%d+):(%d%d)")
    if m then return tonumber(m) * 60 + tonumber(sec) end
    local plain = s:match("^%s*(%d+%.?%d*)%s*s?%s*$")
    return plain and tonumber(plain) or nil
end

local function findPanicTimer()
    local roots = {}
    local info = workspace:FindFirstChild("Info")
    if info then roots[#roots + 1] = info end
    local elevators = workspace:FindFirstChild("Elevators")
    if elevators then roots[#roots + 1] = elevators end

    for _, key in ipairs(PANIC_KEYS) do
        for _, root in ipairs(roots) do
            for k, v in pairs(root:GetAttributes()) do
                if type(v) == "number" and tostring(k):lower():find(key, 1, true) then
                    return { kind = "attr", inst = root, key = k }
                end
            end
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("ValueBase") and d.Name:lower():find(key, 1, true)
                    and type(d.Value) == "number" then
                    return { kind = "val", inst = d }
                end
            end
        end
    end

    for _, inst in ipairs(PlayerGui:GetDescendants()) do
        local visible = inst:IsA("TextLabel") and inst.Visible
        if visible and not isPlaggGui(inst) and parseTimer(inst.Text) then
            local depth, p, found = 1, inst, false
            while p and p ~= PlayerGui do
                for _, key in ipairs(PANIC_KEYS) do
                    if p.Name:lower():find(key, 1, true) then found = true end
                end
                p = p.Parent
                depth = depth + 1
                if depth > 4 then break end
            end
            if found then return { kind = "gui", inst = inst } end
        end
    end
end

local function readPanicTimer(ref)
    if not ref.inst.Parent then return nil end
    if ref.kind == "val" then
        local v = ref.inst.Value
        return type(v) == "number" and v or nil
    end
    if ref.kind == "attr" then
        local v = ref.inst:GetAttribute(ref.key)
        return type(v) == "number" and v or nil
    end
    return parseTimer(ref.inst.Text)
end

local function getPanicTimer()
    if panicRef then
        local ok, v = pcall(readPanicTimer, panicRef)
        if ok and v then return v end
        panicRef = nil
    end
    if tick() - lastPanicScan < 5 then return nil end
    lastPanicScan = tick()
    panicRef = findPanicTimer()
    if panicRef then
        local ok, v = pcall(readPanicTimer, panicRef)
        if ok then return v end
    end
    return nil
end

local function everyoneAtElevator()
    local pos = elevatorPosition()
    if not pos then return false end

    local elevators = workspace:FindFirstChild("Elevators")
    local elevator = elevators and elevators:FindFirstChild("Elevator")
    local base = elevator and elevator:FindFirstChild("Base")
    local radius = (base and base:IsA("BasePart")) and (math.max(base.Size.X, base.Size.Z) / 2 + 6) or 18

    local candidates = {}
    local root = workspace:FindFirstChild("InGamePlayers")
    if root then
        for _, c in ipairs(root:GetChildren()) do
            local plr = Players:FindFirstChild(c.Name)
            if plr then candidates[#candidates + 1] = plr end
        end
    else
        candidates = Players:GetPlayers()
    end

    local count = 0
    for _, plr in ipairs(candidates) do
        local char = plr.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            count = count + 1
            if (hrp.Position - pos).Magnitude > radius then return false end
        end
    end
    return count > 0
end

local function elevatorReady()
    if not (CFG.elevCond.instant or CFG.elevCond.everyone) then return true end
    if CFG.elevCond.instant then return true end
    if everyoneAtElevator() then return true end
    local t = getPanicTimer()
    if t then
        if t <= 5 then return true end
    elseif not panicMissing then
        panicMissing = true
        if notifyFn then pcall(notifyFn, "Panic timer not found. Waiting only for everyone at the elevator.") end
    end
    return false
end

addLoop(0.3, function()
    if not CFG.elev or not allGeneratorsDone() then
        elevatorDone = false
        panicMissing = false
        return
    end
    if elevatorDone then return end
    local hrp, hum = getCharacter()
    if not (hum and hum.Health > 0 and hrp and inGamePlayer()) then return end
    local pos = elevatorPosition()
    if not pos then return end
    if elevatorReady() and teleportTo(pos) then
        elevatorDone = true
    end
end, "elev")

--==============================================================
-- AUTO RESEARCH CAPSULES
--==============================================================
local capsuleSeen = setmetatable({}, { __mode = "k" })

addLoop(0.25, function(l)
    if not CFG.autoCapsule then return end
    if not getCharacter() then return end
    local room = workspace:FindFirstChild("CurrentRoom")
    if not room then return end
    for _, child in ipairs(room:GetChildren()) do
        local items = child:FindFirstChild("Items")
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if item.Parent and not capsuleSeen[item] then
                    local n = item.Name:lower()
                    if n:find("capsule", 1, true) and not n:find("fake", 1, true) then
                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            local part = getPart(item)
                            if part then
                                capsuleSeen[item] = true
                                local pos = part.Position + Vector3.new(0, 2, 0)
                                local hrp = getCharacter()
                                if hrp and pos then
                                    if hrp.Anchored then hrp.Anchored = false end
                                    hrp.AssemblyLinearVelocity = V_ZERO
                                    hrp.CFrame = CFrame.new(pos)
                                end
                                idleWait(l, 0.1)
                                if fireproximityprompt then
                                    pcall(fireproximityprompt, prompt)
                                end
                                idleWait(l, 0.1)
                            end
                        end
                    end
                end
            end
        end
    end
end, "autoCapsule")

--==============================================================
-- RESET / CLOSE BUTTON
--==============================================================
local maximized = false

btnMax.Activated:Connect(function()
    playClick()
    maximized = not maximized
    mainFrame.Size = maximized and MAIN_BIG or MAIN_SIZE
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
end)

btnMin.Activated:Connect(function()
    playClick()
    mainFrame.Visible = false
end)

btnClose.Activated:Connect(function()
    playClick()

    CFG.esItem, CFG.esTw, CFG.esGen, CFG.esPl = false, false, false, false
    CFG.esTend, CFG.esHand, CFG.esPud = false, false, false
    CFG.elev, CFG.autoAbility, CFG.autoCapsule, CFG.autoCal = false, false, false, false
    CFG.noPop, CFG.noSplot = false, false
    GENV.scinstant = false

    if CFG.fly then pcall(setFly, false) end
    if noclipConn then pcall(setNoclip, false) end
    if CFG.tpTool then pcall(setTpTool, false) end

    local _, hum = getCharacter()
    if hum then
        if CFG.speed then
            hum.WalkSpeed = defaultWalkSpeed > 0 and defaultWalkSpeed or 16
        end
        hum.AutoRotate = true
    end

    CFG.speed, CFG.tpw, CFG.spin = false, false, false
    pcall(restoreBright)
    pcall(restoreFog)
    pcall(function() RunService:UnbindFromRenderStep("PlaggDandyWorld") end)

    if CFG.rng then pcall(scanRangeHooks, true) end
    CFG.rng = false

    espAlive = {}
    pcall(gcESP)

    GENV.PlaggGen = (GENV.PlaggGen or 0) + 1
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, g in ipairs({ mainGui, tpGenGui, notifyGui, tpGenGui }) do
        pcall(function() g:Destroy() end)
    end
    task.delay(2, function() pcall(function() clickSound:Destroy() end) end)
end)

-- Info floating button
local openGui = newGui("PlaggOpen", 25)
GENV.PlaggOpenBtn = openGui
local infoBtn = make("TextButton", {
    Size = UDim2.new(0, 64, 0, 34),
    Position = UDim2.new(0, 12, 0.4, 0),
    BackgroundColor3 = UI.bar,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Info",
    Font = Enum.Font.FredokaOne,
    TextColor3 = C_WHITE,
    TextScaled = true,
    Active = true,
}, openGui)
padding(infoBtn, 6, 5, 6, 5)
corner(infoBtn, 8)
gradient(
    make("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C_WHITE }, infoBtn),
    UI.cyan, UI.accent, 45
)
makeDraggable(infoBtn, function()
    playClick()
    mainFrame.Visible = not mainFrame.Visible
end)

--==============================================================
-- BOOT MESSAGE
--==============================================================
if notifyFn then pcall(notifyFn, "Plagg Hub loaded") end
