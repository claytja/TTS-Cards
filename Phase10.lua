function onLoad(save)
	Global.call("RegisterMod",{self.guid})
    display = {"084f05","c3da13"}
    lockout = false
    roundOne = true
    Standard = {
        [1]="2 sets of 3",
        [2]="1 set of 3 and 1 run of 4",
        [3]="1 set of 4 and 1 run of 4",
        [4]="1 run of 7",
        [5]="1 run of 8",
        [6]="1 run of 9",
        [7]="2 sets of 4",
        [8]="7 cards of one color",
        [9]="1 set of 5 and 1 set of 2",
        [10]="1 set of 5 and 1 set of 3",
        [11]="[B]Winner[/B]"
    }
    Master = {
        [1]="3 sets of 3",
        [2]="4 set of 2",
        [3]="1 set of 5 and 1 run of 4",
        [4]="2 sets of 3 and 1 run of 4",
        [5]="1 set of 3 and 1 run of 6",
        [6]="2 runs of 4",
        [7]="1 run of 4 and 4 crads of one color",
        [8]="1 run of 5 of 1 color",
        [9]="8 cards of one color",
        [10]="9 cards of one color",
        [11]="[B]Winner[/B]"
    }
    if save == "" then
    Sets = {
        {color="Black",game=0,deck=""},
        {color="White",phase=1,points=0,hex="7F7F7F"},
        {color="Red",phase=1,points=0,hex="DA1917"},
        {color="Yellow",phase=1,points=0,hex="E6E42B"},
        {color="Green",phase=1,points=0,hex="30B22A"},
        {color="Blue",phase=1,points=0,hex="1E87FF"},
        {color="Pink",phase=1,points=0,hex="F46FCD"}
    }
    self.createButton({
		label="Phase 10", click_function="Start", function_owner=self,
		position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
	})
    else
        Sets = JSON.decode(save)
        if Sets[1].game == 0 then
        Sets = {
            {color="Black",game=0,deck=""},
            {color="White",phase=1,points=0,hex="7F7F7F"},
            {color="Red",phase=1,points=0,hex="DA1917"},
            {color="Yellow",phase=1,points=0,hex="E6E42B"},
            {color="Green",phase=1,points=0,hex="30B22A"},
            {color="Blue",phase=1,points=0,hex="1E87FF"},
            {color="Pink",phase=1,points=0,hex="F46FCD"}
        }
        self.createButton({
            label="Phase 10", click_function="Start", function_owner=self,
            position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
        })
        elseif Sets[1].game == 1 then
            Sstart()
            self.createButton({
                label="Reset", click_function="Reset", function_owner=self,
                position={0,0.19,0}, rotation={0,0,0}, width=600, height=450, font_size=150
            })
        else
            Mstart()
            self.createButton({
                label="Reset", click_function="Reset", function_owner=self,
                position={0,0.19,0}, rotation={0,0,0}, width=600, height=450, font_size=150
            })
        end
    end
end
function onSave()
    return JSON.encode(Sets)
end

function Start()
    for i,obj in ipairs(getAllObjects()) do
        if obj.tag == "Card" or obj.tag == "Deck" then
            obj.destruct()
        end
    end
    self.clearButtons()
    self.createButton({
        label="Reset", click_function="SendReset", function_owner=self,
        position={0,0.19,0}, rotation={0,0,0}, width=600, height=450, font_size=150
    })
    getObjectFromGUID(display[1]).clearButtons()
    getObjectFromGUID(display[2]).clearButtons()
    for i, id in ipairs(display) do
        local obj = getObjectFromGUID(id)
        obj.clearButtons()
        obj.createButton({
            label="Master", click_function="Mstart", function_owner=self, color=stringColorToRGB("Orange"),
            position={1,0.19,0}, rotation={0,0,0}, width=800, height=450, font_size=150
        })
        obj.createButton({
            label="Standard", click_function="Sstart", function_owner=self, color=stringColorToRGB("Teal"),
            position={-1,0.19,0}, rotation={0,0,0}, width=800, height=450, font_size=150
        })
    end
    local pos = getObjectFromGUID("c28f42").getPosition()
    local rot = getObjectFromGUID("c28f42").getRotation()
    local deck = getObjectFromGUID("2eb2f0").takeObject({position=pos,rotation={rot.x,rot.y,180}})
    deck.shuffle()
    Display()
end

function SendReset()
	Global.call("Reset",{})
end

function Reset()
    for i,obj in ipairs(getAllObjects()) do
        if obj.tag == "Card" or obj.tag == "Deck" then
            obj.destruct()
        end
    end
    self.clearButtons()
    getObjectFromGUID(display[1]).clearButtons()
    getObjectFromGUID(display[2]).clearButtons()
    self.createButton({
		label="Phase 10", click_function="Start", function_owner=self,
		position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
	})
    Sets = {
        {color="Black",game=0,deck=""},
        {color="White",phase=1,points=0,hex="7F7F7F"},
        {color="Red",phase=1,points=0,hex="DA1917"},
        {color="Yellow",phase=1,points=0,hex="E6E42B"},
        {color="Green",phase=1,points=0,hex="30B22A"},
        {color="Blue",phase=1,points=0,hex="1E87FF"},
        {color="Pink",phase=1,points=0,hex="F46FCD"}
    }
    setNotes("")
    roundOne = true
end

function findDeck()
    for i, obj in ipairs(getObjectFromGUID("c28f42").getObjects()) do
        if obj.tag == "Deck" then
            return obj
        end
    end
    for i, obj in ipairs(getObjectFromGUID("d72560").getObjects()) do
        if obj.tag == "Deck" then
            return obj
        end
    end
    return false
end

function Display()
    local Output = ""
    for i, player in ipairs(getSeatedPlayers()) do
        local set = getSet(player)
        if set.phase > 0 and set.phase < 12 then
            if Sets[1].game == 2 then
            Output = (Output .. "[" .. set.hex .. "]" .. Player[player].steam_name:sub(0,14) .. ": [FFFFFF]Points: " .. set.points .. "\nPhase: " .. set.phase .. "\n" .. Master[set.phase] .. "\n\n")
            elseif Sets[1].game == 1 then
            Output = (Output .. "[" .. set.hex .. "]" .. Player[player].steam_name:sub(0,14) .. ": [FFFFFF]Points: " .. set.points .. "\nPhase: " .. set.phase .. "\n" ..Standard[set.phase] .. "\n\n")
            end
        end
    end
    setNotes(Output)
end

function getSet(color)
    for i, set in ipairs(Sets) do
        if color == set.color then
            return set
        end
    end
    return false
end

function Mstart()
    Sets[1].game=2
    Display()
    getObjectFromGUID(display[1]).clearButtons()
    getObjectFromGUID(display[2]).clearButtons()
    for i, id in ipairs(display) do
        local obj = getObjectFromGUID(id)
        obj.clearButtons()
        obj.createButton({
            label="Round", click_function="NextRound", function_owner=self, color=stringColorToRGB("Red"),
            position={0,0.19,0}, rotation={0,0,0}, width=800, height=500, font_size=200
        })
    end
    NextRound()
end

function Sstart()
    Sets[1].game=1
    Display()
    getObjectFromGUID(display[1]).clearButtons()
    getObjectFromGUID(display[2]).clearButtons()
    for i, id in ipairs(display) do
        local obj = getObjectFromGUID(id)
        obj.clearButtons()
        obj.createButton({
            label="Round", click_function="NextRound", function_owner=self, color=stringColorToRGB("Red"),
            position={0,0.19,0}, rotation={0,0,0}, width=800, height=500, font_size=200
        })
    end
    NextRound()
end

function NextRound()
    startLuaCoroutine(self,"NextRoundGo")
end
function NextRoundGo()
    if lockout == false then
        lockoutTimer(5)
        for i, player in ipairs(getSeatedPlayers()) do
            local set = getSet(player)
            local hand = Player[player].getHandObjects(1)
            if #hand < 10 and roundOne == false then
                set.phase = set.phase + 1
            end
            for x, card in ipairs(hand) do
                if card.getName() == "1" or card.getName() == "2" or card.getName() == "3" or card.getName() == "4" or card.getName() == "5" or card.getName() == "6" or card.getName() == "7" or card.getName() == "8" or card.getName() == "9" then
                    set.points =  set.points + 5
                elseif card.getName() == "10" or card.getName() == "11" or card.getName() == "12" then
                    set.points = set.points + 10
                elseif card.getName() == "Skip" then
                    set.points = set.points + 15
                elseif card.getName() == "Wild" then
                    set.points = set.points + 25
                end
            end
        end
        roundOne = false
        local Deck = findDeck()
        for i,obj in ipairs(getAllObjects()) do
            if obj ~= Deck then
                if obj.tag == "Card" or obj.tag == "Deck" then
                    Deck.putObject(obj)
                end
            end
        end
        waitFrames(30)
        local pos = getObjectFromGUID("c28f42").getPosition()
        local rot = getObjectFromGUID("c28f42").getRotation()
        Deck.setPosition({pos.x,pos.y,pos.z})
        Deck.setRotation({rot.x,rot.y,180})
        waitFrames(30)
        Deck.shuffle()
        waitFrames(10)
        pos = getObjectFromGUID("d72560").getPosition()
        rot = getObjectFromGUID("d72560").getRotation()
        Deck.takeObject({position=pos,rotation=rot})
        for i, player in ipairs(getSeatedPlayers()) do
            Deck.dealToColor(10,player)
        end
        Display()
        waitFrames(60)
        for i, player in ipairs(getSeatedPlayers()) do
            getObjectFromGUID("7c14e7").call("autoN",{player})
            waitFrames(1)
        end

    end
    return 1
end
function waitFrames(frames)
    while frames > 0 do
    coroutine.yield(0)
    frames = frames - 1
    end
end
function lockoutTimer(time)
    lockout = true
    Timer.destroy(self.getGUID())
    Timer.create({identifier=self.getGUID(), function_name='concludeLockout', delay=time})
end
function concludeLockout()
    lockout = false
end