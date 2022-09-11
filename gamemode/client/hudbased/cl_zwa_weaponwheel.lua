local wepWheel = {}

wepWheel.soundList = {}
wepWheel.soundList.active = ""
wepWheel.soundList.deactive = ""
wepWheel.soundList.select = ""

wepWheel.wepTbl = {}
wepWheel.activeWep = {}
wepWheel.selectedWep = nil

wepWheel.selectTbl = {}
wepWheel.selected = -1
wepWheel.preselect = -1

wepWheel.created = false

wepWheel.overlay = 0

local colorA = Color( 145, 0, 0, 200)
local colorB = Color( 255, 255, 255, 150)
local colorC = Color( 200, 200, 200, 255 )

local lastResolution, currentResolution = 0, 0

local function OnBindPressed( bind )

    local binding = input.LookupBinding( bind ) or 0
    local keyCode = input.GetKeyCode( binding )

    if input.WasKeyPressed( keyCode ) or input.WasMousePressed( keyCode ) then

        -- If any addon suppresses the binding, then this will be known here.
        if not hook.Run( "PlayerBindPress", LocalPlayer(), bind ) then
            return true
        end
    end

    return false
end

function wepWheel.Init()
    for i = 0, 5 do wepWheel.selectTbl[i] = 1 end

    hook.Add( "CreateMove", "wepWheel.wheel", wepWheel.CreateMove )

    hook.Add( "Think", "wepWheel.show", wepWheel.Think )
end


function wepWheel.GetPointInCircle( ang, radius, offX, offY )
	ang = math.rad( ang )
	local x = math.cos( ang ) * radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

local function DrawArc(arc)
    for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

function BeginDrawArc( cx, cy, radius, thickness, startang, endang, roughness, color )
    draw.NoTexture()
	surface.SetDrawColor( colorA )
	DrawArc( PrecacheArc( cx, cy, radius, thickness, startang, endang, roughness ) )
end


function PrecacheArc( cx, cy, radius, thickness, startang, endang, roughness )
	
	local cos, sin, abs, max, rad1, log, pow = math.cos, math.sin, math.abs, math.max, math.rad, math.log, math.pow
	local quadarc = {}
	
	-- Correct start/end ang
	local startang, endang = startang or 0, endang or 0
	
	-- Define step
	-- roughness = roughness or 1

	local smoothness = 3

	-- if roughness <= 0 then smoothness = 1 end
	-- if roughness == 1 then smoothness = 2 end
	-- if roughness == 2 then smoothness = 3 end
	-- if roughness >= 3 then smoothness = 4 end

	local diff = abs(startang-endang)
	local step = diff / (pow(2,smoothness))
	if startang > endang then
		step = abs(step) * -1
	end
	
	-- Create the inner circle's points.
	local inner = {}
	local outer = {}
	local ct = 1
	local r = radius - thickness
	
	for deg=startang, endang, step do
		local rad = rad1(deg)
		-- local rad = deg2rad * deg
		local cosrad, sinrad = sin(rad), cos(rad) --calculate sin,cos
		
		local ox, oy = cx+(cosrad*r), cy+(-sinrad*r) --apply to inner distance
		inner[ct] = {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		}
		
		local ox2, oy2 = cx+(cosrad*radius), cy+(-sinrad*radius) --apply to outer distance
		outer[ct] = {
			x=ox2,
			y=oy2,
			u=(ox2-cx)/radius + .5,
			v=(oy2-cy)/radius + .5,
		}
		
		ct = ct + 1
	end
	
	-- QUAD the points.
	for tri=1,ct do
		local p1,p2,p3,p4
		local t = tri+1
		p1=outer[tri]
		p2=outer[t]
		p3=inner[t]
		p4=inner[tri]
		
		quadarc[tri] = {p1,p2,p3,p4}
	end
	
	-- Return a table of triangles to draw.
	return quadarc
	
end

function wepWheel.CreateWheel()

    -- set scale --
    local pl = LocalPlayer()
    local selSize = ScrH() * 0.65

    wepWheel.panel = vgui.Create( "DPanel" )
    wepWheel.panel:SetSize( selSize, selSize )
    wepWheel.panel:SetPos( ScrW() * 0.5 - selSize * 0.5, ScrH() * 0.5 - selSize * 0.5 )
    wepWheel.panel:SetBackgroundColor( Color( 200, 200, 200, 0 ) )

    local index = 0

    -- create sectors --
    for degrees = -30, 270, 60 do

        local cell = vgui.Create( "DPanel", wepWheel.panel )

        local w, h = wepWheel.panel:GetSize()
        local x, y = selSize * 0.05, selSize * 0.05

        local bias = {
            [-30] = { x =  0, y = -4 },
            [30]  = { x =  4, y = -2 },
            [90]  = { x =  4, y =  2 },
            [150] = { x =  0, y =  4 },
            [210] = { x = -4, y =  2 },
            [270] = { x = -4, y = -2 }
        }
        
        x = x + bias[degrees].x
        y = y + bias[degrees].y

        cell:SetPos( x, y )
        cell:SetSize( selSize * 0.9, selSize * 0.9 )
        cell.Index = index
        cell.Paint = function( self, w, h )

            if not pl:Alive() or table.IsEmpty( wepWheel.wepTbl ) then return end

            local a = degrees
            local b = a + 60
            
            local c = colorB
            local color = Color( c.r, c.g, c.b , c.a )

            local color2 = Color( c.r * 0.5, c.g * 0.5, c.b * 0.5, c.a + 70 )

            if self.Index == wepWheel.selected then
                local c = colorA
                color = Color( c.r + 30, c.g + 30, c.b + 30, c.a )
            end
            
            local activeWep = wepWheel.activeWeapon

            if self.Index == activeWep.slot then
                local c = colorA
                color2 = colorA
            end
            
            BeginDrawArc( w * 0.5, h * 0.5, w * 0.5, w * 0.2, a, b, 3, color )
            BeginDrawArc( w * 0.5, h * 0.5, w * 0.5, w / 70, a, b, 3, color2 )
        end

        index = index + 1
    end

    local w, h = wepWheel.panel:GetSize()
    index = 0

    -- create wep icons and ammo --
    for degrees = -90, 220, 60 do

        local x, y = wepWheel.GetPointInCircle( degrees, selSize * 0.35, h * 0.5, w * 0.5 )
        local size = selSize * 0.3

        local slotInfo = vgui.Create( "DPanel", wepWheel.panel)
        slotInfo:SetPos( x - size * 0.5, y - size * 0.5 )
        slotInfo:SetSize( size, size )
        slotInfo.Index = index
        slotInfo.Paint = function( self, w, h )

            if not pl:Alive() or table.IsEmpty(wepWheel.wepTbl) then return end
            
            local slotWep = wepWheel.wepTbl
            local count = table.Count( slotWep )
            local pos = wepWheel.selectTbl[self.Index]

            if pos <= 0 or table.IsEmpty( slotWep ) then return end
            if slotWep[pos] == nil then
                wepWheel.selectTbl[self.Index] = pos - 1 return
            end

            if not slotWep[pos]:IsValid() then return end

            wepWheel.DrawWeponIcon( slotWep[pos], 0, h - h * 1.1, w, h )

            local clip1 = slotWep[pos]:Clip1()
            local clip2 = pl:GetAmmoCount( slotWep[pos]:GetPrimaryAmmoType() )
            local clip3 = pl:GetAmmoCount( slotWep[pos]:GetSecondaryAmmoType() )

            local text = clip1 .. "  /  " .. clip2
            text = clip1 < 0 and clip2 >= 0 and clip2 or text
            text = clip3 > 0 and text .. "  alt: " .. clip3 or text
            text = ( clip1 <= 0 and clip2 <= 0 ) and slotWep[pos]:HasAmmo() and "∞" or text

            local sybols = string.len( text )
            local factor = sybols > 3 and 0.05 or 0.1
            
            draw.NoTexture()
            surface.SetDrawColor( 0, 0, 0, 150 )
            surface.DrawTexturedRectRotated( w * 0.5, h * 0.61, w * factor * sybols, h * 0.11, 0)

            draw.SimpleTextOutlined( text, "AmmoCount", w * 0.5, h * 0.6, 
                Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
        end

        index = index + 1
    end

    local size = selSize * 0.4
    local w, h = wepWheel.panel:GetSize()
    
    -- create central info --
    local slotInfo = vgui.Create( "DPanel", wepWheel.panel )
    slotInfo:SetPos( w * 0.5 - size * 0.5, w * 0.5 - size * 0.5 )
    slotInfo:SetSize( size, size )
    slotInfo.Paint = function( self, w, h )

        if not pl:Alive() or table.IsEmpty( wepWheel.wepTbl ) then return end
        
        local slot = wepWheel.selected

        if wepWheel.selected < 0 then
            local active = wepWheel.activeWeapon
            slot = active.slot or 0

            if not table.IsEmpty( active ) then            
                for v, k in ipairs( wepWheel.wepTbl[slot] ) do
                    if k:IsValid() and active.wep:IsValid() then
                        if k:GetClass() == active.wep:GetClass() then
                            wepWheel.selectTbl[slot] = v
                        end
                    end
                end
            end
        end

        local slotWep = wepWheel.wepTbl[slot]
        local pos = wepWheel.selectTbl[slot]

        if slotWep == nil then return end

        local count = table.Count( slotWep )

        if wepWheel.selectTbl[slot] > count then
            wepWheel.selectTbl[slot] = count > 0 and count or 1
        end

        wepWheel.selectedWeapon = slotWep[pos]
        
        if pos <= 0 or table.IsEmpty( slotWep ) then return end
        if not slotWep[pos]:IsValid() then return end

        if wepWheel.selected >= 0 then
        local text = "<   " .. pos .. "  /  " .. count .. "   >"
            draw.SimpleTextOutlined( text, "SlotSelection", w * 0.5, h * 0.3, 
                Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
        end
        
        draw.SimpleTextOutlined( slotWep[pos]:GetPrintName(), "SlotSelection", w * 0.5, h * 0.2, 
            Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
    end

    -- create wep info --
    wepWheel.panelInfo = vgui.Create("DPanel")
    wepWheel.panelInfo:SetSize( 260, ScrH() * 0.28 )
    wepWheel.panelInfo:SetPos( ScrW() - 260 - 260 * 0.1, ScrH() * 0.02)
    wepWheel.panelInfo.BoxHeight = 100
    wepWheel.panelInfo.Paint = function( self, w, h )

        local wep = wepWheel.selectedWeapon
        if wep == nil or not wep:IsValid() then return end
        if wep.DrawWeaponInfoBox ~= true then return end
 
        if wep.Author == "" and wep.Contact == "" and wep.Purpose == "" 
            and wep.Instructions == "" then return end

        draw.RoundedBox( 3, 0, 0, w, self.BoxHeight, Color( 50, 50, 50, 200 ) )
        draw.RoundedBox( 3, 0, 0, w, 15, wepWheel.color.a )

        draw.SimpleTextOutlined( "Swep info:", "DermaDefault", 3, 0, 
            Color( 255, 255, 255 ), nil, nil, 1, Color( 0, 0, 0 ) )

        if ( wep.InfoMarkup == nil ) then
            local str = ""
            local title_color = "<color=230,230,230,255>"
            local text_color = "<color=230,150,150,255>"

            str = "<font=DermaDefault>"
            if ( wep.Author ~= "" ) then str = str .. title_color .. 
                    "Author:</color>\t" .. text_color .. wep.Author .. "</color>\n" end
            if ( wep.Contact ~= "" ) then str = str .. title_color .. 
                    "Contact:</color>\t" .. text_color .. wep.Contact .. "</color>\n\n" end
            if ( wep.Purpose ~= "" ) then str = str .. title_color .. 
                    "Purpose:</color>\n" .. text_color .. wep.Purpose .. "</color>\n\n" end
            if ( wep.Instructions ~= "" ) then str = str .. title_color .. 
                    "Instructions:</color>\n" .. text_color .. wep.Instructions .. "</color>\n" end
            str = str .. "</font>"

            wep.InfoMarkup = markup.Parse( str, 250 )
        end

        wep.InfoMarkup:Draw( w * 0.03, h * 0.07, nil, nil, 255 )
        self.BoxHeight = wep.InfoMarkup.totalHeight + 20
    end

    wepWheel.panelInfo:Hide()
    wepWheel.panel:Hide()
end

function wepWheel.ReturnActive( pl )
    
    local wepTbl = {}

    for k, weapon in pairs( pl:GetWeapons() ) do
        if active == pl:GetActiveWeapon() then
            wepTbl = {
                weapon = weapon,
                slot = wep:GetSlot()
            }

            break
        end
    end
    
    return wepTbl
end

function wepWheel.GetWepTable( pl )

    local tbl = {}
    local weps = pl:GetWeapons()

    for i = 0, 5 do

        tbl[i] = {}
        local tumb = {}

        for k, wep in pairs( weps ) do
            if wep:GetSlot() ~= i then continue end
            tumb[k] = { weapon = wep, slotPos = wep:GetSlotPos() }
        end

        local index = 1

        for k, v in SortedPairsByMemberValue( tumb, "slotPos" ) do
            tbl[i][index] = v.weapon

            index = index + 1
        end
    end

    return table
end

function wepWheel.DrawIcon( wep, x, y, w, h )
    local path = "materials/" .. wep:GetClass() .. ".png"

    -- Icons optimizations --
    if wepWheel.iconsBuffer[path] == nil then
        wepWheel.iconsBuffer[path] = file.Exists(path, "GAME")
    end 

    if wepWheel.iconsBuffer[path] then

        surface.SetMaterial( Material( path ) )
        surface.SetDrawColor( wepWheel.color.c )
        surface.DrawTexturedRect( x, y, w, h )
    else
        if wep.WepSelectIcon ~= nil then
            wep:DrawWeaponSelection( 0, 0, w, h )
        else
            draw.SimpleTextOutlined(wep:GetPrintName(), "ZWA_Fonts.NoIcon", w * 0.5, h * 0.5, 
                Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
        end
    end
end

function wepWheel.Show()

    if vgui.CursorVisible() then return end

    if IsValid( wepWheel.panel ) and wepWheel.panel:IsVisible() then return end

    if !LocalPlayer():Alive() or LocalPlayer():InVehicle() then return end

    if wepWheel.wepWheelShoudReCreate and IsValid( wepWheel.panel ) then
        wepWheel.panel:Remove()
        wepWheel.CreateWheel()
    end

    surface.PlaySound( wepWheel.soundList.active )

    wepWheel.panel:Show()

    wepWheel.panelInfo:Show()

    wepWheel.isOpened = true
end

-- hide selection wheel --
function wepWheel.Hide()
    if IsValid( wepWheel.panel ) and wepWheel.panel:IsVisible() then

        if wepWheel.selected >= 0 and LocalPlayer():Alive() then

            local slotWep = wepWheel.wepTbl[wepWheel.selected]
            local pos = wepWheel.selectTbl[wepWheel.selected]

            if not (pos <= 0) and not table.IsEmpty( slotWep ) then
                if slotWep[pos]:IsValid() then
                    RunConsoleCommand( "use", slotWep[pos]:GetClass() )
                end
            end
        end

        gui.EnableScreenClicker(false)
        
        surface.PlaySound( wepWheel.soundList.deactive )

        wepWheel.panelInfo:Hide()
        wepWheel.panel:Hide()
        wepWheel.isOpened = false
        wepWheel.onFastOpen = false

    end

    timer.Remove( "wepWheel.NullControlDelay" )
    timer.Create( "wepWheel.NullControlDelay", 0.1, 1, function()
        hook.Remove( "StartCommand", "wepWheel.NullControl" )
    end)

    hook.Add("Think", "wepWheel.animation", function()
        wepWheel.overlay = Lerp( 10 * FrameTime(), wepWheel.overlay, 0 )
    end)
end


function wepWheel.CreateMove( cmd )
    
    if not wepWheel.created then
        wepWheel.CreateWheel()
        wepWheel.created = true
    end

    local function GetSlotData( slot )
        local slotWep = wepWheel.wepTable[wepWheel.selected] 
        if slotWep == nil then return nil end
        
        local pos = wepWheel.selectedTable[wepWheel.selected]
        local count = table.Count(slotWep)

        return pos, count
    end

    -- scrool wheel input --
    if OnBindPressed( "invprev" ) then
        
        wepWheel.Show()

        if wepWheel.isOpened then
            wepWheel.onFastOpen = true

            if shouldOccur then

                -- If convar mostrush_wepWheel_fastopen_hl2 is TRUE --
                if GetConVar( "mostrush_wepWheel_fastopen_hl2" ):GetBool() then

                    if wepWheel.selected == -1 then
                        wepWheel.selected = wepWheel.activeWeapon.slot or 1
                    end

                    local pos, count = GetSlotData( wepWheel.selected )
                    
                    if pos ~= nil then

                        wepWheel.selectedTable[wepWheel.selected] = pos + 1

                        if wepWheel.selectedTable[wepWheel.selected] > count then

                            local previous = wepWheel.selected

                            wepWheel.selectedTable[wepWheel.selected] = 1
                            wepWheel.selected = wepWheel.selected + 1

                            if wepWheel.selected > 5 then
                                wepWheel.selected = 0
                            end

                            wepWheel.selectedTable[previous] = 1
                        end
                        
                        if count > 1 then
                            wepWheelwheel.SoundPlaySingle( wepWheel.sound.switch2, nil, wepWheel.sound.volume )
                        end

                    end

                -- If convar mostrush_wepWheel_fastopen_hl2 is FALSE --
                else

                    wepWheel.selected = wepWheel.selected + 1

                    if wepWheel.selected > 5 then
                        wepWheel.selected = 0
                    end

                end

                local count = 0

                while wepWheel.selected == -1 or  
                    table.IsEmpty( wepWheel.wepTable[wepWheel.selected] ) do

                    if count >= 5 then wepWheel.selected = -1 break end

                    wepWheel.selected = wepWheel.selected + 1

                    if wepWheel.selected > 5 then
                        wepWheel.selected = 0
                    end

                    count = count + 1
                end

                shouldOccur = false
                timer.Simple( delay, function() shouldOccur = true end )
            end

            timer.Remove( "wepWheel.FastOpenHide" )
            timer.Create( "wepWheel.FastOpenHide", 1, 1, function()
                wepWheel.Hide()
            end)

            hook.Add( "StartCommand", "wepWheelwheel.NullControl", function( ply, cmd )
                cmd:RemoveKey( IN_ATTACK )
            end)
        end
    end

    if OnBindPressed( "invnext" ) then

        wepWheel.Show()

        if wepWheel.isOpened then

            wepWheel.onFastOpen = true
            
            if shouldOccur then

                local shouldSetToCount = false

                -- If convar mostrush_wepWheel_fastopen_hl2 is TRUE --
                if GetConVar( "mostrush_wepWheel_fastopen_hl2" ):GetBool() then
                    if wepWheel.selected == -1 then
                        wepWheel.selected = wepWheel.activeWeapon.slot or 1
                    end

                    local pos, count = GetSlotData( wepWheel.selected )

                    if pos ~= nil then

                        wepWheel.selectedTable[wepWheel.selected] = pos - 1

                        if wepWheel.selectedTable[wepWheel.selected] < 1 then

                            local previous = wepWheel.selected

                            wepWheel.selectedTable[wepWheel.selected] = 1
                            wepWheel.selected = wepWheel.selected - 1

                            if wepWheel.selected < 0 then
                                wepWheel.selected = 5
                            end

                            local pos, count = GetSlotData( wepWheel.selected )
                            
                            wepWheel.selectedTable[wepWheel.selected] = count > 0 and count or 1
                            wepWheel.selectedTable[previous] = 1

                            shouldSetToCount = true
                        end
                        
                        if count > 1 then
                            wepWheelwheel.SoundPlaySingle( wepWheel.sound.switch2, nil, wepWheel.sound.volume )
                        end

                    end

                -- If convar mostrush_wepWheel_fastopen_hl2 is FALSE --
                else

                    wepWheel.selected = wepWheel.selected - 1
                    
                    if wepWheel.selected < 0 then
                        wepWheel.selected = 5
                    end

                end

                local count = 0

                while wepWheel.selected == -1 or  
                    table.IsEmpty( wepWheel.wepTable[wepWheel.selected] ) do

                    if count >= 5 then wepWheel.selected = -1 break end

                    wepWheel.selected = wepWheel.selected - 1

                    if wepWheel.selected < 0 then
                        wepWheel.selected = 5
                    end

                    count = count + 1
                end

                if shouldSetToCount then
                    local pos, count = GetSlotData( wepWheel.selected )
                            
                    if pos ~= nil then
                        wepWheel.selectedTable[wepWheel.selected] = count > 0 and count or 1
                    end
                end

                shouldOccur = false
                timer.Simple( delay, function() shouldOccur = true end )
            end

            timer.Remove( "wepWheel.FastOpenHide" )
            timer.Create( "wepWheel.FastOpenHide", 1, 1, function() 
                wepWheel.Hide()
            end)

            hook.Add( "StartCommand", "wepWheelwheel.NullControl", function( ply, cmd )
                cmd:RemoveKey( IN_ATTACK )
            end)
        end
    end

    if OnBindPressed( "+attack" ) then
        
        wepWheel.Hide()

        timer.Remove( "wepWheel.FastOpenHide" )

        wepWheel.onNumsOpen = false
        return
    end


    local function IsKeyDown( button )

        local isDown = false
        
        isDown = input.IsButtonDown( button )
    
        if isDown then return true end
    
        isDown = input.IsKeyDown( button )
    
        if isDown then return true end
    
        isDown = input.IsMouseDown( button )
    
        return isDown
    end
    
    local function OpenNumsSelection( slotKey )

        if slotKey then

            wepWheel.Show()

            local previous = wepWheel.selected
            wepWheel.selected = slotKey

            if table.IsEmpty( wepWheel.wepTbl[wepWheel.selected] ) then
                wepWheel.selected = -1
            end

            hook.Add( "StartCommand", "wepWheel.NullControl", function( ply, cmd )
                cmd:RemoveKey( IN_ATTACK )
            end)

            if wepWheel.onNumsOpen and previous == wepWheel.selected then
                
                local slotWep = wepWheel.wepTbl[wepWheel.selected] 
                if slotWep == nil then return end
                
                local pos = wepWheel.selectTbl[wepWheel.selected]
                local count = table.Count(slotWep)

                wepWheel.selectTbl[wepWheel.selected] = pos + 1

                if wepWheel.selectTbl[wepWheel.selected] > count then
                    wepWheel.selectTbl[wepWheel.selected] = 1
                end
                
                if count > 1 then
                    surface.PlaySound( wepWheel.soundList.select )
                end

            end

            timer.Remove( "wepWheel.FastOpenHide" )
            timer.Create( "wepWheel.FastOpenHide", 1, 1, function() 
                wepWheel.Hide()
                wepWheel.onNumsOpen = false
            end)

            wepWheel.onNumsOpen = true
        end
    end
end

local curBool, prevBool = false, false

function wepWheel.Think()

    local pl = LocalPlayer()

    if wepWheel.isOpened or wepWheel.onFastOpen then

        -- important 'globals' --
        wepWheel.wepTbl = wepWheel.GetWepTable( pl )
        wepWheel.activeWeapon = wepWheel.ReturnActive( pl )

        -- sound play --
        if wepWheel.selected ~= wepWheel.preselected then
            if wepWheel.selected ~= -1 then
                surface.PlaySound(wepWheel.soundList.select )
                //wepWheelwheel.SoundPlaySingle( wepWheel.sound.switch1, nil, wepWheel.sound.volume )
            end

            wepWheel.preselected = wepWheel.selected
        end

        -- Controls selection --
        local x, y = input.GetCursorPos()
        local oX, oY = ScrW() * 0.5, ScrH() * 0.5
        local a, b = x - oX, oY - y
        local ang = math.Round(math.atan2(a, b) * (180 / 3.14))
        local c = math.sqrt(a * a + b * b)

        local function ChangeSlot( index )
            if not table.IsEmpty( wepWheel.wepTbl[index] ) then
                wepWheel.selected = index
            end
        end

        -- sectors detecting --
        if not wepWheel.onFastOpen and not wepWheel.onNumsOpen then
            if c > ScrW() * 0.09 then
                if ang > -30 and ang < 30 then ChangeSlot( 0 ) end
                if ang > 30 and ang < 90 then ChangeSlot( 1 ) end
                if ang > 90 and ang < 150 then ChangeSlot( 2 ) end
                if ang > 150 and ang < 180 or 
                    ang > -180 and ang < -150 then ChangeSlot( 3 ) end
                if ang > -150 and ang < -90 then ChangeSlot( 4 ) end
                if ang > -90 and ang < -30 then ChangeSlot( 5 ) end
            else
                wepWheel.selected = -1
            end
        end
    end

    if not LocalPlayer():Alive() then wepWheel.Hide() end
end

hook.Add("Think", "wepWheel.ResolutionCheck", function()
    currentResolution = ScrW() * ScrH()

    if currentResolution ~= lastResolution then
        wepWheel.CreateWheel()
        lastResolution = currentResolution
    end
end)

wepWheel.Init()