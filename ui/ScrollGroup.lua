--[[
-- so the basic concept of a scrollgroup (or just a scrolling UI in general):
-- 1. there exists the 'content', this can be infinite in size horizontally or vertically
-- 2. there is the 'viewport', this is what you'll actually see, it's like a camera looking into the content
-- 3. there is the 'scrollbar', one vertical and one horizontal, which are made up of the scroll track and scroll thumb (aka "grip")
-- the part that throws people off (myself included) is how you draw only the portion of content that's visible from the viewport
-- and how to move that content up and down as you scroll
-- but it's actually as simple as it could be
-- in love specifically, there are so many ways to draw only a portion of an image (defining and drawing a quad, setting a scissor before drawing, OR setting a stencil)
-- and they should all have roughly the same performance (stencil is probably slightly faster), so just pick what's comfortable
-- so the viewport can just be a quad (or a rect if we're going the scissor route), and drawing is simple
-- scrolling then, just adjusts the x or y position of the content rectangle. since the content is "behind" the viewport, we can adjust its position freely
-- then each element is parented to the content and thus gets its position based on its parent's position.
-- reference: https://gamedev.stackexchange.com/questions/86591/how-to-make-a-scrollbar (yes it really is that simple)
--]]
-- revisit:
-- so i don't think ScrollGroup should use a canvas at all, i think draws should be made directly.
-- 1. the content is technically infinite so it could exceed the maximum supported dimensions
-- 2. the nature of scrolling means the canvas could very well be dirtied every frame, forcing us to redraw the canvas anyway

local BaseUIElement = require("ui.BaseUIElement");

ScrollGroup = Class("ScrollGroup", BaseUIElement);

local Handlers = {};

function ScrollGroup:__init(name, parent, anchors, offsets, colors)

  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.captureEvents["OnMousePress"] = true;
  self.captureEvents["OnKeyReleased"] = true;
  
  self.gripColor = self.colors.grip;
  
  -- viewport is the window through which we see the infinite content
  self.viewport = UIManager.createRectMask(self.name .. ".Viewport", self, Rectangle(0, 0, 1, 1), Rectangle(0, 0, 20, 20), {normal = {r=1,g=1,b=1,a=0}});
  -- content is the container for every child we add to the scrollgroup
  self.content = UIManager.createPanel(self.name .. ".Viewport.Content", self.viewport, Rectangle(0, 0, 0, 0), Rectangle(0, 0, 0, 0), true, {normal = self.colors.normal});
  
  self.verticalScrollBar = {};
  self.verticalScrollBar.track = UIManager.createPanel(self.name .. ".VerticalScrollBarTrack", self, Rectangle(1, 0, 1, 1), Rectangle(-20, 0, 20, 20), false, {normal = self.colors.track});
  self.verticalScrollBar.button = UIManager.createButton(self.name .. ".VerticalScrollBarButton", self, Rectangle(1, 0, 1, 0), Rectangle(-20, 0, 20, 10), {normal = self.colors.grip, hover = self.colors.gripHighlight, pressed = self.colors.gripHighlight}, nil);
  
  -- re-route the scrollbar button's events to our own handlers.
  self.verticalScrollBar.button.OnPointerMove = Handlers.VerticalScrollBarButton_OnPointerMove;
  self.verticalScrollBar.button.OnPointerExit = Handlers.VerticalScrollBarButton_OnPointerExit
  self.verticalScrollBar.button.OnMousePress = Handlers.VerticalScrollBarButton_OnMousePress;
  self.verticalScrollBar.button.OnMouseRelease = Handlers.VerticalScrollBarButton_OnMouseRelease;

  self.isInitialized = true;
end

-- this should be called when scrolling the mousewheel or using the pageup/pagedown buttons
function ScrollGroup:performScrollStep(isSteppingDown)
  self.verticalScrollBar.button:setOffsetsDirect(nil, self.verticalScrollBar.button.offsets.y + (isSteppingDown and 10 or -10), nil, nil);
  
  self:recalculateScrollPosition();
end

function ScrollGroup:recalculateScrollPosition()
  if (self.verticalScrollBar.button.offsets.y < 0) then
    --print("Clamping scrollGrip to 0");
    self.verticalScrollBar.button:setOffsetsDirect(nil, 0, nil, nil);
  elseif (self.verticalScrollBar.button.offsets.y > self.verticalScrollBar.track.rect.h - self.verticalScrollBar.button.rect.h) then
    --print("Clamping scrollGrip to " .. self.verticalScrollBar.track.rect.h - self.verticalScrollBar.button.rect.h);
    self.verticalScrollBar.button:setOffsetsDirect(nil, self.verticalScrollBar.track.rect.h - self.verticalScrollBar.button.rect.h, nil, nil);
  end
  
  local verticalPos = -(self.verticalScrollBar.button.offsets.y / self.verticalScrollBar.track.rect.h) * self.content.rect.h;
  self.content:setOffsetsDirect(nil, -(self.verticalScrollBar.button.offsets.y / self.verticalScrollBar.track.rect.h) * self.content.rect.h, nil, nil);
end

function ScrollGroup:isLayoutElementVisible(element)
  if ((element.layoutController ~= self) or (self.visible == false) or (self.enabled == false)) then return false end
  
  local elementPos = element:getPosition();
  local viewportContainsElement = self.viewport:containsPoint(elementPos.x, elementPos.y);
  
  return viewportContainsElement;
end

function ScrollGroup:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  
  -- draw the scrollbar's track (the background part)
  self.verticalScrollBar.track:OnDraw(drawingPos);
  -- draw the scrollbar button (the grip part)
  self.verticalScrollBar.button:OnDraw(drawingPos);
  
  -- draw the viewport (all the child elements)
  self.viewport:OnDraw(drawingPos);

  return false, true, false;
end

-- handle moving the trackbar's "grip" button
function Handlers.VerticalScrollBarButton_OnPointerMove(verticalScrollBar, mouseX, mouseY, deltaX, deltaY)
  print("VerticalScrollBarButton_OnPointerMove");
  local sg = verticalScrollBar.parent;
  -- the idea here is to get the Y-position of the mouse relative to the scrollgroup's rect
  -- we then set the (vertical)scrollbar to that y-position
  local mouseTransPosY = mouseY - sg.globalRect.y;
  if (sg.gripGrabbed == true) then
    if (verticalScrollBar.rect.h < 0) then
      print("ERROR");
    end
    verticalScrollBar:setOffsetsDirect(nil, mouseTransPosY, nil, nil);
    sg:recalculateScrollPosition();
  else
    --print("Setting grip color to highlight");
    verticalScrollBar.color = sg.colors.gripHighlight;
  end
  return false, false, false;
end

function Handlers.VerticalScrollBarButton_OnPointerExit(verticalScrollBar, mouseX, mouseY)
  local sg = verticalScrollBar.parent;
  if (sg.gripGrabbed ~= true) then
    --print("Setting grip color back to normal");
    verticalScrollBar.color = sg.colors.grip;
  end
  return false, false, false;
end

function Handlers.VerticalScrollBarButton_OnMousePress(verticalScrollBar, mouseX, mouseY, button, isTouch, presses)
  local sg = verticalScrollBar.parent;
  BaseUIElement.OnMousePress(verticalScrollBar, mouseX, mouseY, button, isTouch, presses);
  sg.gripGrabbed = true;
  print("ScrollGroup is consuming mouse press");
  return true, true, false;
end

function Handlers.VerticalScrollBarButton_OnMouseRelease(verticalScrollBar, mouseX, mouseY, button, isTouch, presses)
  local sg = verticalScrollBar.parent;
  BaseUIElement.OnMouseRelease(verticalScrollBar, mouseX, mouseY, button, isTouch, presses);
  sg.gripGrabbed = false;
  print("ScrollGroup let go of grip (OnMouseRelease)");
  return false, false, false;
end
-- end handle moving the trackbar's "grip" button

-- handle content
function ScrollGroup:OnMousePress(mouseX, mouseY, button, isTouch, presses)
  -- if we click anywhere that isn't a child or the scrollbar, then we should be releasing our grip on the scrollbar.
  -- we don't need to check for bounds because the only way ScrollGroup will get this event is if no other element is above the click.
  if (self.gripGrabbed) then
    self.gripGrabbed = false;
  end
end

function ScrollGroup:OnChildAdded(child)
  BaseUIElement.OnChildAdded(self, child)
  
  if (self.isInitialized == false) then
    return false, false, false;
  end
  
  local contentWidth, contentHeight = self.content.rect.w, self.content.rect.h;
  if ((child.rect.x + child.rect.w) > contentWidth) then
    contentWidth = (child.rect.x + child.rect.w);
  end
  if ((child.rect.y + child.rect.h) > contentHeight) then
    contentHeight = (child.rect.y + child.rect.h);
  end
  
  print(self.name .. " saw new child w/ rect " .. child.rect:ToString() .. ", expanding contentRect to (" .. contentWidth.. ", " .. contentHeight .. ")");
  self.content:setOffsetsDirect(nil, nil, contentWidth, contentHeight);
  
  self.verticalScrollBar.button:setOffsetsDirect(nil, nil, nil, self.viewport.rect.h / contentHeight * self.verticalScrollBar.track.rect.h);
  if (self.verticalScrollBar.button.rect.h > self.verticalScrollBar.track.rect.h) then
    self.verticalScrollBar.button:setOffsetsDirect(nil, nil, nil, self.verticalScrollBar.track.rect.h);
  end
  print("\tSet verticalScrollBar.h to (" .. self.verticalScrollBar.button.rect.h .. ")");
  
  -- reparent child to the content panel
  child:setChildOf(self.content);
  
  child:setLayoutController(self);
  return false, false, false;
end

function ScrollGroup:OnChildRemoved(child)
  BaseUIElement.OnChildRemoved(self, child)
  
  -- TO-DO:
  -- resize content / scrollbar too
  
  child:setLayoutController(nil);
  
  return false, false, false;
end

function ScrollGroup:OnKeyReleased(key)
  if (key == "pageup") then
      self:performScrollStep(false);
      return true, true, false;
  elseif (key == "pagedown") then
    self:performScrollStep(true);
    return true, true, false;
  else
    return false, false, false;
  end
end

return ScrollGroup;