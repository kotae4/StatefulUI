vector = Class("vector", PrintableBase);

-- constructor
function vector:__init(X, Y)
  self.x = X or 0;
  self.y = Y or 0;
end

function vector:__add(otherVec)
  return vector(self.x + otherVec.x, self.y + otherVec.y);
end

function vector:ToString()
  return "{" .. self.x .. ", " .. self.y .. "}";
end

return vector;