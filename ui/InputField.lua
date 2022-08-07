local BaseUIElement = require("ui.BaseUIElement");
local utf8 = require("utf8");

InputField = Class("InputField", BaseUIElement);

-- TO-DO:
-- put all textalignment logic into the utility class so other text-based elements can reuse it too
local function calculateAlignmentOffset(self)
  if (self.textAlignment ~= "left") then
    local labelWidth = UIManager.DefaultFont:getWidth(self.inputText);
    if (labelWidth > self.rect.w) then
      self.alignmentOffset.x = 0;
    elseif (self.textAlignment == "center") then
      -- get the center of the drawing area (half of the width)
      -- then subtract half the label's width
      self.alignmentOffset.x = ((self.rect.w * 0.5) - (labelWidth * 0.5));
      print("Set " .. self.name .. " alignmentOffset to " .. self.alignmentOffset.x);
    end
  end
end

function InputField:__init(name, parent, anchors, offsets, colors, defaultText, textAlignment)
  
  textAlignment = textAlignment or "left";
  
  BaseUIElement.__init(self, name, parent, anchors, offsets, colors);
  
  self.captureEvents["OnMouseClick"] = true;
  self.captureEvents["OnKeyPressed"] = true;
  self.captureEvents["OnTextInput"] = true;
  self.captureEvents["OnSubmit"] = true;
  
  self.inputText = defaultText or "";
  self.textAlignment = textAlignment;
  self.alignmentOffset = Rectangle(0, 0, 0, 0);
  calculateAlignmentOffset(self);
  
  self.isInitialized = true;
end

function InputField:OnMouseClick(mouseX, mouseY)
  if (self.enabled == false) then return false, false, false end
  print("InputField got keyboard focus");
  self.HasKeyboardFocus = true;
  UIManager.ElementWithKeyboardFocus = self;
  UIManager.ElementWithFocus = self;
  love.keyboard.setKeyRepeat(true);
  return true, true, false;
end

function InputField:OnKeyPressed(key, isRepeat)
  if (self.enabled == false) then return false, false, false end
  if key == "backspace" then
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(self.inputText, -1)
    
    if byteoffset then
      -- remove the last UTF-8 character.
      -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
      self.inputText = string.sub(self.inputText, 1, byteoffset - 1)
    end
    return true, true, true;
  end
  return true, false, false;
end

function InputField:OnTextInput(text)
  if (self.enabled == false) then return false, false, false end
  --print("InputField saw '" .. text .. "'");
  self.inputText = self.inputText .. text;
  return true, true, true;
end

function InputField:OnSubmit()
  print("InputField gave up keyboard focus");
  self.HasKeyboardFocus = false;
  UIManager.ElementWithKeyboardFocus = nil;
  UIManager.ElementWithFocus = nil;
  love.keyboard.setKeyRepeat(false);
  return true, true, false;
end

function InputField:OnDraw(cumulativeDrawingPos)
  
  local drawingPos = Vector(cumulativeDrawingPos.x + self.rect.x, cumulativeDrawingPos.y + self.rect.y);

  love.graphics.setColor(self.colors.background.r, self.colors.background.g, self.colors.background.b, self.colors.background.a);
  love.graphics.rectangle("fill", drawingPos.x, drawingPos.y, self.rect.w, self.rect.h);
  
  love.graphics.setColor(self.colors.text.r, self.colors.text.g, self.colors.text.b, self.colors.text.a);
  local alignedDrawingPos = { x=(drawingPos.x + self.alignmentOffset.x), y=(drawingPos.y + self.alignmentOffset.y) };
	love.graphics.print(self.inputText, alignedDrawingPos.x, alignedDrawingPos.y);
  
  BaseUIElement.OnDraw(self, drawingPos);
  
  return false, false, false;
end

return InputField;