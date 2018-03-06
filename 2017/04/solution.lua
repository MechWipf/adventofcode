local utils = dofile "x:\\Notizen\\OtherStuff\\utils.lua"

local function main ()
    local validCount = 0

    for line in io.lines "x:\\Notizen\\OtherStuff\\advent\\04\\input.txt" do
        local words = {}
        local matchWords = {}

        valid = true
        for _, word in pairs( line:explode " " ) do
            local chars = {}
            for i = 1, word:len(), 1 do
                chars[i] = word:sub(i,i)
            end
            table.sort(chars)

            local checkWord = table.concat( chars, "" )
            if not matchWords[checkWord] then
                matchWords[checkWord] = true
            else
                valid = false
                break
            end

            words[k] = checkWord
        end

        if valid then validCount = validCount + 1 print( table.concat(words, " ") ) end
    end
end

local ok, err = pcall(main)
if not ok and err then
    print(err)
end