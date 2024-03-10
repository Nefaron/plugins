--Пак включает в себя:
--Autoinvite
--Combat_loot
--Dragonriding
--Flask
--Led
--Overloads
--Posadka_semeni
--Random_move
--Rogue_vanish_dragonriding
--Sharpener
--Skip_nodes_in_caves
--Hide_quantum_frame
--Skip_shitty_mobs
--Webhook_discord_stucks

-------------------------------------------------------Autoinvite-------------------------------------------------------
C_Timer.NewTicker(60, function ()
    if GMR.IsExecuting() then
        local unit, realm = UnitFullName("player")
        local full_name = unit .. "-" .. realm
        if full_name == "Lentharia-Draenor" then
            local characters_to_invite = {
            "Пусямуська-Ревущийфьорд","Укралиакк-Ревущийфьорд","Яростьветра-Ревущийфьорд",
            "Джьэкки-Ревущийфьорд","Котролль-Ревущийфьорд","Гренкасала-Ревущийфьорд",
            "Лакрона-Ревущийфьорд","Троллиса-Ревущийфьорд","Друледед-Ревущийфьорд",
            "Анира-Ревущийфьорд", "Рэнчи-Ревущийфьорд"}
            for k, v in pairs(characters_to_invite) do
                if not UnitInParty(v) then
                    if GetNumGroupMembers() >= 2 then
                        C_PartyInfo.ConvertToRaid()
                        C_PartyInfo.ConfirmConvertToRaid()
                        C_PartyInfo.InviteUnit(v)
                    else
                        C_PartyInfo.InviteUnit(v)
                    end
                end
            end
        end
    end
end)


C_Timer.NewTicker(0.1, function()
    if GMR.IsExecuting() then
        if not IsInGroup() then
            if not IsInRaid() then
                local frame = CreateFrame("FRAME")
                frame:RegisterEvent("PARTY_INVITE_REQUEST")
                frame:SetScript("OnEvent", function(self, event, sender)
                    if sender == "Lentharia-Draenor" then
                        AcceptGroup()
                        StaticPopup_Hide("PARTY_INVITE")
                    end
                end)
            end
        end
    end
end)
-------------------------------------------------------Autoinvite-------------------------------------------------------

-------------------------------------------------------Combat_loot------------------------------------------------------
C_Timer.NewTicker(0.5, function()
	if GMR.IsExecuting() and GMR.InCombat("player") then 
		for i = 1, #GMR.Tables.Lootables do
			local lootable = GMR.Tables.Lootables[i][1]
			if GMR.GetDistance("player", lootable, "<", 5) and 
            GMR.IsObjectLootable(lootable) and GMR.GetInventorySpace() > GMR.GetMinimumInventorySpace() then
				GMR.InteractObject(lootable)
				GMR.SetDelay("Execute", 0.8)
			end
		end
		for i = 1, #GMR.Tables.Nodes do
			local gatherable = GMR.Tables.Nodes[i][1]
			if GMR.GetDistance("player", gatherable, "<", 7) and 
            GMR.IsNodeInteractable(gatherable) then
				GMR.InteractObject(gatherable)
				GMR.SetDelay("Execute", 3)
			end
		end
	end
end)
-------------------------------------------------------Combat_loot------------------------------------------------------

-------------------------------------------------------Dragonriding-----------------------------------------------------
C_Timer.NewTicker(.1, function()
    local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
	local base = isGliding and forwardSpeed or GetUnitSpeed("player")
	local movespeed = Round(base / BASE_MOVEMENT_SPEED * 100)
    local vigor = UnitPower("player", Enum.PowerType.AlternateMount)
    local surge_forward = GetSpellInfo(372608)              -- Рывок вперед
    local second_wind = GetSpellInfo(425782)                -- Второе дыхание
    local skyward_ascent = GetSpellInfo(372610)             -- Взлет вверх
    local aerial_halt = GetSpellInfo(403092)                -- Остановка в воздухе
    local thrill_of_the_skies_buff = GetSpellInfo(377234)   -- Бафф "Азарт небес"

    local currentCharges, maxCharges, cooldownStart, cooldownDuration, chargeModRate = GetSpellCharges(425782) -- Заряды второго дыхания

    if GMR.IsExecuting() then
        if IsMounted() and IsFlying() then

            --if GMR.HasBuff("player", thrill_of_the_skies_buff, false) then
            --    local node = GMR.GetNode()
            --    if node ~= nil then
            --        local node_distance = GMR.GetDistance("player", node, "<", 40) GMR.GetNode()
            --        if node_distance then
            --            if GMR.IsSpellKnown(aerial_halt) and GMR.IsCastable(aerial_halt) then
            --                GMR.Cast(aerial_halt)
            --            end    
            --        end
            --    end               
            --end

            if vigor > 3 and GMR.IsSpellKnown(surge_forward) and GMR.IsCastable(surge_forward) and 40 < forwardSpeed and forwardSpeed < 64 then 
                GMR.Cast(surge_forward)
            end
            if vigor < 3 and GMR.IsSpellKnown(second_wind) and GMR.IsCastable(second_wind) then
                if not GMR.InCombat("player") and  currentCharges > 1 and IsFlying() then 
                    GMR.Cast(second_wind)
                elseif GMR.InCombat("player") and  currentCharges > 0 then
                    GMR.Cast(second_wind)
                end
            end
        elseif IsMounted() and not IsFlying() then
            if vigor > 0 and GMR.IsSpellKnown(skyward_ascent) and GMR.IsCastable(skyward_ascent) and (GMR.GetNumEnemies("player", 10) >= 3 or UnitClassification("anyenemy") == "elite") then
                GMR.Cast(skyward_ascent)
            end 
        end
    end
end)
-------------------------------------------------------Dragonriding-----------------------------------------------------

-------------------------------------------------------Flask------------------------------------------------------------
C_Timer.NewTicker(0.1, function()
    -- Spells
    local DarkmoonBuff = GetSpellInfo(185562)
    local PhialofPerceptionBuff1 = GetSpellInfo(393716)
    local PhialofPerceptionBuff2 = GetSpellInfo(393715)
    local PhialofPerceptionBuff3 = GetSpellInfo(371454)

    --API
    local affectingCombat = UnitAffectingCombat("player")


    --Items
    local DarkmoonFirewater = GetItemInfo(124671)
    local PhialofPerception1 = GetItemInfo(191354)
    local PhialofPerception3 = GetItemInfo(191356)
    local PhialofPerception2 = GetItemInfo(191355)

    if not GMR.IsUnitFlying("player") == true and GMR.IsExecuting() and not GMR.InCombat("player", true) and not GMR.UnitIsDeadOrGhost("player") then
        if not GMR.HasPlayerBuff("player", DarkmoonBuff) and
            GetItemCooldown(124671) == 0 and
            GMR.GetContainerItemCount(DarkmoonFirewater) > 0 then
            GMR.Use(DarkmoonFirewater)
            print("Use Darkmoon Firewater")
        end
        if not GMR.HasPlayerBuff("player", PhialofPerceptionBuff1) and
            not GMR.HasPlayerBuff("player", PhialofPerceptionBuff2) and
            not GMR.HasPlayerBuff("player", PhialofPerceptionBuff3) and
            GetItemCooldown(191356) == 0 and
            GMR.GetContainerItemCount(PhialofPerception3) > 0 then
            GMR.Use(PhialofPerception3)
            print("Use Phial of Perception #3")
        end
        if not GMR.HasPlayerBuff("player", PhialofPerceptionBuff1) and
            not GMR.HasPlayerBuff("player", PhialofPerceptionBuff2) and
            not GMR.HasPlayerBuff("player", PhialofPerceptionBuff3) and
            GetItemCooldown(191355) == 0 and
            GMR.GetContainerItemCount(PhialofPerception2) > 0 then
            GMR.Use(PhialofPerception2)
            print("Use Phial of Perception #2")
        end
        if not GMR.HasPlayerBuff("player", PhialofPerceptionBuff1) and
            not GMR.HasPlayerBuff("player", PhialofPerceptionBuff2) and
            not GMR.HasPlayerBuff("player", PhialofPerceptionBuff3) and
            GetItemCooldown(191354) == 0 and
            GMR.GetContainerItemCount(PhialofPerception1) > 0 then
            GMR.Use(PhialofPerception1)
            print("Use Phial of Perception #3")
        end
    end
end)
-------------------------------------------------------Flask------------------------------------------------------------

-------------------------------------------------------Led--------------------------------------------------------------
C_Timer.NewTicker(0.5, function()
    local herb_gather = GetSpellInfo(366252)
    local objectlist = GMR.GetNearbyObjects(50)
    local overloadedfrost = GMR.GetObjectWithInfo({id = 197397, rawType = 5})
    if GMR.IsExecuting() and not GMR.UnitIsDeadOrGhost("player") and not IsCurrentSpell(390392) then 
        if GMR.GetDistance("player", overloadedfrost, "<", 50) then 
            GMR.SetChecked("DragonRidingMount", false) 
            GMR.Tables.Nodes = {}  
            GMR.TargetUnit(overloadedfrost)
            inei_buff = GetSpellInfo(390758)  
            if GMR.HasBuff("target", inei_buff, false) and GMR.GetHealth("target") > 0 then  
                local x, y, z = GMR.ObjectPosition(overloadedfrost) 
                local distplayerobjectzemlya = GMR.IsPlayerPosition(x, y, z, 5)  
                if not distplayerobjectzemlya then 
                    GMR.MeshTo(x, y, z)
                    GMR.SetDelay("Execute", 3)
                else 
                    className, classFilename, classId = UnitClass("player")
                    if classId == 11 then 
                        GMR.Shapeshift("Combat")
                    end
                    if not GMR.InCombat("player") then  
                        GMR.FaceDirection(x, y, z)
                        GMR.StartAttack()
                        GMR.Dismount()
                    end
                    if distplayerobjectzemlya and IsMounted() then 
                        GMR.Dismount()
                    end
                    GMR.Fight()  
                end
            end
        else
            GMR.SetChecked("DragonRidingMount", true)  
        end
    end
end)
-------------------------------------------------------Led--------------------------------------------------------------

-------------------------------------------------------Overloads--------------------------------------------------------
C_Timer.NewTicker(0.1, function ()
    if GMR.IsExecuting() then
        if IsCurrentSpell(388213) then
            local dragonriding_mounts = GMR_SavedVariablesPerCharacter["SelectedDragonRidingMount"]
            GMR.CastSpellByName(dragonriding_mounts)
            GMR.SetDelay("Execute", 0.3)
            GMR.SetDelay("Execute", 10)
            GMR.Print("Overload, Pause GMR")
        end
    end
end)

C_Timer.NewTicker(0.1, function()
    if GMR.IsExecuting() then
        if IsCurrentSpell(390392) then
            
            GMR.Print("Overload, Pause GMR")
            GMR.SetDelay("Execute", 5)
        
        end
        
        local objectlist = {GMR.GetNearbyObjects(50)}
        
        for guid1, object in pairs(objectlist[1]) do
            if object.ID==203919 then	
                local suspiciousspore = GMR.GetObjectWithInfo({
                    id = object.ID})
                local x, y, z = GMR.ObjectPosition(suspiciousspore)
                GMR.MeshTo(x, y, z)
                GMR.SetDelay("Execute", 0.3)
            end
        end
    end
end)
-------------------------------------------------------Overloads--------------------------------------------------------

-------------------------------------------------------Posadka_semeni---------------------------------------------------
C_Timer.NewTicker(0.1, function()
	local semya = GetItemInfo(200508) -- Жаждущее свободы пробужденное семечко
	selfgrown_id = {384293, -- Витая кора - самосейка
					384298, -- Сгнившая витая кора - самосейка
					384294, -- Пузырчатый мак - самосейка
					384295, -- Камнеломка-самосейка
					384291, -- Хоэнвейс-самосейка
					384297, -- Сгнившая камнеломка - самосейка
					384296, -- Сгнивший хоэнвейс-самосейка
					384299	-- Сгнивший пузырчатый мак - самосейка
					}
	if GMR.IsExecuting() and not GMR.UnitIsDeadOrGhost("player") then
        for num, table in pairs(GMR.Tables.Nodes) do  
            for nums, object in pairs(table) do
                for k, v in pairs(selfgrown_id) do			
                    if v == GMR.ObjectId(object) then  
                        object = GMR.GetNearestTableEntry(GMR.Tables.Nodes)  
                        local x, y, z = GMR.ObjectPosition(v)
                        if object ~= nil then
                            if GMR.IsNodeInteractable(v) then  
                                if GMR.GetDistance(v, "player", "<", 6) then  
                                    GMR.InteractObject(v)  
                                    GMR.SetDelay("Execute", 3)
                                    GMR.Tables.Nodes = {}
                                elseif GMR.GetDistance(v, "player", ">", 6) then 
                                    GMR.MeshTo(x, y, z)
                                    GMR.SetDelay("Execute", 3)
                                end
                            end

                        end
                    end
                end
            end
        end

        local objectlist = GMR.GetNearbyObjects(350)  
        for guid1, object in pairs(objectlist) do
            if object.ID==384292 then  
                local objectzemlya = GMR.GetObjectWithInfo({id = object.ID})
                local x, y, z = GMR.ObjectPosition(objectzemlya)
                local distplayerobjectzemlya = GMR.IsPlayerPosition(x, y, z, 5)
                if GMR.GetContainerItemCount(semya) > 0 then
                    if not distplayerobjectzemlya then
                        GMR.MeshTo(x, y, z)
                        GMR.ResetSetObject()
                        GMR.SetDelay("Execute", 3)
                    else 
                        GMR.Dismount()
                        GMR.Use(semya)
                        GMR.SetDelay("Execute", 3)
                        GMR.Tables.Nodes ={}  
                    end
                end
            end
        end
    end
end)
-------------------------------------------------------Posadka_semeni---------------------------------------------------

-------------------------------------------------------Random_move------------------------------------------------------
C_Timer.NewTicker(7, function()
    if GMR.IsExecuting() then
        x10 = GMR.GetPlayerPosition().x
        y10 = GMR.GetPlayerPosition().y
        z10 = GMR.GetPlayerPosition().z
    end
end)
    
C_Timer.NewTicker(40, function()
    if GMR.IsExecuting() then
        x20 = GMR.GetPlayerPosition().x
        y20 = GMR.GetPlayerPosition().y
        z20 = GMR.GetPlayerPosition().z
        dis10 = GMR.GetDistanceBetweenPositions(x10,y10,z10,x20,y20,z20)
    end
end)
    
C_Timer.NewTicker(5, function()
    if GMR.IsExecuting() and not GMR.IsCasting("player") and not GMR.InCombat("player") and dis10 ~= nil and dis10 <= 5 then
        GMR.SetCentralIndex(GMR.GetNearestCentralPoint() + 1)
        local dice = math.random(3, 6)
        x30, y30, z30 = x20-dice, y20+dice, z20
        x40, y40, z40 = x30+dice, y30-dice, z30
        GMR.MeshTo(x30, y30, z30)
        if GMR.IsPlayerPosition(x30, y30, z30, 1) then
            GMR.MeshTo(x40, y40, z40)
        end
        dis10 = 6
    end
end)
-------------------------------------------------------Random_move------------------------------------------------------

-------------------------------------------------------Rogue_vanish_dragonriding----------------------------------------
C_Timer.NewTicker(0.1, function()
    local className, classFilename, classId = UnitClass("player")
    if classId == 4 then -- 4 = разбойник. Проверяем по classID, так как имя класса может отличаться из-за локализации.

        -- Spells
        local vanish = GetSpellInfo(1856)

        if GMR.IsExecuting() and GMR.InCombat("player") and GMR.IsSpellKnown(vanish) and not IsMounted() and GMR.GetSpellCooldown(1856) == 0 then

            if GMR.GetNumEnemies("player", 10) >= 2 or UnitClassification("anyenemy") == "elite" then
                if GetSpellInfo(vanish) and IsUsableSpell(vanish) then
                    GMR.StopAttack()
                    GMR.ClearTarget()  
                    GMR.Cast(vanish)
                    GMR.ResetSetObject()

                    local dragonriding_mounts = GMR_SavedVariablesPerCharacter["SelectedDragonRidingMount"]
                    GMR.CastSpellByName(dragonriding_mounts)
                    GMR.SetDelay("Execute", 0.3)
                end
            end
        end
    end
end)
-------------------------------------------------------Rogue_vanish_dragonriding----------------------------------------

-------------------------------------------------------Sharpener--------------------------------------------------------
function HasEnhancement(slot, enhancement)
    local tooltip = C_TooltipInfo.GetInventoryItem('player', slot)
    if tooltip and tooltip.lines then
        for _, line in pairs(tooltip.lines) do
            if line.leftText and line.leftText:find(enhancement) then
                return true
            end
        end
    end
    return false
end

C_Timer.NewTicker(0.5, function()
    
    local Sharpener = {
        Enchantment = '+20', -- make this localize maybe idk
        --Slots = {
        --    {
        --        ID = 20,
        --        Enabled = true -- should we check this slot
        --        --Button = ProfessionsFrame.CraftingPage.Prof0ToolSlot:Click()
        --    },
        --    {
        --        ID = 23,
        --        Enabled = true -- should we check this slot
        --        --Button = ProfessionsFrame.CraftingPage.Prof1ToolSlot:Click()
        --    }
        --}
    }
    
    local item = GetItemInfo(191949)
    if GMR.IsExecuting() then    
        if not GMR.IsUnitFlying("player") and not GMR.UnitIsDeadOrGhost("player") then
            --for _, slot in ipairs(Sharpener.Slots) do
                --if slot.Enabled and not HasEnhancement(slot.ID, Sharpener.Enchantment) then
                if not HasEnhancement(20, Sharpener.Enchantment) then
                    if GetItemCount(item) > 0 then
                        GMR.UseItemByName(item)
                        --PickupInventoryItem(slot.ID)
                        PickupInventoryItem(20)
                        print('Sharpening')
                        --break
                    end
                end
                if not HasEnhancement(23, Sharpener.Enchantment) then
                    if GetItemCount(item) > 0 then
                        GMR.UseItemByName(item)
                        --PickupInventoryItem(slot.ID)
                        PickupInventoryItem(23)
                        print('Sharpening')
                        --break
                    end
                end
                --end
            --end
        end
    end
end)
-------------------------------------------------------Sharpener--------------------------------------------------------

-------------------------------------------------------Skip_nodes_in_caves----------------------------------------------
C_Timer.NewTicker(1, function()
    if GMR.IsExecuting() then
        for i = 1, #GMR.Tables.Nodes do 
            local gatherable_nodes = GMR.Tables.Nodes[i][1]
            if GMR.IsNodeInteractable(gatherable_nodes) then 
                if GMR.IsObjectIndoors(gatherable_nodes) then 
                    local name_object = GMR.ObjectName(gatherable_nodes)
                    GMR.TempBlacklistSetNode(gatherable_nodes) 
                    --GMR.Tables.Nodes = {}
                end
            end
        end
    end
end)
-------------------------------------------------------Skip_nodes_in_caves----------------------------------------------

-------------------------------------------------------Skip_quantum_frame-----------------------------------------------
C_Timer.NewTicker(1, function()
    if Quantum_Frame and Quantum_Frame:IsVisible() then
        Quantum_Frame:Hide()
    end
end)
-------------------------------------------------------Skip_quantum_frame-----------------------------------------------

-------------------------------------------------------Skip_shitty_mobs-------------------------------------------------
C_Timer.NewTicker(3, function()
    if GMR.IsExecuting() then
        local mob_id = GMR.ObjectId("target")    
        local shitty_mobs = {192657, --бешенка заводи
                            192792,  --чистоводная бешенка
                            187802,  --илистая бешенка
                            190965,  --стервятник клана нокхуд
                            186356,  --стервятник клана нокхуд
                            190156   --стервятник клана нокхуд
                            }
        for _, v in pairs(shitty_mobs) do
            if v == mob_id then
                GMR.TargetUnit("player")      
            end
        end
    end       
end)
-------------------------------------------------------Skip_shitty_mobs-------------------------------------------------

-------------------------------------------------------Webhook_discord_stucks-------------------------------------------
C_Timer.NewTicker(39, function()
    if GMR.IsExecuting() then
        x11 = GMR.GetPlayerPosition().x
        y11 = GMR.GetPlayerPosition().y
        z11 = GMR.GetPlayerPosition().z
    end
end)

C_Timer.NewTicker(77, function()
    if GMR.IsExecuting() then
        x21 = GMR.GetPlayerPosition().x
        y21 = GMR.GetPlayerPosition().y
        z21 = GMR.GetPlayerPosition().z
        dis11 = GMR.GetDistanceBetweenPositions(x11,y11,z11,x21,y21,z21)
    end
end)
    
C_Timer.NewTicker(121, function()
    if GMR.IsExecuting() then
        x31 = GMR.GetPlayerPosition().x
        y31 = GMR.GetPlayerPosition().y
        z31 = GMR.GetPlayerPosition().z
        dis21 = GMR.GetDistanceBetweenPositions(x11,y11,z11,x31,y31,z31)
    end
end)
    
C_Timer.NewTicker(125, function()
    dis31 = GMR.GetDistanceBetweenPositions(x21,y21,z21,x31,y31,z31)
    if GMR.IsExecuting() and dis11 ~= nil and dis11 <= 5 and dis21 ~= nil and dis21 <= 5 and dis31 ~= nil and dis31 <= 5 then
        ---Переменные
        local webhook = GMR.GetDiscordWebhook()
        local finStr = {}
        local divBeginStr = ":.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:\n"
        local divEndStr = ":.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:"

        ---Оформление шапки сообщения
        if divBeginStr then
            table.insert(finStr, divBeginStr)
        end

        ---Текст сообщения      
        if GMR.UnitName("player") then
            table.insert(finStr, ":detective: **BOT:**  `"..tostring(GMR.UnitName("player")) .. " застрял." .. "`\n")
        end

        ---Оформление подвала сообщения
        if divEndStr then
            table.insert(finStr, divEndStr)
        end
        local compiledText = ""
        for i = 1, #finStr do
            compiledText = compiledText .. finStr[i]
        end

        ---Отправка сообщения
        if GMR.GetDiscordWebhook() ~= nil then
            GMR.SendDiscordMessage(compiledText, GMR.GetDiscordWebhook())
        elseif GMR.GetDiscordWebhook() == nil then
            GMR.Print("[sh4gH00k]--{err0r}: No Webhook added in GMR settings.")
        end
        dis11 = 6
        dis21 = 6
        dis31 = 6
    end
end)
-------------------------------------------------------webhook_discord_stucks-------------------------------------------