-- Class declarations, per file
local Window;

Game = {};
Game.WindowWidth = 0;
Game.WindowHeight = 0;

local sg = nil;

function love.load(arg, unfilteredArg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  local gfxLimits = love.graphics.getSystemLimits();
  print("Graphics limits:");
  for k,v in pairs(gfxLimits) do
    print("--[" .. tostring(k) .. "]: " .. tostring(v));
  end
  
  Class = require("third-party-code.classy");
  PrintableBase = require("PrintableBase");
  Container = require("third-party-code.container");
  Vector = require("vector");
	Rectangle = require("rectangle");
  ResourceCache = require("ResourceCache");
  utils = require("utils");
  UIManager = require("ui.UIManager");
	Window = require("ui.window");
	
	Game.WindowWidth, Game.WindowHeight = love.graphics.getDimensions();
  print("Game Window Dimensions: (" .. Game.WindowWidth .. ", " .. Game.WindowHeight .. ")");
  
  function addElementsToBase(base)
    local label = UIManager.createLabel("Label1", base, Rectangle(0, 0, 1, 0), Rectangle(0, 0, 0, 20), {text = {r=1,g=1,b=1,a=1}}, "This is a label! This is really really long to test if it overflows or not I honestly don't know it probably shouldn't but I can't remember where I use RectMasks and where I don't");
    local button = UIManager.createButton("Button1", base, Rectangle(0, 0, 1, 0), Rectangle(0, 30, 0, 20), {normal = {r=1,g=0,b=0,a=1}, hover = {r=0,g=1,b=0,a=1}, pressed = {r=0,g=1,b=1,a=1}, text = {r=0,g=0,b=1,a=1}}, "Click me!", "center");
    -- button within button (this is the coolest example tbh, and 100% of my event propagation design went toward this goal lol)
    local buttonTwo = UIManager.createButton("Button2", button, Rectangle(0, 0, 0, 0), Rectangle(5, 5, 50, 10), {normal = {r=0,g=0,b=1,a=1}, hover = {r=0,g=1,b=0,a=1}, pressed = {r=0,g=1,b=1,a=1}, text = {r=1,g=0,b=0,a=1}}, "Click me!", "center");
    local slider = UIManager.createSlider("Slider1", base, Rectangle(0, 0, 1, 0), Rectangle(0, 60, 0, 20), { normal = { r=0.2,g=0.2,b=0.2,a=0.6 }, grip = { r=0.75,g=0.75,b=0.75,a=1 }, gripHighlight = { r=0.5,g=0.5,b=0.5,a=1 }, track = { r=0.1,g=0.1,b=0.1,a=0.8 }, text = {r=1,g=1,b=1,a=1}, hover = {r=0,g=1,b=0,a=1}, pressed = {r=0,g=1,b=1,a=1}, background = {r=1,g=0,b=0,a=1}}, "Slide me!", 0, 100, 20, true);
    local cbox = UIManager.createCheckbox("Checkbox1", base, Rectangle(0, 0, 1, 0), Rectangle(0, 90, 0, 40), {normal = {r=1,g=0,b=0,a=1}, text = {r=1,g=1,b=1,a=1}}, "Checkbox!", false);
    local inputField = UIManager.createInputField("InputField1", base, Rectangle(0, 0, 1, 0), Rectangle(0, 140, 0, 20), {background = {r=1,g=0,b=0,a=1}, text = {r=1,g=1,b=1,a=1}}, "Type here...");
    local dropdown = UIManager.createDropdown(
      "Dropdown1", 
      base,
      Rectangle(0, 0, 1, 0),
      Rectangle(0, 170, 0, 20), 
      { normal = { r=0.2,g=0.2,b=0.2,a=0.6 }, grip = { r=0.75,g=0.75,b=0.75,a=1 }, gripHighlight = { r=0.5,g=0.5,b=0.5,a=1 }, track = { r=0.1,g=0.1,b=0.1,a=0.8 }, text = {r=1,g=1,b=1,a=1}, hover = {r=0,g=1,b=0,a=1}, pressed = {r=0,g=1,b=1,a=1}}, 
      { "Option1", "Option2", "Option3", "Option4", "Option5" }
    );
    local collapseGroup = UIManager.createCollapsibleGroup("CollapsibleGroup1", base, Rectangle(0, 0, 1, 0), Rectangle(0, 200, 0, 400), { normal = { r=1,g=1,b=1,a=0.25 } }, "Collapse Me!");
    local collapseLabel = UIManager.createLabel("Label1", collapseGroup, Rectangle(0, 0, 1, 0), Rectangle(0, 30, 0, 20), {text = {r=1,g=1,b=1,a=1}}, "This is a label inside a collapsible group");
  end

  -- ui
  -- a panel is basically a colored rectangle, it's good for attaching other elements to
  local basePanel = UIManager.createPanel("BasePanel", nil, Rectangle(0.3, 0, 0.7, 0), Rectangle(50, 10, 125, 600), false, { normal={r=0.4,g=0.4,b=0.4,a=0.6} });
  -- add children elements to this panel
  addElementsToBase(basePanel);

  -- a window is a panel but movable and resizable and all that good stuff
  local testWindow = UIManager.createWindow("Window1", nil, Rectangle(0, 0, 0, 0), Rectangle(100, 10, 300, 600), { background={r=0.4,g=0.4,b=0.4,a=0.6}, text = {r=1,g=1,b=1,a=1}, normal = {r=1,g=0,b=0,a=1}, hover = {r=0,g=1,b=0,a=1}, pressed = {r=0,g=1,b=1,a=1}, titlebar = {r=0.4,g=0.4,b=0.4,a=1}, resizeNormal = {r=0.45,g=0.45,b=0.45,a=1}, resizeHover = {r=0.65,g=0.65,b=0.65,a=1} }, true, true, true, true, "Test Window - Hi");
  -- add children elements to this window
  addElementsToBase(testWindow);
  
  -- make another window showcasing the scrollgroup
  local scrollgroupWindow = UIManager.createWindow("Window2", nil, Rectangle(0, 0, 0, 0), Rectangle(800, 20, 200, 300), { background={r=1,g=1,b=1,a=1}, text = {r=1,g=1,b=1,a=1}, normal = {r=1,g=0,b=0,a=1}, hover = {r=0,g=1,b=0,a=1}, pressed = {r=0,g=1,b=1,a=1}, titlebar = {r=0,g=0,b=0,a=1}, resizeNormal = {r=0.85,g=0,b=0,a=1}, resizeHover = {r=1,g=0,b=0,a=1} }, true, false, true, true, "Window - ScrollGroup Showcase");
  local scrollGroup = UIManager.createScrollGroup("ScrollGroup1", scrollgroupWindow, Rectangle(0, 0, 1, 0), Rectangle(0, 0, 0, 300), { normal = { r=1,g=1,b=1,a=0.25 }, grip = { r=0.75,g=0.75,b=0.75,a=1 }, 
        gripHighlight = { r=0.5,g=0.5,b=0.5,a=1 }, track = { r=0.1,g=0.1,b=0.1,a=0.8 } });
    -- add 10 buttons to the scrollgroup
    for i=1,10 do
      UIManager.createButton("SGButton#" .. tostring(i), scrollGroup, Rectangle(0, 0, 1, 0), Rectangle(10, (50 * (i - 1)) + 10, 30, 20), {normal = {r=0,g=0,b=1,a=1}, hover = {r=0,g=1,b=0,a=1}, pressed = {r=0,g=1,b=1,a=1}, text = {r=1,g=0,b=0,a=1}}, (tostring(i) .. " - Click me!"));
    end
  
end

function love.resize(w, h)
	Game.WindowWidth = w;
	Game.WindowHeight = h;
end

function love.keypressed(key, scanCode, isRepeat)
  if (UIManager.KeyPressed(scanCode, isRepeat) == false) then
    -- process game input here
  end
end

function love.keyreleased(key, scanCode)
  if (UIManager.KeyReleased(scanCode) == false) then
    -- process game input here
  end
end

function love.textinput(text)
  -- text is already utf-8 encoded. use utf8 lib to help process it (if necessary)
  UIManager.TextInput(text);
end

function love.mousemoved(x, y, deltaX, deltaY, isTouch)
  UIManager.MouseMoved(x, y, deltaX, deltaY);
end

function love.mousepressed(x, y, button, isTouch, presses)
  UIManager.MousePressed(x, y, button, isTouch, presses);
end

function love.mousereleased(x, y, button, isTouch, presses)
  UIManager.MouseReleased(x, y, button, isTouch, presses);
end

function love.wheelmoved(deltaX, deltaY)
  --[[
  if deltaY > 0 then
    -- wheel moved up
    sg:performScrollStep(false);
  elseif deltaY < 0 then
    -- wheel moved down
    sg:performScrollStep(true);
  end
  --]]
end

function love.draw()
  love.graphics.setBackgroundColor(love.math.colorFromBytes(0, 137, 187));
	love.graphics.setColor(1, 1, 1, 1);
	
  UIManager.draw();
  
  --[[ debug
  local mouseX, mouseY = love.mouse.getPosition();
	love.graphics.setColor(1, 0, 1, 1);
  love.graphics.print("MousePos: (" .. mouseX .. "," .. mouseY .. ")", 0, 45);
  --]]

end