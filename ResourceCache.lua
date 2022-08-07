local ResourceCache = {
  images = {};
  };

function ResourceCache:getImage(filePath, filterMode)
  if (self.images[filePath] ~= nil) then return self.images[filePath] end
  self.images[filePath] = love.graphics.newImage(filePath);
  if (filterMode ~= nil) then
    self.images[filePath]:setFilter(filterMode, filterMode);
  end
  return self.images[filePath];
end

return ResourceCache;