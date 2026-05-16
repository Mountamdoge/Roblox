--!nolint
local HttpService = game:GetService("HttpService")

local CorePackages, CoreGui;

if not pcall(function()
    CorePackages = game:GetService("CorePackages")
end) then
    CorePackages = Instance.new("Folder")
end

if not pcall(function()
    CoreGui = game:GetService("CoreGui")
end) then
    CoreGui = Instance.new("Folder")
end

local module = {
    directory = "bytecodes"
}

local fenv = getgenv and getgenv() or getfenv();

local insert = table.insert

type p = any -- just a cute suffix im gonna use
type Script = { LocalScript | ModuleScript }
type Scripts = { Script }

local function base64encode(txt : string)
    -- we don't use fenv.base64.encode because some executors SOMEHOW MAY MISS THAT! so we use our own.
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((txt:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return letters:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#txt%3+1])
end

function module:setDirectory(directory : string)
    --> What directory the script should save bytecode files to
    assert(typeof(directory) == "string", "invalid argument #1 to 'setDirectory', string expected got " .. typeof(directory))

    module.directory = directory
end

function module:getScripts() : Scripts
    --> Get all scripts in the game (nil & existing)

    assert(fenv.getscriptbytecode, "unable to use 'getScripts', reason: Your executor does not support getscriptbytecode.")
    
    local scripts = {} :: Scripts
    local getnilinstances = fenv.getnilinstances or function()
        warn("Your executor does not support `getnilinstances`, therefore the script was forced to only look through existing scripts.")
        return {};
    end
    --> make sure to ignore `script` though

    local function loop(tbl : { Instance })
        for _, instance : Instance in next, tbl do
            local amicute:p = instance:IsA("LocalScript") or instance:IsA("ModuleScript") -- we can't include regular `Script`s because they cannot be accessed from the client.
            if
                amicute and
                instance ~= script and
                not instance:IsDescendantOf(CorePackages) and
                not instance:IsDescendantOf(CoreGui)
            then --> Using `if not amicute then continue` would be slower i think?
                insert(scripts, instance)
            end
        end
    end

    warn("LOADING INSTANCES, YOUR GAME MAY FREEZE IF YOU ARE ON A LOW END DEVICE.")

    loop(getnilinstances())
    loop(game:GetDescendants())

    return scripts;
end

function module:saveScripts(list : Scripts, threads : boolean?) : number
    assert(fenv.writefile, "unable to use 'saveScripts', reason: writefile is missing!")
    assert(fenv.isfile, "unable to use 'saveScripts', reason: isfile is missing!")
    assert(fenv.makefolder, "unable to use 'saveScripts', reason: makefolder is missing!")

    if not fenv.isfolder(module.directory) then fenv.makefolder(module.directory) end

    local started = os.clock()
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local directory = ("%s/%s"):format(self.directory, gameName)

    for _, script in next, list do
        local path = (("%s/%s"):format(directory, script.Name)):gsub("[^%w/]", "")
        if fenv.isfile(path) then
            path = ("%s/duplicate_%d_%s"):format(directory, math.random(1e4, 1e6), script.Name):gsub("[^%w/]", "")
        end
        path ..= ".luac"
        if threads then
            task.spawn(fenv.writefile, path, fenv.getscriptbytecode(script)) --> process stuff on different threads, might be laggy!
        else
            fenv.writefile(path, fenv.getscriptbytecode(script))
        end
    end

    return os.clock() - started -- how long it took to run
end

function module:decompileScripts(list : Scripts, oracleKey : string?) : ( { string }, number )
    --> If oracleKey is a valid string, the script will attempt to use oracle for every decompilation.
    local decompile = fenv.decompile;
    if oracleKey and fenv.request then
        decompile = function(script : Script) : string
            local bytecode = fenv.getscriptbytecode(script);
            local response = fenv.request({
                Url = `https://oracle.mshq.dev/decompile?key={oracleKey}`,
                Method = "POST",
                Body = HttpService:JSONEncode({
                    script = base64encode(bytecode),
                    decompilerOptions = {} --> Change this to whatever you'd like
                }),
                Headers = {
                    ["Content-Type"] = "application/json"
                }
            })
            if not response.Success or response.StatusCode ~= 200 then
                return ("-- error while decompiling: %s"):format(response.Body)
            end

            return response.Body
        end
    end

    local decompiledList = {}
    local waitAmount;

    local start = os.clock()

    for _, script in next, list do
        -- see how long it took to decompile a script, if it's over 0.5 seconds, it probably uses an http request, so wait per decompilation
        print("decompiling",script.Name)
        local decompiled;
        if not waitAmount then
            local s = os.clock()
            decompiled = decompile(script)
            local time = os.clock() - s
            if time > 0.5 then
                waitAmount = 1;
            else
                waitAmount = 0
            end
        else
            decompiled = decompile(script)
        end
        insert(decompiledList, decompiled)
        task.wait(waitAmount)
    end

    return decompiledList, os.clock() - start
end

return module;
