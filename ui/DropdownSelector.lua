local BaseUIElement = require("ui.BaseUIElement");

DropdownSelector = Class("DropdownSelector", BaseUIElement);

local Handlers = {};

--[[
-- for the dropdown, the rect we pass in is the rect for the main button / label part (the part you click to bring up all the selections)
-- the size of the expanded drop down is constant, with a scrollgroup built in for elements that exceed the dimensions
--]]
function DropdownSelector:__init(name, parent, anchors, offsets, colors, options)
-- TO-DO:
-- argument checking (**especially** the colorTbl!)
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.captureEvents["OnSubmit"] = true;
  
  -- === TO-DO ===
  -- 1. draw a cool little arrow thingie at the right side of the button so the user knows it's a dropdown
  -- 2. fix the option buttons remaining highlighted once the dropdown is closed and re-opened
  -- 3. center the label text
  -- 4. make the expanded drop down more opaque and to consume **all** events so they aren't propagated to the elements beneath
  
  self.options = {};
  self.selectedOption = options[1];

  -- we initialize early because we actually want the built-in elements to be children (simplifies event handling)
  self.isInitialized = true;

  self.mainButton = UIManager.createButton(self.name .. ".MainButton", self, Rectangle(0, 0, 1, 1), Rectangle(0, 0, 0, 0), colors, options[1]);
  self.dropDownSG = UIManager.createScrollGroup(self.name .. ".DropdownSG", self, Rectangle(0, 0, 1, 0), Rectangle(0, 25, 0, 150), colors);
  
  for i=1, #options do
    self.options[i] = {};
    self.options[i].text = options[i];
    self.options[i].button = UIManager.createButton(self.name .. ".Option" .. tostring(i) .. "Button", self.dropDownSG, Rectangle(0, 0, 1, 0), Rectangle(0, ((i - 1) * 30), 20, 30), colors, options[i])
    self.options[i].button.OnMouseClick = Handlers.OptionButton_OnMouseClick;
  end
  
  self.dropDownSG:setVisible(false);
  self.isSelecting = false;
  
  self.mainButton.OnMouseClick = Handlers.MainButton_OnMouseClick;

  
end

function DropdownSelector:selectOption(option)
  print("Dropdown is selecting option '" .. option .. "'");
  for k,v in pairs(self.options) do
    if (v.text == option) then
      self.mainButton.label:setText(v.text);
      self.selectedOption = v.text;
      return;
    end
  end
end

function DropdownSelector:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  self.mainButton:OnDraw(drawingPos);
  if (self.isSelecting == true) then
    self.dropDownSG:OnDraw(drawingPos);
  end
  
  for index = 3,#self.children do
    self.children[index]:OnDraw(drawingPos);
  end
  
  return false, true, false;
end

function Handlers.OptionButton_OnMouseClick(optionButton, x, y)
  print("Clicked option button");
  BaseUIElement.OnMouseClick(optionButton, x, y);
  optionButton.parent.parent.parent.parent:selectOption(optionButton.label.text);
  
  return true, true, true;
end

function Handlers.MainButton_OnMouseClick(mainButton, x, y)
  BaseUIElement.OnMouseClick(mainButton, x, y);
  mainButton.parent.isSelecting = true;
  mainButton.parent.dropDownSG:setVisible(true);
  UIManager.ElementWithFocus = mainButton.parent;
  
  return true, true, true;
end

function DropdownSelector:OnSubmit()
  self.isSelecting = false;
  self.dropDownSG:setVisible(false);
  
end

return DropdownSelector;