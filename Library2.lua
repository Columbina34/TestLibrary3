-- Monium Library v2.1.4 — Simple Edition
local VERSION = "2.1.4"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Wait for player (executor may fire before fully loaded)
if not Players.LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end
repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

-- ═════════════════════════════════════════════════════════════
-- GUI parent resolution — tries each candidate and VERIFIES it
-- ═════════════════════════════════════════════════════════════
local function TryParent(parent)
    if not parent then return false end
    local test = Instance.new("ScreenGui")
    test.Name = "__monium_test"
    test.ResetOnSpawn = false
    local ok = pcall(function() test.Parent = parent end)
    if ok and test.Parent == parent then
        test:Destroy()
        return true
    end
    pcall(function() test:Destroy() end)
    return false
end

local CachedParent = nil
local function GuiParent()
    if CachedParent and CachedParent.Parent then return CachedParent end

    -- 1. Executor hidden UI (best for CoreGui protection)
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui and TryParent(hui) then
            CachedParent = hui
            return hui
        end
    end

    -- 2. Protect GUI if available (protects from game detection)
    if syn and syn.protect_gui then
        local ok, protected = pcall(function()
            local s = Instance.new("ScreenGui")
            s.Name = "__monium_prot"
            s.ResetOnSpawn = false
            syn.protect_gui(s)
            s.Parent = game:GetService("CoreGui")
            return s
        end)
        if ok and protected and protected.Parent then
            CachedParent = protected
            return protected
        end
    end

    -- 3. CoreGui (works in some high-level executors)
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg and TryParent(cg) then
        CachedParent = cg
        return cg
    end

    -- 4. PlayerGui (always works, always visible)
    if PlayerGui and TryParent(PlayerGui) then
        CachedParent = PlayerGui
        return PlayerGui
    end

    -- 5. Last resort
    warn("[Monium] Could not find GUI parent! Falling back to PlayerGui")
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ─────────────────────────────────────────────────────────────
-- Sanity check on load
-- ─────────────────────────────────────────────────────────────
do
    local test = Instance.new("ScreenGui")
    test.Name = "MoniumBootCheck"
    test.ResetOnSpawn = false
    local ok, err = pcall(function()
        test.Parent = GuiParent()
    end)
    if ok and test.Parent then
        print("[Monium] v" .. VERSION .. " — GUI parent OK: " .. test.Parent:GetFullName())
        test:Destroy()
    else
        warn("[Monium] v" .. VERSION .. " — GUI parent FAILED: " .. tostring(err))
        test:Destroy()
    end
end
