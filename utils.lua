utils = {};

function utils:intersectAABB(rectA, rectB)
	return rectA.x < rectB.x + rectB.width and 
		rectB.x < rectA.x + rectA.width and
		rectA.y < rectB.y + rectB.height and
		rectB.y < rectA.y + rectA.height;
end

function utils:tableContains(table, element)
  for k,v in pairs(table) do
    if (v == element) then 
      return true;
    end
  end
  return false;
end

function utils:pack(...)
  return { n = select('#', ...), 
          ... };
end

return utils;