local RectMask = require("ui.RectMask");
local Panel = require("ui.panel");
local Button = require("ui.button");
local TextElement = require("ui.TextElement");
local Checkbox = require("ui.Checkbox");
local InputField = require("ui.InputField");
local ScrollGroup = require("ui.ScrollGroup");
local CollapsibleGroup = require("ui.CollapsibleGroup");
local DropdownSelector = require("ui.DropdownSelector");
local Slider = require("ui.Slider");
local Picturebox = require("ui.Picturebox");
local Window = require("ui.window");

-- necessary controls for a UI system:
-- [x] window (parent for all other elements - can be a generic panel or decorated w/ titlebar, close button, and/or minimize button)
-- [x] button
-- [x] label
-- [x] inputfield
-- [x] checkbox
-- [x] dropdown [requires scrollview]
-- [] enum dropdown [requires scrollview]
-- [x] slider
-- [x] picturebox
-- [x] collapsiblegroup (add elements to it like a window, but with the benefit of being able to collapse the entire group at once)
-- [x] scrollview (fit infinite amount of content, scrolls vertical/horizontal)
-- [-] layoutgroup (horizontal and vertical [and grid?], add elements to it and it automatically positions them for you)
-- [] tooltip support for every relevant element
-- [x] draggable support for windows
-- [x] resizable support for windows (note: must position elements according to anchors (min and max anchors - delta between them))
--    * root elements should have anchors too - the game window itself is what it'd be anchored to.
--    * the min anchor determines where 0 "starts" for the element in relation to its parent
--    * for example, if anchorMinX is 0.2, then 0 for that element starts at parent.x + (parent.w * 0.2)
--    * following the above, if that element then has a position of 15, that would be 15 pixels (absolute) to the right of parent.x + (parent.w * 0.2).
--    * so the full formula would be: self.x = parent.x + (parent.w * self.anchorMinX) + self.offsetX
--    * the hard part now is figuring out how to do things like scrollgroup / collapsiblegroup that require positioning children at a fixed offset
--    * i think we could just have a dummy object that's positioned at the offset, and then parent the children to the dummy object rather than the scrollgroup itself
--    * revisit: so it's not quite the formula above. anchorMin basically defines the left side and top side, and anchorMax defines the right side and bottom side
--    * and then you draw from the left side to the right side, and the top side to the bottom side.
--    * in the case where min and max are equal, the rect is the standard (x, y, w, h).
--    * in the case where max is greater than min (literally every other case), the rect is better represented by (leftOffset, topOffset, rightOffset, bottomOffset).
--    * oh okay, so i guess the formula above does work.

UIManager = {};
UIManager.RootCanvas = {};
UIManager.IsCanvasDirty = true;
UIManager.RootElements = {};
UIManager.TerminalElements = {};
UIManager.ElementWithFocus = nil;
UIManager.ElementWithKeyboardFocus = nil;
UIManager.ElementWithMouseClick = nil;

UIManager.DefaultFont = love.graphics.getFont();

function UIManager.createPanel(name, parent, anchors, offsets, skipRectMask, colors)
  
  local newPanel = Panel(name, parent, anchors, offsets, skipRectMask, colors);
  
  return newPanel;
end

function UIManager.createButton(name, parent, anchors, offsets, colors, label, textAlignment)
  
	local newBtn = Button(name, parent, anchors, offsets, colors, label, textAlignment);
  
  return newBtn;
end

function UIManager.createLabel(name, parent, anchors, offsets, colors, text, textAlignment)
  
	local newTextElement = TextElement(name, parent, anchors, offsets, colors, text, textAlignment);
  
  return newTextElement;
end

function UIManager.createCheckbox(name, parent, anchors, offsets, colors, text, isChecked)
  
  local newCheckbox = Checkbox(name, parent, anchors, offsets, colors, text, isChecked);
  
  return newCheckbox;
end

function UIManager.createInputField(name, parent, anchors, offsets, colors, defaultText, textAlignment)
  
  local newInputField = InputField(name, parent, anchors, offsets, colors, defaultText, textAlignment);
  
  return newInputField;
end

function UIManager.createScrollGroup(name, parent, anchors, offsets, colors)
  
  local newScrollGroup = ScrollGroup(name, parent, anchors, offsets, colors);
  
  return newScrollGroup;
end

function UIManager.createCollapsibleGroup(name, parent, anchors, offsets, colors, headerText)
  
  local newCollapsibleGroup = CollapsibleGroup(name, parent, anchors, offsets, colors, headerText);
  
  return newCollapsibleGroup;
end

function UIManager.createDropdown(name, parent, anchors, offsets, colors, options)
  
  local newDropdown = DropdownSelector(name, parent, anchors, offsets, colors, options);
  
  return newDropdown;
end

function UIManager.createSlider(name, parent, anchors, offsets, colors, label, minValue, maxValue, startValue, includeInputField)
  
  local newSlider = Slider(name, parent, anchors, offsets, colors, label, minValue, maxValue, startValue, includeInputField);
  
  return newSlider;
end

function UIManager.createPicturebox(name, parent, anchors, offsets, colors, imgPath, shouldStretch)
  
  local newPicturebox = Picturebox(name, parent, anchors, offsets, colors, imgPath, shouldStretch);
  
  return newPicturebox;
  
end

function UIManager.createWindow(name, parent, anchors, offsets, colors, hasCloseButton, hasMinimizeButton, isDraggable, isResizable, titleText)
  local newWindow = Window(name, parent, anchors, offsets, colors, hasCloseButton, hasMinimizeButton, isDraggable, isResizable, titleText);
  return newWindow;
end

function UIManager.createRectMask(name, parent, anchors, offsets, colors)
  local newRectMask = RectMask(name, parent, anchors, offsets, colors);
  return newRectMask;
end

-- special little function
function UIManager.draw()
  UIManager.DefaultFont = love.graphics.getFont();
  -- how am i going to add canvas support?
  -- how am i going to handle the elements that are drawn every frame?
  -- how am i going to handle element's transformations? drawing by rect doesn't work when depth > 1.
  -- i don't know how to handle transformations, but in general i think a depth-first propagation would work well
  -- and we can hold an IsCanvasSupported variable on each element
  -- and since it's depth-first, if a parent needs to manually draw each of its children elements then it can cancel the depth search (such as the ScrollGroup)
  -- maybe we can keep a separate list here on UIManager for non-canvas elements? i dunno, that can get sloppy real quick..
  -- or maybe just nil the :draw() method for canvas elements (adding a separate redrawCanvas method)
  -- and for optimizing transformations... a breadth-first propagation would allow us to perform the parent transformation and then draw each sibling via rect coords
  -- we'd only do a transformation when going down a depth-layer. i think. that makes sense in my head. pop the transformation when moving back up.
  -- maybe only worry about optimizing transformations if / when it becomes a problem.
  -- worst case scenario, we can just calculate global coords every time the local coords change. that'll be way faster all around, though we may lose rotation / scaling support.
  local isConsumed = false;
  local isTerminal = false;
  local isCanvasDirty = false;
  for k,element in pairs(UIManager.RootElements) do
    -- process current element
    isConsumed, isTerminal, isCanvasDirty = element["OnDraw"](element, {x=0,y=0});
    UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
  end
end

-- === TO-DO 25/11/20 ===
-- !! figure out why CollapsibleGroup isn't getting OnMouseClick event !!
-- === END TO-DO === 

-- event system
-- new direction [11 nov 20]:
-- the idea is to propagate events all the way down the hierarchy using breadth-first search
-- this should be done here on UIManager or on a separate EventSystem file.
-- ElementWithKeyboardFocus should still get priority.
-- searchMode: 1 for depth-first, otherwise defaults to breadth-first
-- == newest direction [10 dec 20] ==
-- so i tried googling how others do it and couldn't find anything really specific. i tried all the technical terms. i started getting physics-related search results..
-- but, the web standard provides an overview for how their event system works (not specific - just an overview):
-- 1. a tree is kept (sometimes called a graph) of all elements, root -> leaf
-- 2. events exist in 3 phases, the first phase starts at the root and travels down the leaves, forming the event graph / event chain along the way
-- 3. eventually, an element captures the event and this initiates the second phase
-- 4. the second phase is where the actual event handlers are invoked (a button responding to a click)
-- 5. after all the valid event handlers are called.. (the button might be part of a scrollgroup - both would receive the onClick, in the order that they registered their handlers)
--    then the final phase begins - this is an optional phase, and some event types have it disabled by default
-- 6. the final phase is the "bubbling" phase where the event travels from that leaf back up to the root along the event graph / chain.
-- as for implementing this, i have to evaluate whether traversing from root -> terminal is entirely necessary
-- furthermore, i have to consider if there are any edge cases, like a child button consuming an event that's really intended for the scrollgroup it's part of.
-- okay, no, starting from TerminalElements won't work ever because button2.Label and button1.Label are always on the same level, so button1's event handlers would be added to the
-- capture list first (and thus called first, and thus consuming the event before button2 even gets it)
-- inversely, starting from the root will add button1's handlers first, THEN button2's handlers, and we execute the handlers from the last one added to the first one added.
-- so, button2's handler would be called first and consume it, preventing button1 from getting it, as intended.
function UIManager.DoEventPropagation(rootElements, eventName, eventData, nodeSelector, predicate, searchMode, captureIterDirection)
  -- when performing breadth-first, container functions as a queue;
  -- when performing depth-first, container functions as a stack.
  if ((eventName ~= "OnDraw") and (eventName ~= "__PROTECTED__OnMouseMoved")) then
    print("=== BEGIN propagation for " .. eventName .. " ===");
  end
  local treeContainer = Container();
  local seenElements = {};
  local capturedElements = Container();
  local element = nil;
  local isConsumed = false;
  local isTerminal = false;
  local isCanvasDirty = false;
  for k,v in pairs(rootElements) do treeContainer:push_right(v); end
  while ((treeContainer:getLength() ~= 0) and (isConsumed ~= true)) do
    if (searchMode == 1) then
      element = treeContainer:pop_right(); -- depth-first
    else
      element = treeContainer:pop_left(); -- breadth-first
    end
    -- process current element
    if ((predicate == nil) or (predicate(element, eventName, eventData) == true)) then
      if ((eventName ~= "OnDraw") and (eventName ~= "OnPointerMove") and (eventName ~= "__PROTECTED__OnMouseMoved")) then
        print("Capturing " .. element:ToString() .. " for event " .. eventName);
      end
      capturedElements:push_right(element);
    end
    -- add the children of current element
    for k1,v1 in pairs(nodeSelector(element)) do
      if (utils:tableContains(seenElements, v1) == false) then
        treeContainer:push_right(v1); 
        table.insert(seenElements, v1);
      end
    end
  end
  -- now that we've iterated the tree and added all the elements that want to handle the event to a list,
  -- we iterate that list from last -> first (so the top-most element, aka the element furthest from the root of the tree, gets to handle it first)
  -- if any handler wishes to consume the event, then we simply stop the iteration
  while ((capturedElements:getLength() ~= 0) and (isConsumed ~= true)) do
    if (captureIterDirection == 0) then
      element = capturedElements:pop_left();
    else
      element = capturedElements:pop_right();
    end
    isConsumed, isCanvasDirty = element[eventName](element, unpack(eventData));
    UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
    if (isConsumed) then
      break;
    end
  end
  if ((eventName ~= "OnDraw") and (eventName ~= "__PROTECTED__OnMouseMoved")) then
    print("=== END propagation for " .. eventName .. " ===");
  end
  return isConsumed;
end

function UIManager.MousePressed(x, y, button, isTouch, presses)
  UIManager.DoEventPropagation(UIManager.RootElements, "OnMousePress", {x, y, button, isTouch, presses}, (function(element) return element.children end), (function(element) return (element:containsPoint(x,y)) and ((element.captureEvents["OnMousePress"] == true) or (element.captureEvents["OnMouseClick"] == true)) end), 0);
  -- if an element is currently focused, we should check to see if an OnSubmit event should be fired
  if ((UIManager.ElementWithFocus ~= nil) and (UIManager.ElementWithMouseClick == nil)) then
    if (UIManager.ElementWithFocus:containsPoint(x, y) == false) then
      print("UIManager.MousePressed is calling OnSubmit for " .. UIManager.ElementWithFocus.name);
      local isConsumed, isTerminal, isCanvasDirty = UIManager.ElementWithFocus["OnSubmit"](UIManager.ElementWithFocus);
      UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
    end
  end
end

function UIManager.MouseReleased(x, y, button, isTouch, presses)
  if (UIManager.ElementWithMouseClick ~= nil) then
    local element = UIManager.ElementWithMouseClick;
    print("Element '" .. element.name .. "' has mouse click, processing release now");
    local isConsumed, isTerminal, isCanvasDirty = element["OnMouseRelease"](element, x, y, button, isTouch, presses);
    UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
    --print("Calling OnMouseClick for '" .. element.Name .. "'");
    isConsumed, isTerminal, isCanvasDirty = element["OnMouseClick"](element, x, y);
    UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
  else
    print("No element has registered mouse click, propagating OnMouseRelease");
    UIManager.DoEventPropagation(UIManager.RootElements, "OnMouseRelease", {x, y, button, isTouch, presses}, (function(element) return element.children end), (function(element) return (element:containsPoint(x,y)) and (element.captureEvents["OnMouseRelease"] == true) end), 0);
  end
  if (UIManager.ElementWithFocus ~= nil) then
    if (UIManager.ElementWithFocus:containsPoint(x, y) == false) then
      print("UIManager.MouseReleased is calling OnSubmit for " .. UIManager.ElementWithFocus.name);
      local isConsumed, isTerminal, isCanvasDirty = UIManager.ElementWithFocus["OnSubmit"](UIManager.ElementWithFocus);
      UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
    end
  end
end

-- === TO-DO 16/11/20 ===
-- I NEED TO FIGURE OUT HOW TO EXECUTE THE DEEPEST ELEMENT'S EVENTS FIRST
-- THIS IS DIFFERENT THAN JUST A DEPTH-FIRST SEARCH. DEPTH-FIRST EXECUTION.
-- i think one possible solution to this is to keep both the RootElements (currently UIManager.AllWindows) and the TerminalElements.
-- when we want to process the deepest elements first, we start from TerminalElements and do a BFS iteration.
-- we can even check against the RootElements before starting on the TerminalElements.
-- ^^ eg; iterate Roots and add to rootsThatContainMouse list, then iterate Terminals and check if (rootsThatContainMouse.contains(terminalElement.root)) then start here
-- or just say heck it and do a element:containsPoint on each element (when relevant), it probably won't be any less efficient.
-- === END TO-DO ===

function UIManager.MouseMoved(x, y, deltaX, deltaY)
  --print("===Starting MouseMove base event===");
  UIManager.DoEventPropagation(UIManager.RootElements, "__PROTECTED__OnMouseMoved", {x, y, deltaX, deltaY}, (function(element) return element.children end), nil, 0, 0);
  --print("===Done processing MouseMove base event===");
end

function UIManager.KeyPressed(key, isRepeat)
  local isConsumed = false;
  if (UIManager.ElementWithKeyboardFocus ~= nil) then
    print("Calling OnKeyPressed manually");
    isConsumed, isTerminal, isCanvasDirty = UIManager.ElementWithKeyboardFocus["OnKeyPressed"](UIManager.ElementWithKeyboardFocus, key, isRepeat);
    UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
    print("Returning " .. tostring(isConsumed) .. " from manual OnKeyPressed");
    return isConsumed;
  else
    -- iterate over all windows, send event to windows that contain mouse pointer
    isConsumed = UIManager.DoEventPropagation(UIManager.RootElements, "OnKeyPressed", {key, isRepeat}, (function(element) return element.children end), (function(element) return (element.isHovered) and (element.captureEvents["OnKeyPressed"] == true) end));
    print("Returning " .. tostring(isConsumed) .. " from propagated OnKeyPressed");
    return isConsumed;
  end
end

function UIManager.KeyReleased(key)
  if (UIManager.ElementWithFocus ~= nil) then
    if (key == "return") then
      local isConsumed, isTerminal, isCanvasDirty = UIManager.ElementWithFocus["OnSubmit"](UIManager.ElementWithFocus);
      UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
    end
    return false;
  else
    -- iterate over all windows, send event to windows that contain mouse pointer
    return UIManager.DoEventPropagation(UIManager.RootElements, "OnKeyReleased", {key}, (function(element) return element.children end), (function(element) return (element.isHovered) and (element.captureEvents["OnKeyReleased"] == true) end));
  end
end

function UIManager.TextInput(text)
  if (UIManager.ElementWithKeyboardFocus ~= nil) then
    local isConsumed, isTerminal, isCanvasDirty = UIManager.ElementWithKeyboardFocus["OnTextInput"](UIManager.ElementWithKeyboardFocus, text);
    UIManager.IsCanvasDirty = isCanvasDirty or UIManager.IsCanvasDirty;
  end
end

return UIManager;