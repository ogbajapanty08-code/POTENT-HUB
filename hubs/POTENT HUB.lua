local PotentHub = {}
PotentHub.Toggles = {}

local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local guiService = game:GetService("GuiService")

local localPlayer = players.LocalPlayer
local hiddenUI = gethui()

-- Cleanup previous instance if reinjected
if hiddenUI:FindFirstChild("PotentHub") then
	hiddenUI.PotentHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PotentHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = hiddenUI

-- Theme colors
local COLOR_BG = Color3.fromRGB(18, 16, 26)
local COLOR_SIDEBAR = Color3.fromRGB(24, 21, 34)
local COLOR_ACCENT = Color3.fromRGB(151, 71, 255)
local COLOR_ACCENT_DARK = Color3.fromRGB(94, 46, 168)
local COLOR_TEXT = Color3.fromRGB(235, 230, 245)
local COLOR_SUBTEXT = Color3.fromRGB(160, 152, 180)
local COLOR_DANGER = Color3.fromRGB(200, 60, 70)
local COLOR_DANGER_DARK = Color3.fromRGB(140, 40, 50)

local function corner(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or COLOR_ACCENT
	s.Thickness = thickness or 1
	s.Transparency = 0.5
	s.Parent = inst
	return s
end

local function gradient(inst, c1, c2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rotation or 90
	g.Parent = inst
	return g
end

local function makeDraggable(dragHandle, target)
	local dragging, dragStart, startPos = false, nil, nil

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

----------------------------------------------------------------
-- Floating toggle button
----------------------------------------------------------------

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(52, 52)
toggleButton.Position = UDim2.new(0.5, -26, 0.85, 0)
toggleButton.BackgroundColor3 = COLOR_ACCENT
toggleButton.Text = "PH"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.AutoButtonColor = false
toggleButton.Active = true
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui
corner(toggleButton, 26)
gradient(toggleButton, COLOR_ACCENT, COLOR_ACCENT_DARK, 45)
stroke(toggleButton, Color3.fromRGB(255, 255, 255), 1)

makeDraggable(toggleButton, toggleButton)

----------------------------------------------------------------
-- Main window
----------------------------------------------------------------

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(560, 360)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
mainFrame.BackgroundColor3 = COLOR_BG
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui
corner(mainFrame, 12)
stroke(mainFrame, COLOR_ACCENT, 1)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(420, 280)
sizeConstraint.MaxSize = Vector2.new(900, 600)
sizeConstraint.Parent = mainFrame

-- Top bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = COLOR_SIDEBAR
topBar.ZIndex = 5
topBar.Parent = mainFrame
corner(topBar, 12)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 12)
topBarFix.Position = UDim2.new(0, 0, 1, -12)
topBarFix.BackgroundColor3 = COLOR_SIDEBAR
topBarFix.BorderSizePixel = 0
topBarFix.ZIndex = 5
topBarFix.Parent = topBar

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.fromOffset(16, 0)
title.BackgroundTransparency = 1
title.Text = "PotentHub +1 Speed Monkey Escape"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = COLOR_TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = topBar

-- FPS Counter (más a la izquierda)
local fpsCounter = Instance.new("TextLabel")
fpsCounter.Name = "FPSCounter"
fpsCounter.Size = UDim2.new(0, 100, 1, 0)
fpsCounter.Position = UDim2.new(1, -320, 0, 0)
fpsCounter.BackgroundTransparency = 1
fpsCounter.Text = "FPS: 0"
fpsCounter.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsCounter.TextSize = 12
fpsCounter.Font = Enum.Font.GothamBold
fpsCounter.TextXAlignment = Enum.TextXAlignment.Right
fpsCounter.ZIndex = 6
fpsCounter.Parent = topBar

local frameCount = 0
local lastTime = tick()

runService.Heartbeat:Connect(function()
	frameCount = frameCount + 1
	local currentTime = tick()
	if currentTime - lastTime >= 1 then
		local fps = math.floor(frameCount / (currentTime - lastTime))
		fpsCounter.Text = "FPS: " .. tostring(fps)
		if fps >= 60 then
			fpsCounter.TextColor3 = Color3.fromRGB(0, 255, 0)
		elseif fps >= 30 then
			fpsCounter.TextColor3 = Color3.fromRGB(255, 255, 0)
		else
			fpsCounter.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
		frameCount = 0
		lastTime = currentTime
	end
end)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(24, 24)
closeButton.Position = UDim2.new(1, -32, 0.5, -12)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 50, 75)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.TextColor3 = COLOR_TEXT
closeButton.AutoButtonColor = false
closeButton.Active = true
closeButton.ZIndex = 6
closeButton.Parent = topBar
corner(closeButton, 6)

makeDraggable(topBar, mainFrame)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 130, 1, -40)
sidebar.Position = UDim2.fromOffset(0, 40)
sidebar.BackgroundColor3 = COLOR_SIDEBAR
sidebar.ZIndex = 5
sidebar.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -16, 1, -60)
tabContainer.Position = UDim2.fromOffset(8, 8)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 5
tabContainer.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = tabContainer

local destroyButton = Instance.new("TextButton")
destroyButton.Name = "DestroyButton"
destroyButton.Size = UDim2.new(1, -16, 0, 34)
destroyButton.Position = UDim2.new(0, 8, 1, -42)
destroyButton.BackgroundColor3 = COLOR_DANGER
destroyButton.Text = "Destroy GUI"
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 13
destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.AutoButtonColor = false
destroyButton.Active = true
destroyButton.ZIndex = 20
destroyButton.Parent = sidebar
corner(destroyButton, 8)
gradient(destroyButton, COLOR_DANGER, COLOR_DANGER_DARK, 45)

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -130, 1, -40)
contentArea.Position = UDim2.fromOffset(130, 40)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 3
contentArea.Parent = mainFrame

local pages = {}
local tabButtons = {}
local activeTab = nil

local function selectTab(name)
	if activeTab == name then return end
	activeTab = name

	for tabName, page in pairs(pages) do
		page.Visible = (tabName == name)
	end

	for tabName, btn in pairs(tabButtons) do
		local isActive = tabName == name
		tweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and COLOR_ACCENT or COLOR_SIDEBAR,
			BackgroundTransparency = isActive and 0 or 1,
		}):Play()
		btn.TextLabel.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or COLOR_SUBTEXT
	end
end

function PotentHub:AddTab(name)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = name
	tabButton.Size = UDim2.new(1, 0, 0, 34)
	tabButton.BackgroundColor3 = COLOR_SIDEBAR
	tabButton.BackgroundTransparency = 1
	tabButton.Text = ""
	tabButton.AutoButtonColor = false
	tabButton.Active = true
	tabButton.ZIndex = 6
	tabButton.Parent = tabContainer
	corner(tabButton, 8)

	local label = Instance.new("TextLabel")
	label.Name = "TextLabel"
	label.Size = UDim2.new(1, -12, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.TextColor3 = COLOR_SUBTEXT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = tabButton

	local page = Instance.new("ScrollingFrame")
	page.Name = name .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = COLOR_ACCENT
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 3
	page.Parent = contentArea

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingTop = UDim.new(0, 12)
	pagePad.PaddingLeft = UDim.new(0, 12)
	pagePad.PaddingRight = UDim.new(0, 12)
	pagePad.Parent = page

	tabButton.MouseButton1Click:Connect(function()
		selectTab(name)
	end)

	pages[name] = page
	tabButtons[name] = tabButton

	if not activeTab then
		selectTab(name)
	end

	return page
end

----------------------------------------------------------------
-- AddToggle helper with subtitle support
----------------------------------------------------------------

function PotentHub:AddToggle(parent, labelText, subtitle, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -50, 0.6, 0)
	label.Position = UDim2.fromOffset(0, 2)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.TextColor3 = COLOR_TEXT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, -50, 0.4, 0)
	subLabel.Position = UDim2.fromOffset(0, 20)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = subtitle or ""
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextSize = 11
	subLabel.TextColor3 = COLOR_SUBTEXT
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	subLabel.Parent = frame

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.fromOffset(36, 20)
	toggle.Position = UDim2.new(1, -40, 0.5, -10)
	toggle.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.Parent = frame
	corner(toggle, 10)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.fromOffset(16, 16)
	indicator.Position = UDim2.fromOffset(2, 2)
	indicator.BackgroundColor3 = Color3.fromRGB(180, 170, 200)
	indicator.Parent = toggle
	corner(indicator, 8)

	local state = false
	local toggleData = {
		Value = state,
		Callback = callback,
	}

	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggleData.Value = state
		local targetPos = state and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)
		local color = state and COLOR_ACCENT or Color3.fromRGB(180, 170, 200)
		tweenService:Create(indicator, TweenInfo.new(0.12), {
			Position = targetPos,
			BackgroundColor3 = color,
		}):Play()
		if callback then
			pcall(callback, state)
		end
	end)

	PotentHub.Toggles[labelText] = toggleData
	return toggleData
end

----------------------------------------------------------------
-- Open/close logic
----------------------------------------------------------------

local guiOpen = false

local function setOpen(state)
	guiOpen = state
	if state then
		mainFrame.Visible = true
		mainFrame.Size = UDim2.fromOffset(560, 0)
		tweenService:Create(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(560, 360)
		}):Play()
	else
		local tween = tweenService:Create(mainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(560, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			mainFrame.Visible = false
		end)
	end
end

toggleButton.MouseButton1Click:Connect(function()
	setOpen(not guiOpen)
end)

closeButton.MouseButton1Click:Connect(function()
	setOpen(false)
end)

----------------------------------------------------------------
-- Disable all + Destroy GUI
----------------------------------------------------------------

function PotentHub:DisableAll()
	for _, toggleData in pairs(PotentHub.Toggles) do
		if toggleData.Value then
			toggleData.Value = false
		end
		if typeof(toggleData.Callback) == "function" then
			pcall(toggleData.Callback, false)
		end
	end
end

local destroyed = false

destroyButton.MouseButton1Down:Connect(function()
	if destroyed then return end
	destroyed = true

	destroyButton.Active = false
	toggleButton.Active = false
	closeButton.Active = false

	pcall(function()
		PotentHub:DisableAll()
	end)

	if PotentHub.OnDestroy then
		pcall(PotentHub.OnDestroy)
	end

	screenGui:Destroy()

	if getgenv().PotentHub == PotentHub then
		getgenv().PotentHub = nil
	end

	table.clear(PotentHub)
end)

----------------------------------------------------------------
-- Create tabs
----------------------------------------------------------------

local world1 = PotentHub:AddTab("WORLD 1")
local world2 = PotentHub:AddTab("WORLD 2")
local world3 = PotentHub:AddTab("WORLD 3")
local world4 = PotentHub:AddTab("WORLD 4")
local world5 = PotentHub:AddTab("WORLD 5")
local adminAbuse = PotentHub:AddTab("ADMIN ABUSE")

----------------------------------------------------------------
-- Shared functions
----------------------------------------------------------------

local function getShards()
	local sunkenShards = workspace:FindFirstChild("SunkenShards")
	if not sunkenShards then return {} end
	
	local shards = {}
	for i = 1, 9 do
		local shard = sunkenShards:FindFirstChild("Shard" .. i)
		if shard then
			table.insert(shards, shard)
		end
	end
	return shards
end

local function getShardPosition(shard)
	if shard:IsA("BasePart") then
		return shard.Position
	elseif shard:IsA("Model") then
		local primary = shard.PrimaryPart or shard:FindFirstChild("HumanoidRootPart") or shard:FindFirstChildWhichIsA("BasePart")
		if primary then
			return primary.Position
		end
	end
	return nil
end

----------------------------------------------------------------
-- WORLD 1 options
----------------------------------------------------------------

-- AUTO TELEPORT WORLD 1
local autoTeleportActive1 = false
local autoTeleportConnection1 = nil
local TARGET_POSITION_1 = Vector3.new(-9458.78, 391.95, -254.83)

local function startAutoTeleport1()
	if autoTeleportConnection1 then
		autoTeleportConnection1:Disconnect()
		autoTeleportConnection1 = nil
	end
	local time = 0
	autoTeleportConnection1 = runService.Heartbeat:Connect(function(deltaTime)
		local character = localPlayer.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid then return end
		time = time + deltaTime * 20
		local bounceOffset = math.sin(time) * 3
		rootPart.CFrame = CFrame.new(TARGET_POSITION_1 + Vector3.new(0, bounceOffset, 0))
		humanoid.Sit = false
		humanoid.AutoRotate = false
	end)
end

local function stopAutoTeleport1()
	if autoTeleportConnection1 then
		autoTeleportConnection1:Disconnect()
		autoTeleportConnection1 = nil
	end
end

PotentHub:AddToggle(world1, "AUTO TELEPORT WORLD 1", "", function(state)
	autoTeleportActive1 = state
	if state then
		startAutoTeleport1()
	else
		stopAutoTeleport1()
	end
end)

-- AUTO COLLECT SHARDS WORLD 1
local shardCollectActive1 = false
local shardCollectTask1 = nil
local shardIndex1 = 1

local function teleportToShard1()
	local shards = getShards()
	if #shards == 0 then return end
	if shardIndex1 > #shards then shardIndex1 = 1 end
	local targetShard = shards[shardIndex1]
	local targetPos = getShardPosition(targetShard)
	if targetPos then
		local character = localPlayer.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
			end
		end
	end
	shardIndex1 = shardIndex1 + 1
end

local function startShardCollect1()
	if shardCollectTask1 then
		shardCollectTask1:Disconnect()
		shardCollectTask1 = nil
	end
	local shards = getShards()
	if #shards == 0 then return end
	shardIndex1 = 1
	teleportToShard1()
	shardCollectTask1 = runService.Heartbeat:Connect(function()
		if not shardCollectActive1 then return end
		teleportToShard1()
	end)
end

local function stopShardCollect1()
	if shardCollectTask1 then
		shardCollectTask1:Disconnect()
		shardCollectTask1 = nil
	end
	shardIndex1 = 1
end

PotentHub:AddToggle(world1, "AUTO COLLECT SHARDS", "", function(state)
	shardCollectActive1 = state
	if state then
		startShardCollect1()
	else
		stopShardCollect1()
	end
end)

----------------------------------------------------------------
-- WORLD 2 options
----------------------------------------------------------------

local autoTeleportActive2 = false
local autoTeleportConnection2 = nil
local TARGET_POSITION_2 = Vector3.new(-3605.27, 157.59, -9378.28)

local function startAutoTeleport2()
	if autoTeleportConnection2 then
		autoTeleportConnection2:Disconnect()
		autoTeleportConnection2 = nil
	end
	local time = 0
	autoTeleportConnection2 = runService.Heartbeat:Connect(function(deltaTime)
		local character = localPlayer.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid then return end
		time = time + deltaTime * 20
		local bounceOffset = math.sin(time) * 3
		rootPart.CFrame = CFrame.new(TARGET_POSITION_2 + Vector3.new(0, bounceOffset, 0))
		humanoid.Sit = false
		humanoid.AutoRotate = false
	end)
end

local function stopAutoTeleport2()
	if autoTeleportConnection2 then
		autoTeleportConnection2:Disconnect()
		autoTeleportConnection2 = nil
	end
end

PotentHub:AddToggle(world2, "AUTO TELEPORT WORLD 2", "", function(state)
	autoTeleportActive2 = state
	if state then
		startAutoTeleport2()
	else
		stopAutoTeleport2()
	end
end)

-- AUTO COLLECT SHARDS WORLD 2
local shardCollectActive2 = false
local shardCollectTask2 = nil
local shardIndex2 = 1

local function teleportToShard2()
	local shards = getShards()
	if #shards == 0 then return end
	if shardIndex2 > #shards then shardIndex2 = 1 end
	local targetShard = shards[shardIndex2]
	local targetPos = getShardPosition(targetShard)
	if targetPos then
		local character = localPlayer.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
			end
		end
	end
	shardIndex2 = shardIndex2 + 1
end

local function startShardCollect2()
	if shardCollectTask2 then
		shardCollectTask2:Disconnect()
		shardCollectTask2 = nil
	end
	local shards = getShards()
	if #shards == 0 then return end
	shardIndex2 = 1
	teleportToShard2()
	shardCollectTask2 = runService.Heartbeat:Connect(function()
		if not shardCollectActive2 then return end
		teleportToShard2()
	end)
end

local function stopShardCollect2()
	if shardCollectTask2 then
		shardCollectTask2:Disconnect()
		shardCollectTask2 = nil
	end
	shardIndex2 = 1
end

PotentHub:AddToggle(world2, "AUTO COLLECT SHARDS", "", function(state)
	shardCollectActive2 = state
	if state then
		startShardCollect2()
	else
		stopShardCollect2()
	end
end)

----------------------------------------------------------------
-- WORLD 3 options
----------------------------------------------------------------

local autoTeleportActive3 = false
local autoTeleportConnection3 = nil
local TARGET_POSITION_3 = Vector3.new(-8075.32, 285.21, 2740.38)

local function startAutoTeleport3()
	if autoTeleportConnection3 then
		autoTeleportConnection3:Disconnect()
		autoTeleportConnection3 = nil
	end
	local time = 0
	autoTeleportConnection3 = runService.Heartbeat:Connect(function(deltaTime)
		local character = localPlayer.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid then return end
		time = time + deltaTime * 20
		local bounceOffset = math.sin(time) * 3
		rootPart.CFrame = CFrame.new(TARGET_POSITION_3 + Vector3.new(0, bounceOffset, 0))
		humanoid.Sit = false
		humanoid.AutoRotate = false
	end)
end

local function stopAutoTeleport3()
	if autoTeleportConnection3 then
		autoTeleportConnection3:Disconnect()
		autoTeleportConnection3 = nil
	end
end

PotentHub:AddToggle(world3, "AUTO TELEPORT WORLD 3", "", function(state)
	autoTeleportActive3 = state
	if state then
		startAutoTeleport3()
	else
		stopAutoTeleport3()
	end
end)

-- AUTO COLLECT SHARDS WORLD 3
local shardCollectActive3 = false
local shardCollectTask3 = nil
local shardIndex3 = 1

local function teleportToShard3()
	local shards = getShards()
	if #shards == 0 then return end
	if shardIndex3 > #shards then shardIndex3 = 1 end
	local targetShard = shards[shardIndex3]
	local targetPos = getShardPosition(targetShard)
	if targetPos then
		local character = localPlayer.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
			end
		end
	end
	shardIndex3 = shardIndex3 + 1
end

local function startShardCollect3()
	if shardCollectTask3 then
		shardCollectTask3:Disconnect()
		shardCollectTask3 = nil
	end
	local shards = getShards()
	if #shards == 0 then return end
	shardIndex3 = 1
	teleportToShard3()
	shardCollectTask3 = runService.Heartbeat:Connect(function()
		if not shardCollectActive3 then return end
		teleportToShard3()
	end)
end

local function stopShardCollect3()
	if shardCollectTask3 then
		shardCollectTask3:Disconnect()
		shardCollectTask3 = nil
	end
	shardIndex3 = 1
end

PotentHub:AddToggle(world3, "AUTO COLLECT SHARDS", "", function(state)
	shardCollectActive3 = state
	if state then
		startShardCollect3()
	else
		stopShardCollect3()
	end
end)

----------------------------------------------------------------
-- WORLD 4 options
----------------------------------------------------------------

local autoTeleportActive4 = false
local autoTeleportConnection4 = nil
local TARGET_POSITION_4 = Vector3.new(-7760.48, 23.67, 5740.70)

local function startAutoTeleport4()
	if autoTeleportConnection4 then
		autoTeleportConnection4:Disconnect()
		autoTeleportConnection4 = nil
	end
	local time = 0
	autoTeleportConnection4 = runService.Heartbeat:Connect(function(deltaTime)
		local character = localPlayer.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid then return end
		time = time + deltaTime * 20
		local bounceOffset = math.sin(time) * 3
		rootPart.CFrame = CFrame.new(TARGET_POSITION_4 + Vector3.new(0, bounceOffset, 0))
		humanoid.Sit = false
		humanoid.AutoRotate = false
	end)
end

local function stopAutoTeleport4()
	if autoTeleportConnection4 then
		autoTeleportConnection4:Disconnect()
		autoTeleportConnection4 = nil
	end
end

PotentHub:AddToggle(world4, "AUTO TELEPORT WORLD 4", "", function(state)
	autoTeleportActive4 = state
	if state then
		startAutoTeleport4()
	else
		stopAutoTeleport4()
	end
end)

-- AUTO COLLECT SHARDS WORLD 4
local shardCollectActive4 = false
local shardCollectTask4 = nil
local shardIndex4 = 1

local function teleportToShard4()
	local shards = getShards()
	if #shards == 0 then return end
	if shardIndex4 > #shards then shardIndex4 = 1 end
	local targetShard = shards[shardIndex4]
	local targetPos = getShardPosition(targetShard)
	if targetPos then
		local character = localPlayer.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
			end
		end
	end
	shardIndex4 = shardIndex4 + 1
end

local function startShardCollect4()
	if shardCollectTask4 then
		shardCollectTask4:Disconnect()
		shardCollectTask4 = nil
	end
	local shards = getShards()
	if #shards == 0 then return end
	shardIndex4 = 1
	teleportToShard4()
	shardCollectTask4 = runService.Heartbeat:Connect(function()
		if not shardCollectActive4 then return end
		teleportToShard4()
	end)
end

local function stopShardCollect4()
	if shardCollectTask4 then
		shardCollectTask4:Disconnect()
		shardCollectTask4 = nil
	end
	shardIndex4 = 1
end

PotentHub:AddToggle(world4, "AUTO COLLECT SHARDS", "", function(state)
	shardCollectActive4 = state
	if state then
		startShardCollect4()
	else
		stopShardCollect4()
	end
end)

----------------------------------------------------------------
-- WORLD 5 options
----------------------------------------------------------------

local autoTeleportActive5 = false
local autoTeleportConnection5 = nil
local TARGET_POSITION_5 = Vector3.new(-1332.17, 28.42, 7562.34)

local function startAutoTeleport5()
	if autoTeleportConnection5 then
		autoTeleportConnection5:Disconnect()
		autoTeleportConnection5 = nil
	end
	local time = 0
	autoTeleportConnection5 = runService.Heartbeat:Connect(function(deltaTime)
		local character = localPlayer.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid then return end
		time = time + deltaTime * 20
		local bounceOffset = math.sin(time) * 3
		rootPart.CFrame = CFrame.new(TARGET_POSITION_5 + Vector3.new(0, bounceOffset, 0))
		humanoid.Sit = false
		humanoid.AutoRotate = false
	end)
end

local function stopAutoTeleport5()
	if autoTeleportConnection5 then
		autoTeleportConnection5:Disconnect()
		autoTeleportConnection5 = nil
	end
end

PotentHub:AddToggle(world5, "AUTO TELEPORT WORLD 5", "", function(state)
	autoTeleportActive5 = state
	if state then
		startAutoTeleport5()
	else
		stopAutoTeleport5()
	end
end)

-- AUTO COLLECT SHARDS WORLD 5
local shardCollectActive5 = false
local shardCollectTask5 = nil
local shardIndex5 = 1

local function teleportToShard5()
	local shards = getShards()
	if #shards == 0 then return end
	if shardIndex5 > #shards then shardIndex5 = 1 end
	local targetShard = shards[shardIndex5]
	local targetPos = getShardPosition(targetShard)
	if targetPos then
		local character = localPlayer.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
			end
		end
	end
	shardIndex5 = shardIndex5 + 1
end

local function startShardCollect5()
	if shardCollectTask5 then
		shardCollectTask5:Disconnect()
		shardCollectTask5 = nil
	end
	local shards = getShards()
	if #shards == 0 then return end
	shardIndex5 = 1
	teleportToShard5()
	shardCollectTask5 = runService.Heartbeat:Connect(function()
		if not shardCollectActive5 then return end
		teleportToShard5()
	end)
end

local function stopShardCollect5()
	if shardCollectTask5 then
		shardCollectTask5:Disconnect()
		shardCollectTask5 = nil
	end
	shardIndex5 = 1
end

PotentHub:AddToggle(world5, "AUTO COLLECT SHARDS", "", function(state)
	shardCollectActive5 = state
	if state then
		startShardCollect5()
	else
		stopShardCollect5()
	end
end)

----------------------------------------------------------------
-- ADMIN ABUSE options
----------------------------------------------------------------

-- AUTO TELEPORT LUCKY BLOCK
local luckyBlockTeleportActive = false
local luckyBlockTeleportTask = nil
local luckyBlockIndex = 1

local function getLuckyBlocks()
	local luckyBlocksFolder = workspace:FindFirstChild("Lucky Blocks")
	if not luckyBlocksFolder then return {} end
	
	local blocks = {}
	for _, child in ipairs(luckyBlocksFolder:GetChildren()) do
		if child:IsA("BasePart") or child:IsA("Model") then
			table.insert(blocks, child)
		end
	end
	return blocks
end

local function getBlockPosition(block)
	if block:IsA("BasePart") then
		return block.Position
	elseif block:IsA("Model") then
		local primary = block.PrimaryPart or block:FindFirstChild("HumanoidRootPart") or block:FindFirstChildWhichIsA("BasePart")
		if primary then
			return primary.Position
		end
	end
	return nil
end

local function teleportToLuckyBlock()
	local blocks = getLuckyBlocks()
	if #blocks == 0 then return end
	
	if luckyBlockIndex > #blocks then
		luckyBlockIndex = 1
	end
	
	local targetBlock = blocks[luckyBlockIndex]
	local targetPos = getBlockPosition(targetBlock)
	
	if targetPos then
		local character = localPlayer.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
			end
		end
	end
	
	luckyBlockIndex = luckyBlockIndex + 1
end

local function startLuckyBlockTeleport()
	if luckyBlockTeleportTask then
		luckyBlockTeleportTask:Disconnect()
		luckyBlockTeleportTask = nil
	end
	
	local blocks = getLuckyBlocks()
	if #blocks == 0 then return end
	
	luckyBlockIndex = 1
	teleportToLuckyBlock()
	
	luckyBlockTeleportTask = runService.Heartbeat:Connect(function()
		if not luckyBlockTeleportActive then return end
		task.wait(3)
		if not luckyBlockTeleportActive then return end
		teleportToLuckyBlock()
	end)
end

local function stopLuckyBlockTeleport()
	if luckyBlockTeleportTask then
		luckyBlockTeleportTask:Disconnect()
		luckyBlockTeleportTask = nil
	end
	luckyBlockIndex = 1
end

PotentHub:AddToggle(adminAbuse, "AUTO TELEPORT LUCKY BLOCK", "SOLO USAR EN ADMIN ABUSE", function(state)
	luckyBlockTeleportActive = state
	if state then
		startLuckyBlockTeleport()
	else
		stopLuckyBlockTeleport()
	end
end)

-- AUTO TELEPORT BANANAS
local bananaTeleportActive = false
local bananaTeleportTask = nil
local bananaIndex = 1

local function getBananas()
	local bananas = {}
	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name == "BananaNormal" or child.Name == "BananaRare" then
			table.insert(bananas, child)
		end
	end
	return bananas
end

local function getBananaPosition(banana)
	if banana:IsA("BasePart") then
		return banana.Position
	elseif banana:IsA("Model") then
		local primary = banana.PrimaryPart or banana:FindFirstChild("HumanoidRootPart") or banana:FindFirstChildWhichIsA("BasePart")
		if primary then
			return primary.Position
		end
	end
	return nil
end

local function teleportToBanana()
	local bananas = getBananas()
	if #bananas == 0 then return end
	
	if bananaIndex > #bananas then
		bananaIndex = 1
	end
	
	local targetBanana = bananas[bananaIndex]
	local targetPos = getBananaPosition(targetBanana)
	
	if targetPos then
		local character = localPlayer.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
			end
		end
	end
	
	bananaIndex = bananaIndex + 1
end

local function startBananaTeleport()
	if bananaTeleportTask then
		bananaTeleportTask:Disconnect()
		bananaTeleportTask = nil
	end
	
	local bananas = getBananas()
	if #bananas == 0 then return end
	
	bananaIndex = 1
	teleportToBanana()
	
	bananaTeleportTask = runService.Heartbeat:Connect(function()
		if not bananaTeleportActive then return end
		teleportToBanana()
	end)
end

local function stopBananaTeleport()
	if bananaTeleportTask then
		bananaTeleportTask:Disconnect()
		bananaTeleportTask = nil
	end
	bananaIndex = 1
end

PotentHub:AddToggle(adminAbuse, "AUTO TELEPORT BANANAS", "SOLO USAR EN ADMIN ABUSE", function(state)
	bananaTeleportActive = state
	if state then
		startBananaTeleport()
	else
		stopBananaTeleport()
	end
end)

getgenv().PotentHub = PotentHub

return PotentHub
