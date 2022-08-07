local BaseUIElement = require("ui.BaseUIElement");

Checkbox = Class("Checkbox", BaseUIElement);

-- static field used by all instances
Checkbox.CheckMarkSprite = ResourceCache:getImage("images/checkmark.png", "nearest");

function Checkbox:__init(name, parent, anchors, offsets, colors, text, isChecked)
  
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.captureEvents["OnMousePress"] = true;
  self.captureEvents["OnMouseClick"] = true;
  
  self.text = text;
  self.isChecked = isChecked;
  self.sprite = self.isChecked and Checkbox.CheckMarkSprite or nil;

  self.isInitialized = true;
end

function Checkbox:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  -- the background behind the checkmark
  love.graphics.setColor(self.colors.normal.r, self.colors.normal.g, self.colors.normal.b, self.colors.normal.a);
  love.graphics.rectangle("fill", drawingPos.x, drawingPos.y, 32, 32);
  
  -- the checkmark
  if (self.sprite) then
    love.graphics.setColor(1, 1, 1, self.colors.normal.a);
    love.graphics.draw(self.sprite, drawingPos.x, drawingPos.y);
  end
  
  -- the label next to the checkmark
  love.graphics.setColor(self.colors.text.r, self.colors.text.g, self.colors.text.b, self.colors.text.a);
	love.graphics.print(self.text, drawingPos.x + 33, drawingPos.y + 8);
  
  BaseUIElement.OnDraw(self, drawingPos);
  
  return false,false,false;
end

function Checkbox:OnMousePress(mouseX, mouseY, button, isTouch, presses)
  BaseUIElement.OnMousePress(self, mouseX, mouseY, button, isTouch, presses);
  return true, true, false;
end

function Checkbox:OnMouseClick(mouseX, mouseY)
  print("'" .. self.name .. "' was clicked!");
  if (self.enabled == false) then return false end
  self.isChecked = not self.isChecked;
  self.sprite = self.isChecked and Checkbox.CheckMarkSprite or nil;
  return true, true, true;
end

return Checkbox;