-- Legacy XML callback names for the Classic guide-viewer frame.  The active
-- 3.3.5a UI is ModernViewer, so these functions delegate instead of creating
-- an obsolete second frame with broken source-era textures.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

ZYGORGUIDESVIEWERFRAME_TITLE=" "
function ZygorGuidesViewerFrame_OnLoad() end
function ZygorGuidesViewerFrame_OnHide() if ZGV.Frame_OnHide then ZGV:Frame_OnHide() end end
function ZygorGuidesViewerFrame_OnShow() if ZGV.Frame_OnShow then ZGV:Frame_OnShow() end end
function ZygorGuidesViewerFrame_Update() if ZGV.UpdateMainFrame then ZGV:UpdateMainFrame() end end
function ZGVFSectionDropDown_Initialize() if ZGV.InitializeDropDown then return ZGV:InitializeDropDown() end end
function ZGVFSectionDropDown_Func(value) if ZGV.SectionChange then return ZGV:SectionChange(value or (this and this.value)) end end
function ZygorGuidesViewerFrame_HighlightCurrentStep() if ZGV.HighlightCurrentStep then ZGV:HighlightCurrentStep() end end
