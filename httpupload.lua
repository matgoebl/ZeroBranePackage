local G = ...
local id = G.ID("httpuploadtoolbar.httpuploadmenu")
local tool
local config = nil

local httpupload = function()
  local http = require("socket.http")
  local ltn12 = require("ltn12")
  local ed = ide:GetEditor()
  if not ed then 
    DisplayOutputLn("HTTP Upload: No open file to upload.")
    return 
  end 

  local filename = ide:GetDocument(ed):GetFileName()
  local url = config.baseurl .. filename
  local post = ide:GetEditor():GetText()
  local body = {}
  local result, code, headers, status = http.request {
    method = "POST",
    url = url,
    source = ltn12.source.string(post),
    headers = {
      ["content-type"] = "text/plain",
      ["content-length"] = tostring(#post)
    },
    sink = ltn12.sink.table(body)
  }
  
  local msg
  if result == nil then
    msg = "ERROR: " .. code
  else
    if code < 200 or code >= 300 then
      msg = "ERROR: " .. status
    else
      msg = status .. "\n" .. table.concat(body)
    end
  end
  DisplayOutputLn("HTTP Upload of " .. filename .. " to " .. url:gsub("(://[^:/@]*:)([^/@]*)@","%1***@"))
  DisplayOutputLn(msg)
end

return {
  name = "Add `httpupload` toolbar button",
  description = "Adds a menu item and toolbar button that uploads a file via HTTP POST.",
  author = "Matthias Goebl, based on maketoolbar by Paul Kulchenko",
  version = 0.1,
  dependencies = 0.71,

  onRegister = function(self)
    config = ide:GetConfig().httpupload
    if not config or not config.baseurl then 
      DisplayOutputLn("HTTP Upload plugin NOT registered: No URL configured.")
      DisplayOutputLn("Add the following line to your user.lua: go to Edit -> Preferences -> Settings: User")
      DisplayOutputLn('httpupload = {baseurl = "http://user:pw@server.com/data/"}')
      return nil
    end 

    local menu = ide:GetMenuBar():GetMenu(ide:GetMenuBar():FindMenu(TR("&Project")))
    menu:Append(id, "HTTP Upload")
    ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, httpupload)

    local tb = ide:GetToolBar()
    tool = tb:AddTool(id, "HTTP Upload"..KSC(id), wx.wxBitmap({
          -- columns rows colors chars-per-pixel --
          "16 16 87 1",
          "  c None",
          ". c #6D6E6E", "X c #766F67", "o c #7A7162", "O c #6C6E70", "+ c #717171",
          "@ c #747473", "# c #757676", "$ c #797673", "% c #9D754F", "& c #9C7550",
          "* c #AB7745", "= c #AB7845", "- c #AB7846", "; c #AC7845", ": c #AC7846",
          "> c #AC7947", ", c #AD7B46", "< c #A7794A", "1 c #817F7C", "2 c #CB9827",
          "3 c #C2942F", "4 c #CB962B", "5 c #C29434", "6 c #CB983C", "7 c #DFBB3A",
          "8 c #BF9041", "9 c #BB9049", "0 c #BD9249", "q c #BC9154", "w c #87826C",
          "e c #CA9643", "r c #C79943", "t c #C6914D", "y c #E5C84E", "u c #EAC955",
          "i c #F2DD73", "p c #F6DD77", "a c #3F99DC", "s c #3E9ADE", "d c #4F99C3",
          "f c #519ED0", "g c #4BA0DC", "h c #4CA1DF", "j c #52A6E2", "k c #55A7E4",
          "l c #5EAAE2", "z c #5CACE4", "x c #6BAFE2", "c c #6BB0E3", "v c #6AB1EA",
          "b c #6CB7E8", "n c #76B5E4", "m c #70B5EA", "M c #70B9E8", "N c #828383",
          "B c #848585", "V c #858686", "C c #868787", "Z c #878787", "A c #8F8F8F",
          "S c #949595", "D c #B7B8B8", "F c #81BAE3", "G c #81BAE4", "H c #81BBE5",
          "J c #B3D1D7", "K c #A0D3E8", "L c #BCD6E6", "P c #B0D7F0", "I c #BDDEF1",
          "U c #BAE5F6", "Y c #C0C0C0", "T c #CDCDCD", "R c #D4D4D4", "E c #D9D9D9",
          "W c #DCDCDC", "Q c #CADEED", "! c #C2DFF8", "~ c #C9E2FA", "^ c #CEE4FA",
          "/ c #CEEFFE", "( c #CEF2FF", ") c #E1E1E1", "_ c #E2E2E2", "` c #E4E4E4",
          "' c #EBEBEB",
          -- pixels --
          "                ",
          "   &w.C#   ss   ",
          "  %1D_'BO vl    ",
          "  $E_`Z1  Hs  s ",
          " .YWRBo  H~bkbs ",
          " +ETSwr=HQ!/Hk  ",
          " .NAX9i6,IUh    ",
          "  O@ <8y2;h     ",
          "     f;574;     ",
          "    xLJ,5ue;    ",
          "  HH^PKd;0pt;   ",
          " snsv(s  ;que,  ",
          " s  sH    *0pt* ",
          "    zM     ,q;  ",
          "   ss       ,   ",
          "                "
        }))
    tb:Realize()

    DisplayOutputLn("HTTP Upload plugin registered, base url = "..config.baseurl:gsub("(://[^:/@]*:)([^/@]*)@","%1***@"))
  end,

  onUnRegister = function(self)
    local tb = ide:GetToolBar()
    tb:DeleteTool(tool)
    tb:Realize()

    ide:RemoveMenuItem(id)
  end,
}
