-- GGE SCANNER v1.0 (No Hooks, No Freezes)
-- Этот скрипт просто ищет RemoteEvents в игре, не мешая её работе.

local function ScanRemotes()
    print("--- [GGE REMOTE SCAN START] ---")
    local foundCount = 0
    
    -- Рекурсивный поиск всех RemoteEvent в игре
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            foundCount = foundCount + 1
            print("Found Remote: " .. obj.Name .. " | Path: " .. obj:GetFullName())
        end
    end
    
    print("--- [SCAN FINISHED: Found " .. foundCount .. " remotes] ---")
end

-- Запуск в отдельном потоке, чтобы вообще не влиять на игру
task.spawn(function()
    local success, err = pcall(ScanRemotes)
    if not success then
        print("Scan Error: " .. tostring(err))
    end
end)
