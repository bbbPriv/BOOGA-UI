local BoogaUI = {}
local Utility = {}

local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local TS = game:GetService("TweenService")

function Utility.Create(ClassName, Properties)
	local instance = Instance.new(ClassName)

	for k,v in Properties do
		if not pcall(function() instance[k] = v end) then
			warn("Property " .. k .. " does not exist in " .. instance.Name)
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

local function Pop(instance, Offset)
	local Clone = instance:Clone()
	Clone:ClearAllChildren()

	Clone.Size = instance.Size - UDim2.new(0, Offset, 0, Offset)
	Clone.Parent = instance.Parent

	Clone.Position = instance.Position
	instance.ImageTransparency = 1

	TS:Create(Clone, TweenInfo.new(0.2), {Size = instance.Size}):Play()

	task.wait(0.2)

	Clone:Destroy()
	instance.ImageTransparency = 0
end

local function UpdateSlider(Bar, Value, Min, Max, Decimal)
	local percent = (Player:GetMouse().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X

	if Value then
		percent = (Value - Min) / (Max - Min)
	end

	percent = math.clamp(percent, 0, 1)
	Value = Value or not Decimal and math.floor(Min + (Max - Min) * percent) or Min + (Max - Min) * percent
	Value = not Decimal and Value or string.format("%.1f", Value)

	Bar.Parent.TextBox.Text = Value
	TS:Create(Bar.Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1 ,0)}):Play()

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

local function StartsWith(str, start)
	return string.match(str, "^" .. start) ~= nil
end

function Utility.Press(instance, Duration)

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

function Sections:Resize()
	local Size = 32

	for _,v in self.Section.Frame:GetChildren() do
		if v.ClassName ~= "UIListLayout" and v.ClassName ~= "TextLabel" then
			
			if v:FindFirstChild("List") and v.List.ScrollingFrame:FindFirstChildOfClass("TextButton") then
				Size += 128
			else
				Size += v.AbsoluteSize.Y + 8
			end
		end
	end

	self.Instances[self.Section].Size = UDim2.new(1, -16, 0, Size)
	self.Section.Size = UDim2.new(1, -16, 0, Size)
	
	return Size
end

function Sections:AddButton(Name, Callback)
	local Pressing = false

	local Hovering

	local Button = Utility.Create("TextButton", {
		Parent = self.Section.Frame,
		ZIndex = 2,
		Text = Name,
		TextSize = 16,
		Font = Enum.Font.Arial,
		Size = UDim2.new(0.950, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0.1
	})
	
	self:Resize()

	self:ResizePage()

	self:AddInstances({Button, Button.Size})

	Utility.Create("UICorner", {
		Parent = Button,
		CornerRadius = UDim.new(0, 4)
	})

	Button.MouseEnter:Connect(function()
		Hovering = true

		TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 29)}):Play()
	end)

	Button.MouseLeave:Connect(function()
		Hovering = false

		TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()

		if Button.TextSize == 10 then
			TS:Create(Button, TweenInfo.new(0.1), {TextSize = 16}):Play()
		end
	end)

	Button.MouseButton1Down:Connect(function()
		TS:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.900, 0, 0, 26)}):Play()

		TS:Create(Button, TweenInfo.new(0.1), {TextSize = 14}):Play()
	end)

	Button.MouseButton1Click:Connect(function()

		if Pressing then
			return
		end

		task.spawn(Callback)

		local Tween = TS:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.850, 0, 0, 24)})
		Tween:Play()

		Tween.Completed:Connect(function()
			if Hovering then
				TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 28)}):Play()
			else
				TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()
			end
		end)

		Button.TextSize = 0

		local Effect = TS:Create(Button, TweenInfo.new(0.2), {TextSize = 20})
		Effect:Play()

		Effect.Completed:Connect(function()
			TS:Create(Button, TweenInfo.new(0.1), {TextSize = 16}):Play()
		end)

		Pressing = true

		Pressing = false
	end)

	return Button
end

function Sections:AddToggle(Name, IsEnabled, Callback)
	local Switching = false

	local Toggle = Utility.Create("Frame", {
		Name = "Toggle",
		Parent = self.Section.Frame,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Size = UDim2.new(0.950, 0, 0, 30),
		ZIndex = 2,
	})

	local Toggled = Utility.Create("BoolValue", {
		Parent = Toggle,
		Name = "Toggled"
	})

	Utility.Create("UICorner", {
		Parent = Toggle,
		CornerRadius = UDim.new(0, 4)
	})

	if IsEnabled then

		Toggled.Value = true

		task.spawn(function()
			Callback(Toggled)
		end)
	end

	self:Resize()

	self:ResizePage()

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = Toggle,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 1),
		Size = UDim2.fromScale(0.5, 1),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextTransparency = 0.10000000149012,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Utility.Create("UICorner", {
		Parent = Utility.Create("Frame", {
			Parent = Toggle,
			Name = "ToggleBase",
			BackgroundTransparency = 0.9,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(1, -50, 0.5, -8),
			Size = UDim2.fromOffset(40, 16),
			ZIndex = 2,
		}),

		CornerRadius = UDim.new(0, 8)
	})

	Utility.Create("UICorner", {
		Parent = Utility.Create("Frame", {
			Parent = Toggle.ToggleBase,
			Name = "ToggleCircle",
			BackgroundTransparency = 0.1,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = not IsEnabled and UDim2.new(0, 2, 0.5, -6) or UDim2.new(0, 20, 0.5, -6),
			Size = UDim2.new(1, -22, 1, -4),
			ZIndex = 2,
		}),

		CornerRadius = UDim.new(0, 8)
	})

	local Button = Utility.Create("ImageButton", {
		Parent = Toggle.ToggleBase,
		ZIndex = 2,
		Size = Toggle.ToggleBase.Size,
		ImageTransparency = 1,
		BackgroundTransparency = 1
	})

	self:AddInstances({Toggle, Toggle.Size, Toggle.Title, Toggle.Title.Size, Toggle.ToggleBase, Toggle.ToggleBase.Size, Toggle.ToggleBase.ToggleCircle, Toggle.ToggleBase.ToggleCircle.Size})

	Toggle.MouseEnter:Connect(function()
		TS:Create(Toggle, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 29)}):Play()
	end)

	Toggle.MouseLeave:Connect(function()
		TS:Create(Toggle, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()
	end)

	Button.MouseButton1Click:Connect(function()

		if Switching then
			return
		end

		Toggled.Value = not Toggled.Value

		task.spawn(function()
			Callback(Toggled)
		end)

		Switching = true

		local position = {
			In = UDim2.new(0, 2, 0.5, -6),
			Out = UDim2.new(0, 20, 0.5, -6)
		}

		local Frame = Toggle.ToggleBase.ToggleCircle
		local value = Toggled.Value and "Out" or "In"

		TS:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -22, 1, -9), Position = position[value] + UDim2.new(0, 0, 0, 2.5)}):Play()

		task.wait(0.1)

		TS:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -22, 1, -4), Position = position[value]}):Play()

		task.wait(0.1)

		Switching = false
	end)

	return Toggle
end

function Sections:AddTextBox(Name, CallBack)

	local DoubleClick = 0

	local DoubleClicked = false

	local Holder = Utility.Create("ImageButton", {
		Parent = self.Section.Frame,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0.950, 0, 0, 30),
		ZIndex = 2,
		Image = "rbxassetid://5028857472",
		ImageColor3 = Color3.fromRGB(15, 15, 15),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 298, 298)
	})
	
	self:Resize()

	self:ResizePage()

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = Holder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 1),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextTransparency = 0.10000000149012,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Label = Utility.Create("ImageLabel", {
		Parent = Holder,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -110, 0.5, -8),
		Size = UDim2.new(0, 100, 0, 16),
		ZIndex = 2,
		Image = "rbxassetid://5028857472",
		ImageColor3 = Color3.fromRGB(28, 28, 28),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 298, 298)
	})

	local TextBox = Utility.Create("TextBox", {
		BackgroundTransparency = 1,
		Parent = Label,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 5, 0, 0),
		Size = UDim2.new(1, -10, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12
	})

	self:AddInstances({Holder, Holder.Size, Holder.Title, Holder.Title.Size, Label, Label.Size, TextBox, TextBox.Size})

	Holder.MouseEnter:Connect(function()
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 29)}):Play()
	end)

	Holder.MouseLeave:Connect(function()
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()
	end)

	Holder.MouseButton1Click:Connect(function()

		if Label.Size ~= UDim2.new(0, 220, 0, 16) then
			TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(1, -230, 0.5, -8)}):Play()
		else
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

						TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(1, -230, 0.5, -8)}):Play()
					else
						DoubleClicked = false

						TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}):Play()
					end
				end

				task.wait(0.3)

				DoubleClick = 0
			end
		end
	end)

	TextBox:GetPropertyChangedSignal("Text"):Connect(function()

		task.spawn(function()
			CallBack(TextBox.Text, false)
		end)

		Pop(Label, 4)
	end)

	TextBox.FocusLost:Connect(function()
		if DoubleClicked then
			DoubleClicked = false
			task.wait(0.1)

			TS:Create(Label, TweenInfo.new(0.2), {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}):Play()
		end

		TextBox.TextXAlignment = Enum.TextXAlignment.Center

		CallBack(TextBox.Text, true)
	end)

	return Holder
end

function Sections:AddKeybind(Name, Key, Callback)
	local Old = typeof(Key) == "string" and Enum.KeyCode[Key:upper()].Name or (Key and Key.Name or "None")

	local Selecting = false

	local Stop = false

	local Holder = Utility.Create("ImageButton", {
		Parent = self.Section.Frame,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0.950, 0, 0, 30),
		ZIndex = 2,
		Image = "rbxassetid://5028857472",
		ImageColor3 = Color3.fromRGB(15, 15, 15),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 298, 298)
	})
	
	self:Resize()

	self:ResizePage()

	self:AddInstances({Holder, Holder.Size})

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = Holder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 1),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextTransparency = 0.10000000149012,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Label = Utility.Create("ImageLabel", {
		Parent = Holder,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -110, 0.5, -8),
		Size = UDim2.new(0, 100, 0, 16),
		ZIndex = 2,
		Image = "rbxassetid://5028857472",
		ImageColor3 = Color3.fromRGB(28, 28, 28),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 298, 298)
	})

	local KeyLabel = Utility.Create("TextLabel", {
		Name = "KeyLabel",
		BackgroundTransparency = 1,
		Parent = Label,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 5, 0, 0),
		Size = UDim2.new(1, -10, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = typeof(Key) == "string" and Enum.KeyCode[Key:upper()].Name or (Key and Key.Name or "None"),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12
	})

	self:AddInstances({Holder, Holder.Size, Holder.Title, Holder.Title.Size, Label, Label.Size, KeyLabel, KeyLabel.Size})

	Holder.MouseEnter:Connect(function()
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 29)}):Play()
	end)

	Holder.MouseLeave:Connect(function()
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()
	end)

	UIS.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key and not Selecting then
			task.spawn(function()
				Callback(Enum.KeyCode[Key.Name])
			end)
		end
	end)

	Holder.MouseButton1Click:Connect(function()
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
				Key = Enum.KeyCode[Old]
				KeyLabel.Text = Key.Name

				break
			end
		end

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

	UIS.InputBegan:Connect(function(Input, GME)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not isPointInBounds(Input.Position, Holder) and KeyLabel.Text == "..." then
				Stop = true
				Selecting = false

				KeyLabel.Text = Old
			end
		end
	end)

	return Holder
end

function Sections:AddSlider(Name, Value, Min, Max, FixValues, Decimal, Callback)	

	local Holder = Utility.Create("Frame", {
		Parent = self.Section.Frame,
		BackgroundTransparency = 0.1,
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -50, 0.5, -8),
		Size = UDim2.new(0.950, 0, 0, 50),
		ZIndex = 2,
	})
	
	self:Resize()

	self:ResizePage()
	
	Utility.Create("UICorner", {
		Parent = Holder,
		CornerRadius = UDim.new(0, 4)
	})

	table.insert(self.Instances, {instance = Holder, Size = Holder.Size})

	Utility.Create("TextLabel", {
		Name = "Title",
		Parent = Holder,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.02, 0, 0.280, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextTransparency = 0.10000000149012,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Box = Utility.Create("TextBox", {
		Parent = Holder,
		BorderSizePixel = 0,
		Font = Enum.Font.Arial,
		ZIndex = 2,
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		Text = Value,
		Size = UDim2.fromScale(0.1, 0.6),
		Position = UDim2.fromScale(0.88, 0),
		TextXAlignment = Enum.TextXAlignment.Right
	})

	local Bar = Utility.Create("Frame", {
		Parent = Holder,
		Name = "Bar",
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Size = UDim2.fromScale(0.633, 0.22),
		Position = UDim2.fromScale(0.205, 0.550)
	})

	local Fill = Utility.Create("Frame", {
		Parent = Bar,
		Name = "Fill",
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromScale(0.142, 1)
	})

	self:AddInstances({Holder, Holder.Size, Holder.Title, Holder.Title.Size, Box, Box.Size, Bar, Bar.Size, Fill, Fill.Size})

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
		Size = UDim2.fromOffset(19, 15),
		Position = UDim2.fromScale(-0.5, 0),
		ZIndex = 2,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4608020054",
	})

	local Old

	local dragging = false

	UpdateSlider(Bar, Value, Min, Max, Decimal)

	Holder.MouseEnter:Connect(function()
		TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 49)}):Play()
	end)

	Holder.MouseLeave:Connect(function()
		if not dragging then
			TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 50)}):Play()
		else
			repeat task.wait() until not dragging

			TS:Create(Holder, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 50)}):Play()
		end
	end)

	Bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true

			TS:Create(Circle, TweenInfo.new(0.1), {Position = UDim2.new(0, math.clamp(input.Position.X - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X) - 15, 0, -2)}):Play()

			TS:Create(Circle, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()

			Callback(UpdateSlider(Bar, nil, Min, Max, Decimal))		

			repeat task.wait() until not dragging

			task.wait(0.5)

			if dragging then
				return
			end

			TS:Create(Circle, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
			
			task.wait(0.2)
			
		end
	end)

	Bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

			
			TS:Create(Circle, TweenInfo.new(0.1), {Position = UDim2.new(0, math.clamp(input.Position.X - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X) - 15, 0, -2)}):Play()

			TS:Create(Circle, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()

			local Num = UpdateSlider(Bar, nil, Min, Max, Decimal)

			if Num ~= Old then
				Callback(UpdateSlider(Bar, nil, Min, Max, Decimal))
			end

			Old = Num

			repeat task.wait() until not dragging

			task.wait(0.5)

			if dragging then
				return
			end

			TS:Create(Circle, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
			
			task.wait(0.2)
			
		end
	end)

	Box:GetPropertyChangedSignal("Text"):Connect(function()
		local Num = tonumber(Box.Text)

		if Num then
			if FixValues then
				Box.Text = Num > Max and Max or Num < Min and Min or Box.Text
			end

			Callback(UpdateSlider(Bar, Box.Text, Min, Max, Decimal))
		end
	end)

	return Holder
end

function Sections:AddDropdown(Name, Entries, Callback)
	local Dropping = false
	local Last = 0

	local Dont = false

	local Holder = Utility.Create("Frame", {
		Name = "Dropdown",
		Parent = self.Section.Frame,
		Size = UDim2.new(0.950, 0, 0, 30),
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

	Utility.Create("UICorner", {
		Parent = Holder2,
		CornerRadius = UDim.new(0, 4)
	})

	local ScrollingFrame

	local function MakeEntries(Optional)

		for _,v in ScrollingFrame:GetChildren() do
			if v.ClassName == "TextButton" then
				v:Destroy()
			end
		end

		if Entries then
			for _,v in Entries do

				if Holder2.TextBox.Text ~= "None Selected" and not v:find(Holder2.TextBox.Text) then
					continue
				end

				local Pressing = false
				local Hovering = false

				local Button = Utility.Create("TextButton", {
					Parent = ScrollingFrame,
					Text = v,
					TextSize = 14,
					Font = Enum.Font.Arial,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextTransparency = 0.1,
					ZIndex = 2,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(41, 41, 41),
					BackgroundTransparency = 0.1
				})

				TS:Create(Button, TweenInfo.new(0.2), {Size = UDim2.fromScale(0.950, 0.130)}):Play()

				Button.MouseEnter:Connect(function()
					Hovering = true

					TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.930, 0.126)}):Play()
				end)

				Button.MouseLeave:Connect(function()
					Hovering = false

					TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.950, 0.130)}):Play()
				end)

				Button.MouseButton1Click:Connect(function()

					if Pressing then
						return
					end

					task.spawn(function()
						Callback(v)
					end)

					Dont = true

					Holder2.TextBox.Text = v

					local Tween = TS:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.850, 0, 0, 24)})
					Tween:Play()

					Tween.Completed:Connect(function()
						if Hovering then
							TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.930, 0, 0, 28)}):Play()
						else
							TS:Create(Button, TweenInfo.new(0.15), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()
						end
					end)

					Button.TextSize = 0

					local Effect = TS:Create(Button, TweenInfo.new(0.2), {TextSize = 16})
					Effect:Play()

					Effect.Completed:Connect(function()
						TS:Create(Button, TweenInfo.new(0.1), {TextSize = 12}):Play()
					end)

					Pressing = true

					Pressing = false
				end)

				Utility.Create("UICorner", {
					Parent = Button,
					CornerRadius = UDim.new(0, 8)
				})

				if Optional and not StartsWith(v, Holder2.TextBox.Text) then
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
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.02, 0, 0.5, 0),
		Size = UDim2.new(0.3, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = Name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextTransparency = 0.10000000149012,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local TextBox = Utility.Create("TextBox", {
		Parent = Holder2,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.660, 0, 0.5, 0),
		Size = UDim2.new(0.3, 0, 1, 0),
		ZIndex = 3,
		Font = Enum.Font.Arial,
		Text = "None Selected",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextTransparency = 0.10000000149012,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	self:AddInstances({Holder, Holder.Size, Holder2, Holder2.Size, Holder2.TextLabel, Holder2.TextLabel.Size, TextBox, TextBox.Size})

	TextBox:GetPropertyChangedSignal("Text"):Connect(function()

		if Dont then
			Dont = false
			return
		end
		
		if Holder.List.Size.Y.Offset == 30 then
			return
		end

		if TextBox.Text == "None Selected" then
			return
		end

		MakeEntries(TextBox.Text)
	end)

	TextBox.FocusLost:Connect(function()
		if TextBox.Text == "" then
			TextBox.Text = "None Selected"
		end
	end)

	Utility.Create("ImageButton", {
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
		Size = UDim2.new(0.97, 0, 0, 30),
		Position = UDim2.fromScale(0.010, 0),
		ZIndex = 2,
	})

	Utility.Create("UICorner", {
		Parent = List,
		CornerRadius = UDim.new(0, 8)
	})

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

	Utility.Create("UIListLayout", {
		Parent = ScrollingFrame,
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	})

	Holder2.ImageButton.MouseButton1Click:Connect(function()
		if Dropping then
			return
		end

		Dropping = true

		if Holder2.ImageButton.Rotation == 0 then

			TS:Create(Holder2.ImageButton, TweenInfo.new(0.3), {Rotation = 180}):Play()
			TS:Create(Holder, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

			TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 150)}):Play()
			TS:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(0.970, 0, 0, 120), BackgroundTransparency = 0.1, Position = UDim2.fromScale(0.010, 0.2)}):Play()
			TS:Create(ScrollingFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 120)}):Play()

			ScrollingFrame.Visible = true

			MakeEntries()
			
			self:Resize()
			self:ResizePage(true)

		else

			for _,v in ScrollingFrame:GetChildren() do
				if v.ClassName == "TextButton" then
					local Tween = TS:Create(v, TweenInfo.new(0.2), {Size = UDim2.fromScale(0, 0.130), TextTransparency = 1, BackgroundTransparency = 1})
					Tween:Play()

					Tween.Completed:Connect(function()
						v:Destroy()
					end)					
				end
			end
			
			local Size = self:Resize()

			self.Instances[self.Section].Size = UDim2.new(1, -16, 0, Size - 120)
			self.Section.Size = UDim2.new(1, -16, 0, Size - 120)
			
			self:ResizePage()

			TS:Create(Holder2.ImageButton, TweenInfo.new(0.3), {Rotation = 0}):Play()
			TS:Create(Holder, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()

			TS:Create(Holder, TweenInfo.new(0.3), {Size = UDim2.new(0.950, 0, 0, 30)}):Play()
			TS:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(0.970, 0, 0, 30), BackgroundTransparency = 1}):Play()
			TS:Create(ScrollingFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 30)}):Play()

		end

		task.wait(0.3)

		Dropping = false
	end)

	return Holder
end

function Sections:AddSeparator(YOffset)
	local Separator = Utility.Create("Frame", {
		Parent = self.Section.Frame,
		ZIndex = 2,
		Size = UDim2.new(0.950, 0, 0, YOffset),
		BackgroundTransparency = 1
	})
	
	self:Resize()

	self:ResizePage()

	self:AddInstances({Separator, Separator.Size})


	return Separator
end

function Pages:AddSection(Name : string)

	if not Name then
		error("No section name")
	end

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
	}).Padding = UDim.new(0, 8)

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
		["Text"] = Name,
		["TextColor3"] = Color3.fromRGB(255, 255, 255),
		["TextSize"] = 18,
		["TextXAlignment"] = Enum.TextXAlignment.Center,
		["TextYAlignment"] = Enum.TextYAlignment.Bottom
	})


	return setmetatable({SectionPage = self.Page, Section = Section}, Sections)
end

function Pages:ResizePage(DropdownCall)
	local Size = self.SectionPage["Search Bar"].Visible and 50 or 0

	for _, section in self.SectionPage:GetChildren() do
		if section.ClassName == "ImageLabel" then
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

	local Tween

	Bar.TextBox:GetPropertyChangedSignal("Text"):Connect(function()

		if not Tween then
			Tween = TS:Create(self.Page, TweenInfo.new(0.3), {CanvasPosition = Vector2.new(0, 0)})
			Tween:Play()

			Tween.Completed:Connect(function()
				Tween = nil
			end)
		end

		for _, v in self.Page:GetChildren() do
			if v.ClassName == "ImageLabel" then
				for _, v2 in v.Frame:GetChildren() do
					if Bar.TextBox.Text == "" and v2.ClassName ~= "UIListLayout" then
						v2.Visible = true
						continue
					end

					local Label = v2:FindFirstChildOfClass("TextLabel") or (v2.ClassName == "TextButton" and v2) or v2.Name == "Dropdown" and v2.Frame.TextLabel


					if Label then
						if Label.ClassName == "TextLabel" then

							if Label.Parent.Parent.Name == "Dropdown" then
								Label.Parent.Parent.Visible = Label.Text:lower():find(self.Page["Search Bar"].TextBox.Text:lower()) or false
							else
								Label.Parent.Visible = Label.Text:lower():find(self.Page["Search Bar"].TextBox.Text:lower()) or false
							end

						else
							Label.Visible = Label.Text:lower():find(self.Page["Search Bar"].TextBox.Text:lower()) or false
						end
					end

				end
			end
		end
	end)

	return self
end


function BoogaUI.New(Name : string)

	if not Name then
		error("No Name argument")
	end

	BoogaUI.Toggled = false

	BoogaUI.Toggling = false

	BoogaUI.Instances = {}

	BoogaUI.Name = Name

	BoogaUI.Pages = {}

	local SG = Utility.Create("ScreenGui", {
		["Parent"] = identifyexecutor and game.CoreGui or Player.PlayerGui,
		["Name"] = Name,
	})

	local MainLabel = Utility.Create("ImageLabel", {
		["Parent"] = SG,
		["Name"] = "MainLabel",
		["Size"] = UDim2.fromOffset(600, 450),
		["Position"] = UDim2.new(0.171, 354, 0.133, -24),
		["BackgroundTransparency"] = 1,
		["ImageColor3"] = Color3.fromRGB(42, 42, 42),
		["Image"] = "rbxassetid://4641149554",
		["ClipsDescendants"] = true
	})

	BoogaUI.MainLabel = MainLabel

	Utility.Create("ImageLabel", {
		Parent = MainLabel,
		Name = "Glow",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -15, 0, -15),
		Size = UDim2.new(1, 30, 1, 28),
		ZIndex = 0,
		Image = "rbxassetid://5028857084",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(24, 24, 276, 276)
	})

	local Pages = Utility.Create("ImageLabel", {
		["Parent"] = MainLabel,
		["Name"] = "Pages",
		["Size"] = UDim2.fromScale(0.200, 0.871),
		["Position"] = UDim2.new(0, 0, 0.128, 0),
		["BorderSizePixel"] = 0,
		["ImageColor3"] = Color3.fromRGB(27, 27, 27),
		["Image"] = "rbxassetid://5012534273",

	})

	BoogaUI.Pages = Pages

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

	local Top = Utility.Create("ImageLabel", {
		["Parent"] = MainLabel,
		["Name"] = "TitleHolder",
		["Size"] = UDim2.fromScale(1, 0.128),
		["BorderSizePixel"] = 0,
		["ImageColor3"] = Color3.fromRGB(27, 27, 27),
		["Image"] = "rbxassetid://5012534273"
	})

	Utility.Create("TextLabel", {
		Parent = Top,
		Name = "Title",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 19),
		Size = UDim2.new(1, -46, 0, 16),
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = Name,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local dragging = false
	local dragInput, mousePos, framePos

	Top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = MainLabel.Position

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
			framePos = MainLabel.Position

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
			TS:Create(MainLabel, TweenInfo.new(0.090, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)}):Play()
		end
	end)

	return BoogaUI
end

function BoogaUI:AddPage(Title, Icon)

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

	local Size = 0

	for _, section in self.PagesScrolling:GetChildren() do
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
		["Text"] = Title,
		["TextSize"] = 22,
		["Font"] = Enum.Font.Arial,
		["TextColor3"] = Color3.fromRGB(220, 220, 220),
		["Size"] = UDim2.fromScale(1, 1)
	})

	local Icon = Utility.Create("ImageLabel", {
		Name = "Icon",
		Parent = Button,
		BackgroundTransparency = 1,
		ImageTransparency = 0.5,
		Image = tostring(Icon):find("rbx") and Icon or "rbxassetid://" .. tostring(Icon),
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(0, 4, 0.13, 0),
	})

	if not self.FocusedPage then
		self.FocusedPage = Button
	end

	local Page = Utility.Create("ScrollingFrame", {
		["Parent"] = self.MainLabel,
		["Name"] = Title,
		["BackgroundTransparency"] = 1,
		["Position"] = UDim2.new(0.225, 0, 0.14, 0),
		["Size"] = UDim2.new(1, -142, 1, -56),
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
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
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
		Position = UDim2.fromScale(0.9, 0.1),
		ZIndex = 2
	})

	Utility.Create("TextBox", {
		Parent = Page["Search Bar"],
		Size = UDim2.fromScale(0.930, 0.9),
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

	if self.FocusedPage == Button then
		self.FocusedPage = Page
	end

	Button.MouseEnter:Connect(function()
		if AnimatingClick then
			return
		end

		TS:Create(PageTitle, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(170, 170, 170)}):Play()

	end)

	Button.MouseLeave:Connect(function()
		if AnimatingClick then
			return
		end

		TS:Create(PageTitle, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()

	end)

	Button.MouseButton1Down:Connect(function()
		if AnimatingClick then
			return
		end

		TS:Create(PageTitle, TweenInfo.new(0.2), {TextSize = 20}):Play()

		TS:Create(Icon, TweenInfo.new(0.1), {Size = UDim2.fromOffset(18, 18)}):Play()
	end)

	Button.MouseButton1Click:Connect(function()

		task.spawn(function()
			AnimatingClick = true

			TS:Create(PageTitle, TweenInfo.new(0.2), {TextSize = 27}):Play()

			TS:Create(Icon, TweenInfo.new(0.1), {Size = UDim2.fromOffset(21, 22)}):Play()

			task.wait(0.2)

			TS:Create(PageTitle, TweenInfo.new(0.2), {TextSize = 22}):Play()

			TS:Create(Icon, TweenInfo.new(0.1), {Size = UDim2.fromOffset(20, 20)}):Play()

			task.wait(0.2)

			AnimatingClick = false
		end)

		if self.FocusedPage == Page then
			return
		end

		local OldBackgroundTransparency
		local OldTextTransparency
		local OldImageTransparency

		for _,v in self.Instances do
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

					else
						if instance.Name == "Title" or instance.Name == "TextBox" or instance.Name == "KeyLabel" then
							continue
						end

						TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 2, instance.Size.Y.Offset - instance.Size.Y.Offset / 1.1), ImageTransparency = 1}):Play()
					end

					for _,instance in instance:GetDescendants() do

						if instance.ClassName == "UICorner" or instance.ClassName == "ScrollingFrame" or instance.ClassName == "UIListLayout" or instance.ClassName == "BoolValue" or instance.Name == "Circle" or instance.Name == "ToggleBase" or instance.Name == "ToggleCircle" then
							continue
						end

						local OldSize = instance.Size

						if instance.ClassName == "Frame" or instance.ClassName == "TextButton" then
							OldBackgroundTransparency = instance.BackgroundTransparency
							TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale - instance.Size.Y.Scale / 2, instance.Size.Y.Offset - instance.Size.Y.Offset / 1.1), BackgroundTransparency = instance.Name == "ToggleBase" and 0.9 or instance.Name == "ToggleCircle" and 0.5 or 1}):Play()

						elseif instance.ClassName == "TextLabel" or instance.ClassName == "TextBox" then
							OldTextTransparency = instance.TextTransparency
							TS:Create(instance, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
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

		task.wait(0.3)

		Old.Visible = false

		for _,v in self.Instances do
			local instance = v.instance

			if instance:IsDescendantOf(Page) then
				instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, 0, 0)

				TS:Create(instance, TweenInfo.new(0.3), {Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, v.Size.Y.Scale, v.Size.Y.Offset)}):Play()

				if instance.ClassName == "TextButton" then
					TS:Create(instance, TweenInfo.new(0.150), {TextSize = 16, TextTransparency = 0.1}):Play()
				end
			end
		end

		Page.Visible = true

	end)

	BoogaUI.LastPage = Button

	return setmetatable({Page = Page}, Pages)
end

function BoogaUI:Notify(Title, Text, Position, Direction, Callback)
	local Clicked = false

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

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.055, 0.153)}):Play()

		task.wait(0.15)

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.1, 0.21)}):Play()
	end)

	repeat task.wait() until Clicked

	task.wait(0.5)

	HandleOptions(Accept, Decline, Holder, Position or UDim2.fromScale(1, 0.890))
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

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.039, 0.115)}):Play()

		task.wait(0.15)

		TS:Create(Decline, TweenInfo.new(0.15), {Size = UDim2.fromScale(0.084, 0.172)}):Play()
	end)

	repeat task.wait() until Clicked

	task.wait(0.5)

	HandleOptions(Accept, Decline, Dialog, nil, UDim2.fromScale(0, 0))
end

function BoogaUI:Toggle()
	if not self.Toggled and not self.Toggling then

		self.Toggling = true

		self.MainLabel.TitleHolder.Title.ZIndex = 5

		for _, PageTitle in self.MainLabel.Pages:GetDescendants() do
			if PageTitle.ClassName == "TextLabel" or PageTitle.Name == "Icon" then
				PageTitle.ZIndex = 5
			end
		end

		for _,v in self.Instances do
			v = v.instance

			if v.ClassName == "TextLabel" then
				TS:Create(v, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			elseif v.ClassName == "TextBox" then
				TS:Create(v, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			elseif v.ClassName == "ImageLabel" or v.ClassName == "ImageButton" then
				TS:Create(v, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
			elseif v.ClassName == "Frame" then
				TS:Create(v, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			end

			if not v:FindFirstChild("UIListLayout") and v:FindFirstChild("Frame") then
				TS:Create(v, TweenInfo.new(0.5), {Size = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, v.Size.Y.Scale - v.Size.Y.Scale / 4, v.Size.Y.Offset - v.Size.Y.Offset / 4)}):Play()
			else
				TS:Create(v, TweenInfo.new(0.5), {Size = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, v.Size.Y.Scale - v.Size.Y.Scale / 2, v.Size.Y.Offset - v.Size.Y.Offset / 2)}):Play()
			end
		end

		TS:Create(self.MainLabel.TitleHolder.Title, TweenInfo.new(0.250), {TextTransparency = 1}):Play()

		for _, PageTitle in self.MainLabel.Pages:GetDescendants() do
			if PageTitle.ClassName == "TextLabel" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {TextTransparency = 1, TextSize = 0}):Play()
			elseif PageTitle.Name == "Icon" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {ImageTransparency = 1}):Play()
			end
		end

		self.MainLabel.TitleHolder.ZIndex = 4
		TS:Create(self.MainLabel.TitleHolder, TweenInfo.new(0.5), {Size = self.MainLabel.Size}):Play()

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
		self.MainLabel.Glow.Visible = false

		TS:Create(self.MainLabel.TitleHolder, TweenInfo.new(0.5), {Size = UDim2.fromOffset(self.MainLabel.TitleHolder.Size.X.Offset, 428)}):Play()

		task.wait(0.5)

		self.MainLabel.Size = UDim2.fromOffset(self.MainLabel.Size.X.Offset, 428)
		TS:Create(self.MainLabel.TitleHolder, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0.128, 0)}):Play()

		for _,v in self.Instances do

			if v.instance.ClassName == "TextLabel" then
				TS:Create(v.instance, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
			elseif v.instance.ClassName == "TextBox" then
				TS:Create(v.instance, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
			elseif v.instance.ClassName == "ImageLabel" or v.instance.ClassName == "ImageButton" then
				TS:Create(v.instance, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
			elseif v.instance.ClassName == "Frame" then
				TS:Create(v.instance, TweenInfo.new(0.3), {BackgroundTransparency = v.instance.Name == "ToggleBase" and 0.9 or v.instance.Name == "ToggleCircle" and 0.1 or 0}):Play()
			end

			TS:Create(v.instance, TweenInfo.new(0.3), {Size = v.Size}):Play()
		end

		self.MainLabel.ClipsDescendants = true

		task.wait(0.450)

		TS:Create(self.MainLabel.TitleHolder.Title, TweenInfo.new(0.250), {TextTransparency = 0}):Play()

		for _, PageTitle in self.MainLabel.Pages:GetDescendants() do
			if PageTitle.ClassName == "TextLabel" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {TextTransparency = 0}):Play()

				TS:Create(PageTitle, TweenInfo.new(0.1), {TextSize = 18}):Play()
			elseif PageTitle.Name == "Icon" then
				TS:Create(PageTitle, TweenInfo.new(0.250), {ImageTransparency = 0.4}):Play()
			end
		end

		self.MainLabel.Glow.Visible = true

		self.MainLabel.TitleHolder.ZIndex = 1	
		self.MainLabel.TitleHolder.Title.ZIndex = 1

		for _, PageTitle in self.MainLabel.Pages:GetDescendants() do
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
			table.insert(self.Instances, {instance = Arg[idx], Size = Arg[idx + 1]})
		end
	else
		table.insert(self.Instances, {instance = Arg[1], Size = Arg[2]})
	end
end

return BoogaUI
