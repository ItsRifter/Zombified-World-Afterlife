local wepWheel = {}

wepWheel.panel = nil

wepWheel.wepTable = {}
wepWheel.activeWeapon = {}
wepWheel.selectedWeapon = nil

wepWheel.selectedTable = {}
wepWheel.selected = -1
wepWheel.preselected = -1

wepWheel.isOpened = false
wepWheel.onFastOpen = true
wepWheel.onNumsOpen = false

wepWheel.firstCreationBool = false

wepWheel.inAttack2 = false
wepWheel.inAttack = false
wepWheel.inUse = false

wepWheel.sound = {}
wepWheel.sound.close = "zwa/radialequip.wav"
wepWheel.sound.switch1 = "zwa/radialselect.wav"
wepWheel.sound.switch2 = "zwa/radialselect.wav"

wepWheel.color = {}
wepWheel.color.a = Color( 255, 255, 255, 200)
wepWheel.color.b = Color( 30, 30, 30, 150)
wepWheel.color.c = Color( 200, 200, 200, 255 )

wepWheel.overlay = 0

-- Icons optimizations --
wepWheel.iconsBuffer = {}

function IsKeyDown( cmd )
    for key = 1, 161 do
        if input.LookupKeyBinding( key ) == cmd then
            local isDown = false
	
            isDown = input.IsButtonDown( key )

            if isDown then return true end

            isDown = input.IsKeyDown( key )

            if isDown then return true end

            isDown = input.IsMouseDown( key )

            return isDown
        end
    end
end

function GetPointInCircle( ang, radius, offX, offY )
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
	surface.SetDrawColor( color )
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

	if roughness <= 0 then smoothness = 1 end
	if roughness == 1 then smoothness = 2 end
	if roughness == 2 then smoothness = 3 end
	if roughness >= 3 then smoothness = 4 end

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

function PointOnCircle( ang, radius, offX, offY )
	ang = math.rad( ang )
	local x = math.cos( ang ) * radius + offX
	local y = math.sin( ang ) * radius + offY
	return x, y
end

-- initialization --
function InitWeaponWheel() 
    if !ZWA_Fonts then return end
    
    for i = 0, 5 do wepWheel.selectedTable[i] = 1 end

    ZWA_Fonts:CreateFont("NoIconName", 26)
    hook.Add( "CreateMove", "wepWheel.wheel", CreateMove )

    hook.Add( "Think", "Show()", Think )
end

-- get active weapon --
function GetActiveWep( ply )
    
    local table = {}
    local weapons = ply:GetWeapons()
    local active = ply:GetActiveWeapon()

    for k, wep in pairs( weapons ) do
        if active == wep then
            table = {
                wep = wep,
                slot = wep:GetSlot()
            }
        end
    end
    
    return table
end

-- get wep table --
function GetWepTable( ply )

    local table = {}
    local weapons = ply:GetWeapons()

    for i = 0, 5 do

        table[i] = {}
        local tumb = {}

        for k, wep in pairs( weapons ) do
            if wep:GetSlot() ~= i then continue end
            tumb[k] = { weapon = wep, slotPos = wep:GetSlotPos() }
        end

        local index = 1

        for k, v in SortedPairsByMemberValue( tumb, "slotPos" ) do
            table[i][index] = v.weapon

            index = index + 1
        end
    end

    return table
end

-- draw weapon icon --
function wepWheel.DrawWeponIcon( wep, x, y, w, h )
    local class = wep:GetClass()
    local path = "materials/" .. class .. ".png"

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
            draw.SimpleTextOutlined(wep:GetPrintName(), "ZWA_Fonts.NoIconName", w * 0.5, h * 0.5, 
                Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
        end
    end
end

-- create seletion wheel --
function Create()

    wepWheel.wepWheelShoudReCreate = false
    
    -- set scale --
    local ply = LocalPlayer()
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

            if not ply:Alive() or table.IsEmpty( wepWheel.wepTable ) then return end

            local a = degrees
            local b = a + 60
            
            local c = wepWheel.color.b
            local color = Color( c.r, c.g, c.b , c.a )

            local color2 = Color( c.r * 0.5, c.g * 0.5, c.b * 0.5, c.a + 70 )

            if self.Index == wepWheel.selected then
                local c = wepWheel.color.a
                color = Color( c.r + 30, c.g + 30, c.b + 30, c.a )
            end
            
            local activeWep = wepWheel.activeWeapon

            if self.Index == activeWep.slot then
                local c = wepWheel.color.a
                color2 = wepWheel.color.a
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

        local x, y = PointOnCircle( degrees, selSize * 0.35, h * 0.5, w * 0.5 )
        local size = selSize * 0.3

        local slotInfo = vgui.Create( "DPanel", wepWheel.panel)
        slotInfo:SetPos( x - size * 0.5, y - size * 0.5 )
        slotInfo:SetSize( size, size )
        slotInfo.Index = index
        slotInfo.Paint = function( self, w, h )

            if not ply:Alive() or table.IsEmpty(wepWheel.wepTable) then return end
            
            local slotWep = wepWheel.wepTable[self.Index]
            local count = table.Count( slotWep )
            local pos = wepWheel.selectedTable[self.Index]

            if pos <= 0 or table.IsEmpty( slotWep ) then return end
            if slotWep[pos] == nil then
                wepWheel.selectedTable[self.Index] = pos - 1 return
            end

            if not slotWep[pos]:IsValid() then return end

            wepWheel.DrawWeponIcon( slotWep[pos], 0, h - h * 1.1, w, h )

            local clip1 = slotWep[pos]:Clip1()
            local clip2 = ply:GetAmmoCount( slotWep[pos]:GetPrimaryAmmoType() )
            local clip3 = ply:GetAmmoCount( slotWep[pos]:GetSecondaryAmmoType() )

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

        if not ply:Alive() or table.IsEmpty( wepWheel.wepTable ) then return end
        
        local slot = wepWheel.selected

        if wepWheel.selected < 0 then
            local active = wepWheel.activeWeapon
            slot = active.slot or 0

            if not table.IsEmpty( active ) then            
                for v, k in ipairs( wepWheel.wepTable[slot] ) do
                    if k:IsValid() and active.wep:IsValid() then
                        if k:GetClass() == active.wep:GetClass() then
                            wepWheel.selectedTable[slot] = v
                        end
                    end
                end
            end
        end

        local slotWep = wepWheel.wepTable[slot]
        local pos = wepWheel.selectedTable[slot]

        if slotWep == nil then return end

        local count = table.Count( slotWep )

        if wepWheel.selectedTable[slot] > count then
            wepWheel.selectedTable[slot] = count > 0 and count or 1
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

    wepWheel.panel:Hide()
end

-- show selection wheel --
function Show()

    if vgui.CursorVisible() then return end

    if IsValid( wepWheel.panel ) and wepWheel.panel:IsVisible() then return end

    if IsValid( g_ContextMenu ) and g_ContextMenu:IsVisible() then return end
    
    if IsValid( g_SpawnMenu ) && g_SpawnMenu:IsVisible() then return end

    if not LocalPlayer():Alive() or LocalPlayer():InVehicle() then return end

    if wepWheel.wepWheelShoudReCreate and IsValid( wepWheel.panel ) then

        wepWheel.panel:Remove()
        Create()
    end

    wepWheel.panel:Show()

    wepWheel.isOpened = true
end

-- hide selection wheel --
function Hide()
    if IsValid( wepWheel.panel ) and wepWheel.panel:IsVisible() then

        if wepWheel.selected >= 0 and LocalPlayer():Alive() then

            local slotWep = wepWheel.wepTable[wepWheel.selected]
            local pos = wepWheel.selectedTable[wepWheel.selected]

            if not (pos <= 0) and not table.IsEmpty( slotWep ) then
                if slotWep[pos]:IsValid() then
                    RunConsoleCommand( "use", slotWep[pos]:GetClass() )
                  
                end
            end
        end

        gui.EnableScreenClicker(false)
        
        //wepWheel.SoundPlaySingle( wepWheel.sound.close, nil, )

        wepWheel.panel:Hide()
        wepWheel.isOpened = false
        wepWheel.onFastOpen = false

    end

    timer.Remove( "wepWheel.NullControlDelay" )
    timer.Create( "wepWheel.NullControlDelay", 0.1, 1, function()
        hook.Remove( "StartCommand", "wepWheel.NullControl" )
    end)

    -- overlay animations --
    hook.Add("Think", "wepWheel.animation", function()
        wepWheel.overlay = Lerp( 10 * FrameTime(), wepWheel.overlay, 0 )
    end)
end

-- Hook's functions --

local delay = 0.05
local shouldOccur = true

local function WasBindPressed( bind )

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

function CreateMove( cmd )

    -- default selection controls --
    if wepWheel.isOpened and not wepWheel.onFastOpen and not wepWheel.onNumsOpen then
        if wepWheel.selected >= 0 then

            local slotWep = wepWheel.wepTable[wepWheel.selected] 
            if slotWep == nil then return end
            
            local pos = wepWheel.selectedTable[wepWheel.selected]
            local count = table.Count(slotWep)

            if WasBindPressed( "invprev" ) then 
                
                if shouldOccur then
    
                    wepWheel.selectedTable[wepWheel.selected] = pos + 1

                    if wepWheel.selectedTable[wepWheel.selected] > count then
                        wepWheel.selectedTable[wepWheel.selected] = 1
                    end
                    
                    if count > 1 then
                        surface.PlaySound(wepWheel.sound.switch2)
                    end

                    shouldOccur = false

                    timer.Simple( delay, function() shouldOccur = true end )
                end
            end
        
            if WasBindPressed( "invnext" ) then

                if shouldOccur then
        
                    wepWheel.selectedTable[wepWheel.selected] = pos - 1
                    
                    if wepWheel.selectedTable[wepWheel.selected] < 1 then
                        wepWheel.selectedTable[wepWheel.selected] = count > 0 and count or 1
                    end

                    if count > 1 then
                        surface.PlaySound(wepWheel.sound.switch2)
                    end

                    shouldOccur = false

                    timer.Simple( delay, function() shouldOccur = true end )
                end
            end
        end

        if WasBindPressed( "+attack" ) then
            Hide()
        end

        return
    end

    if !wepWheel.inAttack2 and !wepWheel.inAttack and !wepWheel.inUse then

        -- create table if it's isn't created --
        if !wepWheel.firstCreationBool then
            Create()
            wepWheel.firstCreationBool = true
        end

        local function GetSlotData( slot )
            local slotWep = wepWheel.wepTable[wepWheel.selected] 
            if slotWep == nil then return nil end
            
            local pos = wepWheel.selectedTable[wepWheel.selected]
            local count = table.Count(slotWep)

            return pos, count
        end

        -- scrool wheel input --
        if WasBindPressed( "invprev" ) then
            
            Show()

            if wepWheel.isOpened then
                wepWheel.onFastOpen = true

                if shouldOccur then


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
                            surface.PlaySound(wepWheel.sound.switch2)
                        end

                    end

                    local count = 0

                    while wepWheel.selected == -1 or table.IsEmpty( wepWheel.wepTable[wepWheel.selected] ) do

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
                    Hide()
                end)

                hook.Add( "StartCommand", "wepWheel.NullControl", function( ply, cmd )
                    cmd:RemoveKey( IN_ATTACK )
                end)
            end
        end

        if WasBindPressed( "invnext" ) then

            Show()

            if wepWheel.isOpened then

                wepWheel.onFastOpen = true
                
                if shouldOccur then

                    local shouldSetToCount = false

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
                            surface.PlaySound(wepWheel.sound.switch2)
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
                    Hide()
                end)

                hook.Add( "StartCommand", "wepWheel.NullControl", function( ply, cmd )
                    cmd:RemoveKey( IN_ATTACK )
                end)
            end
        end

        if WasBindPressed( "+attack" ) then
            
            Hide()

            timer.Remove( "wepWheel.FastOpenHide" )

            wepWheel.onNumsOpen = false
        end
    end

    -- SWITCHING BY NUMBERS --

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

            Show()

            local previous = wepWheel.selected
            wepWheel.selected = slotKey

            if table.IsEmpty( wepWheel.wepTable[wepWheel.selected] ) then
                wepWheel.selected = -1
            end

            hook.Add( "StartCommand", "wepWheel.NullControl", function( ply, cmd )
                cmd:RemoveKey( IN_ATTACK )
            end)

            if wepWheel.onNumsOpen and previous == wepWheel.selected then
                
                local slotWep = wepWheel.wepTable[wepWheel.selected] 
                if slotWep == nil then return end
                
                local pos = wepWheel.selectedTable[wepWheel.selected]
                local count = table.Count(slotWep)

                wepWheel.selectedTable[wepWheel.selected] = pos + 1

                if wepWheel.selectedTable[wepWheel.selected] > count then
                    wepWheel.selectedTable[wepWheel.selected] = 1
                end
                
                if count > 1 then
                    surface.PlaySound(wepWheel.sound.switch2)
                end

            end

            timer.Remove( "wepWheel.FastOpenHide" )
            timer.Create( "wepWheel.FastOpenHide", 1, 1, function() 
                Hide()
                wepWheel.onNumsOpen = false
            end)

            wepWheel.onNumsOpen = true
        end
    end

    local keys = {
        ["slot1"] = 0, ["slot2"] = 1, ["slot3"] = 2, 
        ["slot4"] = 3, ["slot5"] = 4, ["slot6"] = 5, 
    }

    for key = 1, 161 do
        if not keys[input.LookupKeyBinding( key )] then continue end

        if input.WasKeyPressed( key ) or input.WasMousePressed( key ) then

            local bind = input.LookupKeyBinding( key )
            local ply = LocalPlayer()

            if not hook.Run( "PlayerBindPress", ply, bind ) then

                if shouldOccur then
                    OpenNumsSelection( keys[input.LookupKeyBinding(key)] )

                    shouldOccur = false
                    timer.Simple( 0.1, function() shouldOccur = true end )
                end
            end
        end
    end
    
end

local currentBool, previousBool = false, false

function Think()

    -- for blocking this keys when wepWheel is opened --
    wepWheel.inAttack2 = IsKeyDown( "+attack" )
    wepWheel.inAttack = IsKeyDown( "+attack2" )
    wepWheel.inUse = IsKeyDown( "+use" )

    local ply = LocalPlayer()

    if wepWheel.isOpened or wepWheel.onFastOpen then

        -- important 'globals' --
        wepWheel.wepTable = GetWepTable( ply )
        wepWheel.activeWeapon = GetActiveWep( ply )

        -- sound play --
        if wepWheel.selected ~= wepWheel.preselected then
            if wepWheel.selected ~= -1 then
                surface.PlaySound(wepWheel.sound.switch1)
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
            if not table.IsEmpty( wepWheel.wepTable[index] ) then
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

    -- open default selection --
    currentBool = input.IsKeyDown( 17 ) or input.IsMouseDown( 17 )

    if currentBool ~= previousBool then

        local ply = LocalPlayer()

        if currentBool then
            if not wepWheel.firstCreationBool then
                Create()
                wepWheel.firstCreationBool = true
            end

            Show()

            if ply:Alive() and not vgui.CursorVisible() and not ply:InVehicle() then
                -- overlay animations --
                hook.Add("Think", "wepWheel.animation", function()
                    wepWheel.overlay = Lerp( 10 * FrameTime(), wepWheel.overlay, 1 )
                end)
            end

            wepWheel.onFastOpen = false
            wepWheel.onNumsOpen = false
            timer.Remove( "wepWheel.FastOpenHide" )
        else
            Hide()
        end
    
        gui.EnableScreenClicker(wepWheel.isOpened)
    
        previousBool = currentBool
    end

    if not LocalPlayer():Alive() then Hide() end
end

local previousReso, currentReso = 0, 0

-- check if resolution changed --
hook.Add("Think", "wepWheel.ResolutionCheck", function()
    currentReso = ScrW() * ScrH()

    if currentReso ~= previousReso then
        Create()
        previousReso = currentReso
    end
end)

InitWeaponWheel()