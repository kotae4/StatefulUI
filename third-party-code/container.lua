--[[ == CREDIT ==
--
--- Deque implementation by Pierre 'catwell' Chapuis
--- MIT licensed (see 'licenses/deque_LICENSE.txt')
--
-- Sourced from: https://github.com/catwell/cw-lua/blob/master/deque [via https://stackoverflow.com/questions/18843610/fast-implementation-of-queues-in-lua]
-- I made minor alterations (semicolons, renaming some variables and functions, etc)
--]]

Container = Class("Container", PrintableBase);

-- constructor
function Container:__init()
  self.head = 0;
  self.tail = 0;
end

-- NOTE:
-- push_right is effectively enqueue, pop_left is effectively dequeue
function Container:push_right(x)
  assert(x ~= nil)
  self.tail = self.tail + 1
  self[self.tail] = x
end

function Container:push_left(x)
  assert(x ~= nil)
  self[self.head] = x
  self.head = self.head - 1
end

function Container:peek_right()
  return self[self.tail]
end

function Container:peek_left()
  return self[self.head+1]
end

function Container:pop_right()
  if self:is_empty() then return nil end
  local r = self[self.tail]
  self[self.tail] = nil
  self.tail = self.tail - 1
  return r
end

function Container:pop_left()
  if self:is_empty() then return nil end
  local r = self[self.head+1]
  self.head = self.head + 1
  local r = self[self.head]
  self[self.head] = nil
  return r
end

function Container:getLength()
  return self.tail - self.head
end

function Container:is_empty()
  return self:getLength() == 0
end

function Container:getContents()
  local r = {}
  for i=self.head+1,self.tail do
    r[i-self.head] = self[i]
  end
  return r
end

function Container:iter_right()
  local i = self.tail+1
  return function()
    if i > self.head+1 then
      i = i-1
      return self[i]
    end
  end
end

function Container:iter_left()
  local i = self.head
  return function()
    if i < self.tail then
      i = i+1
      return self[i]
    end
  end
end

function Container:ToString()
  return "{" .. self.head .. ", " .. self.tail .. "}";
end

return Container;