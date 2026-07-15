-- Lightweight class tagging kept for compatibility with legacy Zygor modules.
-- It deliberately uses weak keys so attaching a class never keeps an object
-- alive after the owning UI/module has been released.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Class=ZGV:RegisterModule("Class",{})
local tags=setmetatable({}, {__mode="k"})

function Class:Register(object,name)
  if type(object)~="table" then return false end
  tags[object]=tostring(name or "")
  return true
end

function Class:Get(object) return tags[object] end
function Class:Is(object,name) return tags[object]==name end

-- The historical public surface was a global weak table used as
-- `__CLASS[object] = "Name"`.  Keep that contract for old guide extensions.
ZGV.__CLASS=tags
_G.__CLASS=tags
