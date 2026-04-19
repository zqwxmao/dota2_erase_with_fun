require("match3_game")

if CMatch3GameMode == nil then
    CMatch3GameMode = class({})
end

function Precache(context)
end

function Activate()
    GameRules.Match3Mode = CMatch3GameMode()
    GameRules.Match3Mode:InitGameMode()
end

function CMatch3GameMode:InitGameMode()
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:SetHeroSelectionTime(0)
    GameRules:SetStrategyTime(0)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPreGameTime(0)
    GameRules:SetPostGameTime(30)
    GameRules:SetStartingGold(0)
    GameRules:SetGoldPerTick(0)
    GameRules:SetGoldTickTime(999)
    GameRules:SetTreeRegrowTime(999)
    GameRules:SetUseUniversalShopMode(false)

    local mode = GameRules:GetGameModeEntity()
    mode:SetAnnouncerDisabled(true)
    mode:SetFogOfWarDisabled(true)
    mode:SetDaynightCycleDisabled(true)
    mode:SetKillingSpreeAnnouncerDisabled(true)
    mode:SetRemoveIllusionsOnDeath(true)
    mode:SetBuybackEnabled(false)
    mode:SetTopBarTeamValuesOverride(true)
    mode:SetTopBarTeamValuesVisible(false)

    local hudElements = {
        DOTA_HUD_VISIBILITY_TOP_TIMEOFDAY,
        DOTA_HUD_VISIBILITY_TOP_HEROES,
        DOTA_HUD_VISIBILITY_TOP_SCOREBOARD,
        DOTA_HUD_VISIBILITY_ACTION_PANEL,
        DOTA_HUD_VISIBILITY_ACTION_MINIMAP,
        DOTA_HUD_VISIBILITY_INVENTORY_PANEL,
        DOTA_HUD_VISIBILITY_INVENTORY_SHOP,
        DOTA_HUD_VISIBILITY_INVENTORY_ITEMS,
        DOTA_HUD_VISIBILITY_INVENTORY_QUICKBUY,
        DOTA_HUD_VISIBILITY_INVENTORY_COURIER,
        DOTA_HUD_VISIBILITY_INVENTORY_PROTECT,
        DOTA_HUD_VISIBILITY_INVENTORY_GOLD,
        DOTA_HUD_VISIBILITY_SHOP_SUGGESTEDITEMS,
        DOTA_HUD_VISIBILITY_TOP_MENU_BUTTONS,
        DOTA_HUD_VISIBILITY_KILL_CAM,
    }
    for _, element in pairs(hudElements) do
        if element ~= nil then
            mode:SetHUDVisible(element, false)
        end
    end

    self.match3Games = {}

    ListenToGameEvent("npc_spawned", Dynamic_Wrap(CMatch3GameMode, "OnNPCSpawned"), self)
    CustomGameEventManager:RegisterListener("match3_swap_request", function(userID, data)
        self:OnSwapRequest(data)
    end)
    CustomGameEventManager:RegisterListener("match3_request_board", function(userID, data)
        self:OnRequestBoard(data)
    end)
end

function CMatch3GameMode:OnNPCSpawned(event)
    local unit = EntIndexToHScript(event.entindex)
    if not unit or not unit:IsRealHero() then return end

    local playerID = unit:GetPlayerID()
    if self.match3Games[playerID] then return end

    unit:AddNoDraw()

    local game = Match3Game()
    game:Init(playerID)
    self.match3Games[playerID] = game
end

function CMatch3GameMode:OnSwapRequest(data)
    local playerID = data.PlayerID
    local game = self.match3Games[playerID]
    if not game then return end
    game:TrySwap(data.row1, data.col1, data.row2, data.col2)
end

function CMatch3GameMode:OnRequestBoard(data)
    local playerID = data.PlayerID
    local game = self.match3Games[playerID]
    if not game then return end
    game:SyncBoardToClient()
end
