local BaseUIElement = require("ui.BaseUIElement");

Slider = Class("Slider", BaseUIElement);

local Handlers = {};

function Slider:__init(name, parent, anchors, offsets, colors, label, minValue, maxValue, startValue, includeInputField)

  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  if (startValue > maxValue) then
    startValue = maxValue;
  elseif (startValue < minValue) then
    startValue = minValue;
  end
  
  self.label = label;
  self.minValue = minValue;
  self.maxValue = maxValue;
  self.value = startValue;
  self.hasInputField = includeInputField;
  
  self.sliderWidth = self.rect.w;
  -- track rect is the background of the slider, it should be half height and centered vertically
  local halfHeight = self.rect.h * 0.5;
  local quarterHeight = halfHeight * 0.5;
  self.trackRect = Rectangle(0, halfHeight - quarterHeight, self.sliderWidth, halfHeight);
  -- NOTE: we use 50 as the hardcoded size of the inputfield (if included), and 5 for padding
  -- TO-DO: don't hardcode important values
  if (includeInputField) then
    self.inputField = UIManager.createInputField(name .. ".InputField", self, Rectangle(1, 0, 1, 1), Rectangle(-45, 0, 40, 0), colors, tostring(startValue), "center");
    self.inputField.OnSubmit = Handlers.InputField_OnSubmit;
  end
  if ((label ~= nil) and (label ~= "")) then
    local labelWidth = UIManager.DefaultFont:getWidth(label);
    self.textElement = UIManager.createLabel(name .. ".TextElement", self, Rectangle(0, 0, 0, 1), Rectangle(0, 0, labelWidth, 0), colors, label)
    self.trackRect.x = labelWidth + 5;
    print("Slider.labelWidth: " .. tostring(labelWidth));
    if (includeInputField) then
      self.trackRect.w = self.rect.w - labelWidth - 60;
    elseif (includeInputField == false) then
      self.trackRect.w = self.rect.w - labelWidth - 10;
    end
  elseif (includeInputField) then
    self.trackRect.w = self.rect.w - 55;
  else
    -- shouldn't need to do this according to flow, but thorough is my middl
    self.trackRect.w = self.rect.w;
  end
  -- gripButton is the part that moves along the track
  self.gripButton = UIManager.createButton(name .. ".GripButton", self, Rectangle(0, 0, 0, 1), Rectangle(self.trackRect.x, 0, 15, 0), colors, nil);
  self.gripButton.color = colors.grip;
  -- re-route the grip button's events to our own handlers.
  self.gripButton.OnPointerMove = Handlers.GripButton_OnPointerMove;
  self.gripButton.OnPointerExit = Handlers.GripButton_OnPointerExit
  self.gripButton.OnMousePress = Handlers.GripButton_OnMousePress;
  self.gripButton.OnMouseRelease = Handlers.GripButton_OnMouseRelease;
  self:setValue(startValue);

  self.isInitialized = true;
end

function Slider:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  local numChildren = 1;
  if (self.textElement ~= nil) then
    self.textElement:OnDraw(drawingPos);
    numChildren = numChildren + 1;
  end
  if (self.inputField ~= nil) then
    self.inputField:OnDraw(drawingPos);
    numChildren = numChildren + 1;
  end

  -- drawing the track background
  love.graphics.rectangle("fill", self.globalRect.x + self.trackRect.x, self.globalRect.y + self.trackRect.y, self.trackRect.w, self.trackRect.h);
  
  love.graphics.setColor(1, 1, 1, 1);
  self.gripButton:OnDraw(drawingPos);
  
  for index = numChildren+1,#self.children do
    self.children[index]:OnDraw(drawingPos);
  end

end

function Slider:setValue(newValue)
  if (newValue < self.minValue) then
    newValue = self.minValue;
  elseif (newValue > self.maxValue) then
    newValue = self.maxValue;
  end
  
  self.value = newValue;
  if (self.hasInputField == true) then
    self.inputField.inputText = tostring(self.value);
  end
  
  local valueRange = self.maxValue - self.minValue;
  local sliderValue = (newValue - self.minValue) / valueRange;
  local sliderPos = (sliderValue * (self.trackRect.w - self.gripButton.rect.w)) + self.trackRect.x;
  self.gripButton:setOffsetsDirect(sliderPos, nil, nil, nil);
  
end

function Slider:recalculateSlidePosition()
  if (self.gripButton.rect.x < self.trackRect.x) then
    --print("Clamping scrollGrip to 0");
    self.gripButton:setOffsetsDirect(self.trackRect.x, nil, nil, nil);
  elseif (self.gripButton.rect.x > self.trackRect.x + self.trackRect.w - self.gripButton.rect.w) then
    --print("Clamping scrollGrip to " .. self.trackRect.x + self.trackRect.w - self.gripButton.rect.w);
    self.gripButton:setOffsetsDirect(self.trackRect.x + self.trackRect.w - self.gripButton.rect.w, nil, nil, nil);
  end
  
  local sliderPos = ((self.gripButton.rect.x - self.trackRect.x) / (self.trackRect.w - self.gripButton.rect.w));
  local valueRange = self.maxValue - self.minValue;
  local sliderValue = self.minValue + (valueRange * sliderPos);
  print("Setting value to " .. sliderValue .. " (was " .. self.value .. ")");
  self.value = math.floor(self.minValue + (valueRange * sliderPos));
  if (self.hasInputField == true) then
    self.inputField.inputText = tostring(self.value);
  end
end

-- handle the inputfield's submit
function Handlers.InputField_OnSubmit(inputField)
  local retValues = utils:pack(BaseUIElement.OnSubmit(inputField));
  local slider = inputField.parent;
  if ((inputField.inputText ~= nil) and (inputField.inputText ~= "")) then
    slider:setValue(tonumber(inputField.inputText));
  else
    slider:setValue(slider.minValue);
  end
  return unpack(retValues);
end
-- handle moving the grip button
function Handlers.GripButton_OnPointerMove(gripButton, mouseX, mouseY, deltaX, deltaY)
  local slider = gripButton.parent;
  local mouseTransPosX = mouseX - slider.globalRect.x;
  if (slider.gripGrabbed == true) then
    gripButton:setOffsetsDirect(mouseTransPosX, nil, nil, nil);
    slider:recalculateSlidePosition();
  else
    --print("Setting grip color to highlight");
    gripButton.color = slider.colors.gripHighlight;
  end
  return false, false, false;
end

function Handlers.GripButton_OnPointerExit(gripButton, mouseX, mouseY)
  local slider = gripButton.parent;
  if (slider.gripGrabbed ~= true) then
    --print("Setting grip color back to normal");
    gripButton.color = slider.colors.grip;
  end
  return false, false, false;
end

function Handlers.GripButton_OnMousePress(gripButton, mouseX, mouseY, button, isTouch, presses)
  local slider = gripButton.parent;
  BaseUIElement.OnMousePress(gripButton, mouseX, mouseY, button, isTouch, presses);
  slider.gripGrabbed = true;
  print("Slider is consuming mouse press");
  return true, true, false;
end

function Handlers.GripButton_OnMouseRelease(gripButton, mouseX, mouseY, button, isTouch, presses)
  local slider = gripButton.parent;
  BaseUIElement.OnMouseRelease(gripButton, mouseX, mouseY, button, isTouch, presses);
  slider.gripGrabbed = false;
  print("Slider let go of grip (OnMouseRelease)");
  return false, false, false;
end
-- end handle moving the grip button

return Slider;