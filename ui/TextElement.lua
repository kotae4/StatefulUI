local BaseUIElement = require("ui.BaseUIElement");

TextElement = Class("TextElement", BaseUIElement);

local function calculateAlignmentOffset(self)
  if (self.textAlignment ~= "left") then
    local labelWidth = UIManager.DefaultFont:getWidth(self.text);
    if (labelWidth > self.rect.w) then
      self.alignmentOffset.x = 0;
    elseif (self.textAlignment == "center") then
      -- get the center of the drawing area (half of the width)
      -- then subtract half the label's width
      print("Set alignment offset to " .. self.alignmentOffset.x);
      self.alignmentOffset.x = ((self.rect.w * 0.5) - (labelWidth * 0.5));
    end
  end
end

function TextElement:__init(name, parent, anchors, offsets, colors, text, textAlignment)
  
  textAlignment = textAlignment or "left";
  
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.text = text;
  self.textAlignment = textAlignment;
  self.alignmentOffset = Rectangle(0, 0, 0, 0);
  calculateAlignmentOffset(self);
  
  self.isInitialized = true;
end

function TextElement:setText(newText)
  self.text = newText;
  
  -- calculate new alignment offset based on width
  calculateAlignmentOffset(self);
  
  -- TO-DO:
  -- marking the window as dirty is a really bad idea because Text might frequently update if it's tied to some data (for example, if you're displaying the FPS in a TextElement)
  -- this could cause every single element associated with the Window to be redrawn every single frame, which totally defeats the optimization of using a canvas.
  -- i need to think of some better way of drawing frequently-changed elements like text...
  UIManager.IsCanvasDirty = true;
end

function TextElement:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);
  local alignedDrawingPos = { x=(drawingPos.x + self.alignmentOffset.x), y=(drawingPos.y + self.alignmentOffset.y) };

  love.graphics.setColor(self.colors.text.r, self.colors.text.g, self.colors.text.b, self.colors.text.a);
  love.graphics.print(self.text, alignedDrawingPos.x, alignedDrawingPos.y);
  
  BaseUIElement.OnDraw(self, drawingPos);
  
  return false, false, false;
end

return TextElement;