local BaseUIElement = require("ui.BaseUIElement");

CollapsibleGroup = Class("CollapsibleGroup", BaseUIElement);

local Handlers = {};

function CollapsibleGroup:__init(name, parent, anchors, offsets, colors, headerText)
  
  --EventListenerBase.__init(self);
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.captureEvents["OnMouseClick"] = true;
  
  self.childAnchorOffset.y = 20;
  
  self.viewport = UIManager.createRectMask(self.name .. ".Viewport", self, Rectangle(0, 0, 1, 1), Rectangle(0, 20, 0, 0), {normal = self.colors.normal});
  self.collapseHeader = {};
  self.collapseHeader.button = UIManager.createButton(self.name .. ".CollapseBtn", self, Rectangle(0, 0, 1, 0), Rectangle(20, 0, 0, 20), {normal = {r=1,g=1,b=1,a=0}, hover = {r=1,g=1,b=1,a=0}, pressed = {r=1,g=1,b=1,a=0}, text = {r=1,g=1,b=1,a=1}}, headerText);
  self.collapseHeader.img = ResourceCache:getImage("images/arrow.png", "nearest");
  
  self.isCollapsed = false;
  
  self.collapseHeader.button.OnMouseClick = Handlers.CollapseHeaderButton_OnMouseClick;
  
  self.isInitialized = true;
end

function CollapsibleGroup:setCollapseState(collapsed)
  self.isCollapsed = collapsed;
  -- TO-DO:
  -- propagate v:setEnabled(collapsed) properly
  for index=3,#self.children do
    self.children[index]:setEnabled(not collapsed);
  end
end

function CollapsibleGroup:isLayoutElementVisible(element)
  if ((element.layoutController ~= self) or (self.isCollapsed == true)) then return false end
  
  local elementPos = element:getPosition();
  local viewportContainsElement = self.viewport:containsPoint(elementPos.x, elementPos.y);

  return viewportContainsElement;
end

function CollapsibleGroup:OnDraw(cumulativeDrawingPos)
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  love.graphics.setColor(1, 1, 1, 1);
  love.graphics.draw(self.collapseHeader.img, self.globalRect.x, self.globalRect.y, (self.isCollapsed and 0 or 1.571), 0.5, 0.5, 0, (self.isCollapsed and 0 or self.collapseHeader.img:getHeight()));
  
  self.collapseHeader.button:OnDraw(drawingPos);
  
  if (self.isCollapsed == false) then
    self.viewport:OnDraw(drawingPos);
  end
  
  return true, false;
end

-- handle the header click
function Handlers.CollapseHeaderButton_OnMouseClick(collapseHeader, mouseX, mouseY)
  local cg = collapseHeader.parent;
  cg:setCollapseState(not cg.isCollapsed);
  return true, true;
end
-- end handling header click

function CollapsibleGroup:OnChildAdded(child)
  BaseUIElement.OnChildAdded(self, child)
  
  if (self.isInitialized == false) then
    return false, false, false;
  end
  
  -- reparent child to the viewport
  child:setChildOf(self.viewport);
  
  child:setLayoutController(self);
  
  return false, false;
end

function CollapsibleGroup:OnChildRemoved(child)
  BaseUIElement.OnChildRemoved(self, child)
  
  -- TO-DO:
  -- remove child from viewport? probably not necessary, can't think right now
  
  child:setLayoutController(nil);
  
  return false, false;
end

return CollapsibleGroup;