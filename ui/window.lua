--[[
-- Window is like a panel but provides (optional) decoration (titlebar, 'X' button, etc)
--]]

local BaseUIElement = require("ui.BaseUIElement");

Window = Class("Window", BaseUIElement);

function Window:__init(name, parent, anchors, offsets, colors, hasCloseButton, hasMinimizeButton, isDraggable, isResizable, titleText)

  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);

  self.isDraggable = isDraggable;
  self.isResizable = isResizable;
  self.viewport = UIManager.createRectMask(self.name .. ".Viewport", self, Rectangle(0, 0, 1, 1), Rectangle(0, 20, 0, 0), {normal = {r=1,g=1,b=1,a=0}});
  self.childAnchorOffset.y = 20;
  
  self.numBuiltinChildren = 0;
  if ((hasCloseButton) or (hasMinimizeButton) or ((titleText ~= nil) and (titleText ~= "")) or (isDraggable)) then
    -- add the background for the titlebar, also serves as the part of the window that's draggable
    local titlebarWidth = (hasCloseButton and hasMinimizeButton) and 40 or (hasCloseButton == false and hasMinimizeButton == false) and 0 or 20;
    self.titlebarBG = UIManager.createPanel(name .. ".TitlebarBG", self, Rectangle(0, 0, 1, 0), Rectangle(0, 0, titlebarWidth, 20), false, { normal = colors.titlebar });
    self.numBuiltinChildren = self.numBuiltinChildren + 1;
    if (hasCloseButton) then
      self.closeButton = UIManager.createButton(name .. ".CloseButton", self, Rectangle(1, 0, 1, 0), Rectangle(-20, 0, 20, 20), colors, "X", "center");
      self.numBuiltinChildren = self.numBuiltinChildren + 1;
    end
    if (hasMinimizeButton) then
      self.minimizeButton = UIManager.createButton(name .. ".MinimizeButton", self, Rectangle(1, 0, 1, 0), Rectangle(-40, 0, 20, 20), colors, "-", "center");
      self.numBuiltinChildren = self.numBuiltinChildren + 1;
    end
    if ((titleText ~= nil) and (titleText ~= "")) then
      self.titleText = UIManager.createLabel(name .. ".TitleText", self, Rectangle(0, 0, 1, 0), Rectangle(0, 0, 40, 20), colors, titleText);
      self.numBuiltinChildren = self.numBuiltinChildren + 1;
    end
    if (isDraggable) then
      self.captureEvents["OnPointerMove"] = true;
      self.captureEvents["OnMousePress"] = true;
      self.captureEvents["OnMouseRelease"] = true;
    end
  end

  if (isResizable) then
    self.resizeIcon = UIManager.createPicturebox(name .. ".ResizeIcon", self, Rectangle(1, 1, 1, 1), Rectangle(-20, -20, 20, 20), {normal = colors.resizeNormal, hover = colors.resizeHover}, "images/resize_grip.png", true);
    self.numBuiltinChildren = self.numBuiltinChildren + 1;
  end
  
  self.isInitialized = true;
end

function Window:isLayoutElementVisible(element)
  if ((element.layoutController ~= self) or (self.enabled == false)) then return false end
  
  local elementPos = element:getPosition();
  local viewportContainsElement = self.viewport:containsPoint(elementPos.x, elementPos.y);

  return viewportContainsElement;
end

function Window:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  -- draw background rect
  love.graphics.setColor(self.colors.background.r, self.colors.background.g, self.colors.background.b, self.colors.background.a);
  love.graphics.rectangle("fill", drawingPos.x, drawingPos.y, self.rect.w, self.rect.h);

  -- draw titlebar elements
  if (self.titlebarBG ~= nil) then
    self.titlebarBG:OnDraw(drawingPos);
  end
  if (self.titleText ~= nil) then
    self.titleText:OnDraw(drawingPos);
  end
  if (self.closeButton ~= nil) then
    self.closeButton:OnDraw(drawingPos);
  end
  if (self.minimizeButton ~= nil) then
    self.minimizeButton:OnDraw(drawingPos);
  end

  -- draw children
  if (#self.children > self.numBuiltinChildren) then
    self.viewport:OnDraw(drawingPos);
  end

  -- draw resizeIcon on top of everything else
  if (self.resizeIcon ~= nil) then
    self.resizeIcon:OnDraw(drawingPos);
  end

  return false, false, false;
end

-- begin dragging logic
function Window:OnPointerMove(mouseX, mouseY, deltaX, deltaY)
  if ((self.globalRect.x + deltaX < 0) or (self.globalRect.x + deltaX + self.rect.w > Game.WindowWidth)) then
    deltaX = 0;
  end
  if ((self.globalRect.y + deltaY < 0) or (self.globalRect.y + deltaY + self.rect.h > Game.WindowHeight)) then
    deltaY = 0;
  end
  if (self.isDragging == true) then
    self:setPosition(self.anchors, Rectangle(self.offsets.x + deltaX, self.offsets.y + deltaY, self.offsets.w, self.offsets.h));
  elseif (self.isResizing == true) then
    self:setPosition(self.anchors, Rectangle(self.offsets.x, self.offsets.y, self.offsets.w + deltaX, self.offsets.h + deltaY));
  end
end

function Window:OnMousePress(mouseX, mouseY, button, isTouch, presses)
  print(self.name .. " got mouse press");
  if ((self.isDraggable) and (self.titlebarBG:containsPoint(mouseX, mouseY))) then
    UIManager.ElementWithMouseClick = self;
    self.hasMousePress = true;
    self.isDragging = true;
    print("!! Dragging window !!");
  elseif ((self.isResizable) and (self.resizeIcon:containsPoint(mouseX, mouseY))) then
    UIManager.ElementWithMouseClick = self;
    self.hasMousePress = true;
    self.isResizing = true;
    print("!! Resizing window !!");
  end
end

function Window:OnMouseRelease(mouseX, mouseY, button, isTouch, presses)
  
  UIManager.ElementWithMouseClick = nil;
  self.hasMousePress = false;
  self.isDragging = false;
  self.isResizing = false;
  print("!! Done dragging / resizing window !!");
end
-- end dragging logic

function Window:OnChildAdded(child)
  BaseUIElement.OnChildAdded(self, child);
  
  if (self.isInitialized == false) then
    return false, false, false;
  end
  
  -- reparent child to the content panel
  child:setChildOf(self.viewport);
  
  child:setLayoutController(self);

  return false, false, false;
end

function Window:OnChildRemoved(child)
  BaseUIElement.OnChildRemoved(self, child)
  
  child:setLayoutController(nil);
  
  return false, false, false;
end

return Window;