local BaseUIElement = require("ui.BaseUIElement");

Button = Class("Button", BaseUIElement);

function Button:__init(name, parent, anchors, offsets, colors, label, textAlignment)
-- TO-DO:
-- argument checking (**especially** the colorTbl!)
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.captureEvents["OnPointerEnter"] = true;
  self.captureEvents["OnPointerExit"] = true;
  self.captureEvents["OnMousePress"] = true;
  self.captureEvents["OnMouseRelease"] = true;
  self.captureEvents["OnMouseClick"] = true;
  
  if ((label ~= nil) and (label ~= "")) then
    self.label = UIManager.createLabel(name .. ".Label", self, Rectangle(0, 0, 1, 1), Rectangle(0, 0, 0, 0), colors, label, textAlignment);
  end
  
  self.isInitialized = true;
end

function Button:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a);
  love.graphics.rectangle("fill", drawingPos.x, drawingPos.y, self.rect.w, self.rect.h);
  
  BaseUIElement.OnDraw(self, drawingPos);
  
  return false, false, false;
end

function Button:OnPointerEnter(mouseX, mouseY)
  BaseUIElement.OnPointerEnter(self, mouseX, mouseY);
  if (self.enabled == false) then return false, false, false end
  --print("Button is hovered (func: " .. tostring(Events.OnPointerEnter) .. ")");
	self.color = self.colors.hover;
	return true, true;
end

function Button:OnPointerExit(mouseX, mouseY)
  BaseUIElement.OnPointerExit(self, mouseX, mouseY);
  if (self.enabled == false) then return false, false, false end
  --print("Button is NOT hovered (func: " .. tostring(Events.OnPointerExit) .. ")");
	self.color = self.colors.normal;
	return true, true;
end

function Button:OnMousePress(mouseX, mouseY, button, isTouch, presses)
  if (self.enabled == false) then 
    return false, false, false;
  end
  UIManager.ElementWithMouseClick = self;
  self.hasMousePress = true;
  print(Class.name(self) .. " is pressed [enabled: " .. tostring(self.enabled) .. "] (func: " .. tostring(self.OnMousePress) .. ")");
  self.color = self.colors.pressed;
  return true, true, true;
end

function Button:OnMouseRelease(mouseX, mouseY, button, isTouch, presses)
  if (self.enabled == false) then return false, false, false end
  UIManager.ElementWithMouseClick = nil;
  self.hasMousePress = false;
  print(Class.name(self) .. " is released (func: " .. tostring(self.OnMouseRelease) .. ")");
  if (self.isHovered) then
    self.color = self.colors.hover;
  else
    self.color = self.colors.normal;
  end
  return true, true, true;
end

function Button:OnMouseClick(mouseX, mouseY)
  if (self.enabled == false) then return false, false, false end
  print("Mouse clicked");
  --print("Button was clicked! (func: " .. tostring(Button.Events.OnMouseClick) .. ")");
  return true, true, false;
end

return Button;