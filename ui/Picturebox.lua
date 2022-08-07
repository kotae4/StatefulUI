local BaseUIElement = require("ui.BaseUIElement");

Picturebox = Class("Picturebox", BaseUIElement);

function Picturebox:__init(name, parent, anchors, offsets, colors, imgPath, shouldStretch)
-- TO-DO:
-- argument checking (**especially** the colorTbl!)
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.imgPath = imgPath;
  self.img = ResourceCache:getImage(imgPath, "nearest");
  
  self.imgQuad = love.graphics.newQuad(0, 0, self.rect.w, self.rect.h, self.img:getDimensions());
  
  if (shouldStretch) then
    self.scaleX = self.rect.w / self.img:getWidth();
    self.scaleY = self.rect.h / self.img:getHeight();
  else
    self.scaleX = 1;
    self.scaleY = 1;
  end

  self.isInitialized = true;
end

function Picturebox:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a);
  love.graphics.draw(self.img, self.imgQuad, drawingPos.x, drawingPos.y, 0, self.scaleX, self.scaleY);
  
  BaseUIElement.OnDraw(self, drawingPos);
  
  return false, false, false;
end

function Picturebox:OnPointerEnter(mouseX, mouseY)
  BaseUIElement.OnPointerEnter(self, mouseX, mouseY);
  if (self.enabled == false) then return false, false end
  print("Setting " .. self.name .. " to colors.hover");
	self.color = self.colors.hover;
	return true, true;
end

function Picturebox:OnPointerExit(mouseX, mouseY)
  BaseUIElement.OnPointerExit(self, mouseX, mouseY);
  if (self.enabled == false) then return false, false end
  print("Setting " .. self.name .. " to colors.normal");
	self.color = self.colors.normal;
	return true, true;
end

return Picturebox;