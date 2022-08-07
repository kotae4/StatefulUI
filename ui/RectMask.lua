local BaseUIElement = require("ui.BaseUIElement");

RectMask = Class("RectMask", BaseUIElement);

function RectMask:__init(name, parent, anchors, offsets, colors)
  
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.isCanvasSupported = true;
  
  self.isInitialized = true;
end

function RectMask:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  love.graphics.intersectScissor(self.globalRect.x, self.globalRect.y, self.globalRect.w, self.globalRect.h);
  --love.graphics.setScissor(self.globalRect.x, self.globalRect.y, self.globalRect.w, self.globalRect.h);
  
  -- TO-DO:
  -- why am i coloring and drawing a rectmask?? just use a panel??
  -- pretty sure this was just for debugging. but i'm keeping it, whatever.
  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a);
  love.graphics.rectangle("fill", drawingPos.x, drawingPos.y, self.rect.w, self.rect.h);
  
  BaseUIElement.OnDraw(self, drawingPos);
  
  -- TO-DO:
  -- now that intersectScissor is being used, should we still clear the scissor here?
  love.graphics.setScissor();
  
  return false, false, false;
end

return RectMask;