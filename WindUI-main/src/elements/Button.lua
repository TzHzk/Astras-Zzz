local Button = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

function Button.New(Title, Icon, Callback, Variant, Parent, Dialog, FullRounded, Radius)
	Variant = Variant or "Primary"
	local Radius = Radius or (not FullRounded and 10 or 99)
	local IconButtonFrame
	if Icon and Icon ~= "" then
		IconButtonFrame = New("ImageLabel", {
			Image = Creator.Icon(Icon)[1],
			ImageRectSize = Creator.Icon(Icon)[2].ImageRectSize,
			ImageRectOffset = Creator.Icon(Icon)[2].ImageRectPosition,
			Size = UDim2.new(0, 24 - 3, 0, 24 - 3),
			BackgroundTransparency = 1,
			ImageColor3 = Variant == "White" and Color3.new(0, 0, 0) or nil,
			ImageTransparency = Variant == "White" and 0.4 or 0,
			ThemeTag = {
				ImageColor3 = Variant ~= "White" and "Icon" or nil,
			},
		})
	end

	local ButtonFrame = New("TextButton", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = "X",
		Parent = Parent,
		BackgroundTransparency = 1,
	}, {
		Creator.NewRoundFrame(Radius, "Squircle", {
			ThemeTag = {
				ImageColor3 = Variant ~= "White" and "Button" or nil,
			},
			ImageColor3 = Variant == "White" and Color3.new(1, 1, 1) or nil,
			Size = UDim2.new(1, 0, 1, 0),
			Name = "Squircle",
			ImageTransparency = Variant == "Primary" and 0 or Variant == "White" and 0 or 0.9,
		}),

		Creator.NewRoundFrame(Radius, "Squircle", {
			ImageColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(1, 0, 1, 0),
			Name = "Special",
			ImageTransparency = Variant == "Secondary" and 0.95 or 1,
		}),

		Creator.NewRoundFrame(Radius, "Shadow-sm", {
			ImageColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1, 3, 1, 3),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Name = "Shadow",
			ImageTransparency = 1,
			Visible = not FullRounded,
		}),

		-- AQUÍ ESTÁ EL UIStroke AGREGADO
		Creator.NewRoundFrame(Radius, not FullRounded and "Glass-1" or "Glass-0.7", {
			ThemeTag = {
				ImageColor3 = "White",
			},
			Size = UDim2.new(1, 0, 1, 0),
			ImageTransparency = 0.6,
			Name = "Outline",
		}, {
			New("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.5,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			})
		}),

		Creator.NewRoundFrame(Radius, "Squircle", {
			Size = UDim2.new(1, 0, 1, 0),
			Name = "Frame",
			ThemeTag = {
				ImageColor3 = Variant ~= "White" and "Text" or nil,
			},
			ImageColor3 = Variant == "White" and Color3.new(0, 0, 0) or nil,
			ImageTransparency = 1,
		}, {
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			}),
			New("UIListLayout", {
				FillDirection = "Horizontal",
				Padding = UDim.new(0, 8),
				VerticalAlignment = "Center",
				HorizontalAlignment = "Center",
			}),
			IconButtonFrame,
			New("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
				Text = Title or "Button",
				ThemeTag = {
					TextColor3 = (Variant ~= "Primary" and Variant ~= "White") and "Text",
				},
				TextColor3 = Variant == "Primary" and Color3.new(1, 1, 1)
					or Variant == "White" and Color3.new(0, 0, 0)
					or nil,
				AutomaticSize = "XY",
				TextSize = 18,
			}),
		}),
	})

	Creator.AddSignal(ButtonFrame.MouseEnter, function()
		Tween(ButtonFrame.Frame, 0.047, { ImageTransparency = 0.95 }):Play()
	end)
	Creator.AddSignal(ButtonFrame.MouseLeave, function()
		Tween(ButtonFrame.Frame, 0.047, { ImageTransparency = 1 }):Play()
	end)
	Creator.AddSignal(ButtonFrame.MouseButton1Up, function()
		if Dialog then
			Dialog:Close()()
		end
		if Callback then
			Creator.SafeCallback(Callback)
		end
	end)

	return ButtonFrame
end

return Button
