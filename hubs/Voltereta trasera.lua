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

local TARGET_PLACE_ID = "102553576537621"
local currentPlaceId = tostring(game.PlaceId)

if currentPlaceId ~= TARGET_PLACE_ID then
	local blackScreen = Instance.new("Frame")
	blackScreen.Size = UDim2.fromScale(1, 1)
	blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blackScreen.BackgroundTransparency = 0
	blackScreen.ZIndex = 999
	blackScreen.Parent = hiddenUI

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "THIS GAME NOT SUPPORTED"
	label.Font = Enum.Font.GothamBold
	label.TextSize = 30
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.ZIndex = 1000
	label.Parent = blackScreen

	task.wait(2)
	blackScreen:Destroy()
	return
end

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

local COLOR_BG = Color3.fromRGB(15, 13, 22)
local COLOR_BG_LIGHT = Color3.fromRGB(21, 18, 30)
local COLOR_SIDEBAR = Color3.fromRGB(19, 17, 27)
local COLOR_ACCENT = Color3.fromRGB(158, 82, 255)
local COLOR_ACCENT_DARK = Color3.fromRGB(96, 46, 176)
local COLOR_ACCENT_SOFT = Color3.fromRGB(90, 60, 130)
local COLOR_TEXT = Color3.fromRGB(240, 236, 250)
local COLOR_SUBTEXT = Color3.fromRGB(148, 140, 172)
local COLOR_DANGER = Color3.fromRGB(210, 65, 78)
local COLOR_DANGER_DARK = Color3.fromRGB(150, 42, 54)
local COLOR_TAB_HOVER = Color3.fromRGB(30, 26, 42)

local function corner(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or COLOR_ACCENT
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.5
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

local function shadow(inst, transparency)
	local img = Instance.new("ImageLabel")
	img.Name = "Shadow"
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://1316045217"
	img.ImageColor3 = Color3.fromRGB(0, 0, 0)
	img.ImageTransparency = transparency or 0.45
	img.ScaleType = Enum.ScaleType.Slice
	img.SliceCenter = Rect.new(10, 10, 118, 118)
	img.Size = UDim2.new(1, 40, 1, 40)
	img.Position = UDim2.new(0, -20, 0, -14)
	img.ZIndex = inst.ZIndex - 1
	img.Parent = inst
	return img
end

local function hoverColor(button, normal, hovered)
	button.MouseEnter:Connect(function()
		tweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = hovered }):Play()
	end)
	button.MouseLeave:Connect(function()
		tweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = normal }):Play()
	end)
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

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(54, 54)
toggleButton.Position = UDim2.new(0.5, -27, 0.85, 0)
toggleButton.BackgroundColor3 = COLOR_ACCENT
toggleButton.Text = "PH"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.AutoButtonColor = false
toggleButton.Active = true
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui
corner(toggleButton, 27)
gradient(toggleButton, COLOR_ACCENT, COLOR_ACCENT_DARK, 55)
stroke(toggleButton, Color3.fromRGB(255, 255, 255), 1, 0.7)
shadow(toggleButton, 0.55)

toggleButton.MouseEnter:Connect(function()
	tweenService:Create(toggleButton, TweenInfo.new(0.15), { Size = UDim2.fromOffset(58, 58) }):Play()
end)
toggleButton.MouseLeave:Connect(function()
	tweenService:Create(toggleButton, TweenInfo.new(0.15), { Size = UDim2.fromOffset(54, 54) }):Play()
end)

makeDraggable(toggleButton, toggleButton)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(580, 480)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -240)
mainFrame.BackgroundColor3 = COLOR_BG
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui
corner(mainFrame, 14)
stroke(mainFrame, COLOR_ACCENT, 1, 0.35)
shadow(mainFrame, 0.5)

local bgGradient = gradient(mainFrame, COLOR_BG_LIGHT, COLOR_BG, 90)
bgGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(1, 0.4),
})

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(440, 320)
sizeConstraint.MaxSize = Vector2.new(920, 680)
sizeConstraint.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = COLOR_SIDEBAR
topBar.ZIndex = 5
topBar.Parent = mainFrame
corner(topBar, 14)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 14)
topBarFix.Position = UDim2.new(0, 0, 1, -14)
topBarFix.BackgroundColor3 = COLOR_SIDEBAR
topBarFix.BorderSizePixel = 0
topBarFix.ZIndex = 5
topBarFix.Parent = topBar

local topBarAccent = Instance.new("Frame")
topBarAccent.Size = UDim2.new(1, 0, 0, 2)
topBarAccent.Position = UDim2.new(0, 0, 1, 0)
topBarAccent.BackgroundColor3 = COLOR_ACCENT
topBarAccent.BorderSizePixel = 0
topBarAccent.ZIndex = 6
topBarAccent.Parent = topBar
gradient(topBarAccent, COLOR_ACCENT, COLOR_ACCENT_DARK, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 220, 1, 0)
title.Position = UDim2.fromOffset(16, 0)
title.BackgroundTransparency = 1
title.Text = "PotentHub"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = COLOR_TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = topBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 220, 0, 12)
subtitleLabel.Position = UDim2.fromOffset(16, 23)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = ""
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 10
subtitleLabel.TextColor3 = COLOR_SUBTEXT
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.ZIndex = 6
subtitleLabel.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(26, 26)
closeButton.Position = UDim2.new(1, -36, 0.5, -13)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 40, 58)
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.TextColor3 = COLOR_TEXT
closeButton.AutoButtonColor = false
closeButton.Active = true
closeButton.ZIndex = 6
closeButton.Parent = topBar
corner(closeButton, 7)
hoverColor(closeButton, Color3.fromRGB(45, 40, 58), COLOR_DANGER)

makeDraggable(topBar, mainFrame)

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 136, 1, -42)
sidebar.Position = UDim2.fromOffset(0, 42)
sidebar.BackgroundColor3 = COLOR_SIDEBAR
sidebar.ZIndex = 5
sidebar.Parent = mainFrame

local sidebarDivider = Instance.new("Frame")
sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
sidebarDivider.Position = UDim2.new(1, 0, 0, 0)
sidebarDivider.BackgroundColor3 = COLOR_ACCENT
sidebarDivider.BackgroundTransparency = 0.85
sidebarDivider.BorderSizePixel = 0
sidebarDivider.ZIndex = 5
sidebarDivider.Parent = sidebar

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -16, 1, -62)
tabContainer.Position = UDim2.fromOffset(8, 10)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 5
tabContainer.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 5)
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
hoverColor(destroyButton, COLOR_DANGER, Color3.fromRGB(230, 80, 92))

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -136, 1, -42)
contentArea.Position = UDim2.fromOffset(136, 42)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 3
contentArea.Parent = mainFrame

local pages = {}
local tabButtons = {}
local tabIndicators = {}
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
			BackgroundColor3 = isActive and COLOR_ACCENT_SOFT or COLOR_SIDEBAR,
			BackgroundTransparency = isActive and 0.75 or 1,
		}):Play()
		btn.TextLabel.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or COLOR_SUBTEXT
		local indicator = tabIndicators[tabName]
		if indicator then
			tweenService:Create(indicator, TweenInfo.new(0.15), {
				BackgroundTransparency = isActive and 0 or 1,
			}):Play()
		end
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

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 3, 0, 16)
	indicator.Position = UDim2.new(0, 0, 0.5, -8)
	indicator.BackgroundColor3 = COLOR_ACCENT
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.ZIndex = 7
	indicator.Parent = tabButton
	corner(indicator, 2)

	local label = Instance.new("TextLabel")
	label.Name = "TextLabel"
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.fromOffset(16, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = COLOR_SUBTEXT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = tabButton

	tabButton.MouseEnter:Connect(function()
		if activeTab ~= name then
			tweenService:Create(tabButton, TweenInfo.new(0.15), {
				BackgroundColor3 = COLOR_TAB_HOVER,
				BackgroundTransparency = 0,
			}):Play()
		end
	end)
	tabButton.MouseLeave:Connect(function()
		if activeTab ~= name then
			tweenService:Create(tabButton, TweenInfo.new(0.15), {
				BackgroundTransparency = 1,
			}):Play()
		end
	end)

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
	pageLayout.Padding = UDim.new(0, 6)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingTop = UDim.new(0, 14)
	pagePad.PaddingLeft = UDim.new(0, 14)
	pagePad.PaddingRight = UDim.new(0, 14)
	pagePad.Parent = page

	tabButton.MouseButton1Click:Connect(function()
		selectTab(name)
	end)

	pages[name] = page
	tabButtons[name] = tabButton
	tabIndicators[name] = indicator

	if not activeTab then
		selectTab(name)
	end

	return page
end

function PotentHub:AddToggle(parent, labelText, subtitleText, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 52)
	frame.BackgroundColor3 = COLOR_BG_LIGHT
	frame.BackgroundTransparency = 0.3
	frame.Parent = parent
	corner(frame, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -54, 0.55, 0)
	label.Position = UDim2.fromOffset(0, 6)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = COLOR_TEXT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, -54, 0.4, 0)
	subLabel.Position = UDim2.fromOffset(0, 26)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = subtitleText or ""
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextSize = 10
	subLabel.TextColor3 = COLOR_SUBTEXT
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	subLabel.Parent = frame

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.fromOffset(40, 22)
	toggle.Position = UDim2.new(1, -40, 0.5, -11)
	toggle.BackgroundColor3 = Color3.fromRGB(42, 38, 55)
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.Parent = frame
	corner(toggle, 11)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.fromOffset(18, 18)
	indicator.Position = UDim2.fromOffset(2, 2)
	indicator.BackgroundColor3 = Color3.fromRGB(175, 168, 195)
	indicator.Parent = toggle
	corner(indicator, 9)

	local state = false
	local toggleData = {
		Value = state,
		Callback = callback,
	}

	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggleData.Value = state
		local targetPos = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
		local knobColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 168, 195)
		local trackColor = state and COLOR_ACCENT or Color3.fromRGB(42, 38, 55)
		tweenService:Create(indicator, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Position = targetPos,
			BackgroundColor3 = knobColor,
		}):Play()
		tweenService:Create(toggle, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			BackgroundColor3 = trackColor,
		}):Play()
		if callback then
			pcall(callback, state)
		end
	end)

	PotentHub.Toggles[labelText] = toggleData
	return toggleData
end

function PotentHub:AddButton(parent, labelText, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 44)
	frame.BackgroundColor3 = COLOR_BG_LIGHT
	frame.BackgroundTransparency = 0.3
	frame.Parent = parent
	corner(frame, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = COLOR_ACCENT_SOFT
	btn.BackgroundTransparency = 0.85
	btn.Text = labelText
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.TextColor3 = COLOR_TEXT
	btn.AutoButtonColor = false
	btn.Parent = frame
	corner(btn, 8)
	hoverColor(btn, COLOR_ACCENT_SOFT, Color3.fromRGB(50, 40, 72))

	btn.MouseButton1Click:Connect(function()
		if callback then
			pcall(callback)
		end
	end)

	return btn
end

function PotentHub:AddSlider(parent, labelText, subtitleText, minVal, maxVal, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 62)
	frame.BackgroundColor3 = COLOR_BG_LIGHT
	frame.BackgroundTransparency = 0.3
	frame.Parent = parent
	corner(frame, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 160, 0.55, 0)
	label.Position = UDim2.fromOffset(0, 6)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = COLOR_TEXT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0.55, 0)
	valueLabel.Position = UDim2.new(1, -50, 0, 6)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(defaultVal)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 13
	valueLabel.TextColor3 = COLOR_ACCENT
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, 0, 0, 16)
	subLabel.Position = UDim2.fromOffset(0, 28)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = subtitleText or ""
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextSize = 10
	subLabel.TextColor3 = COLOR_SUBTEXT
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	subLabel.Parent = frame

	local sliderTrack = Instance.new("Frame")
	sliderTrack.Size = UDim2.new(1, -0, 0, 4)
	sliderTrack.Position = UDim2.new(0, 0, 1, -10)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(42, 38, 55)
	sliderTrack.Parent = frame
	corner(sliderTrack, 2)

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	sliderFill.BackgroundColor3 = COLOR_ACCENT
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderTrack
	corner(sliderFill, 2)

	local sliderKnob = Instance.new("Frame")
	sliderKnob.Size = UDim2.fromOffset(14, 14)
	sliderKnob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
	sliderKnob.BackgroundColor3 = COLOR_ACCENT
	sliderKnob.Parent = sliderTrack
	corner(sliderKnob, 7)

	local currentVal = defaultVal
	local dragging = false

	local function updateSlider(input)
		local posX = input.Position.X
		local absPos = sliderTrack.AbsolutePosition.X
		local width = sliderTrack.AbsoluteSize.X
		if width <= 0 then return end
		local percent = math.clamp((posX - absPos) / width, 0, 1)
		local val = minVal + (maxVal - minVal) * percent
		val = math.floor(val + 0.5)
		currentVal = val
		valueLabel.Text = tostring(val)
		sliderFill.Size = UDim2.new(percent, 0, 1, 0)
		sliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
		if callback then
			pcall(callback, val)
		end
	end

	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateSlider(input)
		end
	end

	sliderKnob.InputBegan:Connect(onInputBegan)
	sliderTrack.InputBegan:Connect(onInputBegan)

	sliderKnob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	sliderKnob.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	return { Value = currentVal, Set = function(v) currentVal = v end }
end

local guiOpen = false

local function setOpen(state)
	guiOpen = state
	if state then
		mainFrame.Visible = true
		mainFrame.Size = UDim2.fromOffset(580, 0)
		tweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(580, 480)
		}):Play()
	else
		local tween = tweenService:Create(mainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(580, 0)
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
-- Tabs
----------------------------------------------------------------

local world1 = PotentHub:AddTab("WORLD 1")
local world2 = PotentHub:AddTab("WORLD 2")
local world3 = PotentHub:AddTab("WORLD 3")
local movement = PotentHub:AddTab("MOVEMENT")
local config = PotentHub:AddTab("CONFIG")

----------------------------------------------------------------
-- AUTO TELEPORT WORLD 1
----------------------------------------------------------------

local autoTeleportEnabled = false
local teleportPos = Vector3.new(-6510.57, 276.12, -15755.79)
local teleportConnection = nil

PotentHub:AddToggle(world1, "AUTO TELEPORT WORLD 1", "", function(state)
	autoTeleportEnabled = state
	
	if teleportConnection then
		teleportConnection:Disconnect()
		teleportConnection = nil
	end
	
	if state then
		teleportConnection = runService.Heartbeat:Connect(function()
			local char = localPlayer.Character
			if not char then return end
			
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChild("Humanoid")
			if not hrp or not humanoid then return end
			
			hrp.CFrame = CFrame.new(teleportPos)
			
			local bobOffset = math.sin(tick() * 30) * 1.5
			local targetPos = teleportPos + Vector3.new(0, bobOffset, 0)
			hrp.CFrame = CFrame.new(targetPos)
		end)
	end
end)

----------------------------------------------------------------
-- VIP ACCESS UNLOCK (WORLD 1)
----------------------------------------------------------------

PotentHub:AddToggle(world1, "VIP Access Unlock", "", function(state)
	if state then
		localPlayer:SetAttribute("HasVIPAccess", true)
		local configData = replicatedStorage:FindFirstChild("Config")
		if configData then
			configData:SetAttribute("VIPServerOwnerUserId", localPlayer.UserId)
		end
	end
end)

----------------------------------------------------------------
-- AUTO TELEPORT WORLD 2
----------------------------------------------------------------

local autoTeleportEnabled2 = false
local teleportPos2 = Vector3.new(-32655.05, -1754.57, 50199.60)
local teleportConnection2 = nil

PotentHub:AddToggle(world2, "AUTO TELEPORT WORLD 2", "", function(state)
	autoTeleportEnabled2 = state
	
	if teleportConnection2 then
		teleportConnection2:Disconnect()
		teleportConnection2 = nil
	end
	
	if state then
		teleportConnection2 = runService.Heartbeat:Connect(function()
			local char = localPlayer.Character
			if not char then return end
			
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChild("Humanoid")
			if not hrp or not humanoid then return end
			
			hrp.CFrame = CFrame.new(teleportPos2)
			
			local bobOffset = math.sin(tick() * 30) * 1.5
			local targetPos = teleportPos2 + Vector3.new(0, bobOffset, 0)
			hrp.CFrame = CFrame.new(targetPos)
		end)
	end
end)

----------------------------------------------------------------
-- VIP ACCESS UNLOCK (WORLD 2)
----------------------------------------------------------------

PotentHub:AddToggle(world2, "VIP Access Unlock", "", function(state)
	if state then
		localPlayer:SetAttribute("HasVIPAccess", true)
		local configData = replicatedStorage:FindFirstChild("Config")
		if configData then
			configData:SetAttribute("VIPServerOwnerUserId", localPlayer.UserId)
		end
	end
end)

----------------------------------------------------------------
-- AUTO TELEPORT WORLD 3
----------------------------------------------------------------

local autoTeleportEnabled3 = false
local teleportPos3 = Vector3.new(-27238.17, 1662.17, 76625.84)
local teleportConnection3 = nil

PotentHub:AddToggle(world3, "AUTO TELEPORT WORLD 3", "", function(state)
	autoTeleportEnabled3 = state
	
	if teleportConnection3 then
		teleportConnection3:Disconnect()
		teleportConnection3 = nil
	end
	
	if state then
		teleportConnection3 = runService.Heartbeat:Connect(function()
			local char = localPlayer.Character
			if not char then return end
			
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChild("Humanoid")
			if not hrp or not humanoid then return end
			
			hrp.CFrame = CFrame.new(teleportPos3)
			
			local bobOffset = math.sin(tick() * 30) * 1.5
			local targetPos = teleportPos3 + Vector3.new(0, bobOffset, 0)
			hrp.CFrame = CFrame.new(targetPos)
		end)
	end
end)

----------------------------------------------------------------
-- VIP ACCESS UNLOCK (WORLD 3)
----------------------------------------------------------------

PotentHub:AddToggle(world3, "VIP Access Unlock", "", function(state)
	if state then
		localPlayer:SetAttribute("HasVIPAccess", true)
		local configData = replicatedStorage:FindFirstChild("Config")
		if configData then
			configData:SetAttribute("VIPServerOwnerUserId", localPlayer.UserId)
		end
	end
end)

----------------------------------------------------------------
-- MOVEMENT TAB
----------------------------------------------------------------

local speedEnabled = false
local speedValue = 50
local speedConnection = nil

PotentHub:AddToggle(movement, "Speed", "", function(state)
	speedEnabled = state
	if speedConnection then
		speedConnection:Disconnect()
		speedConnection = nil
	end
	if state then
		speedConnection = runService.Heartbeat:Connect(function()
			local char = localPlayer.Character
			if not char then return end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = speedValue
			end
		end)
	end
end)

PotentHub:AddSlider(movement, "Speed Value", "16-250", 16, 250, 50, function(val)
	speedValue = val
	if speedEnabled then
		local char = localPlayer.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = val
			end
		end
	end
end)

local infiniteJumpEnabled = false
local jumpConnection = nil

PotentHub:AddToggle(movement, "Infinite Jump", "", function(state)
	infiniteJumpEnabled = state
	
	if jumpConnection then
		jumpConnection:Disconnect()
		jumpConnection = nil
	end
	
	if state then
		jumpConnection = userInputService.JumpRequest:Connect(function()
			local char = localPlayer.Character
			if not char then return end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end
end)

local noClipEnabled = false
local noClipConnection = nil

PotentHub:AddToggle(movement, "NOCLIP", "", function(state)
	noClipEnabled = state
	if noClipConnection then
		noClipConnection:Disconnect()
		noClipConnection = nil
	end
	if state then
		noClipConnection = runService.Heartbeat:Connect(function()
			local char = localPlayer.Character
			if not char then return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end)

----------------------------------------------------------------
-- CONFIG TAB
----------------------------------------------------------------

PotentHub:AddButton(config, "DISCORD SERVER", function()
	local success, err = pcall(function()
		setclipboard("https://discord.gg/X7Y4NzuC67")
	end)
	if not success then
		pcall(function()
			Clipboard = "https://discord.gg/X7Y4NzuC67"
		end)
	end
end)

getgenv().PotentHub = PotentHub

return PotentHub
