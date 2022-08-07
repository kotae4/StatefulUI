local BaseUIElement = require("ui.BaseUIElement");

Panel = Class("Panel", BaseUIElement);

function Panel:__init(name, parent, anchors, offsets, skipRectMask, colors)
  
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.hasRectMask = false;
  -- NOTE:
  -- some elements that have a built-in panel child element may want to skip the rect mask since they have their own rect mask already
  -- TO-DO:
  -- re-think this
  if (skipRectMask ~= true) then
    self.viewport = UIManager.createRectMask(self.name .. ".Viewport", self, Rectangle(0, 0, 1, 1), Rectangle(0, 0, 0, 0), {normal = {r=1,g=1,b=1,a=0}});
    self.hasRectMask = true;
  end
  
  self.isCanvasSupported = true;
  
  self.isInitialized = true;
end

function Panel:isLayoutElementVisible(element)
  if ((element.layoutController ~= self) or (self.enabled == false)) then return false end
  
  local elementPos = element:getPosition();
  local viewportContainsElement = self.viewport:containsPoint(elementPos.x, elementPos.y);

  return viewportContainsElement;
end

function Panel:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a);
  love.graphics.rectangle("fill", drawingPos.x, drawingPos.y, self.rect.w, self.rect.h);
  
  if (self.hasRectMask == true) then
    self.viewport:OnDraw(drawingPos);
  else
    BaseUIElement.OnDraw(self, drawingPos);
  end
  
  return false, false, false;
end

function Panel:OnChildAdded(child)
  BaseUIElement.OnChildAdded(self, child);
  
  if ((self.isInitialized == false) or (self.hasRectMask == false)) then
    return false, false, false;
  end
  -- reparent child to the content panel
  child:setChildOf(self.viewport);
  
  child:setLayoutController(self);

  return false, false, false;
end

return Panel;