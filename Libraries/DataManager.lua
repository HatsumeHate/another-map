do


    local Alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local CyrillicAlphabet = "йцукенгшщзхъфывапролджэюбьтимсчяёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЮБЬТИМСЧЯ"
    local ConvAlphabet     = "abcdefghijklmnopqrstuvwxyz12345678"
    local LoadBuffer
    local CA = 0
    local CAUP = 0
    local RA = 0
    PlayerSyncData = nil
    PlayerPackages = nil
    SaveDataPath = "CastleRevival\\"


    function IsCyrillic(str)
        for i = 1, #str do
            for k = 1, #CyrillicAlphabet do
                if string.match(string.lower(string.sub(str, i, i+1)), string.sub(CyrillicAlphabet,k, k+1)) ~= nil then
                    return true
                end
            end
        end
        return false
    end


    function ConvertToCyrillic(str)
        local new_str = ""

        for i = 1, #str do
            local char = SubString(str, i-1, i)
            --print("char " .. char)

                for k = 1, #RA do
                    if RA[k] == char then
                        new_str = new_str .. CA[k]
                    end
                end

        end
        return new_str
    end


    function ConvertFromCyrillic(str)

        for i = 1, #str do
            local char = SubString(str, i-1, i+1)

                for k = 1, #CA do
                    if CA[k] == char or CAUP[k] == char then
                        str = string.gsub(str, char, RA[k])
                    end
                end

        end

        return str
    end

    function lsh(value,shift)
        return (value*(2^shift)) %% 256
    end

    function rsh(value,shift)
        return math.floor(value/2^shift) %% 256
    end

    function bit(x,b)
        return (x %% 2^b - x %% 2^(b-1) > 0)
    end

    function lor(x,y)
        local result = 0
        for p=1,8 do result = result + (((bit(x,p) or bit(y,p)) == true) and 2^(p-1) or 0) end
        return result
    end


    local base64chars
    local base64bytes

    function enc(data)
        local bytes = {}
        local result = ""
        for spos=0,string.len(data)-1,3 do
            for byte=1,3 do bytes[byte] = string.byte(string.sub(data,(spos+byte))) or 0 end
            result = string.format('%%s%%s%%s%%s%%s',result,base64chars[rsh(bytes[1],2)],base64chars[lor(lsh((bytes[1] %% 4),4), rsh(bytes[2],4))] or "=",((#data-spos) > 1) and base64chars[lor(lsh(bytes[2] %% 16,2), rsh(bytes[3],6))] or "=",((#data-spos) > 2) and base64chars[(bytes[3] %% 64)] or "=")
        end
        return result
    end




    function dec(data)
        local chars = {}
        local result=""
        for dpos=0,string.len(data)-1,4 do
            for char=1,4 do chars[char] = base64bytes[(string.sub(data,(dpos+char),(dpos+char)) or "=")] end
            result = string.format('%%s%%s%%s%%s',result,string.char(lor(lsh(chars[1],2), rsh(chars[2],4))),(chars[3] ~= nil) and string.char(lor(lsh(chars[2],4), rsh(chars[3],2))) or "",(chars[4] ~= nil) and string.char(lor(lsh(chars[3],6) %% 192, (chars[4]))) or "")
        end
        return result
    end





    function AddToBuffer(value)

        if not LoadBuffer then LoadBuffer = {} end

        LoadBuffer[#LoadBuffer+1] = value

    end

    function GetFileSlot(code)
        for i = 1, #code do
            if SubString(code, i - 4, i) == "slot" then
                return S2I(SubString(code, i, i+1))
            end
        end
        return 0
    end

    function FileLoad(path)

            Preloader(path)
            PreloadGenClear()


        local part_1 = BlzGetAbilityTooltip(FourCC("Agyv"), 0)
        local part_2 = BlzGetAbilityTooltip(FourCC("Aroc"), 0)
        local result = part_1..part_2
        local slot = GetFileSlot(path)
        local prefix

        if slot > 0 then
            prefix = "dataload" .. slot
        else
            prefix = "dataload_progression"
        end

        for i = 0, 5 do
            if GetLocalPlayer() == Player(i) then
                BlzSendSyncData(prefix, result)
                --print("send data ".. result .." in slot " .. slot)
            end
        end

    end


    function ParsePlayerNameOut(name)
        return string.gsub(name, "_", "#", 1)
    end

    function ParsePlayerNameIn(name)
        return string.gsub(name, "#", "_", 1)
    end


    function FileOverwrite(player, path, data)
        PreloadGenClear()

        if GetLocalPlayer() == Player(player) then
            Preload("\")\ncall BlzSetAbilityTooltip ('Agyv',\"".. data .. "\",0)" .. "\n//")
            Preload("\")\ncall BlzSetAbilityTooltip ('Aroc',\"".. data .. "\",0)" .. "\n//")
            PreloadGenEnd(path)
        end
    end


    ---@param player integer
    ---@param path string
    ---@param additional_data string
    function FileWrite(player, path, additional_data)
        local name = GetPlayerName(Player(player))

        if IsCyrillic(name) then name = ConvertFromCyrillic(name) end

        local result = ParsePlayerNameIn(name) .. "_"

        if not LoadBuffer then return end

        for i = 1, #LoadBuffer do
            result = result .. LoadBuffer[i]
        end

       --print("string to encode: " ..result)
        result = enc(additional_data..GetFileSlot(path)..result)
       --print("decoded string: " .. result)

        PreloadGenClear()
        local half = math.floor(#result / 2)
        local part_1 = string.sub(result, 1, half)
        local part_2 = string.sub(result, half+1, #result)

        if GetLocalPlayer() == Player(player) then
            Preload("\")\ncall BlzSetAbilityTooltip ('Agyv',\"".. part_1 .. "\",0)" .. "\n//")
            Preload("\")\ncall BlzSetAbilityTooltip ('Aroc',\"".. part_2 .. "\",0)" .. "\n//")
            PreloadGenEnd(path)
            --print("saved!")
        end

        LoadBuffer = nil
    end


    function InitFileData()

        base64chars = {[0]='A',[1]='B',[2]='C',[3]='D',[4]='E',[5]='F',[6]='G',[7]='H',[8]='J',[9]='I',[10]='K',[11]='L',[12]='M',[13]='N',[14]='O',[15]='P',[16]='Q',[17]='R',[18]='T',[19]='S',[20]='U',[21]='W',[22]='V',[23]='X',[24]='Y',[25]='Z',[26]='a',[27]='b',[28]='c',[29]='d',[30]='e',[31]='f',[32]='h',[33]='g',[34]='i',[35]='j',[36]='k',[37]='l',[38]='m',[39]='n',[40]='o',[41]='p',[42]='r',[43]='q',[44]='s',[45]='t',[46]='u',[47]='v',[48]='w',[49]='x',[50]='y',[51]='z',[52]='0',[53]='1',[54]='2',[55]='3',[56]='4',[57]='5',[58]='6',[59]='7',[60]='8',[61]='9',[62]='-',[63]='_'}
        base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['J']=8,['I']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['T']=18,['S']=19,['U']=20,['W']=21,['V']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['h']=32,['g']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['r']=42,['q']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}


        PlayerSyncData = {}
        PlayerPackages = {}

        local trigger = CreateTrigger()

        for i = 0, 5 do

            for k = 1, 7 do
                BlzTriggerRegisterPlayerSyncEvent(trigger, Player(i), "dataload" .. k, false)
            end

            BlzTriggerRegisterPlayerSyncEvent(trigger, Player(i), "dataload_progression", false)

            PlayerSyncData[i+1] = {
                [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false
            }
        end

        TriggerAddAction(trigger, function()
            --print("sync event!")
            local sync_string = dec(BlzGetTriggerSyncData())
            --print("decoded")
            local slot = GetFileSlot(sync_string)

            --print("sync to load" .. sync_string)

            --print("slot is " .. slot)

                if slot > 0 then
                    --print("its a slot with data " .. sync_string)
                    local begin = string.find(sync_string, "slot", 1, true)+5
                    local delc = string.find(sync_string, "_-a", begin, true)
                    local player = ParsePlayerNameOut(string.sub(sync_string, begin, delc-1))--SubString(sync_string, 5, delc-3))

                    --print("got data to sync from player " .. player .. " in slot ".. slot)
                    --print("slot is " .. (slot or "NOT SUPPOSED TO HAPPEN"))

                        if StringLength(sync_string) > 1 then
                            sync_string = string.sub(sync_string, delc, #sync_string)
                        else
                            sync_string = ""
                        end

                       -- print("data is " .. (sync_string or "NOT SUPPOSED TO HAPPEN"))

                        for i = 0, 5 do
                            local name = GetPlayerName(Player(i))
                            if #name > 0 then

                                if IsCyrillic(name) then name = ConvertFromCyrillic(name) end

                                if name == player and not PlayerSyncData[i+1][slot] and #sync_string > 1 then
                                    LoadItem(sync_string, i+1, slot)
                                    PlayerSyncData[i+1][slot] = true
                                    break
                                end
                            end
                            --print("name")

                        end

                elseif BlzGetTriggerSyncPrefix() == "dataload_progression" then
                    local player = ParsePlayerNameOut(string.sub(sync_string, 2, string.find(sync_string, "@", 1, true)-2))

                    --print("player name to load " .. player)

                        for i = 0, 5 do
                            local name = GetPlayerName(Player(i))
                            if #name > 0 then

                                if IsCyrillic(name) then name = ConvertFromCyrillic(name) end

                                if name == player and not PlayerSyncData[i+1]["current_wave"] and #sync_string > 1 then
                                    --LoadItem(sync_string, i+1, slot)

                                    PlayerSyncData[i+1]["current_wave"] = string.sub(sync_string, string.find(sync_string, "@currentwave", 1, true)+12, #sync_string)
                                    break
                                end
                            end
                            --print("name")

                        end
                end

        end)

        BlzSetAbilityTooltip(FourCC("Agyv"),"", 0)
        BlzSetAbilityTooltip(FourCC("Aroc"),"", 0)


        CA      = { "й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "ъ", "ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "ё", }
        CAUP    = { "Й", "Ц", "У", "К", "Е", "Н", "Г", "Ш", "Щ", "З", "Х", "Ъ", "Ф", "Ы", "В", "А", "П", "Р", "О", "Л", "Д", "Ж", "Э", "Я", "Ч", "С", "М", "И", "М", "Ь", "Б", "Ю", "Ё", }
        RA      = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", }

    end



end