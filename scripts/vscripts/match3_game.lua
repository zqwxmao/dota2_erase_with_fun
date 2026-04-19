if Match3Game == nil then
    Match3Game = class({})
end

BOARD_SIZE = 10
NUM_HERO_TYPES = 8

HERO_NAMES = {
    "npc_dota_hero_axe",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_pudge",
    "npc_dota_hero_invoker",
    "npc_dota_hero_antimage",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_furion"
}

function Match3Game:Init(playerID)
    self.playerID = playerID
    self.board = {}
    self.score = 0
    self.combo = 0
    self.isProcessing = false
    self:GenerateBoard()
end

function Match3Game:GenerateBoard()
    for row = 1, BOARD_SIZE do
        self.board[row] = {}
        for col = 1, BOARD_SIZE do
            self.board[row][col] = self:GetRandomTypeNoMatch(row, col)
        end
    end
end

function Match3Game:GetRandomTypeNoMatch(row, col)
    local excluded = {}

    if col >= 3 then
        local left1 = self.board[row][col - 1]
        local left2 = self.board[row][col - 2]
        if left1 and left2 and left1 == left2 then
            excluded[left1] = true
        end
    end

    if row >= 3 then
        local up1 = self.board[row - 1] and self.board[row - 1][col]
        local up2 = self.board[row - 2] and self.board[row - 2][col]
        if up1 and up2 and up1 == up2 then
            excluded[up1] = true
        end
    end

    local available = {}
    for i = 1, NUM_HERO_TYPES do
        if not excluded[i] then
            table.insert(available, i)
        end
    end

    return available[RandomInt(1, #available)]
end

function Match3Game:InBounds(row, col)
    return row >= 1 and row <= BOARD_SIZE and col >= 1 and col <= BOARD_SIZE
end

function Match3Game:Swap(row1, col1, row2, col2)
    local temp = self.board[row1][col1]
    self.board[row1][col1] = self.board[row2][col2]
    self.board[row2][col2] = temp
end

function Match3Game:TrySwap(row1, col1, row2, col2)
    if self.isProcessing then return end

    if not self:InBounds(row1, col1) or not self:InBounds(row2, col2) then
        self:SendEvent("match3_swap_rejected", {})
        return
    end

    local dr = math.abs(row1 - row2)
    local dc = math.abs(col1 - col2)
    if not ((dr == 1 and dc == 0) or (dr == 0 and dc == 1)) then
        self:SendEvent("match3_swap_rejected", {})
        return
    end

    self:Swap(row1, col1, row2, col2)

    local matches = self:FindMatches()
    if #matches == 0 then
        self:Swap(row1, col1, row2, col2)
        self:SendEvent("match3_swap_rejected", {})
        return
    end

    self.isProcessing = true
    self.combo = 0
    self:ResolveMatches(matches)
end

function Match3Game:ResolveMatches(matches)
    self.combo = self.combo + 1

    local baseScore = #matches * 10
    local comboMultiplier = self.combo
    self.score = self.score + baseScore * comboMultiplier

    for _, cell in ipairs(matches) do
        self.board[cell.row][cell.col] = 0
    end

    self:ApplyGravity()
    self:FillEmpty()

    local newMatches = self:FindMatches()
    if #newMatches > 0 then
        self:ResolveMatches(newMatches)
    else
        self.isProcessing = false
        self:SyncBoardToClient()
    end
end

function Match3Game:FindMatches()
    local matched = {}
    for row = 1, BOARD_SIZE do
        matched[row] = {}
        for col = 1, BOARD_SIZE do
            matched[row][col] = false
        end
    end

    for row = 1, BOARD_SIZE do
        local col = 1
        while col <= BOARD_SIZE do
            local heroType = self.board[row][col]
            if heroType == 0 then
                col = col + 1
            else
                local count = 1
                while col + count <= BOARD_SIZE and self.board[row][col + count] == heroType do
                    count = count + 1
                end
                if count >= 3 then
                    for i = 0, count - 1 do
                        matched[row][col + i] = true
                    end
                end
                col = col + count
            end
        end
    end

    for col = 1, BOARD_SIZE do
        local row = 1
        while row <= BOARD_SIZE do
            local heroType = self.board[row][col]
            if heroType == 0 then
                row = row + 1
            else
                local count = 1
                while row + count <= BOARD_SIZE and self.board[row + count][col] == heroType do
                    count = count + 1
                end
                if count >= 3 then
                    for i = 0, count - 1 do
                        matched[row + i][col] = true
                    end
                end
                row = row + count
            end
        end
    end

    local results = {}
    for row = 1, BOARD_SIZE do
        for col = 1, BOARD_SIZE do
            if matched[row][col] then
                table.insert(results, { row = row, col = col })
            end
        end
    end

    return results
end

function Match3Game:ApplyGravity()
    for col = 1, BOARD_SIZE do
        local writeRow = BOARD_SIZE
        for readRow = BOARD_SIZE, 1, -1 do
            if self.board[readRow][col] ~= 0 then
                if writeRow ~= readRow then
                    self.board[writeRow][col] = self.board[readRow][col]
                    self.board[readRow][col] = 0
                end
                writeRow = writeRow - 1
            end
        end
    end
end

function Match3Game:FillEmpty()
    for row = 1, BOARD_SIZE do
        for col = 1, BOARD_SIZE do
            if self.board[row][col] == 0 then
                self.board[row][col] = RandomInt(1, NUM_HERO_TYPES)
            end
        end
    end
end

function Match3Game:BoardToString()
    local str = ""
    for row = 1, BOARD_SIZE do
        for col = 1, BOARD_SIZE do
            str = str .. tostring(self.board[row][col])
        end
    end
    return str
end

function Match3Game:HasValidMoves()
    for row = 1, BOARD_SIZE do
        for col = 1, BOARD_SIZE do
            if col < BOARD_SIZE then
                self:Swap(row, col, row, col + 1)
                local matches = self:FindMatches()
                self:Swap(row, col, row, col + 1)
                if #matches > 0 then return true end
            end
            if row < BOARD_SIZE then
                self:Swap(row, col, row + 1, col)
                local matches = self:FindMatches()
                self:Swap(row, col, row + 1, col)
                if #matches > 0 then return true end
            end
        end
    end
    return false
end

function Match3Game:SyncBoardToClient()
    local hasValidMoves = self:HasValidMoves()

    if not hasValidMoves then
        self:GenerateBoard()
    end

    self:SendEvent("match3_board_update", {
        board = self:BoardToString(),
        score = self.score,
        combo = self.combo,
        no_moves = not hasValidMoves
    })
end

function Match3Game:SendEvent(eventName, data)
    local player = PlayerResource:GetPlayer(self.playerID)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, eventName, data)
    end
end
