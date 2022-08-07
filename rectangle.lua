rectangle = Class("rectangle", PrintableBase);

-- constructor
function rectangle:__init(X, Y, Width, Height)
  self.x = X or 0;
  self.y = Y or 0;
  self.w = Width or 0;
  self.h = Height or 0;
end

function rectangle:containsPoint(x, y)
	if (x > self.x + self.w) or (x < self.x) or (y > self.y + self.h) or (y < self.y) then
		return false;
	else
		return true;
	end
end

function rectangle:ToString()
  return "{" .. self.x .. ", " .. self.y .. ", " .. self.w .. ", " .. self.h .. "}";
end

return rectangle;