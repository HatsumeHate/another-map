do


    local Alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local LoadBuffer
    PlayerSyncData = nil
    PlayerPackages = nil



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
        return "0"
    end

    function FileLoad(path)
        local abilcode = FourCC("Agyv")

            print("start loading")
            Preloader(path)
            PreloadGenClear()
            local result = BlzGetAbilityTooltip(abilcode, 0)
            local slot = GetFileSlot(path)

            for i = 0, 5 do
                if GetLocalPlayer() == Player(i) then
                    BlzSendSyncData("dataload" .. slot, result)
                    print("send data ".. result .." in slot " .. slot)
                end
            end

    end


    function ParsePlayerNameOut(name)

        for i = 1, #name do
            if SubString(name, i-1, i) == "_" then
                return SubString(name, 0, i-1) .. "#" .. SubString(name, i, #name)
            end
        end

        return name
    end

    function ParsePlayerNameIn(name)

        for i = 1, #name do
            if SubString(name, i-1, i) == "#" then
                return SubString(name, 0, i-1) .. "_" .. SubString(name, i, #name)
            end
        end

        return name
    end

    function FileOverwrite(player, path, data)
        PreloadGenClear()

        if GetLocalPlayer() == Player(player) then
            Preload("\")\ncall BlzSetAbilityTooltip ('Agyv',\"".. data .. "\",0)" .. "\n//")
            PreloadGenEnd(path)
        end
    end

    function FileWrite(player, path)
        local result = ParsePlayerNameIn(GetPlayerName(Player(player))) .. "_"

        if not LoadBuffer then return end

        for i = 1, #LoadBuffer do
            result = result .. LoadBuffer[i]
        end

        result = enc("slot"..GetFileSlot(path)..result)

        PreloadGenClear()

        if GetLocalPlayer() == Player(player) then
            Preload("\")\ncall BlzSetAbilityTooltip ('Agyv',\"".. result .. "\",0)" .. "\n//")
            PreloadGenEnd(path)
        end

        LoadBuffer = nil
    end


    function GetPlayerNameCode(string)
            local length = #string

                for i = 1, length do
                    if SubString(string, i-1, i) == "_" then
                        for k = i-1, length do
                            if SubString(string, k-1, k) == "_" then
                                return SubString(string, i, k-1)
                            end
                        end
                    end
                end


        return ""
    end


    function GetPlayerNameDeclens(string)
            local length = #string

                for i = 1, length do
                    if SubString(string, i-1, i) == "_" then
                        return i
                    end
                end

        return 0
    end


    function InitFileData()

        base64chars = {[0]='A',[1]='B',[2]='C',[3]='D',[4]='E',[5]='F',[6]='G',[7]='H',[8]='J',[9]='I',[10]='K',[11]='L',[12]='M',[13]='N',[14]='O',[15]='P',[16]='Q',[17]='R',[18]='T',[19]='S',[20]='U',[21]='W',[22]='V',[23]='X',[24]='Y',[25]='Z',[26]='a',[27]='b',[28]='c',[29]='d',[30]='e',[31]='f',[32]='h',[33]='g',[34]='i',[35]='j',[36]='k',[37]='l',[38]='m',[39]='n',[40]='o',[41]='p',[42]='r',[43]='q',[44]='s',[45]='t',[46]='u',[47]='v',[48]='w',[49]='x',[50]='y',[51]='z',[52]='0',[53]='1',[54]='2',[55]='3',[56]='4',[57]='5',[58]='6',[59]='7',[60]='8',[61]='9',[62]='-',[63]='_'}
        base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['J']=8,['I']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['T']=18,['S']=19,['U']=20,['W']=21,['V']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['h']=32,['g']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['r']=42,['q']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}


        PlayerSyncData = {}
        PlayerPackages = {}
        --PlayerPackageValue = {}

        local trigger = CreateTrigger()

        for i = 0, 5 do

            for k = 1, 6 do
                BlzTriggerRegisterPlayerSyncEvent(trigger, Player(i), "dataload" .. k, false);
            end

            PlayerSyncData[i+1] = {}
        end

        TriggerAddAction(trigger, function()
            local sync_string = dec(BlzGetTriggerSyncData())
            local slot = GetFileSlot(sync_string)

            if slot > 0 then
                local delc = GetPlayerNameDeclens(sync_string)
                local sync_prefix = SubString(BlzGetTriggerSyncPrefix(), 8, 9)
                local player = ParsePlayerNameOut(SubString(sync_string, 5, delc-1))

                print("got data from player " .. player .. " in slot ".. slot)
                print("prefix is " .. sync_prefix)

                    if StringLength(sync_string) > 1 then
                        sync_string = SubString(sync_string, delc, #sync_string)
                    else
                        sync_string = ""
                    end

                    if not PlayerSyncData[player] then PlayerSyncData[player] = { } end

                    PlayerSyncData[player][S2I(sync_prefix)] = sync_string
            end

        end)

        BlzSetAbilityTooltip(FourCC("Agyv"),"", 0)
    end



end