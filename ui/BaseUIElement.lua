BaseUIElement = Class("BaseUIElement");

-- constructor
function BaseUIElement:__init(name, parent, anchors, offsets, colors)
  
  self.name = name;
  self.children = {};
  self.parent = parent;
  self.anchors = anchors;
  self.offsets = offsets;
  self.rect = Rectangle(0, 0, 0, 0);
  self.globalRect = Rectangle(0, 0, 0, 0);
  self:setPosition(anchors, offsets);
  self.childAnchorOffset = Rectangle(0, 0, 0, 0);
  self.colors = colors;
  self.color = colors.normal;
  self.visible = true;
  self.enabled = true;
  self.isInitialized = false;
  self.isHovered = false;
  self.captureEvents = {};
  -- elements should set this to true if they don't need to be redrawn often
  -- then, those elements should be setting UIManager.IsCanvasDirty to true whenever they do need to be redrawn
  -- alternatively, they can "return nil, nil, true" from any event handler.
  self.isCanvasSupported = false;
  
  if (parent ~= nil) then
    self:setChildOf(parent);
  else
    self.root = nil;
    self.parent = nil;
    self.depth = 0;
    self.layoutController = nil;
    table.insert(UIManager.RootElements, self);
  end
  -- every element starts as a TerminalElement because it cannot start with children.
  table.insert(UIManager.TerminalElements, self);
end

function BaseUIElement:getRoot()
  local root = self;
  while(root.parent ~= nil) do
    root = root.parent;
  end
  return root;
end

function BaseUIElement:setChildOf(parent)
  if (parent == nil) then return end
  
  -- if we are currently a top-level element, then remove ourself from that top-level list before being adopted.
  if (self.root == nil) then
    for k,v in pairs(UIManager.RootElements) do
      if (v == self) then
        table.remove(UIManager.RootElements, k);
        break;
      end
    end
  end
  -- if we were already parented to another element, then remove ourselves from our old parent's children list.
  if (self.parent ~= nil) then
    for k,v in pairs(self.parent.children) do
      if (v == self) then
        table.remove(self.parent.children, k);
        break;
      end
    end
    self.parent.OnChildRemoved(self.parent, self);
  end
  
  self:setLayoutController(parent.layoutController);
  
  table.insert(parent.children, self);
  
  self.depth = parent.depth + 1;
  self.parent = parent;
  self.root = parent:getRoot();
  
  parent.OnChildAdded(parent, self);
end

function BaseUIElement:updateRect()
  -- updates both local and global rect for self and all children recursively
  -- ideally, need to re-design this to where the globalRect can be inferred instead of needing to recalculate it each time
  -- i tried both ways and found this recalculation to be easier but maybe there's an even better design i can't fathom
  local parentRect = nil;
  if (self.parent == nil) then
    parentRect = Rectangle(0, 0, Game.WindowWidth, Game.WindowHeight);
    self.globalRect = Rectangle(parentRect.x, parentRect.y, 0, 0);
  else
    parentRect = self.parent.rect;
    self.globalRect = Rectangle(self.parent.globalRect.x, self.parent.globalRect.y, 0, 0);
  end
  self.rect.x = (parentRect.w * self.anchors.x) + self.offsets.x;
  self.rect.y = (parentRect.h * self.anchors.y) + self.offsets.y;
  if (self.anchors.w == self.anchors.x) then
    self.rect.w = math.abs(self.offsets.w);
  else
    -- this gets the right-most point
    self.rect.w = (parentRect.w * self.anchors.w) - self.offsets.w;
    -- this gets the actual width (right-most point minus left-most point)
    self.rect.w = self.rect.w - self.rect.x;
  end
  if (self.anchors.h == self.anchors.y) then
    self.rect.h = math.abs(self.offsets.h);
  else
    -- this gets the bottom-most point
    self.rect.h = (parentRect.h * self.anchors.h) - self.offsets.h;
    -- this gets the actual height (bottom-most point minus top-most point)
    self.rect.h = self.rect.h - self.rect.y;
  end
  --print(self.name .. ".rect: " .. self.rect:ToString());
  self.globalRect.x = self.globalRect.x + self.rect.x;
  self.globalRect.y = self.globalRect.y + self.rect.y;
  self.globalRect.w = self.rect.w;
  self.globalRect.h = self.rect.h;
  --print(self.name .. ":updateRect().globalRect: " .. self.globalRect:ToString());
  -- NOTE:
  -- recursion might not be a great idea here, can switch to iterative if it's an issue
  for k,v in pairs(self.children) do
    v:updateRect();
  end
end

function BaseUIElement:setOffsetsDirect(newX, newY, newW, newH)
  self.offsets.x, self.offsets.y, self.offsets.w, self.offsets.h = newX or self.offsets.x, newY or self.offsets.y, newW or self.offsets.w, newH or self.offsets.h;
  
  self:updateRect();
end

function BaseUIElement:setPosition(anchors, offsets)
  if (anchors ~= nil) then
    self.anchors = anchors;
  end
  if (offsets ~= nil) then
    self.offsets = offsets;
  end

  self:updateRect();
end

function BaseUIElement:getPosition()
  return self.globalRect;
end

function BaseUIElement:containsPoint(x, y)
  if (self.hasLayoutController == true) then
    if (self.layoutController:isLayoutElementVisible(self) == false) then
      return false;
    end
  end

  local doesContainMouse = false;
	if (x > self.globalRect.x + self.globalRect.w) or (x < self.globalRect.x) or (y > self.globalRect.y + self.globalRect.h) or (y < self.globalRect.y) then
		doesContainMouse = false;
	else
		doesContainMouse = true;
	end
  
  return doesContainMouse;
end

function BaseUIElement:setEnabled(isEnabled)
  self.enabled = isEnabled;
  for k,v in pairs(self.children) do
    v:setEnabled(isEnabled);
  end
end

function BaseUIElement:setVisible(isVisible)
  self.visible = isVisible;
  self.enabled = isVisible;
  for k,v in pairs(self.children) do
    v:setVisible(isVisible);
  end
end

function BaseUIElement:setLayoutController(element)
  self.hasLayoutController = element ~= nil;
  self.layoutController = element;
  self:setPosition(self.anchors, self.offsets);
  for k,v in pairs(self.children) do
    v:setLayoutController(element);
  end
end

function BaseUIElement:OnDraw(cumulativeDrawingPos)
  --- should return tuple of "isConsumed, isTerminal, isCanvasDirty"
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  local isConsumed = false;
  local isTerminal = false;
  local isCanvasDirty = false;
  for k,element in pairs(self.children) do
    isConsumed, isTerminal, isCanvasDirty = element["OnDraw"](element, cumulativeDrawingPos);
    UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
  end
  
  return false, false, false;
end

function BaseUIElement:OnChildRemoved(child)
  -- check if we have any remaining children, and, if we do not, then add ourselves to the TerminalElements list
  if (#self.children == 0) then
    table.insert(UIManager.TerminalElements, self);
  end
  return false, false, false;
end

function BaseUIElement:OnChildAdded(child)
  -- check if we were previously registered as a TerminalElement, and, if so, then remove ourselves from that list
  if (#self.children == 1) then
    for k,v in pairs(UIManager.TerminalElements) do
      if (v == self) then
        table.remove(UIManager.TerminalElements, k);
        break;
      end
    end
  end
  return false, false, false;
end

function BaseUIElement:__PROTECTED__OnMouseMoved(x, y, deltaX, deltaY)
  if (self:containsPoint(x, y)) then
    self:OnPointerMove(x, y, deltaX, deltaY);
    if (self.isHovered ~= true) then
      local isConsumed, discard = self:OnPointerEnter(x, y);
      if (isConsumed) then
        UIManager.DoEventPropagation(UIManager.RootElements, "OnPointerExit", {x, y}, (function(element) return element.children end), (function(element) return (element ~= self) and (element.isHovered == true) and (element.captureEvents["OnPointerExit"] == true) end), 0, true);
      end
    end
  else
    if (self.isHovered == true) then
      self:OnPointerExit(x, y);
    end
    if (self.hasMousePress) then
      self:OnPointerMove(x, y, deltaX, deltaY);
    end
  end
end

function BaseUIElement:OnPointerEnter(mouseX, mouseY)
  print(self.name .. " was entered");
  self.isHovered = true;
  return false, false, false;
end

function BaseUIElement:OnPointerMove(mouseX, mouseY, deltaX, deltaY)
  --print(Class.name(self) .. " is handling OnPointerMove");
  return false, false, false;
end

function BaseUIElement:OnPointerExit(mouseX, mouseY)
  print(self.name .. " was exited");
  self.isHovered = false;
  return false, false, false;
end

function BaseUIElement:OnMousePress(mouseX, mouseY, button, isTouch, presses)
  UIManager.ElementWithMouseClick = self;
  self.hasMousePress = true;
  
  return false, false, false;
end

function BaseUIElement:OnMouseRelease(mouseX, mouseY, button, isTouch, presses)
  UIManager.ElementWithMouseClick = nil;
  self.hasMousePress = false;
  return false, false, false;
end

function BaseUIElement:OnMouseClick(mouseX, mouseY)
  return false, false, false;
end

function BaseUIElement:OnKeyPressed(key, isRepeat)
  return false, false, false;
end

function BaseUIElement:OnKeyReleased(key)
  return false, false, false;
end

function BaseUIElement:OnTextInput(text)
  return false, false, false;
end

function BaseUIElement:OnSubmit()
  return false, false, false;
end

function BaseUIElement:ToString()
  return self.name .. "(" .. Class.name(self) .. ")";
end

return BaseUIElement;