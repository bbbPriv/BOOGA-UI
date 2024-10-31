local BoogaUI = {}
local Utility = {}

local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local TS = game:GetService("TweenService")

function Utility.Create(ClassName, Properties)
	local instance = Instance.new(ClassName)

	for k,v in pairs(Properties) do

		local _, Error = pcall(function() instance[k] = v end)

		if Error then
			warn(Error)
		end

	end

	return instance
end

local function isPointInBounds(point, gui)
	local guiPosition = gui.AbsolutePosition
	local guiSize = gui.AbsoluteSize
	return (point.X >= guiPosition.X and point.X <= guiPosition.X + guiSize.X and
		point.Y >= guiPosition.Y and point.Y <= guiPosition.Y + guiSize.Y)
end

local function isDescendantOfByName(child, parentName)
	local current = child

	while current do
		if current.Name == parentName then
			return true
		end
		current = current.Parent
	end

	return false
end

local function Pop(instance, Offset)
	local Clone = instance:Clone()
	Clone:ClearAllChildren()

	if instance:FindFirstChild("UICorner") then
		Utility.Create("UICorner", {
			Parent = Clone,
			CornerRadius = instance.UICorner.CornerRadius
		})
	end

	Clone.Size = instance.Size - UDim2.new(0, Offset, 0, Offset)
	Clone.Parent = instance.Parent

	Clone.Position = instance.Position

	if instance.ClassName == "Frame" then
		instance.BackgroundTransparency = 1
	else
		instance.ImageTransparency = 1
	end

	TS:Create(Clone, TweenInfo.new(0.2), {Size = instance.Size}):Play()

	task.wait(0.2)

	Clone:Destroy()

	if instance.ClassName == "Frame" then
		instance.BackgroundTransparency = 0
	else
		instance.ImageTransparency = 0
	end
end

local function UpdateSlider(Bar, Value, Min, Max, FixValues, Decimal, Increment)
	local Old = Value

	local percent = (Player:GetMouse().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X

	if Value then
		percent = (Value - Min) / (Max - Min)
	end

	percent = math.clamp(percent, 0, 1)
	
	if percent == 0 then
		TS:Create(Bar.Fill.Circle, TweenInfo.new(0.2), {ImageTransparency = 1, Size = UDim2.fromOffset()}):Play()
	elseif Bar.Fill.Circle.ImageTransparency == 1 then
		TS:Create(Bar.Fill.Circle, TweenInfo.new(0.2), {ImageTransparency = 0, Size = UDim2.fromOffset(12, 11)}):Play()
	end
	
	Value = Min + (Max - Min) * percent

	if Increment then
		Value = math.floor((Value / Increment) + 0.5) * Increment
	end

	Value = FixValues and Value or Old or Value
	Value = typeof(Decimal) ~= "table" and math.floor(Value) or (Decimal[1] == true and string.format("%." .. Decimal[2] .. "f", Value)) or math.floor(Value)

	Bar.Parent.TextBox.Text = Value
	BoogaUI.Instances[Bar.Fill].Size = UDim2.new(percent, 0, 1 ,0)
	TS:Create(Bar.Fill, TweenInfo.new(0.150), {Size = UDim2.new(percent, 0, 1 ,0)}):Play()
	TS:Create(Bar.Fill.Circle, TweenInfo.new(0.15), {Position = UDim2.new(0, math.clamp(percent * Bar.AbsoluteSize.X, 0, Bar.AbsoluteSize.X) - 5, 0, -2)}):Play()

	return Value
end

local function HandleOptions(Accept, Decline, Holder, Position, Size)
	TS:Create(Accept, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1}):Play()

	TS:Create(Decline, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1}):Play()

	TS:Create(Holder.Title, TweenInfo.new(0.7), {TextSize = 0, TextTransparency = 1}):Play()

	TS:Create(Holder.Text, TweenInfo.new(0.7), {TextSize = 0, TextTransparency = 1}):Play()

	Holder.Title.TextXAlignment = Enum.TextXAlignment.Center

	Holder.Text.TextXAlignment = Enum.TextXAlignment.Center

	task.spawn(function()
		task.wait(0.1)

		pcall(function()
			for i = Holder.Title.Text:len(), 1, -1 do
				Holder.Title.Text = Holder.Title.Text:gsub(Holder.Title.Text:sub(i, i) .. "?$", "", 1)

				task.wait()
			end
		end)
	end)

	task.spawn(function()
		task.wait(0.1)

		pcall(function()
			for i = Holder.Text.Text:len(), 1, -1 do
				Holder.Text.Text = Holder.Text.Text:gsub(Holder.Text.Text:sub(i, i) .. "?$", "", 1)

				task.wait()
			end
		end)
	end)

	task.wait(0.5)

	TS:Create(Holder, TweenInfo.new(Position and 1 or 0.5), {Position = Position or Holder.Position, Size = Size or Holder.Size}):Play()

	task.wait(1)

	Holder:Destroy()
end

local function SetKeybindSize(self, Key, Label, Duration)
	if Key.Name:len() <= 3 then
		TS:Create(Label, TweenInfo.new(Duration), {Size = UDim2.new(0, 34, 0, 16), Position = UDim2.new(1, -44, 0.5, -8)}):Play()
		self.Instances[Label].Size = UDim2.new(0, 34, 0, 16)
	elseif Key.Name:len() == 4 then
		TS:Create(Label, TweenInfo.new(Duration), {Size = UDim2.new(0, 42, 0, 16), Position = UDim2.new(1, -52, 0.5, -8)}):Play()
		self.Instances[Label].Size = UDim2.new(0, 42, 0, 16)
	elseif Key.Name:len() == 5 then
		TS:Create(Label, TweenInfo.new(Duration), {Size = UDim2.new(0, Key.Name == "Comma" and 50 or 46, 0, 16), Position = UDim2.new(1, Key.Name == "Comma" and -60 or -56, 0.5, -8)}):Play()
		self.Instances[Label].Size = UDim2.new(0, Key.Name == "Comma" and 50 or 46, 0, 16)
	elseif Key.Name:len() == 6 then
		TS:Create(Label, TweenInfo.new(Duration), {Size = UDim2.new(0, 52, 0, 16), Position = UDim2.new(1, -60, 0.5, -8)}):Play()
		self.Instances[Label].Size = UDim2.new(0, 52, 0, 16)
	else
		TS:Create(Label, TweenInfo.new(Duration), {Size = UDim2.new(0, Key.Name:find("Keypad") and 80 or 76, 0, 16), Position = UDim2.new(1, Key.Name:find("Keypad") and -88 or -84, 0.5, -8)}):Play()
		self.Instances[Label].Size = UDim2.new(0, Key.Name:find("Keypad") and 80 or 76, 0, 16)
	end
end

local function StartsWith(str, start)
	return string.match(str, "^" .. start) ~= nil
end

local function TypeCheck(Check, Callback, Default)
	if typeof(Check) == "function" then
		return Default, Check
	end

	return Check, Callback
end

local function ColorPickerClose(ColorPicker)
	local Tween = TS:Create(ColorPicker.Gui:FindFirstChildOfClass("Frame"), TweenInfo.new(0.250), {Size = UDim2.fromScale(0, 0)})
	Tween:Play()

	Tween.Completed:Connect(function()
		ColorPicker:Destroy()
		ColorPicker.Gui:Destroy()
	end)
end

local function InformationInteractable(self, Holder, Holder2, Information)
	TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.930, 0, 0, 70)}):Play()
	TS:Create(self.Section, TweenInfo.new(0.3), {Size = self.Section.Size + UDim2.fromOffset(0, 43)}):Play()

	local Separator = Utility.Create("Frame", {
		Parent = Holder2,
		Size = UDim2.new(0.850, 0, 0, 4),
		Position = UDim2.fromScale(0, 1.05),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ZIndex = 3
	})

	Utility.Create("UICorner", {
		Parent = Separator,
		CornerRadius = UDim.new(0, 12)
	})

	local InformationLabel = Utility.Create("TextLabel", {
		Name = "Title",
		Parent = Holder2,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 1.5),
		Size = UDim2.new(0.850, 0, 0, 5),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Information,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	TS:Create(Separator, TweenInfo.new(0.250), {BackgroundTransparency = 0.750, Position = UDim2.fromScale(0.07, 1.05)}):Play()
	TS:Create(InformationLabel, TweenInfo.new(0.250), {TextTransparency = 0.07, Position = UDim2.fromScale(0.07, 1.5)}):Play()
	
	task.delay(0.3, function()
		self:ResizePage()
	end)
	
	return Separator, InformationLabel
end

local Properties = {
	Frame = "BackgroundTransparency",
	TextButton = "BackgroundTransparency",

	TextLabel = "TextTransparency",
	TextBox = "TextTransparency",

	ImageLabel = "ImageTransparency",
	ImageButton = "ImageTransparency"
}

local Pages = {}
Pages.__index = Pages

setmetatable(Pages, {__index = BoogaUI})

local Sections = {}
Sections.__index = Sections

setmetatable(Sections, {__index = Pages})

local Interactables = {}
Interactables.__index = Interactables

local InteractablesInfo = {}

local AllSections = {}

local CleanConnections = {}

function Interactables:Remove()
	self.Interactable:Destroy()
	
	local Env = Pages:GetSectionEnv(self.Section)
	Env:Resize()
	Env:ResizePage()
end

function Interactables:Edit(Properties)
	local Interactable = self.Interactable

	if Properties.Text then
		if Interactable.ClassName ~= "TextButton" then
			Interactable.Title.Text = Properties.Text
		else
			Interactable.Text = Properties.Text
		end
	end
	
	if Properties.Callback then
		InteractablesInfo[Interactable].Callback = Properties.Callback
	end
	
	if Properties.InputText then
		Interactable.Frame.TextBox.Text = Properties.InputText
	end
end

function Pages:GetSectionEnv(Section)
	for k,v in pairs(AllSections) do
		if k == Section then
			return setmetatable({Section = v.Section, SectionPage = v.SectionPage}, Sections)
		end
	end
end

function Sections:Resize(Section)
	local Size = 32

	for _,v in pairs(Section and Section:GetChildren() or self.Section.Frame:GetChildren()) do
		if v.ClassName ~= "UIListLayout" and v.ClassName ~= "TextLabel" and v.Visible then

			if v:FindFirstChild("List") and v.List.ScrollingFrame:FindFirstChildOfClass("TextButton") then

				local DropdownSize = 0

				for _,v in pairs(v.List.ScrollingFrame:GetChildren()) do
					if v.ClassName == "TextButton" or v.Name == "First" then
						DropdownSize += 1
					end
				end

				Size += DropdownSize <= 3 and DropdownSize * 40 + 34 or DropdownSize > 3 and 162 or 154
			else
				Size += v.AbsoluteSize.Y + 5
			end
		end
	end

	if not Section then
		self.Instances[self.Section].Size = UDim2.new(1, -16, 0, Size)
		self.Section.Size = UDim2.new(1, -16, 0, Size)
	else
		self.Instances[Section.Parent].Size = UDim2.new(1, -16, 0, Size)
		Section.Parent.Size = UDim2.new(1, -16, 0, Size)
	end

	return Size
end

function Sections:AddButton(Settings)
	local Callback = Settings.Callback or function() end
	
	local Hovering
	local Time = 0
	
	local GoingSmaller = false
	
	local Holder = Utility.Create("Frame", {
		Parent = self.Section.Frame,
		Name = "Button",
		ZIndex = 2,
		Size = UDim2.new(0.950, 0, 0, 31),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0
	})
	
	Utility.Create("UIStroke", {
		Parent = Holder,
		Name = "StrokeBorder",
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55),
		Transparency = 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Enabled = true
	})
	
	Utility.Create("UICorner", {
		Parent = Holder,
		CornerRadius = UDim.new(0, 4)
	})

	local Button = Utility.Create("TextButton", {
		Parent = Holder,
		ZIndex = 3,
		Text = Settings.Name or "Button",
		TextSize = 17,
		Font = Enum.Font.Arial,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextTransparency = 0.07,
		AutoButtonColor = false
	})
	
	Utility.Create("UICorner", {
		Parent = Button,
		CornerRadius = UDim.new(0, 4)
	})
	
	InteractablesInfo[Button] = {Callback = Callback}
	
	local UnderButton = Utility.Create("TextButton", {
		Parent = Button,
		Name = "Under",
		ZIndex = 2,
		Text = "",
		TextSize = 0,
		Font = Enum.Font.Arial,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		TextTransparency = 1,
		AutoButtonColor = false
	})
	
	Utility.Create("UICorner", {
		Parent = UnderButton,
		CornerRadius = UDim.new(0, 4)
	})

	Utility.Create("ImageLabel", {
		Parent = UnderButton,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		Size = UDim2.fromScale(0.06, 0.68),
		Position = UDim2.fromScale(0.93, 0.12),
		Image = "rbxassetid://3926305904",
		ImageTransparency = 0.05,
		ImageRectOffset = Vector2.new(84, 204),
		ImageRectSize = Vector2.new(36, 36),
		ZIndex = 3
	})

	self:Resize()

	self:ResizePage()

	self:AddInstances({Holder, Holder.Size, Button, Button.Size, UnderButton.ImageLabel, UnderButton.ImageLabel.Size})

	Holder.MouseEnter:Connect(function()
		Hovering = true

		TS:Create(Holder, TweenInfo.new(0.2), {Size = UDim2.new(0.930, 0, 0, 30)}):Play()
		TS:Create(Button, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
		TS:Create(Button, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TS:Create(UnderButton, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 30)}):Play()

		Time = tick()

		while self.StrokeBorders and Hovering do
			task.wait()

			if tick() - Time > self.StrokeBordersDelay then
				
				local Old
				local Separator
				local InformationLabel

				if not GoingSmaller then
					GoingSmaller = true

					Old = self.Section.Size

					Separator, InformationLabel = InformationInteractable(self, Holder, Button, Settings.Information or "No information for this button was provided.")
				end
				
				local StrokeTween = TS:Create(Holder.StrokeBorder, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, Transparency = 0.1})
				StrokeTween:Play()

				repeat task.wait() until not Hovering or tick() - Time < self.StrokeBordersDelay or not self.StrokeBorders

				StrokeTween:Cancel()
				
				if GoingSmaller then
					if self.Section.Size - UDim2.fromOffset(0, 43) == Old then
						Old = self.Section.Size - UDim2.fromOffset(0, 43)
					end

					TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.930, 0, 0, 31)}):Play()
					TS:Create(self.Section, TweenInfo.new(0.3), {Size = Old}):Play()
					TS:Create(Separator, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.fromScale(0.075, 0.9)}):Play()
					TS:Create(InformationLabel, TweenInfo.new(0.2), {TextTransparency = 1, Position = UDim2.fromScale(0.075, 1.3)}):Play()
					
					task.delay(0.3, function()
						GoingSmaller = false

						Separator:Destroy()
						InformationLabel:Destroy()

						self:ResizePage()

						if Holder.StrokeBorder.Color == Color3.fromRGB(0, 0, 0) then
							Holder.StrokeBorder.Enabled = false
						end
					end)
				end

				TS:Create(Holder.StrokeBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(55, 55, 55), Thickness = 1, Transparency = 0}):Play()
			end
		end
	end)

	Holder.MouseLeave:Connect(function()
		Hovering = false
		
		task.wait()

		TS:Create(Holder, TweenInfo.new(0.2), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
		TS:Create(Button, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 31)}):Play()
		TS:Create(Button, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		TS:Create(UnderButton, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 31)}):Play()

		if Button.TextSize == 10 then
			TS:Create(Button, TweenInfo.new(0.1), {TextSize = 16}):Play()
		end
	end)

	Button.MouseButton1Down:Connect(function()
		TS:Create(Holder, TweenInfo.new(0.1), {Size = UDim2.new(0.900, 0, 0, 27)}):Play()
		TS:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 27)}):Play()
		TS:Create(UnderButton, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 27)}):Play()

		TS:Create(Button, TweenInfo.new(0.1), {TextSize = 14}):Play()
	end)

	Button.MouseButton1Click:Connect(function()

		Hovering = false

		task.spawn(InteractablesInfo[Button].Callback)

		local Tween = TS:Create(Holder, TweenInfo.new(0.1), {Size = UDim2.new(0.850, 0, 0, 25)})
		Tween:Play()
		
		TS:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 25)})
		TS:Create(UnderButton, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 25)})

		Tween.Completed:Connect(function()
			if Hovering then
				TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 34)}):Play()
				TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 34)}):Play()
				TS:Create(UnderButton, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 34)}):Play()
			else
				TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.970, 0, 0, 35)}):Play()
				TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 35)}):Play()
				TS:Create(UnderButton, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 35)}):Play()
			end
			
			task.wait(0.15)

			TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
			TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 31)}):Play()
			TS:Create(UnderButton, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 31)}):Play()
		end)

		Button.TextSize = 0

		local Effect = TS:Create(Button, TweenInfo.new(0.2), {TextSize = 20})
		Effect:Play()

		Effect.Completed:Connect(function()
			TS:Create(Button, TweenInfo.new(0.1), {TextSize = 16}):Play()
		end)
	end)

	return setmetatable({instance = Button, Interactable = Button, Section = self.Section}, Interactables)
end

function Sections:AddToggle(Settings)
	local Callback = Settings.Callback or function() end

	local Hovering = false

	local Time = 0
	
	local GoingSmaller = false

	local Toggle = Utility.Create("Frame", {
		Name = "Toggle1",
		Parent = self.Section.Frame,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Size = UDim2.new(0.950, 0, 0, 31),
		ZIndex = 2,
	})
	
	Utility.Create("UIStroke", {
		Parent = Toggle,
		Name = "StrokeBorder2",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55)
	})

	Utility.Create("UICorner", {
		Parent = Toggle,
		CornerRadius = UDim.new(0, 4)
	})
	
	InteractablesInfo[Toggle] = {Callback = Callback}

	local Toggled = Utility.Create("BoolValue", {
		Parent = Toggle,
		Name = "Toggled"
	})
	
	local ToggleUnder = Utility.Create("Frame", {
		Name = "Under",
		Parent = Toggle,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 31),
		ZIndex = 2,
	})

	if Settings.IsEnabled then

		Toggled.Value = true

		task.spawn(function()
			InteractablesInfo[Toggle].Callback(Toggled)
		end)
	end

	self:Resize()

	self:ResizePage()

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = ToggleUnder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 1),
		Size = UDim2.fromScale(0.5, 1),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Settings.Name or "Toggle",
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.120,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Utility.Create("UICorner", {
		Parent = Utility.Create("Frame", {
			Parent = ToggleUnder,
			Name = "ToggleBase",
			BackgroundTransparency = 0.9,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(1, -50, 0.5, -8),
			Size = UDim2.fromOffset(40, 16),
			ZIndex = 2,
		}),

		CornerRadius = UDim.new(0, 8)
	})

	Utility.Create("UIStroke", {
		Parent = ToggleUnder.ToggleBase,
		Name = "StrokeBorder",
		Thickness = 0,
		Color = Color3.fromRGB(15, 15, 15),
		Transparency = 0.5,
		Enabled = false
	})

	Utility.Create("UICorner", {
		Parent = Utility.Create("Frame", {
			Parent = ToggleUnder.ToggleBase,
			Name = "ToggleCircle",
			BackgroundTransparency = 0.1,
			BackgroundColor3 = Toggled.Value and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170),
			Position = not Settings.IsEnabled and UDim2.new(0, 2, 0.5, -6) or UDim2.new(0, 20, 0.5, -6),
			Size = UDim2.new(1, -22, 1, -4),
			ZIndex = 2,
		}),

		CornerRadius = UDim.new(0, 8)
	})

	local Button = Utility.Create("ImageButton", {
		Parent = Toggle,
		ZIndex = 2,
		Size = UDim2.fromScale(1, 1),
		ImageTransparency = 1,
		BackgroundTransparency = 1
	})

	self:AddInstances({Toggle, Toggle.Size, ToggleUnder.Title, ToggleUnder.Title.Size, ToggleUnder.ToggleBase, ToggleUnder.ToggleBase.Size, ToggleUnder.ToggleBase.ToggleCircle, ToggleUnder.ToggleBase.ToggleCircle.Size})

	Toggle.MouseEnter:Connect(function()
		Hovering = true

		TS:Create(Toggle, TweenInfo.new(0.2), {Size = UDim2.new(0.930, 0, 0, 30)}):Play()
		TS:Create(ToggleUnder, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
		TS:Create(ToggleUnder.Title, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TS:Create(ToggleUnder.ToggleBase.ToggleCircle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()

		Time = tick()

		while self.StrokeBorders and Hovering do
			task.wait()

			if tick() - Time > self.StrokeBordersDelay then
				ToggleUnder.ToggleBase.StrokeBorder.Enabled = true
				
				local Old
				local Separator
				local InformationLabel
				
				if not GoingSmaller then
					GoingSmaller = true
					
					Old = self.Section.Size

					Separator, InformationLabel = InformationInteractable(self, Toggle, ToggleUnder, Settings.Information or "No information for this toggle was provided.")
				end

				local StrokeTween = TS:Create(ToggleUnder.ToggleBase.StrokeBorder, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, Transparency = 0.1})
				StrokeTween:Play()

				repeat task.wait() until not Hovering or tick() - Time < self.StrokeBordersDelay or not self.StrokeBorders

				StrokeTween:Cancel()
				
				if GoingSmaller then
					if self.Section.Size - UDim2.fromOffset(0, 43) == Old then
						Old = self.Section.Size - UDim2.fromOffset(0, 43)
					end
					
					TS:Create(Toggle, TweenInfo.new(0.3), {Size = UDim2.new(0.930, 0, 0, 31)}):Play()
					TS:Create(self.Section, TweenInfo.new(0.3), {Size = Old}):Play()
					TS:Create(Separator, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.fromScale(0.075, 0.9)}):Play()
					TS:Create(InformationLabel, TweenInfo.new(0.2), {TextTransparency = 1, Position = UDim2.fromScale(0.075, 1.3)}):Play()
				end

				local Tween = TS:Create(ToggleUnder.ToggleBase.StrokeBorder, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 0, 0), Transparency = 0.5, Thickness = 0})
				Tween:Play()

				Tween.Completed:Connect(function()
					GoingSmaller = false

					Separator:Destroy()
					InformationLabel:Destroy()

					self:ResizePage()
					
					if ToggleUnder.ToggleBase.StrokeBorder.Color == Color3.fromRGB(0, 0, 0) then
						ToggleUnder.ToggleBase.StrokeBorder.Enabled = false
					end
				end)
			end
		end
	end)

	Toggle.MouseLeave:Connect(function()
		Hovering = false
		
		task.wait()
		
		TS:Create(Toggle, TweenInfo.new(0.2), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
		TS:Create(ToggleUnder, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 31)}):Play()

		if not Toggled.Value then
			TS:Create(ToggleUnder.Title, TweenInfo.new(0.2), {TextTransparency = 0.12, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
			TS:Create(ToggleUnder.ToggleBase.ToggleCircle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(170, 170, 170)}):Play()
		end
	end)

	Button.MouseButton1Click:Connect(function()

		Hovering = false

		Toggled.Value = not Toggled.Value

		task.spawn(function()
			InteractablesInfo[Toggle].Callback(Toggled)
		end)

		local position = {
			In = UDim2.new(0, 2, 0.5, -6),
			Out = UDim2.new(0, 20, 0.5, -6)
		}

		local value = Toggled.Value and "Out" or "In"
		
		TS:Create(ToggleUnder.Title, TweenInfo.new(0.2), {TextColor3 = value == "Out" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220), TextTransparency = value == "Out" and 0 or 0.1}):Play()

		TS:Create(ToggleUnder.ToggleBase.ToggleCircle, TweenInfo.new(0.2), {Position = position[value] + UDim2.new(0, 0, 0, 2.2), Size = UDim2.new(1, -22, 1, -8), BackgroundColor3 = value == "Out" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)}):Play()
		
		task.wait(0.1)
		
		TS:Create(ToggleUnder.ToggleBase.ToggleCircle, TweenInfo.new(0.1), {Position = position[value], Size = UDim2.new(1, -22, 1, -4)}):Play()
	end)

	return setmetatable({instance = Toggle, Interactable = Toggle, Section = self.Section}, Interactables)
end

function Sections:AddTextBox(Settings)
	local Callback = Settings.Callback or function() end
	
	Settings.DefaultText = Settings.DefaultText or Settings.Name

	local DoubleClick = 0
	local DoubleClicked = false

	local Hovering = false
	local Time = 0
	
	local GoingSmaller = false

	local Holder = Utility.Create("Frame", {
		Name = "TextBox",
		Parent = self.Section.Frame,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Size = UDim2.new(0.950, 0, 0, 31),
		ZIndex = 2,
	})
	
	InteractablesInfo[Holder] = {Callback = Callback}

	Utility.Create("UIStroke", {
		Parent = Holder,
		Name = "StrokeBorder2",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55)
	})

	Utility.Create("UICorner", {
		Parent = Holder,
		CornerRadius = UDim.new(0, 4)
	})
	
	local UnderHolder = Utility.Create("Frame", {
		Name = "Under",
		Parent = Holder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 31),
		ZIndex = 2,
	})

	self:Resize()

	self:ResizePage()

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = UnderHolder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 1),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Settings.Name or "TextBox",
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.07,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Label = Utility.Create("Frame", {
		Parent = UnderHolder,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -110, 0.5, -8),
		Size = UDim2.new(0, 100, 0, 16),
		ZIndex = 2,
	})

	Utility.Create("StringValue", {
		Parent = Label,
		Name = "AddIndex"
	})

	Utility.Create("UICorner", {
		Parent = Label,
		CornerRadius = UDim.new(0, 3)
	})

	Utility.Create("UIStroke", {
		Parent = Label,
		Name = "StrokeBorder",
		Thickness = 1.5,
		Color = Color3.fromRGB(67, 67, 67),
		Transparency = 0.15,
	})

	local TextBox = Utility.Create("TextBox", {
		BackgroundTransparency = 1,
		Parent = Label,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 5, 0, 0),
		Size = UDim2.new(1, -10, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Settings.DefaultText ~= Settings.Name and Settings.DefaultText or "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12
	})

	if Settings.DefaultText ~= Settings.Name then
		InteractablesInfo[Holder].Callback(Settings.DefaultText, true)
	end

	local Button = Utility.Create("ImageButton", {
		Parent = UnderHolder,
		ZIndex = 2,
		Size = UnderHolder.Size,
		ImageTransparency = 1,
		BackgroundTransparency = 1
	})

	self:AddInstances({Holder, Holder.Size, UnderHolder.Title, UnderHolder.Title.Size, Label, Label.Size, TextBox, TextBox.Size})

	Button.MouseEnter:Connect(function()
		Hovering = true

		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 30)}):Play()
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 30)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

		Time = tick()

		while self.StrokeBorders and Hovering do
			task.wait()

			if not TextBox:IsFocused() and tick() - Time > self.StrokeBordersDelay then
				Label.StrokeBorder.Enabled = true
				
				local Old
				local Separator
				local InformationLabel

				if not GoingSmaller then
					GoingSmaller = true

					Old = self.Section.Size

					Separator, InformationLabel = InformationInteractable(self, Holder, UnderHolder, Settings.Information or "No information for this textbox was provided.")
				end

				local StrokeTween = TS:Create(Label.StrokeBorder, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.1})
				StrokeTween:Play()

				repeat task.wait() until not Hovering or TextBox:IsFocused() or tick() - Time < self.StrokeBordersDelay or not self.StrokeBorders

				StrokeTween:Cancel()
				
				if GoingSmaller then
					if self.Section.Size - UDim2.fromOffset(0, 43) == Old then
						Old = self.Section.Size - UDim2.fromOffset(0, 43)
					end

					TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
					TS:Create(self.Section, TweenInfo.new(0.3), {Size = Old}):Play()
					TS:Create(Separator, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.fromScale(0.075, 0.9)}):Play()
					TS:Create(InformationLabel, TweenInfo.new(0.2), {TextTransparency = 1, Position = UDim2.fromScale(0.075, 1.3)}):Play()
				end
				
				local Tween = TS:Create(Label.StrokeBorder, TweenInfo.new(0.3), {Color = Color3.fromRGB(67, 67, 67), Transparency = 0.15, Thickness = 1.5})
				Tween:Play()
				
				Tween.Completed:Connect(function()
					GoingSmaller = false

					Separator:Destroy()
					InformationLabel:Destroy()
					
					self:ResizePage()
				end)
			end
		end
	end)

	Button.MouseLeave:Connect(function()
		Hovering = false
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 31)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
	end)

	Button.MouseButton1Click:Connect(function()

		Time = tick()

		if Label.Size ~= UDim2.new(0, 220, 0, 16) then
			self.Instances[Label].Size = UDim2.new(0, 220, 0, 16)
			TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(1, -230, 0.5, -8)}):Play()
		else
			self.Instances[Label].Size = UDim2.new(0, 100, 0, 16)
			TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}):Play()
		end

		TextBox.TextXAlignment = Enum.TextXAlignment.Left
	end)

	UIS.InputBegan:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if isPointInBounds(Input.Position, Label) then
				DoubleClick += 1

				if DoubleClick == 2 then
					if Label.Size == UDim2.new(0, 100, 0, 16) then
						DoubleClicked = true

						self.Instances[Label].Size = UDim2.new(0, 220, 0, 16)
						TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(1, -230, 0.5, -8)}):Play()
					else
						DoubleClicked = false

						self.Instances[Label].Size = UDim2.new(0, 100, 0, 16)
						TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}):Play()
					end
				end

				task.wait(0.3)

				DoubleClick = 0
			elseif Label.Size.X.Offset > 100 and isPointInBounds(Input.Position, Label) then
				self.Instances[Label].Size = UDim2.new(0, 100, 0, 16)
				TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}):Play()
			end
		end
	end)

	TextBox:GetPropertyChangedSignal("Text"):Connect(function()

		task.spawn(function()
			InteractablesInfo[Holder].Callback(TextBox.Text, false)
		end)

		Pop(Label, 4)
	end)

	TextBox.FocusLost:Connect(function()

		task.spawn(function()
			InteractablesInfo[Holder].Callback(TextBox.Text, true)
		end)

		if DoubleClicked then
			DoubleClicked = false
			task.wait(0.1)

			self.Instances[Label].Size = UDim2.new(1, -110, 0.5, -8)
			TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}):Play()
		end

		TextBox.TextXAlignment = Enum.TextXAlignment.Center
	end)

	return setmetatable({instance = Holder, Interactable = Holder, Section = self.Section}, Interactables)
end

function Sections:AddKeybind(Settings)
	local Callback = Settings.Callback or function() end
	local Key = Settings.Key or "None"
	
	local Old

	if Key ~= "None" then
		Old = typeof(Key) == "string" and Enum.KeyCode[Key:sub(2) ~= "" and Key:sub(1,1):upper() .. Key:sub(2):lower() or Key:upper()].Name or (Key and Key.Name or "None")
		Key = typeof(Key) == "string" and Enum.KeyCode[Key:sub(2) ~= "" and Key:sub(1,1):upper() .. Key:sub(2):lower() or Key:upper()] or (Key and Key.Name or "None")
	else
		Old = "None"
		Key = "None"
	end

	if typeof(Key) == "string" and Key ~= "None" then
		Key = Enum.KeyCode[Key]
	end

	local Selecting = false
	local Stop = false

	local Hovering = false
	local Time = 0
	
	local GoingSmaller = false

	local Holder = Utility.Create("Frame", {
		Name = "Toggle",
		Parent = self.Section.Frame,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Size = UDim2.new(0.950, 0, 0, 31),
		ZIndex = 2,
	})
	
	InteractablesInfo[Holder] = {Callback = Callback}

	Utility.Create("UIStroke", {
		Parent = Holder,
		Name = "StrokeBorder2",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55)
	})

	Utility.Create("UICorner", {
		Parent = Holder,
		CornerRadius = UDim.new(0, 4)
	})
	
	local UnderHolder = Utility.Create("Frame", {
		Name = "Under",
		Parent = Holder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 31),
		ZIndex = 2,
	})

	self:Resize()

	self:ResizePage()

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = UnderHolder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 1),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Settings.Name,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.07,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Label = Utility.Create("Frame", {
		Parent = UnderHolder,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0,
		Position = UDim2.new(1, -55, 0.5, -8),
		Size = UDim2.new(0, 45, 0, 16),
		ZIndex = 2,
	})

	Utility.Create("UIStroke", {
		Parent = Label,
		Name = "StrokeBorder",
		Thickness = 1.5,
		Color = Color3.fromRGB(67, 67, 67),
		Transparency = 0.15,
	})

	Utility.Create("UICorner", {
		Parent = Label,
		CornerRadius = UDim.new(0, 3)
	})

	Utility.Create("StringValue", {
		Parent = Label,
		Name = "AddIndex"
	})

	self:AddInstances({Label, Label.Size})

	SetKeybindSize(self, Key ~= "None" and Key or {Name = Key}, Label, 0.3)

	local KeyLabel = Utility.Create("TextLabel", {
		Name = "KeyLabel",
		BackgroundTransparency = 1,
		Parent = Label,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 5, 0, 0),
		Size = UDim2.new(1, -10, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Old,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12
	})

	local Button = Utility.Create("ImageButton", {
		Parent = UnderHolder,
		ZIndex = 2,
		Size = Holder.Size,
		ImageTransparency = 1,
		BackgroundTransparency = 1
	})

	self:AddInstances({Holder, Holder.Size, UnderHolder.Title, UnderHolder.Title.Size, KeyLabel, KeyLabel.Size})

	Button.MouseEnter:Connect(function()
		Hovering = true
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 30)}):Play()
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 30)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

		Time = tick()

		while self.StrokeBorders and Hovering do
			task.wait()

			if tick() - Time > self.StrokeBordersDelay then
				Label.StrokeBorder.Enabled = true
				
				local Old
				local Separator
				local InformationLabel

				if not GoingSmaller then
					GoingSmaller = true

					Old = self.Section.Size

					Separator, InformationLabel = InformationInteractable(self, Holder, UnderHolder, Settings.Information or "No information for this keybind was provided.")
				end

				local StrokeTween = TS:Create(Label.StrokeBorder, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, Transparency = 0.1})
				StrokeTween:Play()

				repeat task.wait() until not Hovering or tick() - Time < self.StrokeBordersDelay or not self.StrokeBorders

				StrokeTween:Cancel()

				if GoingSmaller then
					if self.Section.Size - UDim2.fromOffset(0, 43) == Old then
						Old = self.Section.Size - UDim2.fromOffset(0, 43)
					end

					TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
					TS:Create(self.Section, TweenInfo.new(0.3), {Size = Old}):Play()
					TS:Create(Separator, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.fromScale(0.075, 0.9)}):Play()
					TS:Create(InformationLabel, TweenInfo.new(0.2), {TextTransparency = 1, Position = UDim2.fromScale(0.075, 1.3)}):Play()
				end

				local Tween = TS:Create(Label.StrokeBorder, TweenInfo.new(0.3), {Color = Color3.fromRGB(67, 67, 67), Transparency = 0.15, Thickness = 1.5})
				Tween:Play()

				Tween.Completed:Connect(function()
					GoingSmaller = false

					Separator:Destroy()
					InformationLabel:Destroy()

					self:ResizePage()
				end)
			end
		end
	end)

	Button.MouseLeave:Connect(function()
		Hovering = false
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 31)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
	end)

	CleanConnections[#CleanConnections + 1] = UIS.InputBegan:Connect(function(Input, GME)
		if not GME and Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key and not Selecting then
			task.spawn(function()
				InteractablesInfo[Holder].Callback(Enum.KeyCode[Key.Name])
			end)
		end
	end)

	Button.MouseButton1Click:Connect(function()
		Hovering = false
		Time = tick()

		TS:Create(Label, TweenInfo.new(0.3), {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}):Play()

		if KeyLabel.Text ~= "..." then
			Old = KeyLabel.Text
		end

		KeyLabel.Text = "..."

		Selecting = true

		Key = UIS.InputBegan:Wait()

		while Key.UserInputType ~= Enum.UserInputType.Keyboard do
			Key = UIS.InputBegan:Wait()

			task.wait()

			if not Selecting then
				Key = Old ~= "None" and Enum.KeyCode[Old] or {Name = Old}
				KeyLabel.Text = Key.Name

				SetKeybindSize(self, typeof(Key) == "Instance" and Key.KeyCode or Key, Label, 0.3)

				break
			end
		end

		SetKeybindSize(self, typeof(Key) == "Instance" and Key.KeyCode or Key, Label, 0.3)

		if not Selecting then

			if Stop then
				Stop = false
			end

			return
		end

		task.delay(0, function()
			Selecting = false
		end)

		if Stop then
			Stop = false

			return
		end

		KeyLabel.Text = Key.KeyCode.Name

		Key = Key.KeyCode
	end)

	CleanConnections[#CleanConnections + 1] = UIS.InputBegan:Connect(function(Input, GME)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not isPointInBounds(Input.Position, Holder) and KeyLabel.Text == "..." then
				Stop = true
				Selecting = false

				KeyLabel.Text = Old

				SetKeybindSize(self, Old ~= "None" and Enum.KeyCode[Old] or {Name = Old}, Label, 0.3)
			end
		end
	end)

	return setmetatable({instance = Holder, Interactable = Holder, Section = self.Section}, Interactables)
end

function Sections:AddSlider(Settings)	
	local Value = Settings.Value or 5
	local Min = Settings.Min or 0
	local Max = Settings.Max or 10

	local FixValues = Settings.FixValues or false
	local Decimal = Settings.Decimal or {false, 1}
	local Increment = Settings.Increment or 1
	
	local Callback = Settings.Callback or function() end

	local Hovering = false
	local Time = 0
	local GoingSmaller = false

	local Holder = Utility.Create("Frame", {
		Parent = self.Section.Frame,
		BackgroundTransparency = 0.1,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -50, 0.5, -8),
		Size = UDim2.new(0.950, 0, 0, 31),
		ZIndex = 2,
	})
	
	Utility.Create("UIStroke", {
		Parent = Holder,
		Name = "StrokeBorder2",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55)
	})

	Utility.Create("UICorner", {
		Parent = Holder,
		CornerRadius = UDim.new(0, 4)
	})
	
	local UnderHolder = Utility.Create("Frame", {
		Parent = Holder,
		Name = "Under",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 31),
		ZIndex = 2,
	}) 
	
	InteractablesInfo[Holder] = {Callback = Callback}

	self:Resize()

	self:ResizePage()

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = UnderHolder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.02, 0, 0.5, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Settings.Name or "Slider",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.07,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Box = Utility.Create("TextBox", {
		Parent = UnderHolder,
		BorderSizePixel = 0,
		Font = Enum.Font.Arial,
		ZIndex = 2,
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.07,
		Text = Settings.Value or 5,
		Size = UDim2.fromScale(0.1, 0.6),
		Position = UDim2.fromScale(0.42, 0.2),
		TextXAlignment = Enum.TextXAlignment.Right
	})

	local Bar = Utility.Create("Frame", {
		Parent = UnderHolder,
		Name = "Bar",
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Size = UDim2.fromScale(0.4, 0.22),
		Position = UDim2.fromScale(0.550, 0.43)
	})

	Utility.Create("UIStroke", {
		Parent = Bar,
		Name = "StrokeBorder",
		Thickness = 0,
		Color = Color3.fromRGB(15, 15, 15),
		Transparency = 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Enabled = false
	})

	local Fill = Utility.Create("Frame", {
		Parent = Bar,
		Name = "Fill",
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromScale(0.142, 1)
	})

	Utility.Create("StringValue", {
		Parent = Fill,
		Name = "AddIndex"
	})

	Utility.Create("UICorner", {
		Parent = Bar,
		CornerRadius = UDim.new(0, 8)
	})

	Utility.Create("UICorner", {
		Parent = Fill,
		CornerRadius = UDim.new(0, 8)
	})

	local Circle = Utility.Create("ImageLabel", {
		Parent = Fill,
		Name = "Circle",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(190, 190, 190),
		Position = UDim2.fromScale(-0.5, 0),
		Size = UDim2.fromOffset(12, 11),
		ZIndex = 2,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4608020054",
	})
	
	Utility.Create("UICorner", {
		Parent = Circle,
		CornerRadius = UDim.new(0, 2)
	})
	
	self:AddInstances({Holder, Holder.Size, UnderHolder.Title, UnderHolder.Title.Size, Box, Box.Size, Bar, Bar.Size, Fill, Fill.Size, Circle, Circle.Size})
	
	Circle.Size = UDim2.fromOffset()

	local Old

	local dragging = false

	UpdateSlider(Bar, Value, Min, Max, FixValues, Decimal, Increment)

	Holder.MouseEnter:Connect(function()
		Hovering = true
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 30)}):Play()
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 30)}):Play()
		TS:Create(UnderHolder.TextBox, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

		Time = tick()

		while Hovering do
			task.wait()

			if self.StrokeBorders and tick() - Time > self.StrokeBordersDelay then
				Bar.StrokeBorder.Enabled = true
				
				local Old
				local Separator
				local InformationLabel

				if not GoingSmaller then
					GoingSmaller = true

					Old = self.Section.Size

					Separator, InformationLabel = InformationInteractable(self, Holder, UnderHolder, Settings.Information or "No information for this slider was provided.")
				end

				local StrokeTween = TS:Create(Bar.StrokeBorder, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.1})
				StrokeTween:Play()

				repeat task.wait() until not Hovering or tick() - Time < self.StrokeBordersDelay or Box:IsFocused() or not self.StrokeBorders

				StrokeTween:Cancel()
				
				if GoingSmaller then
					if self.Section.Size - UDim2.fromOffset(0, 43) == Old then
						Old = self.Section.Size - UDim2.fromOffset(0, 43)
					end

					TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
					TS:Create(self.Section, TweenInfo.new(0.3), {Size = Old}):Play()
					TS:Create(Separator, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.fromScale(0.075, 0.9)}):Play()
					TS:Create(InformationLabel, TweenInfo.new(0.2), {TextTransparency = 1, Position = UDim2.fromScale(0.075, 1.3)}):Play()
				end

				local Tween = TS:Create(Bar.StrokeBorder, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 0, 0), Transparency = 0.5, Thickness = 0})
				Tween:Play()

				Tween.Completed:Connect(function()
					GoingSmaller = false

					Separator:Destroy()
					InformationLabel:Destroy()

					self:ResizePage()
					
					if Bar.StrokeBorder.Color == Color3.fromRGB(0, 0, 0) then
						Bar.StrokeBorder.Enabled = false
					end
				end)
			end
		end
	end)

	Holder.MouseLeave:Connect(function()
		Hovering = false

		if not dragging then
			TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
		else
			repeat task.wait() until not dragging

			TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
		end
		
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 31)}):Play()
		
		TS:Create(UnderHolder.TextBox, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
	end)

	Bar.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			
			if Circle.Size.X.Offset == 0 then
				TS:Create(Circle, TweenInfo.new(0.2), {Size = UDim2.fromOffset(12, 11)}):Play()
			end

			InteractablesInfo[Holder].Callback(UpdateSlider(Bar, nil, Min, Max, FixValues, Decimal, Increment))		

			repeat task.wait() until not dragging

			task.wait(0.5)

			if dragging then
				return
			end

		end
	end)

	Bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

			Hovering = false
			Time = tick()
			
			if Circle.Size.X.Offset == 0 then
				TS:Create(Circle, TweenInfo.new(0.2), {Size = UDim2.fromOffset(12, 11)}):Play()
			end

			local Num = UpdateSlider(Bar, nil, Min, Max, FixValues, Decimal, Increment)

			if Num ~= Old then
				InteractablesInfo[Holder].Callback(UpdateSlider(Bar, nil, Min, Max, FixValues, Decimal, Increment))
			end

			Old = Num

			repeat task.wait() until not dragging

			task.wait(0.5)

			if dragging then
				return
			end

		end
	end)

	Box:GetPropertyChangedSignal("Text"):Connect(function()
		Hovering = false
		Time = tick()

		if not tonumber(Box.Text:sub(#Box.Text)) then
			Box.Text = Box.Text:sub(1, -2)
		end

		local Num = tonumber(Box.Text)

		if Num then
			if FixValues then
				Box.Text = Num > Max and Max or Num < Min and Min or Box.Text
			end

			InteractablesInfo[Holder].Callback(UpdateSlider(Bar, Box.Text, Min, Max, FixValues, Decimal, Increment))
		end
	end)

	return setmetatable({instance = Holder, Interactable = Holder, Section = self.Section}, Interactables)
end

function Sections:AddDropdown(Settings)
	local Callback = Settings.Callback or function() end
	local Entries = Settings.Entries or {"Option 1", "Option 2", "Option 3"}
	
	for k,v in pairs(Entries) do
		for k2, v2 in pairs(Entries) do
			if v == v2 and k ~= k2 then
				Entries[k2] = nil
			end
		end
	end

	local Dropping = false
	local Last = 0

	local Dont = false
	local Open = false

	local Hovering = false
	local Time = 0
	
	local Clicked = false
	local Time2 = 1
	
	local LastPicked

	local Holder = Utility.Create("Frame", {
		Name = "Dropdown",
		Parent = self.Section.Frame,
		Size = UDim2.new(0.950, 0, 0, 31),
		BackgroundTransparency = 1
	})

	self:Resize()

	self:ResizePage()

	local Holder2 = Utility.Create("Frame", {
		Parent = Holder,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.fromOffset(0.02, 0),
		ZIndex = 3,
	})
	
	InteractablesInfo[Holder2] = {Callback = Callback}

	Utility.Create("UIStroke", {
		Parent = Holder2,
		Name = "StrokeBorder2",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55)
	})

	Utility.Create("UICorner", {
		Parent = Holder2,
		CornerRadius = UDim.new(0, 4)
	})

	local ScrollingFrame

	local function MakeEntries(Optional)
		
		for _,v in pairs(ScrollingFrame:GetChildren()) do
			if v.ClassName == "TextButton" then
				v:Destroy()
			end
		end

		if Entries then
			for _,v in pairs(Entries) do

				if Holder2.TextBox.Text ~= "" and (Optional and not v:lower():match(Holder2.TextBox.Text:lower())) then
					continue
				end
				
				local Continue = false
				
				for _,v2 in pairs(ScrollingFrame:GetChildren()) do
					if v2.ClassName == "TextButton" and v2.Text == v then
						Continue = true
					end
				end
				
				if Continue then
					continue
				end
				
				local Pressing = false
				local Hovering = false

				local Button = Utility.Create("TextButton", {
					Parent = ScrollingFrame,
					Name = "Dropdown Option",
					Text = v,
					TextSize = 16,
					TextWrapped = true,
					Font = Enum.Font.Arial,
					TextColor3 = Color3.fromRGB(220, 220, 220),
					TextTransparency = 0.1,
					Size = UDim2.fromScale(0.950, 0),
					Position = UDim2.fromScale(0.025, 0.22),
					ZIndex = 2,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(33, 33, 33),
					BackgroundTransparency = 0.1
				})
				
				Utility.Create("UIStroke", {
					Parent = Button,
					Name = "StrokeBorder",
					Color = LastPicked ~= v and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(180, 180, 180),
					Transparency = LastPicked ~= v and 0 or 0.1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				})

				Utility.Create("StringValue", {
					Parent = Button,
					Name = "AddIndex"
				})

				self:AddInstances({Button, UDim2.new(0.950, 0, 0, #Entries > 1 and 30 or 26)})

				TS:Create(Button, TweenInfo.new(0.2), {Size = UDim2.new(0.950, 0, 0, #Entries == 1 and 26 or 30)}):Play()

				Button.Destroying:Connect(function()
					self.Instances[Button] = nil
				end)

				Button.MouseEnter:Connect(function()
					Hovering = true

					TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, #Entries == 1 and 25 or 29), Position = UDim2.fromScale(0.035, 0.22)}):Play()
				end)

				Button.MouseLeave:Connect(function()
					Hovering = false

					TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, #Entries == 1 and 26 or 30), Position = UDim2.fromScale(0.025, 0.22)}):Play()
				end)

				Button.MouseButton1Click:Connect(function()
					
					LastPicked = v
					
					Clicked = nil
					Time2 = tick()
					
					task.spawn(function()
						InteractablesInfo[Holder2].Callback(v)
					end)

					Dont = true

					Holder2.TextBox.Text = v

					local Tween = TS:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.850, 0, 0, #Entries == 1 and 24 or 28)})
					Tween:Play()

					if #Entries == 1 then
						TS:Create(Button, TweenInfo.new(0.1), {Position = UDim2.fromScale(0.07, 0.17)}):Play()
					end

					Tween.Completed:Connect(function()
						for _, v in pairs(ScrollingFrame:GetChildren()) do
							if v.ClassName == "TextButton" and v.StrokeBorder.Color.R > 0 then
								TS:Create(v.StrokeBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 0, 0), Transparency = 0}):Play()
							end
						end
						
						TS:Create(Button.StrokeBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(180, 180, 180), Transparency = 0.1}):Play()
						
						if Hovering then
							TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, #Entries == 1 and 25 or 28)}):Play()
						else
							TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, #Entries == 1 and 26 or 30)}):Play()
						end

						if #Entries == 1 then
							if Hovering then
								TS:Create(Button, TweenInfo.new(0.1), {Position = UDim2.fromScale(0.035, 0.17)}):Play()
							else
								TS:Create(Button, TweenInfo.new(0.1), {Position = UDim2.fromScale(0.025, 0.17)}):Play()
							end
						end

					end)

					Button.TextSize = 0

					local Effect = TS:Create(Button, TweenInfo.new(0.2), {TextSize = 18})
					Effect:Play()

					Effect.Completed:Connect(function()
						TS:Create(Button, TweenInfo.new(0.1), {TextSize = 16}):Play()
						
						if Dropping then
							return
						end
						
						task.wait(0.350)
						
						Dropping = true
						
						Open = false

						for _,v in pairs(ScrollingFrame:GetChildren()) do
							if v.ClassName == "TextButton" or v.Name == "First" then
								TS:Create(v.Name ~= "First" and v.StrokeBorder or v["Dropdown Option"].StrokeBorder, TweenInfo.new(0.2), {Thickness = 0}):Play()

								local Tween = TS:Create(v.Name ~= "First" and v or v["Dropdown Option"], TweenInfo.new(0.2), {Size = UDim2.fromScale(v.Name ~= "First" and 0.950 or 1, 0), TextTransparency = 1, BackgroundTransparency = 1})
								Tween:Play()

								Tween.Completed:Connect(function()
									v:Destroy()
								end)					
							end
						end

						local Size = self:Resize()

						self.Instances[self.Section].Size = UDim2.new(1, -16, 0, Size - tonumber(Holder.AbsoluteSize.Y) + 31)
						self.Section.Size = UDim2.new(1, -16, 0, Size - tonumber(Holder.AbsoluteSize.Y) + 31)

						self:ResizePage()

						TS:Create(Holder2["Dropdown Arrow"], TweenInfo.new(0.3), {Rotation = 0}):Play()
						TS:Create(Holder, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()

						TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
						TS:Create(Holder.List, TweenInfo.new(0.3), {Size = UDim2.new(0.970, 0, 0, 31), Position = UDim2.fromScale(0.010, 0), BackgroundTransparency = 1}):Play()

						self.Instances[Holder.List].Size = UDim2.new(0.970, 0, 0, 31)

						TS:Create(ScrollingFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 31)}):Play()
						
						task.wait(0.3)
						
						Dropping = false
					end)
				end)

				Utility.Create("UICorner", {
					Parent = Button,
					CornerRadius = UDim.new(0, 3)
				})

				if Optional and not StartsWith(v:lower(), Holder2.TextBox.Text:lower()) then
					task.spawn(function()
						if Holder2.TextBox.Text:len() <= 1 then

							if Holder2.TextBox.Text:len() == 1 then
								Button:Destroy()
							end

							TS:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()

							task.wait(0.2)

							Button:Destroy()
						else
							Button:Destroy()
						end
					end)
				end

				Last = Holder2.TextBox.Text:len()
			end
		end
	end

	Utility.Create("TextLabel", {
		Parent = Holder2,
		Name = "Title",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.02, 0, 0.5, 0),
		Size = UDim2.new(0.3, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Settings.Name or "Dropdown",
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.07,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local TextBox = Utility.Create("TextBox", {
		Parent = Holder2,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.660, 0, 0.5, 0),
		Size = UDim2.new(0.27, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = "",
		TextColor3 = Color3.fromRGB(220, 220, 220),
		PlaceholderText = "None Selected",
		PlaceholderColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.07,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	self:AddInstances({Holder2, Holder2.Size, Holder2.Title, Holder2.Title.Size, TextBox, TextBox.Size})

	Holder.MouseEnter:Connect(function()
		Hovering = true
		
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, Open and #Entries <= 3 and #Entries * 40 + 30 or Open and 163 or 30)}):Play()
		TS:Create(Holder2.Title, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TS:Create(TextBox, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255), PlaceholderColor3 = Color3.fromRGB(255, 255, 255)}):Play()

		Time = tick()

		while self.StrokeBorders and Hovering do
			task.wait()

			if tick() - Time > self.StrokeBordersDelay then
				local StrokeTween = TS:Create(Holder2["Dropdown Arrow"], TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {ImageTransparency = 0.7})
				StrokeTween:Play()

				repeat task.wait() until not Hovering or tick() - Time < self.StrokeBordersDelay or not self.StrokeBorders

				StrokeTween:Cancel()
				Holder2["Dropdown Arrow"].ImageTransparency = 0
			end
		end
	end)

	Holder.MouseLeave:Connect(function()
		Hovering = false
		
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, Open and Open and #Entries == 1 and 64 or Open and #Entries <= 3 and #Entries * 40 + 30 or Open and 163 or 31)}):Play()
		TS:Create(Holder2.Title, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		TS:Create(TextBox, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220), PlaceholderColor3 = Color3.fromRGB(220, 220, 220)}):Play()
	end)

	TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		
		if tick() - Time2 < 0.01 then
			Clicked = nil
		else
			Clicked = TextBox.Text
		end

		if Dont then
			Dont = false
			return
		end

		if Holder.List.Size.Y.Offset == 31 then
			return
		end

		if TextBox.Text == "" then
			MakeEntries()
			return
		end

		MakeEntries(TextBox.Text)
	end)

	Utility.Create("ImageButton", {
		Name = "Dropdown Arrow",
		Parent = Holder2,
		Image = "http://www.roblox.com/asset/?id=293296862",
		ZIndex = 4,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.93, 0, 0, 0),
		Size = UDim2.fromScale(0.060, 0.9)
	})

	local List = Utility.Create("Frame", {
		BackgroundTransparency = 1,
		Name = "List",
		Parent = Holder,
		BackgroundColor3 = Color3.fromRGB(17, 17, 17),
		BorderSizePixel = 0,
		Size = UDim2.new(0.97, 0, 0, 31),
		Position = UDim2.fromScale(0.010, 0),
		ZIndex = 2,
	})

	Utility.Create("StringValue", {
		Parent = List,
		Name = "AddIndex"
	})

	Utility.Create("UICorner", {
		Parent = List,
		CornerRadius = UDim.new(0, 3)
	})

	self:AddInstances({List, List.Size, Holder2["Dropdown Arrow"], Holder2["Dropdown Arrow"].Size})

	ScrollingFrame = Utility.Create("ScrollingFrame", {
		Visible = false,
		Parent = List,
		Size = UDim2.new(1, 0, 0, 30),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
	})

	local Button = Utility.Create("ImageButton", {
		Parent = Holder,
		ZIndex = 2,
		Size = UDim2.new(0.65, 0, 0, 31),
		ImageTransparency = 1,
		BackgroundTransparency = 1
	})

	if #Entries > 1 then

		Utility.Create("UIListLayout", {
			Parent = ScrollingFrame,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	end
	
	local function HandleDropdown()
		Hovering = false
		Time = tick()

		if Dropping then
			return
		end

		Dropping = true

		if Holder2["Dropdown Arrow"].Rotation == 0 then
			Open = true

			TS:Create(Holder2["Dropdown Arrow"], TweenInfo.new(0.3), {Rotation = 180}):Play()
			TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, #Entries == 1 and 64 or #Entries <= 3 and #Entries * 40 + 30 or 163), BackgroundTransparency = 1}):Play()

			TS:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(0.970, 0, 0, #Entries <= 3 and #Entries * 40 or 132), BackgroundTransparency = 0.1, Position = UDim2.fromScale(0.010, #Entries > 3 and 0.190 or #Entries == 3 and 0.208 or #Entries == 2 and 0.280 or #Entries == 1 and 0.392)}):Play()

			self.Instances[List].Size = UDim2.new(0.970, 0, 0, #Entries <= 3 and #Entries * 40 or 132)

			ScrollingFrame.Visible = true
			TS:Create(ScrollingFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, #Entries <= 3 and #Entries * 40 or 128)}):Play()

			MakeEntries(Clicked)

			if #Entries > 3 then

				local Size = 0

				for _,v in pairs(ScrollingFrame:GetChildren()) do
					if v.ClassName == "TextButton" or v.Name == "First" then
						Size += 37
					end
				end

				ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, Size)
			else
				ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			end

			self:Resize()
			self:ResizePage(true)

		else

			Open = false

			for _,v in pairs(ScrollingFrame:GetChildren()) do
				if v.ClassName == "TextButton" or v.Name == "First" then
					TS:Create(v.Name ~= "First" and v.StrokeBorder or v["Dropdown Option"].StrokeBorder, TweenInfo.new(0.2), {Thickness = 0}):Play()
					
					local Tween = TS:Create(v.Name ~= "First" and v or v["Dropdown Option"], TweenInfo.new(0.2), {Size = UDim2.fromScale(v.Name ~= "First" and 0.950 or 1, 0), TextTransparency = 1, BackgroundTransparency = 1})
					Tween:Play()

					Tween.Completed:Connect(function()
						v:Destroy()
					end)					
				end
			end

			local Size = self:Resize()

			self.Instances[self.Section].Size = UDim2.new(1, -16, 0, Size - tonumber(Holder.AbsoluteSize.Y) + 31)
			self.Section.Size = UDim2.new(1, -16, 0, Size - tonumber(Holder.AbsoluteSize.Y) + 31)

			self:ResizePage()

			TS:Create(Holder2["Dropdown Arrow"], TweenInfo.new(0.3), {Rotation = 0}):Play()
			TS:Create(Holder, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()

			TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
			TS:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(0.970, 0, 0, 31), Position = UDim2.fromScale(0.010, 0), BackgroundTransparency = 1}):Play()

			self.Instances[List].Size = UDim2.new(0.970, 0, 0, 31)

			TS:Create(ScrollingFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 31)}):Play()

		end

		task.wait(0.3)

		Dropping = false
	end

	Holder2["Dropdown Arrow"].MouseButton1Click:Connect(function()
		HandleDropdown()
	end)

	Button.MouseButton1Click:Connect(function()
		HandleDropdown()
	end)

	return setmetatable({instance = Holder, Interactable = Holder2, Section = self.Section}, Interactables)
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")

local Color = {}
Color.__index = Color

export type ParameterStyle = {
	Color: Color3?,
	Transparency: number?,
}

export type Parameters = {
	Position: UDim2?,
	RoundedCorners: number?,
	Draggable: boolean?,
	ZIndex: number?,
	Size: number?,

	Primary: ParameterStyle?,
	Secondary: ParameterStyle?,
	Topbar: ParameterStyle?,
	Text: ParameterStyle?,
}

function toPolar(v)
	return math.atan2(v.Y,v.X),v.Magnitude
end

function radToDeg(x)
	return ((x + math.pi) / (2 * math.pi)) * 360
end

function getScreenGuiWorldDetails(gui)
	local part = gui.Parent
	if gui.Face == Enum.NormalId.Front then
		return part.Position + part.CFrame.LookVector * part.Size.Z / 2,part.CFrame.LookVector
	elseif gui.Face == Enum.NormalId.Back then
		return part.Position + part.CFrame.LookVector * -part.Size.Z / 2,-part.CFrame.LookVector
	elseif gui.Face == Enum.NormalId.Right then
		return part.Position + part.CFrame.RightVector * part.Size.X / 2,part.CFrame.RightVector
	elseif gui.Face == Enum.NormalId.Left then
		return part.Position + part.CFrame.RightVector * -part.Size.X / 2,-part.CFrame.RightVector
	elseif gui.Face == Enum.NormalId.Top then
		return part.Position + part.CFrame.UpVector * part.Size.Y / 2,part.CFrame.UpVector
	elseif gui.Face == Enum.NormalId.Bottom then
		return part.Position + part.CFrame.UpVector * -part.Size.Y / 2,-part.CFrame.UpVector
	end
end

function template(tab,t)
	tab = (tab and (typeof(tab) == "table")) and tab or {}
	for i,v in pairs(t) do
		if tab[i] == nil or (typeof(v) == "table") then
			tab[i] = (typeof(v) == "table") and template(tab[i] or {},v) or v
		end
	end

	return tab
end

function roundToHundredths(num)
	return math.round(num * 100) / 100
end

script = workspace.Color

function Color.New(gui : LayerCollector,params : Parameters?)
	if gui:IsA("SurfaceGui") then
		assert(gui.Face == Enum.NormalId.Front,"Color Picker - SurfaceGui must have it's Face property set to 'Front' to work properly")
	end

	local defaultPos = gui:IsA("ScreenGui") and (UserInputService:GetMouseLocation() + Vector2.new(16,-20)) or Vector2.zero
	params = template(params,{
		Name = "Color Picker",
		Position = UDim2.fromOffset(defaultPos.X,defaultPos.Y),
		RoundedCorners = true,
		Draggable = true,
		ZIndex = 1,
		Size = 0.4,

		Primary = {Color = Color3.fromRGB(26,26,36),Transparency = 0},
		Secondary = {Color = Color3.fromRGB(36,36,46),Transparency = 0},
		Topbar = {Color = Color3.fromRGB(21,21,31),Transparency = 0},
		Text = {Color = Color3.fromRGB(255,255,255),Transparency = 0}
	})

	local self = setmetatable({},Color)
	self.Params = params
	self.Gui = gui

	self.Connections = {}

	self:Create(params.Name)
	self:SetColor(Color3.fromRGB(255,255,255))

	return self
end

function Color:Create()
	local sample = self.Gui.ColorWindow
	sample.Position = self.Params.Position
	sample.Size = UDim2.fromScale(self.Params.Size,self.Params.Size)
	sample.ZIndex = self.Params.ZIndex
	sample.Parent = self.Gui
	sample.Visible = true
	
	sample.Topbar.Title.Text = self.Params.Name

	if self.Params.Draggable then
		sample.Topbar.Button.MouseButton1Down:Connect(function()
			local startMousePos = self:GetMousePos() or Vector2.zero
			local startWindowPos = self.Instance.Position
			self._dragFunc = RunService.Heartbeat:Connect(function()
				local pos = ((self:GetMousePos() or Vector2.zero) - startMousePos)
				TS:Create(self.Instance, TweenInfo.new(0.090, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Position = startWindowPos + UDim2.fromOffset(pos.X,pos.Y)}):Play()
			end)
		end)
	end

	self.Updated = sample.UpdateEvent.Event
	self.Finished = sample.FinishedEvent.Event

	self.Canceled = sample.CanceledEvent.Event
	self.Cancelled = sample.CanceledEvent.Event

	local function _updateVisual(tab,params)
		for i,v in pairs(tab) do
			for q,e in pairs(params) do
				v[q] = e
			end
		end
	end

	_updateVisual(
		{sample.Content.Background.Top,sample.Content.Background.Bottom.Frame,sample.Properties},
		{BackgroundColor3 = self.Params.Primary.Color,BackgroundTransparency = self.Params.Primary.Transparency}
	)

	_updateVisual(
		{sample.Properties.Line,sample.Content.Bottom.Hex.Frame},
		{BackgroundColor3 = self.Params.Secondary.Color,BackgroundTransparency = self.Params.Secondary.Transparency}
	)

	_updateVisual(
		{sample.Topbar.Frame,sample.Topbar.Top.Frame},
		{BackgroundColor3 = self.Params.Topbar.Color,BackgroundTransparency = self.Params.Topbar.Transparency}
	)

	for i,v in pairs({sample.Properties.HSV,sample.Properties.RGB}) do
		for q,e in pairs(v:GetChildren()) do
			if e:IsA("Frame") then
				e.Frame.BackgroundColor3 = self.Params.Secondary.Color
				e.Frame.BackgroundTransparency = self.Params.Secondary.Transparency
			end
		end
	end

	for i,v in pairs(sample:GetDescendants()) do
		if not self.Params.RoundedCorners and v:IsA("UICorner") and v.Parent.Name ~= "Select" then
			v:Destroy()
		end

		if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("ImageButton") then
			v[(v:IsA("TextLabel") or v:IsA("TextBox")) and "TextColor3" or "ImageColor3"] = self.Params.Text.Color
			v[(v:IsA("TextLabel") or v:IsA("TextBox")) and "TextTransparency" or "ImageTransparency"] = self.Params.Text.Transparency
		end
	end

	local wheel = sample.Content.Wheel
	self.Connections.wheelMainUpdate = wheel.Button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if self.Gui:IsA("PluginGui") then sample.Button.Visible = true end
			self.Connections.wheelReposition = RunService.Heartbeat:Connect(function(dt)
				local mousePos = self:GetMousePos()
				if mousePos and wheel and wheel:FindFirstChild("Image") and wheel.Image:FindFirstChild("Select") then
					local wheelMid = wheel.Image.AbsolutePosition + wheel.Image.AbsoluteSize / 2
					local toWheelMid = (mousePos - wheelMid) / wheel.Image.AbsoluteSize
					if toWheelMid.Magnitude > 0.5 then
						toWheelMid = toWheelMid.Unit / 2
					end

					wheel.Image.Select.Position = UDim2.fromScale(0.5 + toWheelMid.X,0.5 + toWheelMid.Y)

					local phi,len = toPolar(toWheelMid * Vector2.new(1,-1))
					local hue,saturation = math.clamp(radToDeg(phi) / 360,0,1),math.clamp(len * 2,0,1)

					self.Saturation = saturation
					self.Hue = hue

					self:UpdateColorVisual()
				end
			end)
		end
	end)

	local valueSlider = sample.Content.Right.Value
	self.Connections.valueMainUpdate = valueSlider.Button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if self.Gui:IsA("PluginGui") then sample.Button.Visible = true end
			self.Connections.valueReposition = RunService.Heartbeat:Connect(function(dt)
				local mousePos = self:GetMousePos()
				if mousePos and valueSlider and valueSlider:FindFirstChild("Select") then
					local valueTop = valueSlider.AbsolutePosition

					local v = 1 - math.clamp((mousePos.Y - valueTop.Y) / valueSlider.AbsoluteSize.Y,0,1)
					self.Value = v

					valueSlider.Select.Position = UDim2.fromScale(0,1 - v)
					self:UpdateColorVisual()
				end
			end)
		end
	end)

	local function _mouseUpEvent()
		sample.Button.Visible = false
		if self.Connections.wheelReposition then
			self.Connections.wheelReposition:Disconnect()
			self.Connections.wheelReposition = nil
		end

		if self.Connections.valueReposition then
			self.Connections.valueReposition:Disconnect()
			self.Connections.valueReposition = nil
		end

		if self._dragFunc then
			self._dragFunc:Disconnect()
			self._dragFunc = nil
		end
	end

	if not self.Gui:IsA("PluginGui") then
		self.Connections.inputEnded = UserInputService.InputEnded:Connect(function(input,typing)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				_mouseUpEvent()
			end
		end)
	else
		self.Connections.inputEnded = sample.Button.MouseButton1Up:Connect(_mouseUpEvent)
		self.Connections.inputEnded2 = self.Gui.WindowFocusReleased:Connect(_mouseUpEvent)
	end

	sample.Content.Bottom.Hex.Frame.TextBox.FocusLost:Connect(function()
		local hexText = sample.Content.Bottom.Hex.Frame.TextBox.Text
		local success,color = pcall(function() return Color3.fromHex(hexText) end)
		sample.Content.Bottom.Hex.Frame.InvalidStroke.Enabled = not success

		if not success then
			warn(string.format("%s is not a valid hex color.",hexText))
			return
		end

		self:SetColor(color)
	end)

	for i,v in pairs(sample.Properties.RGB:GetChildren()) do
		if v:IsA("Frame") then
			v.Frame.TextBox.FocusLost:Connect(function()
				self:SetColor(Color3.fromRGB(
					math.clamp(tonumber(sample.Properties.RGB.R.Frame.TextBox.Text) or 255,0,255),
					math.clamp(tonumber(sample.Properties.RGB.G.Frame.TextBox.Text) or 255,0,255),
					math.clamp(tonumber(sample.Properties.RGB.B.Frame.TextBox.Text) or 255,0,255)
					))
			end)
		end
	end

	for i,v in pairs(sample.Properties.HSV:GetChildren()) do
		if v:IsA("Frame") then
			v.Frame.TextBox.FocusLost:Connect(function()
				self:SetColor(Color3.fromHSV(
					math.clamp(tonumber(sample.Properties.HSV.H.Frame.TextBox.Text) or 0,0,360) / 360,
					math.clamp(tonumber(sample.Properties.HSV.S.Frame.TextBox.Text) or 1,0,1),
					math.clamp(tonumber(sample.Properties.HSV.V.Frame.TextBox.Text) or 1,0,1)
					))
			end)
		end
	end

	sample.Content.Bottom.Buttons.Confirm.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sample.FinishedEvent:Fire(Color3.fromHSV(self.Hue,self.Saturation,self.Value))
		end
	end)

	sample.Content.Bottom.Buttons.Cancel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sample.CanceledEvent:Fire()
		end
	end)

	self.Instance = sample
	
	TS:Create(sample, TweenInfo.new(0.3), {Size = UDim2.fromScale(self.Params.FinalSize, self.Params.FinalSize)}):Play()
	
	return sample
end

function Color:GetMousePos()
	local mousePos = UserInputService:GetMouseLocation()
	if self.Gui:IsA("ScreenGui") then
		return mousePos - Vector2.new(0,36)
	elseif self.Gui:IsA("PluginGui") then
		return self.Gui:GetRelativeMousePosition()
	else
		local ray = game.Workspace.CurrentCamera:ViewportPointToRay(mousePos.X,mousePos.Y)
		local planePoint,planeNormal = getScreenGuiWorldDetails(self.Gui)

		local p = -((ray.Origin - planePoint):Dot(planeNormal)) / (ray.Direction:Dot(planeNormal))
		local mouseHit = ray.Origin + ray.Direction * p

		local relative = (-self.Gui.Parent.CFrame:PointToObjectSpace(mouseHit) + self.Gui.Parent.Size / 2) * self.Gui.PixelsPerStud
		return Vector2.new(relative.X,relative.Y)
	end
end

function Color:UpdateColorVisual()
	if self.Instance then
		local color = Color3.fromHSV(self.Hue,self.Saturation,self.Value)
		self.Instance.UpdateEvent:Fire(color)

		self.Instance.Content.Right.Value.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromHSV(self.Hue,self.Saturation,1)),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))
		})

		self.Instance.Content.Bottom.Color.Frame.BackgroundColor3 = color
		self.Instance.Content.Bottom.Hex.Frame.TextBox.Text = string.format("#%s",color:ToHex())

		self.Instance.Properties.RGB.R.Frame.TextBox.Text = math.floor(color.R * 255)
		self.Instance.Properties.RGB.G.Frame.TextBox.Text = math.floor(color.G * 255)
		self.Instance.Properties.RGB.B.Frame.TextBox.Text = math.floor(color.B * 255)

		self.Instance.Properties.HSV.H.Frame.TextBox.Text = math.floor(self.Hue * 360)
		self.Instance.Properties.HSV.S.Frame.TextBox.Text = roundToHundredths(self.Saturation)
		self.Instance.Properties.HSV.V.Frame.TextBox.Text = roundToHundredths(self.Value)

		self.Instance.Content.Bottom.Hex.Frame.InvalidStroke.Enabled = false
	end
end

function Color:SetColor(c : Color3)
	if self.Instance then
		local h,s,v = c:ToHSV()
		self.Saturation = s
		self.Value = v
		self.Hue = h

		local h2 = h * math.pi * 2
		local wv = Vector2.new(-math.cos(h2) / 2 * s,math.sin(h2) / 2 * s)
		self.Instance.Content.Wheel.Image.Select.Position = UDim2.fromScale(0.5 + wv.X,0.5 + wv.Y)
		self.Instance.Content.Right.Value.Select.Position = UDim2.fromScale(0,1 - v)

		self:UpdateColorVisual()
	end
end

function Color:Destroy()
	for i,v in pairs(self.Connections) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		end
	end

	if self._dragFunc then
		self._dragFunc:Disconnect()
		self._dragFunc = nil
	end

	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

function Sections:AddColorPicker(Settings)
	local Callback = Settings.Callback or function() end

	local Hovering = false
	local Time = 0
	
	local ColorPicker
	local GoingSmaller = false
	
	local OldColor = Settings.DefaultColor or Color3.fromRGB(255, 255, 255)
	
	local Holder = Utility.Create("Frame", {
		Name = "ColorPicker",
		Parent = self.Section.Frame,
		BackgroundTransparency = 0.1,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -50, 0.5, -8),
		Size = UDim2.new(0.950, 0, 0, 31),
		ZIndex = 2,
	})
	
	Utility.Create("UIStroke", {
		Parent = Holder,
		Name = "StrokeBorder",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55)
	})

	Utility.Create("UICorner", {
		Parent = Holder,
		CornerRadius = UDim.new(0, 4)
	})
	
	local UnderHolder = Utility.Create("Frame", {
		Name = "Under",
		Parent = Holder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 31),
		ZIndex = 2,
	})
	
	local Button = Utility.Create("ImageButton", {
		Parent = UnderHolder,
		ZIndex = 2,
		Size = UDim2.fromScale(1, 1),
		ImageTransparency = 1,
		BackgroundTransparency = 1
	})
	
	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = UnderHolder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.02, 0, 0.5, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Settings.Name or "ColorPicker",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextTransparency = 0.07,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local Preview = Utility.Create("Frame", {
		Name = "Preview",
		Parent = UnderHolder,
		BackgroundColor3 = Settings.DefaultColor or Color3.fromRGB(255, 255, 255),
		Position = UDim2.fromScale(0.84, 0.250),
		Size = UDim2.fromScale(0.130, 0.550),
		ZIndex = 2,
	})
	
	Utility.Create("UIStroke", {
		Parent = Preview,
		Name = "StrokeBorder2",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 2,
		Color = Color3.fromRGB(68, 68, 68)
	})
	
	Utility.Create("UICorner", {
		Parent = Preview,
		CornerRadius = UDim.new(0, 3)
	})
	
	self:Resize()
	self:ResizePage()
	
	self:AddInstances({Holder, Holder.Size, UnderHolder.Title, UnderHolder.Title.Size, Preview, Preview.Size})
	
	Holder.MouseEnter:Connect(function()
		Hovering = true

		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 30)}):Play()
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 30)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

		Time = tick()

		while self.StrokeBorders and Hovering do
			task.wait()

			if tick() - Time > self.StrokeBordersDelay then
				local StrokeTween = TS:Create(Holder.StrokeBorder, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, Transparency = 0.1})
				StrokeTween:Play()
				
				local Old
				local Separator
				local InformationLabel

				if not GoingSmaller then
					GoingSmaller = true

					Old = self.Section.Size

					Separator, InformationLabel = InformationInteractable(self, Holder, UnderHolder, Settings.Information or "No information for this colorpicker was provided.")
				end

				repeat task.wait() until not Hovering or tick() - Time < self.StrokeBordersDelay or not self.StrokeBorders

				StrokeTween:Cancel()
				
				if GoingSmaller then
					if self.Section.Size - UDim2.fromOffset(0, 43) == Old then
						Old = self.Section.Size - UDim2.fromOffset(0, 43)
					end

					TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
					TS:Create(self.Section, TweenInfo.new(0.3), {Size = Old}):Play()
					TS:Create(Separator, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.fromScale(0.075, 0.9)}):Play()
					TS:Create(InformationLabel, TweenInfo.new(0.2), {TextTransparency = 1, Position = UDim2.fromScale(0.075, 1.3)}):Play()
					
					task.delay(0.3, function()
						GoingSmaller = false

						Separator:Destroy()
						InformationLabel:Destroy()

						self:ResizePage()
					end)
				end

				TS:Create(Holder.StrokeBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(55, 55, 55), Thickness = 1, Transparency = 0}):Play()
			end
		end
	end)

	Holder.MouseLeave:Connect(function()
		Hovering = false

		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 31)}):Play()
		TS:Create(UnderHolder, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 31)}):Play()
		TS:Create(UnderHolder.Title, TweenInfo.new(0.2), {TextTransparency = 0.07, TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
		TS:Create(Preview, TweenInfo.new(0.1), {Size = UDim2.fromScale(0.130, 0.550), Position = UDim2.fromScale(0.84, 0.250)}):Play()
	end)
	
	Button.MouseButton1Down:Connect(function()
		TS:Create(Preview, TweenInfo.new(0.1), {Size = UDim2.fromScale(0.120, 0.4), Position = UDim2.fromScale(0.85, 0.3)}):Play()
	end)
	
	Button.MouseButton1Click:Connect(function()
		Hovering = false

		local Tween = TS:Create(Preview, TweenInfo.new(0.1), {Size = UDim2.fromScale(0.110, 0.250), Position = UDim2.fromScale(0.855, 0.320)})
		Tween:Play()
		
		Tween.Completed:Connect(function()
			TS:Create(Preview, TweenInfo.new(0.1), {Size = UDim2.fromScale(0.130, 0.550), Position = UDim2.fromScale(0.84, 0.250)}):Play()
		end)

		if ColorPicker then
			ColorPickerClose(ColorPicker)
			ColorPicker = nil
			return
		end

		local PickerSC = Utility.Create("ScreenGui", {
			Parent = Holder,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		})
		
		local ColorWindow = Utility.Create("Frame", {
			Parent = PickerSC,
			Name = "ColorWindow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(26, 26, 36),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 0,
			Position = UDim2.new(0.546, 533, 0.267, -32),
			Size = UDim2.fromScale(0.27, 0.27),
			Visible = false
		})
		
		Utility.Create("UIAspectRatioConstraint", {
			Parent = ColorWindow,
			AspectRatio = 1.1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width
		})
		
		for _, v in {"CanceledEvent", "FinishedEvent", "UpdateEvent"} do
		
			Utility.Create("BindableEvent", {
				Parent = ColorWindow,
				Name = v
			})
		end
			
		local Content = Utility.Create("Frame", {
			Parent = ColorWindow,
			Name = "Content",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(26, 26, 36),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.9)
		})
		
		local Background = Utility.Create("Folder", {
			Parent = Content,
			Name = "Background",
		})
		
		local BottomBackground = Utility.Create("Frame", {
			Parent = Background,
			Name = "Bottom",
			BackgroundColor3 = Color3.fromRGB(26, 26, 36),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(1, 0.5),
			ZIndex = 0,
			ClipsDescendants = true
		})
		
		local FrameBottomBackground = Utility.Create("Frame", {
			Parent = BottomBackground,
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(34, 34, 34),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 2)
		})
		
		Utility.Create("UICorner", {
			Parent = FrameBottomBackground,
			CornerRadius = UDim.new(0.05, 0)
		})
		
		Utility.Create("Frame", {
			Parent = Background,
			Name = "Top",
			BackgroundColor3 = Color3.fromRGB(34, 34, 34),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.5),
			ZIndex = 0
		})
		
		local Bottom = Utility.Create("Frame", {
			Parent = Content,
			Name = "Bottom",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.15)
		})
		
		local Buttons = Utility.Create("Frame", {
			Parent = Bottom,
			Name = "Buttons",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0.2, 0.5),
			Size = UDim2.fromScale(0.3, 0.8)
		})
		
		local Cancel = Utility.Create("ImageButton", {
			Parent = Buttons,
			Name = "Cancel",
			AnchorPoint = Vector2.new(1, 0),
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://3192543734",
			ImageColor3 = Color3.fromRGB(220, 220, 220),
			ImageTransparency = 0.07,
			ScaleType = Enum.ScaleType.Stretch
		})
		
		Utility.Create("UIAspectRatioConstraint", {
			Parent = Cancel,
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width
		})
		
		local Confirm = Utility.Create("ImageButton", {
			Parent = Buttons,
			Name = "Confirm",
			AnchorPoint = Vector2.new(0, 0),
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://4510424237",
			ImageColor3 = Color3.fromRGB(220, 220, 220),
			ImageTransparency = 0.07,
			ScaleType = Enum.ScaleType.Stretch
		})
		
		Utility.Create("UIAspectRatioConstraint", {
			Parent = Confirm,
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width
		})
		
		local ColorFrame = Utility.Create("Frame", {
			Parent = Bottom,
			Name = "Color",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1)
		})
		
		Utility.Create("UIAspectRatioConstraint", {
			Parent = ColorFrame,
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width
		})
		
		local Frame = Utility.Create("Frame", {
			Parent = ColorFrame,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8)
		})
		
		Utility.Create("UICorner", {
			Parent = Frame,
			CornerRadius = UDim.new(0.35, 0)
		})
		
		local Hex = Utility.Create("Frame", {
			Parent = Bottom,
			Name = "Hex",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0.55, 0),
			Size = UDim2.fromScale(0.4, 1)
		})
		
		local Frame2 = Utility.Create("Frame", {
			Parent = Hex,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.6)
		})
		
		Utility.Create("UIStroke", {
			Parent = Frame2,
			Name = "InvalidStroke",
			Color = Color3.fromRGB(255, 75, 75),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Enabled = false
		})
		
		Utility.Create("UICorner", {
			Parent = Frame2,
			CornerRadius = UDim.new(0.3, 0)
		})
		
		Utility.Create("TextBox", {
			Parent = Frame2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.6),
			Text = ""
		})
		
		local Right = Utility.Create("Frame", {
			Parent = Content,
			Name = "Right",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.3, 0.85)
		})
		
		local Value = Utility.Create("Frame", {
			Parent = Right,
			Name = "Value",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.25, 0.5),
			Size = UDim2.fromScale(0.8, 0.8)
		})
		
		Utility.Create("UIAspectRatioConstraint", {
			Parent = Value,
			AspectRatio = 0.1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width
		})
		
		Utility.Create("UIGradient", {
			Parent = Value,
			Offset = Vector2.new(0, 0),
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
			})
		})
		
		local Select = Utility.Create("Frame", {
			Parent = Value,
			Name = "Select",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1)
		})
		
		Utility.Create("UIAspectRatioConstraint", {
			Parent = Select,
			AspectRatio = 4,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width
		})
		
		local Select2 = Utility.Create("Frame", {
			Parent = Select,
			Name = "Select",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.5, 1.5)
		})
		
		Utility.Create("UICorner", {
			Parent = Select2,
			CornerRadius = UDim.new(0.5, 0)
		})
		
		Utility.Create("UIStroke", {
			Parent = Select2,
			Color = Color3.fromRGB(255, 255, 255),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2
		})
		
		Utility.Create("TextButton", {
			Parent = Value,
			Name = "Button",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 99,
			Text = ""
		})
		
		local Wheel = Utility.Create("Frame", {
			Parent = Content,
			Name = "Wheel",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(0.85, 0.85)
		})
		
		Utility.Create("UIAspectRatioConstraint", {
			Parent = Wheel,
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width
		})
		
		Utility.Create("TextButton", {
			Parent = Wheel,
			Name = "Button",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 99,
			Text = ""
		})
		
		local Image = Utility.Create("ImageLabel", {
			Parent = Wheel,
			Name = "Image",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			Image = "rbxassetid://2849458409",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Stretch
		})
		
		local ImageSelect = Utility.Create("Frame", {
			Parent = Image,
			Name = "Select",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.06, 0.06)
		})
		
		Utility.Create("UICorner", {
			Parent = ImageSelect,
			CornerRadius = UDim.new(0.5, 0)
		})
		
		Utility.Create("UIStroke", {
			Parent = ImageSelect,
			Color = Color3.fromRGB(0, 0, 0),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2
		})
		
		local Properties = Utility.Create("Frame", {
			Parent = ColorWindow,
			Name = "Properties",
			BackgroundColor3 = Color3.fromRGB(34, 34, 34),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0, 1.01),
			Size = UDim2.fromScale(1, 0.3),
		})
		
		Utility.Create("UICorner", {
			Parent = Properties,
			CornerRadius = UDim.new(0.165, 0)
		})
		
		local HSV = Utility.Create("Frame", {
			Parent = Properties,
			Name = "HSV",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(1, 0.5)
		})
		
		Utility.Create("UIListLayout", {
			Parent = HSV,
			Padding = UDim.new(0, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = false,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
			VerticalAlignment = Enum.VerticalAlignment.Top
		})
		
		local H = Utility.Create("Frame", {
			Parent = HSV,
			Name = "H",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Size = UDim2.fromScale(0.3, 1)
		})
		
		local FrameH = Utility.Create("Frame", {
			Parent = H,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.3, 0.5),
			Size = UDim2.fromScale(0.6, 0.6)
		})
		
		Utility.Create("UICorner", {
			Parent = FrameH,
			CornerRadius = UDim.new(0.3, 0)
		})
		
		Utility.Create("TextBox", {
			Parent = FrameH,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.6),
			Text = "",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})
		
		Utility.Create("TextLabel", {
			Parent = H,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.4),
			Text = "H",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})
		
		local S = Utility.Create("Frame", {
			Parent = HSV,
			Name = "S",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Size = UDim2.fromScale(0.3, 1)
		})

		local FrameS = Utility.Create("Frame", {
			Parent = S,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.3, 0.5),
			Size = UDim2.fromScale(0.6, 0.6)
		})

		Utility.Create("UICorner", {
			Parent = FrameS,
			CornerRadius = UDim.new(0.3, 0)
		})

		Utility.Create("TextBox", {
			Parent = FrameS,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.6),
			Text = "",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})

		Utility.Create("TextLabel", {
			Parent = S,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.4),
			Text = "S",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})
		
		local V = Utility.Create("Frame", {
			Parent = HSV,
			Name = "V",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Size = UDim2.fromScale(0.3, 1)
		})

		local FrameV = Utility.Create("Frame", {
			Parent = V,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.3, 0.5),
			Size = UDim2.fromScale(0.6, 0.6)
		})

		Utility.Create("UICorner", {
			Parent = FrameV,
			CornerRadius = UDim.new(0.3, 0)
		})

		Utility.Create("TextBox", {
			Parent = FrameV,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.6),
			Text = "",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})

		Utility.Create("TextLabel", {
			Parent = V,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.4),
			Text = "V",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})
		
		Utility.Create("Frame", {
			Parent = Properties,
			Name = "Line",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.95, 0, 0, 2)
		})
		
		local RGB = Utility.Create("Frame", {
			Parent = Properties,
			Name = "RGB",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.5),
		})
		
		Utility.Create("UIListLayout", {
			Parent = RGB,
			Padding = UDim.new(0, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = false,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
			VerticalAlignment = Enum.VerticalAlignment.Top
		})
		
		local R = Utility.Create("Frame", {
			Parent = RGB,
			Name = "R",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Size = UDim2.fromScale(0.3, 1)
		})

		local FrameR = Utility.Create("Frame", {
			Parent = R,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.3, 0.5),
			Size = UDim2.fromScale(0.6, 0.6)
		})

		Utility.Create("UICorner", {
			Parent = FrameR,
			CornerRadius = UDim.new(0.3, 0)
		})

		Utility.Create("TextBox", {
			Parent = FrameR,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.6),
			Text = "",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})

		Utility.Create("TextLabel", {
			Parent = R,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.4),
			Text = "R",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})
		
		local G = Utility.Create("Frame", {
			Parent = RGB,
			Name = "G",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Size = UDim2.fromScale(0.3, 1)
		})

		local FrameG = Utility.Create("Frame", {
			Parent = G,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.3, 0.5),
			Size = UDim2.fromScale(0.6, 0.6)
		})

		Utility.Create("UICorner", {
			Parent = FrameG,
			CornerRadius = UDim.new(0.3, 0)
		})

		Utility.Create("TextBox", {
			Parent = FrameG,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.6),
			Text = "",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})

		Utility.Create("TextLabel", {
			Parent = G,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.4),
			Text = "G",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})
		
		local B = Utility.Create("Frame", {
			Parent = RGB,
			Name = "B",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Size = UDim2.fromScale(0.3, 1)
		})

		local FrameB = Utility.Create("Frame", {
			Parent = B,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0.3, 0.5),
			Size = UDim2.fromScale(0.6, 0.6)
		})

		Utility.Create("UICorner", {
			Parent = FrameB,
			CornerRadius = UDim.new(0.3, 0)
		})

		Utility.Create("TextBox", {
			Parent = FrameB,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.6),
			Text = "",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})

		Utility.Create("TextLabel", {
			Parent = B,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.4),
			Text = "B",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextScaled = true
		})
		
		local TopBar = Utility.Create("Frame", {
			Parent = ColorWindow,
			Name = "Topbar",
			BackgroundColor3 = Color3.fromRGB(21, 21, 31),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.1)
		})
		
		local TopFrame = Utility.Create("Frame", {
			Parent = TopBar,
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.5)
		})
		
		local Top = Utility.Create("Frame", {
			Parent = TopBar,
			Name = "Top",
			BackgroundColor3 = Color3.fromRGB(21, 21, 31),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.5),
			ZIndex = 0,
			ClipsDescendants = true
		})
		
		local TopFrame2 = Utility.Create("Frame", {
			Parent = Top,
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			BackgroundTransparency = 0,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 2),
			ZIndex = 0
		})
		
		Utility.Create("UICorner", {
			Parent = TopFrame2,
			CornerRadius = UDim.new(0.38, 0)
		})
		
		Utility.Create("TextButton", {
			Parent = TopBar,
			Name = "Button",
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			Text = ""
		})
		
		Utility.Create("TextLabel", {
			Parent = TopBar,
			Name = "Title",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
			BorderSizePixel = 1,
			Position = UDim2.fromScale(0.02, 0.5),
			Size = UDim2.fromScale(0.8, 0.7),
			Text = "",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			TextScaled = true
		})
		
		Utility.Create("TextButton", {
			Parent = ColorWindow,
			Name = "Button",
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			ZIndex = 9,
			Text = ""
		})
		
		ColorWindow.Visible = true
		
		ColorPicker = Color.New(PickerSC, {
			Name = Settings.Name or "ColorPicker",
			Position = self.MainLabel.Parent.Position + UDim2.fromScale(0.375, 0.134),
			RoundedCorners = true,
			Draggable = true,
			ZIndex = 1,
			Size = 0,
			FinalSize = 0.270,
			Primary = {Color = Color3.fromRGB(34, 34, 34), Transparency = 0},
			Secondary = {Color = Color3.fromRGB(70, 70, 70), Transparency = 0},
			Topbar = {Color = Color3.fromRGB(22, 22, 22), Transparency = 0},
			Text = {Color = Color3.fromRGB(220, 220, 220), Transparency = 0.07}
		})
		
		ColorPicker:SetColor(Preview.BackgroundColor3)
		
		ColorPicker.Updated:Connect(function(Color)
			Preview.BackgroundColor3 = Color
			Callback(Color)
		end)
		
		ColorPicker.Finished:Connect(function()
			OldColor = Preview.BackgroundColor3

			ColorPickerClose(ColorPicker)
			ColorPicker = nil
		end)
		
		ColorPicker.Canceled:Connect(function()
			TS:Create(Preview, TweenInfo.new(0.3), {BackgroundColor3 = OldColor}):Play()

			ColorPickerClose(ColorPicker)
			ColorPicker = nil
		end)
	end)
end

function Sections:AddLabel(Settings)
	local Frame = Utility.Create("Frame", {
		Parent = self.Section.Frame,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		ZIndex = 2,
		Size = UDim2.new(0.950, 0, 0, 35),
	})
	
	if Settings.FrameProperties then
		for k, v in pairs(Settings.FrameProperties) do
			Frame[k] = v
		end
	end
	
	Utility.Create("UIStroke", {
		Parent = Frame,
		Name = "StrokeBorder",
		Thickness = 1,
		Color = Color3.fromRGB(55, 55, 55),
		Transparency = 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	Utility.Create("UICorner", {
		Parent = Frame,
		CornerRadius = UDim.new(0, 4)
	})

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = Frame,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.02, 0, 0.470, 0),
		Size = UDim2.fromScale(0.950, 1),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = "Label",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		TextTransparency = 0.1,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	if Settings.LabelProperties then
		for k, v in pairs(Settings.LabelProperties) do
			Frame.Title[k] = v
		end
	end

	self:AddInstances({Frame, Frame.Size, Frame.Title, Frame.Title.Size})
	
	return Frame.Title
end

function Sections:AddLine(Settings)
	local Separator = Utility.Create("Frame", {
		Parent = self.Section.Frame,
		Size = UDim2.new(0.950, 0, 0, Settings.YOffset),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.750,
		ZIndex = 2
	})
	
	Utility.Create("UICorner", {
		Parent = Separator,
		CornerRadius = UDim.new(0, 5)
	})
	
	self:Resize()

	self:ResizePage()

	return Separator
end

function Sections:AddSeparator(Settings)
	local Separator = Utility.Create("Frame", {
		Parent = self.Section.Frame,
		ZIndex = 2,
		Size = UDim2.new(0.950, 0, 0, Settings.YOffset),
		BackgroundTransparency = 1
	})

	self:Resize()

	self:ResizePage()

	return Separator
end

function Pages:AddSection(Name)

	Utility.Create("UIListLayout", {
		["Parent"] = self.Page,
		["SortOrder"] = Enum.SortOrder.LayoutOrder,
		["Padding"] = UDim.new(0, 10),
		["HorizontalAlignment"] = Enum.HorizontalAlignment.Left
	})

	local Section = Utility.Create("ImageLabel", {
		["Name"] = Name,
		["Parent"] = self.Page,
		["BackgroundTransparency"] = 1,
		["Size"] = UDim2.new(1, -16, 0, 28),
		["ZIndex"] = 2,
		["Image"] = "rbxassetid://5028857472",
		["ImageColor3"] = Color3.fromRGB(28, 28, 28),
		["ScaleType"] = Enum.ScaleType.Slice,
		["SliceCenter"] = Rect.new(4, 4, 296, 296),
		["ClipsDescendants"] = true
	})

	self.ResizePage({SectionPage = self.Page, Section = Section})

	table.insert(self.Instances, {instance = Section, Size = Section.Size})

	self.Instances[Section] = {instance = Section, Size = Section.Size}

	Utility.Create("Frame", {
		["Parent"] = self.Page[Name],
		["Active"] = true,
		["BackgroundTransparency"] = 1,
		["BorderSizePixel"] = 0,
		["Position"] = UDim2.new(0, 8, 0, 8),
		["Size"] = UDim2.new(1, -16, 1, -16)
	})

	Utility.Create("UIListLayout", {
		["Parent"] = Section.Frame,
		["SortOrder"] = Enum.SortOrder.LayoutOrder,
		["HorizontalAlignment"] = Enum.HorizontalAlignment.Center
	}).Padding = UDim.new(0, 5)

	Utility.Create("UIListLayout", {
		["Parent"] = self.Page[Name],
		["SortOrder"] = Enum.SortOrder.LayoutOrder,
		["Padding"] = UDim.new(0, 8)
	})

	Utility.Create("TextLabel", {
		["Parent"] = self.Page[Name].Frame,
		["Name"] = "Title",
		["BackgroundTransparency"] = 1,
		["Size"] = UDim2.new(1, 0, 0, 20),
		["ZIndex"] = 2,
		["Font"] = Enum.Font.GothamSemibold,
		["RichText"] = true,
		["Text"] = Name and "<b>" .. Name .. "</b>" or "Section",
		["TextColor3"] = Color3.fromRGB(255, 255, 255),
		["TextSize"] = 17.5,
		["TextXAlignment"] = Enum.TextXAlignment.Center,
		["TextYAlignment"] = Enum.TextYAlignment.Bottom
	})


	local tbl = {SectionPage = self.Page, Section = Section}
	AllSections[Section] = tbl

	return setmetatable(tbl, Sections)
end

function Pages:ResizePage(DropdownCall)
	local Size = self.SectionPage["Search Bar"].Visible and 50 or 0

	for _, section in pairs(self.SectionPage:GetChildren()) do
		if section.ClassName == "ImageLabel" and section.Visible then
			Size += section.AbsoluteSize.Y + 10
		end
	end

	self.SectionPage.CanvasSize = UDim2.fromOffset(0, Size)

	if DropdownCall and self.SectionPage.ScrollBarImageTransparency == 1 then
		TS:Create(self.SectionPage, TweenInfo.new(0.3), {CanvasPosition = Vector2.new(0, self.SectionPage.CanvasPosition.Y + 60)}):Play()
	end

	self.SectionPage.ScrollBarImageTransparency = Size > self.SectionPage.AbsoluteSize.Y and 0 or 1

	return Size
end

function Pages:AddSearchBar()
	local Bar = self.Page["Search Bar"]
	Bar.Visible = true

	local Hovering = false

	local Time = 0

	Bar.MouseEnter:Connect(function()
		Hovering = true
		Time = tick()

		while Hovering do
			if tick() - Time > self.StrokeBordersDelay then
				local Tween = TS:Create(Bar.TextBox, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {TextColor3 = Color3.fromRGB(255, 255, 255), PlaceholderColor3 = Color3.fromRGB(255, 255, 255)})
				Tween:Play()

				local Tween2 = TS:Create(Bar.ImageButton, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true), {ImageTransparency = 0})
				Tween2:Play()

				repeat task.wait() until not Hovering or tick() - Time < self.StrokeBordersDelay

				Tween:Cancel()
				Tween2:Cancel()

				TS:Create(Bar.TextBox, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255), PlaceholderColor3 = Color3.fromRGB(176, 176, 176)}):Play()
				TS:Create(Bar.ImageButton, TweenInfo.new(0.3), {ImageTransparency = 0.250}):Play()
			end

			task.wait()
		end
	end)

	Bar.MouseLeave:Connect(function()
		Hovering = false
	end)

	local Tween

	Bar.TextBox:GetPropertyChangedSignal("Text"):Connect(function()

		if not Tween then
			Tween = TS:Create(self.Page, TweenInfo.new(0.3), {CanvasPosition = Vector2.new(0, 0)})
			Tween:Play()

			Tween.Completed:Connect(function()
				Tween = nil
			end)
		end

		for _, v in pairs(self.Page:GetChildren()) do
			if v.ClassName == "ImageLabel" then
				local Invisible = true

				for _, v2 in pairs(v.Frame:GetChildren()) do
					if Bar.TextBox.Text == "" and v2.ClassName ~= "UIListLayout" then
						v2.Visible = true
						v.Visible = true
						Invisible = false

						local self = self:GetSectionEnv(v)

						self:Resize()

						self:ResizePage()

						continue
					end

					local Label = v2:FindFirstChildOfClass("TextLabel") or (v2:FindFirstChild("Under") and v2.Under:FindFirstChildOfClass("TextLabel")) or (v2.Name == "Button" and v2.TextButton) or v2.Name == "Dropdown" and v2.Frame:FindFirstChildOfClass("TextLabel")

					if Label then
						if Label.ClassName == "TextLabel" then

							if Label.Parent.Parent.Name == "Dropdown" then
								Label.Parent.Parent.Visible = Label.Text:lower():find(self.Page["Search Bar"].TextBox.Text:lower()) or false
							else
								if Label.Parent.Name == "Under" then
									Label.Parent.Parent.Visible = Label.Text:lower():find(self.Page["Search Bar"].TextBox.Text:lower()) or false
								else
									Label.Parent.Visible = Label.Text:lower():find(self.Page["Search Bar"].TextBox.Text:lower()) or false
								end
							end

						else
							Label.Parent.Visible = Label.Text:lower():find(self.Page["Search Bar"].TextBox.Text:lower()) or false
						end
					end

					if v2.ClassName ~= "UIListLayout" and v2.ClassName ~= "TextLabel" and v2.Visible then
						v.Visible = true
						Invisible = false
					end

				end

				local self = self:GetSectionEnv(v)

				self:ResizePage()

				local Skip = false

				if Invisible then
					v.Visible = false
					Skip = true
				end

				if not Skip then
					self:Resize(v.Frame)
				end
			end
		end
	end)

	return self
end

function BoogaUI.New(Parameters)

	BoogaUI.Toggled = false

	BoogaUI.Toggling = false

	BoogaUI.Instances = {}
	
	BoogaUI.OldValues = {}

	BoogaUI.Name = Parameters.Name

	BoogaUI.Pages = {}

	BoogaUI.Orders = {}

	BoogaUI.SelectorMovement = Parameters.SelectorMovement

	BoogaUI.LastPageButton = false

	BoogaUI.LastSelected = false

	BoogaUI.LastButton = false

	BoogaUI.ChangingPage = false

	BoogaUI.StrokeBorders = true

	BoogaUI.StrokeBordersDelay = 0.5
	
	BoogaUI.FirstCategoryCreated = false

	local SG = Utility.Create("ScreenGui", {
		["Parent"] = identifyexecutor and game.CoreGui or Player.PlayerGui,
		["Name"] = Parameters.Name or "Booga UI Lib",
	})
	
	local Fake = Utility.Create("Frame", {
		["Parent"] = SG,
		["Name"] = "Fake",
		["Size"] = UDim2.fromOffset(600, 450),
		["Position"] = UDim2.new(0.171, 354, 0.133, -24),
		["BackgroundTransparency"] = 1,
	})
	
	local MainLabel = Utility.Create("Frame", {
		["Parent"] = Fake,
		["Name"] = "MainLabel",
		["Size"] = UDim2.fromOffset(600, 450),
		["BackgroundTransparency"] = 0,
		["BackgroundColor3"] = Color3.fromRGB(42, 42, 42),
		["ClipsDescendants"] = true
	}) 

	BoogaUI.MainLabel = MainLabel

	Utility.Create("UICorner", {
		Parent = MainLabel,
		CornerRadius = UDim.new(0, 4)
	})

	Utility.Create("ImageLabel", {
		Parent = Fake,
		Name = "Glow",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -15, 0, -15),
		Size = UDim2.new(1, 30, 1, 30),
		ZIndex = 0,
		Image = "rbxassetid://5028857084",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(24, 24, 276, 276)
	})

	local Pages = Utility.Create("ImageLabel", {
		["Parent"] = MainLabel,
		["Name"] = "Pages",
		["Size"] = UDim2.fromScale(0.220, 0.755),
		["Position"] = UDim2.new(0, 0, 0.09, 0),
		["BorderSizePixel"] = 0,
		["ImageColor3"] = Color3.fromRGB(27, 27, 27),
		["Image"] = "rbxassetid://5012534273",

	})

	BoogaUI.Pages = Pages
	
	BoogaUI.PagesLastPos = {}

	local Profile = Utility.Create("ImageLabel", {
		["Parent"] = MainLabel,
		["Name"] = "Profile",
		["Size"] = UDim2.fromScale(0.220, 0.17),
		["Position"] = UDim2.new(0, 0, 0.835, 0),
		["BorderSizePixel"] = 0,
		["ImageColor3"] = Color3.fromRGB(27, 27, 27),
		["Image"] = "rbxassetid://5012534273",

	})

	Utility.Create("TextLabel", {
		Parent = Profile,
		Name = "Game Name",
		Size = UDim2.fromScale(0.9, 0.1),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		RichText = true,
		TextWrapped = true,
		TextSize = 9,
		Text = "<b>" .. Parameters.CustomName .. "</b>" or "<b>" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "</b>",
	})

	Profile["Game Name"].Position = UDim2.fromScale(0.050, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.1 or 0.14)

	Utility.Create("TextLabel", {
		Parent = Profile,
		Name = "Player Name",
		Size = UDim2.fromScale(0.1, 0.1),
		Position = UDim2.fromScale(0.45, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.280 or 0.4),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 9,
		Text = Player.Name
	})
	
	Utility.Create("ImageLabel", {
		Parent = Profile,
		Name = "FPS Image",
		Size = UDim2.fromScale(0.120, 0.205),
		Position = UDim2.fromScale(0.230, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.520 or 0.550),
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=18797095927",
	})

	Utility.Create("TextLabel", {
		Parent = Profile,
		Name = "FPS",
		Size = UDim2.fromScale(0.1, 0.1),
		Position = UDim2.fromScale(0.51, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.550 or 0.6),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 9,
		Text = "FPS : ",
	})

	local LastTime = tick()
	local FrameCount = 0

	local FPS

	game:GetService("RunService").RenderStepped:Connect(function()
		FrameCount = FrameCount + 1
		local currentTime = tick()

		if currentTime - LastTime >= 1 then
			FPS = math.floor(FrameCount / (currentTime - LastTime))
			
			if FPS == 59 then
				FPS = 60
			end
			
			if FPS > 99 then
				Profile.FPS.Position = UDim2.fromScale(0.53, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.550 or 0.6)
			else
				Profile.FPS.Position = UDim2.fromScale(0.51, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.550 or 0.6)
			end

			Profile.FPS.Text = "FPS : " .. FPS

			FrameCount = 0
			LastTime = currentTime
		end
	end)
	
	Utility.Create("ImageLabel", {
		Parent = Profile,
		Name = "Ping Image",
		Size = UDim2.fromScale(0.1, 0.160),
		Position = UDim2.fromScale(0.240, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.720 or 0.740),
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=18797246498",
	})
	
	Utility.Create("TextLabel", {
		Parent = Profile,
		Name = "Ping",
		Size = UDim2.fromScale(0.1, 0.1),
		Position = UDim2.fromScale(0.51, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.750 or 0.770),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 9,
		Text = "Ping : ",
	})
	
	task.spawn(function()
		local Stats = game:GetService("Stats")

		while true do
			local Ping =  math.random(60,120) --math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

			if Ping > 99 then
				Profile.Ping.Position = UDim2.fromScale(0.53, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.750 or 0.770)
			else
				Profile.Ping.Position = UDim2.fromScale(0.51, Profile["Game Name"].Text:gsub("<b>", ""):gsub("</b>", ""):len() <= 18 and 0.750 or 0.770)
			end

			Profile.Ping.Text = "Ping : " .. Ping
			
			task.wait(0.2)
		end
	end)

	local Separator = Utility.Create("Frame", {
		Parent = Profile,
		Name = "Profile Separator",
		Size = UDim2.fromScale(0.9, 0.025),
		Position = UDim2.fromScale(0.05, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.750
	})
	
	BoogaUI:AddInstances({Separator, Separator.Size, Profile["Game Name"], Profile["Game Name"].Size, Profile["Player Name"], Profile["Player Name"].Size, Profile["FPS Image"], Profile["FPS Image"].Size, Profile.FPS, Profile.FPS.Size, Profile["Ping Image"], Profile["Ping Image"].Size, Profile.Ping, Profile.Ping.Size})

	Utility.Create("UICorner", {
		Parent = Separator
	})

	local PagesScrolling = Utility.Create("ScrollingFrame", {
		["Parent"] = Pages,
		["Name"] = "Pages Scrolling",
		["BackgroundTransparency"] = 1,
		["Size"] = UDim2.fromScale(0.996, 1),
		["CanvasSize"] = UDim2.fromScale(0, 8),
		["ScrollBarThickness"] = 6,
		["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0),
		["BorderSizePixel"] = 0
	})

	BoogaUI.PagesScrolling = PagesScrolling

	Utility.Create("UIListLayout", {
		["Parent"] = PagesScrolling,
		["SortOrder"] = Enum.SortOrder.LayoutOrder,
		["Padding"] = UDim.new(0, 10)
	})

	local Top = Utility.Create("Frame", {
		["Parent"] = MainLabel,
		["Name"] = "TitleHolder",
		["Size"] = UDim2.fromScale(1, 0.095),
		["BackgroundColor3"] = Color3.fromRGB(27, 27, 27),
		["BorderSizePixel"] = 0,
	})

	Utility.Create("UICorner", {
		Parent = Top,
		CornerRadius = UDim.new(0, 4)
	})

	Utility.Create("TextLabel", {
		Parent = Top,
		Name = "Title",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 19),
		Size = UDim2.new(1, -46, 0, 16),
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = Parameters.Name or "Booga UI Lib",
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	Utility.Create("TextLabel", {
		Parent = MainLabel,
		BackgroundTransparency = 1,
		RichText = true,
		Text = "",
		TextSize = 10,
		TextTransparency = 0.15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromScale(0.03, 0.03),
		Position = UDim2.fromScale(0.250, 0.1)
	})

	local dragging = false
	local dragInput, mousePos, framePos

	Top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = Fake.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Top.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	Top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = Fake.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Top.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			TS:Create(Fake, TweenInfo.new(0.090, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)}):Play()
		end
	end)

	if Parameters.TogglePages then
		local Hidden = false

		local Button = Utility.Create("TextButton", {
			Parent = MainLabel,
			BackgroundTransparency = 0.550,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 4, 0.250, 0),
			Position = UDim2.fromScale(0.208, 0.4),
			ZIndex = 3,
			AutoButtonColor = false,
			Text = "",
		})
		
		Utility.Create("UICorner", {
			Parent = Button,
			CornerRadius = UDim.new(0, 20)
		})

		Button.MouseButton1Click:Connect(function()
			Hidden = not Hidden
			
			local PageLabel = MainLabel.TextLabel
			
			local ActivePage
			
			for _, Object in pairs(MainLabel:GetChildren()) do
				if Object.ClassName == "ScrollingFrame" and Object.Visible then
					ActivePage = Object
				end
			end

			if Hidden then
				TS:Create(Pages, TweenInfo.new(0.2), {Size = UDim2.fromScale(0, 0.871)}):Play()
				TS:Create(Profile, TweenInfo.new(0.3), {Size = UDim2.fromScale(0, 0.17)}):Play()
				
				Profile["Game Name"].TextWrapped = false
				
				for _, Object in pairs(Profile:GetDescendants()) do
					if Object.ClassName == "TextLabel" or Object.ClassName == "TextButton" then
						TS:Create(Object, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
					elseif Object.ClassName == "ImageLabel" or Object.ClassName == "ImageButton" then
						TS:Create(Object, TweenInfo.new(0.1), {ImageTransparency = 1}):Play()
					end
				end
				
				for _, Object in pairs(ActivePage:GetChildren()) do
					if Object.ClassName == "ImageLabel" then
						for _, ObjectInUI in Object.Frame:GetChildren() do
							if ObjectInUI.ClassName == "TextButton" then
								ObjectInUI.ImageLabel.Size = UDim2.fromScale(0.047, 0.68)
								ObjectInUI.ImageLabel.Position = UDim2.fromScale(0.948, 0.12)
							end
						end
					elseif Object.ClassName == "Frame" then
						Object.ImageButton.Size = UDim2.fromScale(0.058, 0.787)
						Object.ImageButton.Position = UDim2.fromScale(0.93, 0.1)
					end
				end
				
				TS:Create(Button, TweenInfo.new(0.195), {Size = UDim2.new(0, 3, 0.250, 0), Position = UDim2.fromScale(0, 0.4)}):Play()
				TS:Create(PageLabel, TweenInfo.new(0.2), {Position = UDim2.fromScale(0.007 + (0.0034 * string.len(PageLabel.Text)), 0.1)}):Play()

				for _,v in pairs(PagesScrolling:GetDescendants()) do
					if v.ClassName == "TextLabel" then
						TS:Create(v, TweenInfo.new(0.150), {TextTransparency = 1}):Play()
					elseif v.ClassName == "ImageLabel" then
						TS:Create(v, TweenInfo.new(0.150), {ImageTransparency = 1}):Play()
					end
				end

				for _,v in pairs(MainLabel:GetChildren()) do
					if v.ClassName == "ScrollingFrame" then
						TS:Create(v, TweenInfo.new(0.3), {Size = UDim2.new(0.973, 0, 1, -56), Position = UDim2.new(0.02, 1.5, 0.14, 0)}):Play()
					end
				end
			else
				TS:Create(Pages, TweenInfo.new(0.3), {Size = UDim2.fromScale(0.22, 0.871)}):Play()
				TS:Create(Profile, TweenInfo.new(0.3), {Size = UDim2.fromScale(0.22, 0.17)}):Play()
				
				Profile["Game Name"].TextWrapped = true
				
				for _, Object in pairs(Profile:GetDescendants()) do
					if Object.ClassName == "TextLabel" or Object.ClassName == "TextButton" then
						TS:Create(Object, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
					elseif Object.ClassName == "ImageLabel" or Object.ClassName == "ImageButton" then
						TS:Create(Object, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
					end
				end
				
				for _, Object in pairs(ActivePage:GetChildren()) do
					if Object.ClassName == "ImageLabel" then
						for _, ObjectInUI in pairs(Object.Frame:GetChildren()) do
							if ObjectInUI.ClassName == "TextButton" then
								ObjectInUI.ImageLabel.Size = UDim2.fromScale(0.06, 0.68)
								ObjectInUI.ImageLabel.Position = UDim2.fromScale(0.93, 0.12)
							end
						end
					elseif Object.ClassName == "Frame" then
						Object.ImageButton.Size = UDim2.fromScale(0.07, 0.787)
						Object.ImageButton.Position = UDim2.fromScale(0.91, 0.1)
					end
				end
				
				TS:Create(Button, TweenInfo.new(0.3), {Size = UDim2.new(0, 4, 0.250, 0), Position = UDim2.fromScale(0.208, 0.4)}):Play()
				TS:Create(PageLabel, TweenInfo.new(0.3), {Position = UDim2.fromScale(0.21 + (0.0055 * string.len(PageLabel.Text)), 0.1)}):Play()

				for _,v in pairs(PagesScrolling:GetDescendants()) do
					if v.ClassName == "TextLabel" then
						TS:Create(v, TweenInfo.new(0.150), {TextTransparency = 0}):Play()
					elseif v.ClassName == "ImageLabel" then
						TS:Create(v, TweenInfo.new(0.150), {ImageTransparency = 0.5}):Play()
					end
				end

				for _,v in pairs(MainLabel:GetChildren()) do
					if v.ClassName == "ScrollingFrame" then
						TS:Create(v, TweenInfo.new(0.2), {Size = UDim2.new(0.973, -142, 1, -56), Position = UDim2.new(0.252, 1.5, 0.14, 0)}):Play()
					end
				end
			end
		end)
	end

	return BoogaUI
end

function BoogaUI:AddPage(Title, Icon, IconProperties)

	local AnimatingClick = false

	local Button = Utility.Create("TextButton", {
		Name = Title,
		Parent = self.PagesScrolling,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 26),
		ZIndex = 3,
		AutoButtonColor = false,
		Font = Enum.Font.Gotham,
		Text = "",
		TextSize = 14
	})

	local Size = 1

	for _,v in pairs(self.Orders) do
		Size += 1
	end

	self.Orders[Button] = Size

	local Selected = Utility.Create("Frame", {
		Name = "Selector",
		Parent = Button,
		Size = UDim2.fromScale(0.91, 1),
		Position = UDim2.fromScale(0.03, 0.04),
		BackgroundColor3 = Color3.fromRGB(85, 85, 85),
		BackgroundTransparency = (not self.FocusedPage) and 0.7 or 1,
	})

	if not self.FocusedPage then
		self.MainLabel.TextLabel.Text = "<b>" .. Title .. "</b>"
		self.MainLabel.TextLabel.Position = UDim2.fromScale(0.250 + (0.0055 * Title:len()), 0.1)
		
		self.Selected = Selected
	end

	Utility.Create("UICorner", {
		Parent = Selected,
		CornerRadius = UDim.new(0, 4)
	})

	Utility.Create("UIStroke", {
		Parent = Selected,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = not self.FocusedPage and 1.5 or 0,
		Color = Color3.fromRGB(135, 135, 135),
		Transparency = not self.FocusedPage and 0 or 1,
		Enabled = true,
	})

	local Size = 0

	for _, section in pairs(self.PagesScrolling:GetChildren()) do
		if section.ClassName == "TextButton" then
			Size += section.AbsoluteSize.Y + 10
		end
	end

	self.PagesScrolling.CanvasSize = UDim2.fromOffset(0, Size)
	self.PagesScrolling.ScrollBarImageTransparency = Size > self.PagesScrolling.AbsoluteSize.Y and 0 or 1

	local PageTitle = Utility.Create("TextLabel", {
		["Name"] = "Title",
		["Parent"] = Button,
		["BackgroundTransparency"] = 1,
		["Text"] = not self.FocusedPage and "<b>" .. Title .. "</b>" or Title,
		["RichText"] = true,
		["TextSize"] = 17,
		["Font"] = Enum.Font.Arial,
		["TextColor3"] = not self.FocusedPage and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(185, 185, 185),
		["Size"] = UDim2.new(1, -10, 1, 0),
		["TextXAlignment"] = Enum.TextXAlignment.Left,
		["Position"] = Icon and UDim2.fromScale(0.25, 0) or UDim2.fromScale(0.05, 0)
	})

	local Icon = Utility.Create("ImageLabel", IconProperties or {
		Name = "Icon",
		Parent = Button,
		BackgroundTransparency = 1,
		ImageTransparency = 0.5,
		Image = tostring(Icon):find("rbx") and Icon or "rbxassetid://" .. tostring(Icon),
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(0, 7, 0.118, 0),
	})

	if not self.FocusedPage then
		self.LastPageButton = PageTitle
		self.FocusedPage = Button
	end

	local Page = Utility.Create("ScrollingFrame", {
		["Parent"] = self.MainLabel,
		["Name"] = Title,
		["BackgroundTransparency"] = 1,
		["Position"] = UDim2.new(0.252, 1.5, 0.135, 0),
		["Size"] = UDim2.new(0.973, -142, 1, -56),
		["ScrollBarThickness"] = 3,
		["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0),
		["ScrollBarImageTransparency"] = 1,
		["BorderSizePixel"] = 0,
		["Visible"] = Button == self.FocusedPage and true or false

	})

	Utility.Create("UICorner", {
		Parent = Utility.Create("Frame", {
			Name = "Search Bar",
			Parent = Page,
			ZIndex = 2,
			Size = UDim2.new(0.965, 0, 0, 35),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			Visible = false
		}),

		CornerRadius = UDim.new(0, 6)
	})

	Utility.Create("ImageButton", {
		Parent = Page["Search Bar"],
		Image = "http://www.roblox.com/asset/?id=11496279085",
		ImageTransparency = 0.250,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.070, 0.787),
		Position = UDim2.fromScale(0.91, 0.1),
		ZIndex = 2
	})

	Utility.Create("TextBox", {
		Parent = Page["Search Bar"],
		Size = UDim2.fromScale(0.895, 0.9),
		Position = UDim2.fromScale(0.02, 0),
		BackgroundTransparency = 1,
		Text = "",
		Font = Enum.Font.Arial,
		PlaceholderColor3 = Color3.fromRGB(176, 176, 176),
		PlaceholderText = "Search Something...",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		ZIndex = 2
	})
	
	self:AddInstances({Page["Search Bar"], Page["Search Bar"].Size, Page["Search Bar"].ImageButton, Page["Search Bar"].ImageButton.Size, Page["Search Bar"].TextBox, Page["Search Bar"].TextBox.Size})

	if self.FocusedPage == Button then
		self.FocusedPage = Page
	end

	Button.MouseEnter:Connect(function()
		if AnimatingClick then
			return
		end

		PageTitle.Text = "<b>" .. PageTitle.Text .. "</b>"
		TS:Create(PageTitle, TweenInfo.new(0.150), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play()

	end)

	Button.MouseLeave:Connect(function()
		if AnimatingClick then
			return
		end

		if self.LastPageButton ~= PageTitle then
			PageTitle.Text = PageTitle.Text:gsub("<b>", ""):gsub("</b>", "")
			TS:Create(PageTitle, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(185, 185, 185)}):Play()
		end
	end)

	Button.MouseButton1Down:Connect(function()
		if AnimatingClick then
			return
		end

		PageTitle.Text = PageTitle.Text:gsub("<b>", ""):gsub("</b>", "")
		TS:Create(PageTitle, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(135, 135, 135)}):Play()
	end)

	Button.MouseButton1Click:Connect(function()
		if self.ChangingPage then
			return
		end
		
		self.ChangingPage = true
		
		self.PagesLastPos[Page] = Page.CanvasPosition

		if self.SelectorMovement then
			local Multiply = 1.385

			for k,v in pairs(self.Orders) do
				if k == "Separator" and v < self.Orders[Button] then
					Multiply = 1.230 + (0.017 + (0.00001 * (self.Orders[Button] - v)) * (self.Orders[Button] - v))
					break
				end
			end
			
			print(Multiply)
			
			TS:Create(self.Selected, TweenInfo.new(0.3), {Position = UDim2.fromScale(0.03, self.Orders[Button] == 1 and 0.05 or (self.Orders[Button] < 2 and self.Orders[Button] or self.Orders[Button] - 1) * Multiply)}):Play()
		else
			TS:Create(self.Selected, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
			TS:Create(self.Selected.UIStroke, TweenInfo.new(0.4), {Thickness = 0, Transparency = 1}):Play()
			
			self.Selected = Selected
			
			TS:Create(Button.Selector, TweenInfo.new(0.4), {BackgroundTransparency = 0.7}):Play()
			TS:Create(Button.Selector.UIStroke, TweenInfo.new(0.4), {Thickness = 1.5, Transparency = 0}):Play()
		end

		if self.LastPageButton then 
			self.LastPageButton.Text = self.LastPageButton.Text:gsub("<b>", ""):gsub("</b>", "")
			TS:Create(PageTitle, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play()
		end

		self.LastPageButton = PageTitle

		task.spawn(function()
			AnimatingClick = true

			PageTitle.Text = "<b>" .. PageTitle.Text .. "</b>"
			TS:Create(PageTitle, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play()

			task.wait(0.2)

			AnimatingClick = false
		end)

		if self.FocusedPage == Page then
			self.ChangingPage = false
			return
		end
		
		local PageLabel = self.MainLabel.TextLabel

		local Tween = TS:Create(PageLabel, TweenInfo.new(0.03 * PageLabel.Text:len()), {TextTransparency = 1})
		Tween:Play()

		task.spawn(function()
			local Text = PageLabel.Text:match("<b>(.+)</b>")

			for i = Text:len(), 1, -1 do
				PageLabel.Text = "<b>" .. Text:gsub(Text:sub(i, i) .. "?$", "", 1) .. "</b>"
				Text = Text:gsub(Text:sub(i, i) .. "?$", "", 1)

				task.wait(0.03)
			end

			TS:Create(PageLabel, TweenInfo.new(0.1), {TextTransparency = 0.1}):Play()

			task.wait(0.1)

			Text = PageTitle.Text:match("<b>(.+)</b>")

			for i = 1, Text:len() do
				PageLabel.Text = "<b>" .. Text:sub(1, i) .. "</b>"

				local Len = Text:len()

				PageLabel.Position = UDim2.fromScale(0.250 + (0.0055 * Len), 0.1)

				task.wait(0.03)
			end
		end)

		local OldBackgroundTransparency
		local OldTextTransparency
		local OldImageTransparency

		for _,v in pairs(self.Instances) do
			local instance = v.instance

			if instance:IsDescendantOf(self.FocusedPage) then

				if instance.ClassName == "Frame" or instance.ClassName == "TextButton" then
					OldBackgroundTransparency = instance.BackgroundTransparency
				elseif instance.ClassName == "TextLabel" or instance.ClassName == "TextBox" then
					OldTextTransparency = instance.TextTransparency
				elseif instance.ClassName == "ImageLabel" or instance.ClassName == "ImageButton" then
					OldImageTransparency = instance.ImageTransparency
				end

				task.delay(0.305, function()
					instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, v.Size.Y.Scale, v.Size.Y.Offset)

					if instance.Name == "ToggleBase" then
						OldBackgroundTransparency = 0.9
					elseif instance.Name == "ToggleCircle" then
						OldBackgroundTransparency = 0.1
					elseif instance.Name == "Dropdown Option" then
						instance.Size = UDim2.new(0.950, 0, 0, 30)
					elseif instance.Name == "Toggle1" or instance.Name == "Search Bar" then
						OldBackgroundTransparency = 0
					end

					instance[Properties[instance.ClassName]] = (Properties[instance.ClassName] == "BackgroundTransparency" and OldBackgroundTransparency) or (Properties[instance.ClassName] == "TextTransparency" and OldTextTransparency) or (Properties[instance.ClassName] == "ImageTransparency" and OldImageTransparency)
				end)

				if instance.ClassName ~= "ImageLabel" or not instance:FindFirstChild("UIListLayout") then

					if instance.ClassName == "Frame" or instance.ClassName == "TextButton" then
						TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 2, instance.Size.Y.Offset - instance.Size.Y.Offset / 1.1), BackgroundTransparency = 1}):Play()

						if instance.ClassName == "TextButton" then
							TS:Create(instance, TweenInfo.new(0.3), {TextSize = 0, TextTransparency = 1}):Play()
						end

					elseif instance.ClassName == "TextLabel" then
						TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 2, instance.Size.Y.Offset - instance.Size.Y.Offset / 1.1), TextTransparency = 1}):Play()

						local OldTextSize = instance.TextSize
						TS:Create(instance, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = OldTextSize - 2}):Play()

						task.delay(0.305, function()
							TS:Create(instance, TweenInfo.new(0.3), {TextSize = OldTextSize}):Play()
						end)

					else
						if instance.Name == "Title" or instance.Name == "TextBox" or instance.Name == "KeyLabel" then
							continue
						end

						TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 2, instance.Size.Y.Offset - instance.Size.Y.Offset / 1.1), ImageTransparency = 1}):Play()
					end
					
					if isDescendantOfByName(instance, "ColorPicker") then
						continue
					end

					for _,instance in pairs(instance:GetDescendants()) do

						if instance.ClassName == "UICorner" or instance.ClassName == "ScrollingFrame" or instance.ClassName == "UIListLayout" or instance.ClassName == "BoolValue" or instance.Name == "ToggleBase" or instance.Name == "Under" or instance.Name == "ToggleCircle" or instance.Name == "AddIndex" or instance.Name == "Dropdown Option" or instance.ClassName == "ScreenGui" then
							continue
						end

						if instance.Name == "StrokeBorder" or instance.Name == "StrokeBorder2" then
							instance.Enabled = false

							task.delay(0.305, function()
								instance.Enabled = true
							end)

							continue
						end

						local OldSize = instance.Size

						if instance.ClassName == "Frame" or instance.ClassName == "TextButton" then
							OldBackgroundTransparency = instance.BackgroundTransparency
							TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 2, instance.Size.Y.Offset - instance.Size.Y.Offset / 1.1), BackgroundTransparency = instance.Name == "ToggleBase" and 0.9 or instance.Name == "ToggleCircle" and 0.5 or 1}):Play()

						elseif instance.ClassName == "TextLabel" or instance.ClassName == "TextBox" then
							OldTextTransparency = instance.TextTransparency
							TS:Create(instance, TweenInfo.new(instance.Parent.Name ~= "Search Bar" and 0.3 or 0.2), {TextTransparency = 1}):Play()
						else
							OldImageTransparency = instance.ImageTransparency
							TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 2, instance.Size.Y.Offset - instance.Size.Y.Offset / 1.1), ImageTransparency = 1}):Play()
						end

						task.delay(0.305, function()
							instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, OldSize.Y.Scale, OldSize.Y.Offset)

							instance[Properties[instance.ClassName]] = (Properties[instance.ClassName] == "BackgroundTransparency" and OldBackgroundTransparency) or (Properties[instance.ClassName] == "TextTransparency" and OldTextTransparency) or (Properties[instance.ClassName] == "ImageTransparency" and OldImageTransparency)
						end)
					end

				else
					TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 4, instance.Size.Y.Offset - instance.Size.Y.Offset / 2), ImageTransparency = 1}):Play()

					TS:Create(instance.Frame.Title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()

					task.delay(0.305, function()
						instance.Frame.Title.TextTransparency = 0
					end)
				end
			end
		end

		local Old = self.FocusedPage

		self.FocusedPage = Page
		
		Page.CanvasPosition = Vector2.new()

		task.wait(0.3)

		Old.Visible = false

		for _,v in pairs(self.Instances) do
			local instance = v.instance

			if instance:IsDescendantOf(Page) then
				instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, 0, 0)

				TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, v.Size.Y.Scale, v.Size.Y.Offset)}):Play()

				if instance.ClassName == "TextButton" then
					if instance.Name == "Dropdown Option" then
						TS:Create(instance, TweenInfo.new(0.150), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()
					end

					TS:Create(instance, TweenInfo.new(0.150), {TextSize = 16, TextTransparency = 0.1}):Play()
				end
			end
		end

		Page.Visible = true

		task.wait(0.3)

		self.ChangingPage = false
		
		if self.PagesLastPos[Page].Y > 80 then
		
			TS:Create(Page, TweenInfo.new(0.2), {CanvasPosition = self.PagesLastPos[Page]}):Play()
		end
	end)

	BoogaUI.LastPage = Button

	return setmetatable({Page = Page}, Pages)
end

function BoogaUI:AddPageCategory(Title)
	local Condition = self.PagesScrolling:FindFirstChildOfClass("TextButton") or self.PagesScrolling:FindFirstChildOfClass("Frame")

	if not self.FirstCategoryCreated then
		self.FirstCategoryCreated = true
	else
		
		local Base = Utility.Create("Frame", {
			Parent = self.PagesScrolling,
			Size = UDim2.new(0.950, 0, 0, 2),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ZIndex = 2
		})

		
		local Separator = Utility.Create("Frame", {
			Parent = Base,
			Size = UDim2.new(0.950, 0, 0, 2),
			Position = UDim2.fromScale(0.05, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 0.7,
			ZIndex = 2
		})

		Utility.Create("UICorner", {
			Parent = Separator,
			CornerRadius = UDim.new(0, 5)
		})
		
		local Size = 1
		
		for _,v in pairs(self.Orders) do
			Size += 1
		end

		self.Orders["Separator"] = Size
	end
	
	local Holder = Utility.Create("Frame", {
		Parent = self.PagesScrolling,
		Name = Title,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.950, 0, 0, Condition and 2 or 10),
	})
	
	Utility.Create("TextLabel", {
		Parent = Holder,
		Name = Title,
		Text = Title,
		TextColor3 = Color3.fromRGB(120, 120, 120),
		TextSize = 16,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.950, 0, 0, Condition and 2 or 10),
	})
	
	Holder[Title].Position = UDim2.fromScale(-0.4 + (Holder[Title].Text:len() * 30 / (Holder[Title].Text:len() <= 5 and 1000 or 900)), Condition and -0.3 or 0.3)
end

function BoogaUI:AddSeparator(YOffset)
	local Separator = Utility.Create("Frame", {
		Name = "Separator",
		Parent = self.PagesScrolling,
		ZIndex = 2,
		Size = UDim2.new(0.950, 0, 0, YOffset),
		BackgroundTransparency = 1
	})

	local Size = 0

	for _, section in pairs(self.PagesScrolling:GetChildren()) do
		if section.ClassName == "TextButton" or section.Name == "Separator" then
			Size += section.AbsoluteSize.Y + 10
		end
	end

	self.PagesScrolling.CanvasSize = UDim2.fromOffset(0, Size)
	self.PagesScrolling.ScrollBarImageTransparency = Size > self.PagesScrolling.AbsoluteSize.Y and 0 or 1

	return Separator
end

function BoogaUI:UpdateTitle(Properties)
	for k,v in pairs(Properties) do
		self.MainLabel.TitleHolder.Title[k] = v
	end

	return self.MainLabel.TitleHolder.Title
end

function BoogaUI:Notify(Title, Text, Position, Direction, Callback)
	local Clicked

	local Holder = Utility.Create("Frame", {
		Parent = self.MainLabel.Parent,
		Size = UDim2.fromOffset(309, 113),
		Position = Position or UDim2.fromScale(1, 0.890),
		BackgroundTransparency = 0.5,
		ZIndex = 5
	})

	Utility.Create("UICorner", {
		Parent = Holder
	})

	Utility.Create("UIGradient", {
		Parent = Holder,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.new(0.294118, 0.294118, 0.294118)),
			ColorSequenceKeypoint.new(0.032872, Color3.new(0.309804, 0.309804, 0.309804)),
			ColorSequenceKeypoint.new(0.0761246, Color3.new(0.329412, 0.329412, 0.329412)),
			ColorSequenceKeypoint.new(0.152249, Color3.new(0.301961, 0.301961, 0.301961)),
			ColorSequenceKeypoint.new(0.219723, Color3.new(0.32549, 0.32549, 0.32549)),
			ColorSequenceKeypoint.new(0.278547, Color3.new(0.298039, 0.298039, 0.298039)),
			ColorSequenceKeypoint.new(0.33737, Color3.new(0.313726, 0.313726, 0.313726)),
			ColorSequenceKeypoint.new(0.404844, Color3.new(0.290196, 0.290196, 0.290196)),
			ColorSequenceKeypoint.new(0.479239, Color3.new(0.337255, 0.337255, 0.337255)),
			ColorSequenceKeypoint.new(0.543253, Color3.new(0.298039, 0.298039, 0.298039)),
			ColorSequenceKeypoint.new(0.610727, Color3.new(0.27451, 0.27451, 0.27451)),
			ColorSequenceKeypoint.new(0.67474, Color3.new(0.309804, 0.309804, 0.309804)),
			ColorSequenceKeypoint.new(0.726644, Color3.new(0.294118, 0.294118, 0.294118)),
			ColorSequenceKeypoint.new(0.782007, Color3.new(0.356863, 0.356863, 0.356863)),
			ColorSequenceKeypoint.new(0.83737, Color3.new(0.333333, 0.333333, 0.333333)),
			ColorSequenceKeypoint.new(0.885813, Color3.new(0.282353, 0.282353, 0.282353)),
			ColorSequenceKeypoint.new(0.932526, Color3.new(0.309804, 0.309804, 0.309804)),
			ColorSequenceKeypoint.new(1, Color3.new(0.294118, 0.294118, 0.294118))
		}
	})

	Utility.Create("TextLabel", {
		Parent = Holder,
		Name = "Title",
		Text = Title,
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamSemibold,
		TextSize = 24,
		TextScaled = true,
		TextWrapped = true,
		Size = UDim2.fromScale(1, 0.338),
		ZIndex = 5
	})

	Utility.Create("TextLabel", {
		Parent = Holder,
		Name = "Text",
		Text = Text,
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamSemibold,
		TextSize = 16,
		TextScaled = true,
		TextWrapped = true,
		Size = UDim2.fromScale(1, 0.2),
		Position = UDim2.fromScale(0, 0.4),
		ZIndex = 5
	})

	local Accept = Utility.Create("ImageButton", {
		Parent = Holder,
		Image = "rbxassetid://17515824960",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.107, 0.257),
		Position = UDim2.fromScale(0.761, 0.673),
		ZIndex = 5
	})

	local Decline = Utility.Create("ImageButton", {
		Parent = Holder,
		Image = "rbxassetid://17515838102",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.1, 0.21),
		Position = UDim2.fromScale(0.9, 0.699),
		ZIndex = 5
	})

	TS:Create(Holder, TweenInfo.new(0.5), {Position = Direction or UDim2.fromScale(0.835, 0.890)}):Play()

	Accept.MouseEnter:Connect(function()
		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.102, 0.250)}):Play()
	end)

	Accept.MouseLeave:Connect(function()
		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.107, 0.257)}):Play()
	end)

	Accept.MouseButton1Down:Connect(function()
		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.090, 0.230)}):Play()
	end)

	Accept.MouseButton1Click:Connect(function()
		if Clicked then
			return
		end

		Clicked = true

		task.spawn(function()
			Callback(true)
		end)

		task.spawn(function()
			task.wait(0.5)

			HandleOptions(Accept, Decline, Holder, Position or UDim2.fromScale(1, 0.890))
		end)

		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.062, 0.2)}):Play()

		task.wait(0.15)

		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.107, 0.257)}):Play()
	end)

	Decline.MouseEnter:Connect(function()
		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.095, 0.203)}):Play()
	end)

	Decline.MouseLeave:Connect(function()
		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.1, 0.21)}):Play()
	end)

	Decline.MouseButton1Down:Connect(function()
		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.083, 0.183)}):Play()
	end)

	Decline.MouseButton1Click:Connect(function()
		if Clicked then
			return
		end

		Clicked = true

		task.spawn(function()
			Callback(false)
		end)

		task.spawn(function()
			task.wait(0.5)

			HandleOptions(Accept, Decline, Holder, Position or UDim2.fromScale(1, 0.890))
		end)

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.055, 0.153)}):Play()

		task.wait(0.15)

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.1, 0.21)}):Play()
	end)

	return Holder
end

function BoogaUI:Dialog(Title, Text, Callback)
	if self.MainLabel.Parent:FindFirstChild("Dialog") then
		self.MainLabel.Parent.Dialog:Destroy()
	end

	local Clicked

	local Dialog = Utility.Create("ImageButton", {
		Parent = self.MainLabel.Parent,
		Name = "Dialog",
		Image = "rbxassetid://14407899530",
		ImageTransparency = 0.5,
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 5

	})

	Dialog.AnchorPoint = Vector2.new(0.5, 0.5)

	Utility.Create("UICorner", {
		Parent = Dialog
	})

	Utility.Create("TextLabel", {
		Parent = Dialog,
		Name = "Title",
		Text = "<b>" .. Title .. "</b>",
		TextSize = 22,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamSemibold,
		RichText = true,
		BackgroundTransparency = 1,
		TextWrapped = true,
		Size = UDim2.fromScale(1, 0.25),
		ZIndex = 5
	})

	Utility.Create("TextLabel", {
		Parent = Dialog,
		Name = "Text",
		Text = Text,
		TextSize = 18,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamSemibold,
		BackgroundTransparency = 1,
		TextWrapped = true,
		Size = UDim2.fromScale(1, 0.7),
		Position = UDim2.fromScale(0, 0.075),
		ZIndex = 5
	})

	local Accept = Utility.Create("ImageButton", {
		Parent = Dialog,
		Image = "rbxassetid://17515824960",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.113, 0.191),
		Position = UDim2.fromScale(0.364, 0.747),
		ZIndex = 5
	})

	local Decline = Utility.Create("ImageButton", {
		Parent = Dialog,
		Image = "rbxassetid://17515838102",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.084, 0.172),
		Position = UDim2.fromScale(0.559, 0.757),
		ZIndex = 5
	})

	TS:Create(Dialog, TweenInfo.new(0.250), {Size = UDim2.fromScale(0.25, 0.29)}):Play()

	task.wait(0.250)

	TS:Create(Dialog, TweenInfo.new(0.250), {Size = UDim2.fromScale(0.2, 0.22)}):Play()

	Accept.MouseEnter:Connect(function()
		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.108, 0.184)}):Play()
	end)

	Accept.MouseLeave:Connect(function()
		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.113, 0.191)}):Play()
	end)

	Accept.MouseButton1Down:Connect(function()
		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.096, 0.164)}):Play()
	end)


	Accept.MouseButton1Click:Connect(function()
		if Clicked then
			return
		end

		Clicked = true

		task.spawn(function()
			Callback(true)
		end)

		task.spawn(function()
			task.wait(0.5)

			HandleOptions(Accept, Decline, Dialog, nil, UDim2.fromScale(0, 0))
		end)

		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.068, 0.134)}):Play()

		task.wait(0.15)

		TS:Create(Accept, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.113, 0.191)}):Play()
	end)


	Decline.MouseEnter:Connect(function()
		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.079, 0.165)}):Play()
	end)

	Decline.MouseLeave:Connect(function()
		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.084, 0.172)}):Play()
	end)

	Decline.MouseButton1Down:Connect(function()
		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.067, 0.145)}):Play()
	end)

	Decline.MouseButton1Click:Connect(function()
		if Clicked then
			return
		end

		Clicked = true

		task.spawn(function()
			Callback(false)
		end)

		task.spawn(function()
			task.wait(0.5)

			HandleOptions(Accept, Decline, Dialog, nil, UDim2.fromScale(0, 0))
		end)

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.039, 0.115)}):Play()

		task.wait(0.15)

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.084, 0.172)}):Play()
	end)

	return Dialog
end

function BoogaUI:Toggle()
	if not self.Toggled and not self.Toggling then

		self.Toggling = true

		self.MainLabel.TitleHolder.Title.ZIndex = 5

		for _, PageTitle in pairs(self.MainLabel.Pages:GetDescendants()) do
			if PageTitle.ClassName == "TextLabel" or PageTitle.Name == "Icon" then
				PageTitle.ZIndex = 5
			end
		end

		for _, Page in pairs(self.MainLabel:GetChildren()) do
			if Page.ClassName == "ScrollingFrame" then
				for _, Section in pairs(Page:GetChildren()) do
					if Section.ClassName == "ImageLabel" then
						TS:Create(Section.Frame.Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
					end
				end
			end
		end

		for _,v in pairs(self.Instances) do
			if not v.instance:IsDescendantOf(self.FocusedPage) and v.instance.Parent and v.instance.Parent.Name ~= "Profile" then
				continue	
			end
			
			v = v.instance

			if v.ClassName == "TextLabel" then
				TS:Create(v, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			elseif v.ClassName == "TextBox" then
				TS:Create(v, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			elseif v.Name == "Dropdown Arrow" then
				TS:Create(v, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
			elseif (v.ClassName == "ImageLabel" or v.ClassName == "ImageButton") then
				TS:Create(v, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
			elseif v.ClassName == "Frame" then
				TS:Create(v, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			elseif v.Name == "Dropdown Option" or v.ClassName == "TextButton" then
				TS:Create(v, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			end
			
			local Stroke = v:FindFirstChildOfClass("UIStroke")
			
			if Stroke and not self.OldValues[Stroke] then
				self.OldValues[Stroke] = Stroke.Thickness
			end
			
			if Stroke and Stroke.Thickness > 0 then
				TS:Create(Stroke, TweenInfo.new(0.5), {Thickness = 0}):Play()
			end

			if not v:FindFirstChild("UIListLayout") and v:FindFirstChild("Frame") then
				TS:Create(v, TweenInfo.new(0.5), {Size = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, v.Size.Y.Scale - v.Size.Y.Scale / 4, v.Size.Y.Offset - v.Size.Y.Offset / 4)}):Play()
			else
				TS:Create(v, TweenInfo.new(0.5), {Size = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, v.Size.Y.Scale - v.Size.Y.Scale / 2, v.Size.Y.Offset - v.Size.Y.Offset / 2)}):Play()
			end
		end

		TS:Create(self.MainLabel.TitleHolder.Title, TweenInfo.new(0.250), {TextTransparency = 1}):Play()

		for _, PageTitle in pairs(self.MainLabel.Pages:GetDescendants()) do
			if PageTitle.ClassName == "TextLabel" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {TextTransparency = 1, TextSize = 0}):Play()
			elseif PageTitle.Name == "Icon" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {ImageTransparency = 1}):Play()
			end
		end

		self.MainLabel.TitleHolder.ZIndex = 4
		TS:Create(self.MainLabel.TitleHolder, TweenInfo.new(0.5), {Size = self.MainLabel.Size}):Play()
		
		self.MainLabel.Parent.Glow.Visible = false

		task.wait(0.5)

		self.MainLabel.ClipsDescendants = true

		TS:Create(self.MainLabel.TitleHolder, TweenInfo.new(0.5), {Size = UDim2.fromOffset(self.MainLabel.TitleHolder.Size.X.Offset, 0)}):Play()
		TS:Create(self.MainLabel, TweenInfo.new(0.5), {Size = UDim2.fromOffset(self.MainLabel.Size.X.Offset, 0)}):Play()

		task.wait(0.5)

		self.Toggled = true
		self.Toggling = false

	elseif self.Toggled and not self.Toggling then

		self.Toggling = true

		self.MainLabel.ClipsDescendants = false

		TS:Create(self.MainLabel.TitleHolder, TweenInfo.new(0.5), {Size = UDim2.fromOffset(self.MainLabel.TitleHolder.Size.X.Offset, 450)}):Play()

		task.wait(0.5)
		
		self.MainLabel.Parent.Glow.Visible = true

		self.MainLabel.Size = UDim2.fromOffset(self.MainLabel.Size.X.Offset, 450)
		TS:Create(self.MainLabel.TitleHolder, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0.095, 0)}):Play()

		for _,v in pairs(self.Instances) do
			
			if not v.instance:IsDescendantOf(self.FocusedPage) and v.instance.Parent and v.instance.Parent.Name ~= "Profile" then
				continue	
			end
			
			local Stroke = v.instance:FindFirstChildOfClass("UIStroke")

			if Stroke then
				TS:Create(Stroke, TweenInfo.new(0.3), {Thickness = self.OldValues[Stroke] or (v.instance.Name == "Preview" and 2) or 1}):Play()
			end
			
			if v.instance.ClassName == "TextLabel" then
				TS:Create(v.instance, TweenInfo.new(0.8), {TextTransparency = v.instance.Parent.Parent.Name == "Dropdown" and 0.07 or (v.instance.Parent:FindFirstChild("Toggled") and v.instance.Parent.Toggled.Value and 0 or v.instance.Parent:FindFirstChild("Toggled") and 0.12) or v.instance.Name == "Title" and 0.07 or 0}):Play()
			elseif v.instance.ClassName == "TextBox" then
				TS:Create(v.instance, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
			elseif v.instance.Name == "Dropdown Arrow" then

				task.delay(0.150, function()
					TS:Create(v.instance, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
				end)

			elseif v.instance.ClassName == "ImageLabel" or v.instance.ClassName == "ImageButton" then
				TS:Create(v.instance, TweenInfo.new(0.8), {ImageTransparency = 0}):Play()
			elseif v.instance.ClassName == "Frame" then
				TS:Create(v.instance, TweenInfo.new(0.8), {BackgroundTransparency = v.instance.Name == "ToggleBase" and 0.9 or v.instance.Name == "ToggleCircle" and 0.1 or v.instance.Name == "Profile Separator" and 0.750 or 0}):Play()
			elseif v.instance.ClassName == "TextButton" then
				TS:Create(v.instance, TweenInfo.new(0.8), {BackgroundTransparency = 0, TextTransparency = 0.1}):Play()
			elseif v.instance.Name == "Dropdown Option" then
				TS:Create(v.instance, TweenInfo.new(0.6), {BackgroundTransparency = 0, TextTransparency = 0.1}):Play()
				TS:Create(v.instance, TweenInfo.new(0.4), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()

				continue
			end

			TS:Create(v.instance, TweenInfo.new(0.3), {Size = v.Size}):Play()
		end

		task.delay(0.2, function()
			for _, Page in pairs(self.MainLabel:GetChildren()) do
				if Page.ClassName == "ScrollingFrame" then
					for _, Section in pairs(Page:GetChildren()) do
						if Section.ClassName == "ImageLabel" then
							TS:Create(Section.Frame.Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
						end
					end
				end
			end
		end)

		self.MainLabel.ClipsDescendants = true

		task.wait(0.450)

		TS:Create(self.MainLabel.TitleHolder.Title, TweenInfo.new(0.250), {TextTransparency = 0}):Play()

		for _, PageTitle in pairs(self.MainLabel.Pages:GetDescendants()) do
			if PageTitle.ClassName == "TextLabel" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {TextTransparency = 0}):Play()

				TS:Create(PageTitle, TweenInfo.new(0.1), {TextSize = 18}):Play()
			elseif PageTitle.Name == "Icon" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {ImageTransparency = 0.4}):Play()
			end
		end

		self.MainLabel.TitleHolder.ZIndex = 1
		self.MainLabel.TitleHolder.Title.ZIndex = 1

		for _, PageTitle in pairs(self.MainLabel.Pages:GetDescendants()) do
			if PageTitle.ClassName == "TextLabel" or PageTitle.Name == "Icon" then
				PageTitle.ZIndex = 1
			end
		end

		self.Toggled = false
		self.Toggling = false
	end
end

function BoogaUI:AddInstances(Arg)
	if #Arg > 2 then
		for idx = 1, #Arg, 2 do
			local tbl = {instance = Arg[idx], Size = Arg[idx + 1]}
			table.insert(self.Instances, tbl)

			if Arg[idx]:FindFirstChild("AddIndex") then
				self.Instances[Arg[idx]] = tbl
			end
		end
	else
		local tbl = {instance = Arg[1], Size = Arg[2]}
		table.insert(self.Instances, tbl)

		if Arg[1]:FindFirstChild("AddIndex") then
			self.Instances[Arg[1]] = tbl
		end
	end
end

function BoogaUI:Destroy(DestroyPrevious)
	for _,v in pairs(identifyexecutor and game.CoreGui:GetChildren() or Player.PlayerGui:GetChildren()) do
		if (DestroyPrevious and v ~= self.MainLabel.Parent and v:FindFirstChild("MainLabel")) or (not DestroyPrevious and v:FindFirstChild("MainLabel") and v.MainLabel:FindFirstChild("TitleHolder")) then
			v:Destroy()
		end
	end

	for idx = 1, #CleanConnections do
		CleanConnections[idx]:Disconnect()
		CleanConnections[idx] = nil
	end
end

return BoogaUI
