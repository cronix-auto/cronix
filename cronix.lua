-- I HATE CRONIX
local CoreGui = game:GetService('CoreGui')

for _, g in ipairs(CoreGui:GetChildren()) do
    if
        g:IsA('ScreenGui')
        and (g.Name == 'HYDRA_WS_COMPAT' or g.Name == 'HYDRA_ComingSoon')
    then
        g:Destroy()
    end
end

local function inst(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do
        o[k] = v
    end
    if parent then
        o.Parent = parent
    end
    return o
end

local C_CARD = Color3.fromRGB(5, 8, 16)
local C_TEXT = Color3.fromRGB(208, 218, 234)

local Screen = inst('ScreenGui', {
    Name = 'HYDRA_WS_COMPAT',
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 8000,
}, CoreGui)

local Win = inst('Frame', {
    Name = 'HydraWindow',
    BackgroundColor3 = C_CARD,
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(500, 170),
    Position = UDim2.new(0.5, -250, 0.5, -85),
}, Screen)

inst('UICorner', { CornerRadius = UDim.new(0, 12) }, Win)
inst('UIStroke', {
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Thickness = 1,
    LineJoinMode = Enum.LineJoinMode.Round,
    Transparency = 0.55,
    Color = Color3.fromRGB(24, 36, 64),
}, Win)

local Logo = inst('ImageLabel', {
    Name = 'BrandIcon',
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(32, 32),
    Position = UDim2.new(0, 10, 0, 6),
    Image = 'rbxassetid://101729094480674',
    ScaleType = Enum.ScaleType.Fit,
}, Win)

inst('UICorner', { CornerRadius = UDim.new(1, 0) }, Logo)
inst('UIStroke', {
    Thickness = 1,
    Transparency = 0.7,
    Color = Color3.fromRGB(30, 48, 84),
}, Logo)

inst('TextLabel', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 50, 0, 8),
    Size = UDim2.new(1, -214, 0, 24),
    Text = 'HYDRA',
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = C_TEXT,
    TextTransparency = 0.05,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, Win)

inst('TextLabel', {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 8),
    Size = UDim2.fromOffset(460, 60),
    Text = 'Coming soon',
    Font = Enum.Font.GothamBold,
    TextSize = 28,
    TextColor3 = Color3.fromRGB(220, 228, 244),
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
}, Win)
