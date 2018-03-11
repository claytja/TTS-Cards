function onLoad(save)
   placecardrightafterturn = true
   handsorters = {"7c14e7","ff9b4f"}
   Global.call("RegisterMod",{self.guid})
   timerTick = 1
   poslist = {
      {0,0,4.65},
      {-2.1,0,4.65},
      {2.1,0,4.65},
   }
   if save ~= "" then
      Running = false
      self.createButton({
         label="Palace", click_function="Start", function_owner=self,
         position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
      })
   else
      local tbl = JSON.decode(save) or {}
      Running = tbl[1] or false
      if Running == false then
         self.clearButtons()
         self.createButton({
            label="Palace", click_function="Start", function_owner=self,
            position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
         })
      else
         self.clearButtons()
         self.createButton({
            label="Reset", click_function="SendReset", function_owner=self,
            position={0,0.19,0}, rotation={0,0,0}, width=600, height=450, font_size=150
         })
      end
   end

   self.createButton({
      label="Palace", click_function="Start", function_owner=self,
      position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
   })
   display = {getObjectFromGUID("084f05"),getObjectFromGUID("c3da13")}
   RZone = getObjectFromGUID("11b50e")
   GZone = getObjectFromGUID("c28f42")
   WZone = getObjectFromGUID("d72560")
   delayedCallback("getTurn",{},0.5)
   lockout = false
   lockout2 = false
   lastcardinfo = {}
end
function onSave()
   local tbl = {Running}
   return JSON.encode(tbl)
end

function SendReset()
Global.call("Reset",{})
end

function Reset()
   Running = false
   self.clearButtons()
   self.createButton({
      label="Palace", click_function="Start", function_owner=self,
      position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
   })
   Turn = Global.getVar("Turn")
   lockout = false
   lockout2 = false
end

function getTurn()
   Turn = Global.getVar("Turn")
end

function Start()
   for i,v in pairs(handsorters) do
      local o = getObjectFromGUID(v)
      o.setVar("ace", 1)
      o.call("Ace")
   end
   lastcardinfo.name = "None"
   lastcardinfo.numb = 0
   startLuaCoroutine(self,"Start2")
end

function Start2()
   Running = true
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
   for i=1,2 do
      display[i].clearButtons()
      display[i].createButton({
         label="Mulligan", click_function="mulliganf", function_owner=self,
         position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
      })
   end
   local pos = getObjectFromGUID("c28f42").getPosition()
   local rot = getObjectFromGUID("c28f42").getRotation()
   getObjectFromGUID("7882de").takeObject({position=pos,rotation={rot.x,rot.y,180}})
   waitFrames(60)
   if #getSeatedPlayers() > 3 then
      getObjectFromGUID("7882de").takeObject({position=pos,rotation={rot.x,rot.y,180}})
      waitFrames(180)
   end
   local deck = findDeck(GZone)
   deck.shuffle()
   waitFrames(10)
   for x, color in ipairs(getSeatedPlayers()) do
      for i=1, #poslist do
         local ppos = rotateLocalCoordinates(poslist[i],color)
         local rot = Player[color].getHandTransform().rotation
         deck.takeObject({position=ppos,rotation={rot.x,rot.y+180,180}})
      end
      deck.dealToColor(6,color)
   end
   return 1
end

function mulliganf(obj,col)
   if #Player[col].getHandObjects() == 6 then
      local deck = findDeck(GZone)
      local pos = deck.getPosition()
      for i,v in pairs(Player[col].getHandObjects()) do
         v.setPosition({pos.x,pos.y+i/2,pos.z})
         v.setRotation(deck.getRotation())
      end
      deck.shuffle()
      deck.deal(6,col)
   else
      printToColor("You must have all 6 original cards in hand", col, {1,0,0})
   end
end

function PickUp(o,color)
   local Deck = findDeck(WZone)
   if color == Turn then
      if Deck ~= false then
         Global.call("NextPlayer",{false})
         getTurn()
         local num = Deck.getQuantity()
         if num == -1 then num = 1 end
         Deck.deal(num,color)
         lastcardinfo.numb = 0
         lastcardinfo.name = "None"
         delayedCallback("forcesort1",{color},1)
      end
   end
end

function forcesort1(info)
   getObjectFromGUID("ff9b4f").call("forcesortn",{info[1]})
end

function onObjectEnterScriptingZone(Zone,Obj)
   if Zone == WZone and Running == true then
      local color = Obj.held_by_color
      if color == nil then return
      elseif color == Turn then
         if checkifcardgood({Obj}) == false then
            return
         end
         local pos = WZone.getPosition()
         if findDeck(WZone) then
            local deck = findDeck(WZone)
            Obj.setPosition({pos.x,deck.getBounds().size.y+deck.getPosition().y,pos.z})
         else
            Obj.setPosition({pos.x,1.03,pos.z})
         end
         Obj.setRotation({0,180,0})
         Obj.reload()
         if lockout == false then
            lockout = true
            startLuaCoroutine(self,"CheckDiscard")
         end
      elseif Turn == "Off" then --nobody's turn
         for i=1,2 do
            display[i].clearButtons()
            display[i].createButton({
               label="Pick Up", click_function="PickUp", function_owner=self,
               position={0,0.19,0}, rotation={0,0,0}, width=1200, height=450, font_size=300
            })
         end
         Global.call("SetTurn",{color})
         delayedCallback("getTurn",{},0.5)
         local pos = WZone.getPosition()
         Obj.setPosition({pos.x,1.03,pos.z})
         Obj.setRotation({0,180,0})
         Obj.reload()
         if lockout == false then
            lockout = true
            startLuaCoroutine(self,"CheckDiscard")
         end
      elseif color == lastturncol and placecardrightafterturn == true then
         local deck = findDeck(wzone)
         local dnumb = 0
         local cnumb = 0
         if deck.tag == "Card" then
            dnumb = tonumber(string.sub(deck.getDescription(),1,2))
         elseif deck.tag == "Deck" and checkcardssame(deck) then
            dnumb = tonumber(string.sub(deck.getObjects()[1].getDescription(),1,2))
         end
         if obj.tag == "Card" then
            cnumb = tonumber(string.sub(obj.getDescription(),1,2))
         elseif obj.tag == "Deck" and checkcardssame(obj) then
            cnumb = tonumber(string.sub(obj.getObjects()[1].getDescription(),1,2))
         end
         if cnumb == dnumb then
            local pos = wzone.getPosition()
            obj.setRotation(deck.getRotation())
            obj.setPosition({pos.x,deck.getBounds().size.y+deck.getPosition().y,pos.z})
            --put code to set position right above deck here. Don't advance turn or lockout.
         else
            if obj.tag == "Card" then
               obj.deal(1, color)
            elseif obj.tag == "Deck" then
               obj.deal(obj.getQuantity(), color)
            end
         end
      else
         local count = Obj.getQuantity()
         if count == -1 then count = 1 end
         Obj.deal(count,color)
      end
      if lockout2 == false then
         lockout2 = true
         delayedCallback("DealCards",{color},0.5)
      end
   end
end

function onObjectEnterRedZone()

end
function onObjectEnterGreyZone()

end
function onObjectEnterWhiteZone()

end


function checkcardssame(checkdeck)
   if checkdeck.tag == "Card" then
      return false
   end
   local checkobjs = checkdeck.getObjects
   local checkcard = checkobjs[1]
   for i,v in pairs(checkobjs) do
      if tonumber(string.sub(v,1,2)) ~= tonumber(string.sub(checkcard,1,2)) then
         return false
      end
   end
   return true
end

function checkifcardgood(info)
   local Obj = info[1]
   local color = Obj.held_by_color
   --local Deck = findDeck(WZone)
   --local Cards = Deck.getObjects()
   local numb
   if Obj.tag == "Deck" then
      if Obj.getObjects()[1].name == "Ace" then
         numb = 14
      elseif Obj.getObjects()[1].name == "Two" then
         numb = 100
      elseif Obj.getObjects()[1].name == "Ten" then
         numb = 100
      elseif Obj.getObjects()[1].name == "Four" then
         numb = 100
      else
         numb = tonumber(string.sub(Obj.getObjects()[1].description,1,2))
      end
      if lastcardinfo.numb <= numb then
         for i,v in pairs(Obj.getObjects()) do
            if Obj.getObjects()[1].name ~= v.name then
               local count = Obj.getQuantity()
               if count == -1 then count = 1 end
               Obj.deal(count,color)
               return false
            end
         end
         return true
      else
         local count = Obj.getQuantity()
         if count == -1 then count = 1 end
         Obj.deal(count,color)
         return false
      end
   elseif Obj.tag == "Card" then
      if Obj.getName() == "Ace" then
         numb = 14
      elseif Obj.getName() == "Ten" then
         numb = 100
      elseif Obj.getName() == "Two" then
         numb = 100
      elseif Obj.getName() == "Four" then
         numb = 100
      else
         numb = tonumber(string.sub(Obj.getDescription(),1,2))
      end
      if lastcardinfo.numb <= numb then
         return true
      else
         local count = Obj.getQuantity()
         if count == -1 then count = 1 end
         Obj.deal(count,color)
         return false
      end
   end
end

function CheckDiscard()
   waitFrames(20)
   local Deck = findDeck(WZone)
   if Deck.getQuantity() == -1 then
      if Deck.getName() == "Two" then
         lastcardinfo.name = "None"
         lastcardinfo.numb = 0
         broadcastToAll("Go Again",stringColorToRGB("White"))
      elseif Deck.getName() == "Ten" then
         lastcardinfo.name = "None"
         lastcardinfo.numb = 0
         Deck.setPosition(RZone.getPosition())
         broadcastToAll("Go Again",stringColorToRGB("White"))
      elseif Deck.getName() == "Four" then
         broadcastToAll("Last Card: " .. lastcardinfo.name,stringColorToRGB("White"))
         Global.call("NextPlayer",{false})
         getTurn()
      else
         if Deck.getName() == "Ace" then
            lastcardinfo.numb = 14
         else
            lastcardinfo.numb = tonumber(string.sub(Deck.getDescription(),1,2))
         end
         lastcardinfo.name = Deck.getName()
         Global.call("NextPlayer",{false})
         getTurn()
      end
   else
      local Cards = Deck.getObjects()
      if #Cards >= 4 and Cards[#Cards].nickname == Cards[#Cards-1].nickname and Cards[#Cards].nickname == Cards[#Cards-2].nickname and Cards[#Cards].nickname == Cards[#Cards-3].nickname then
         Deck.setPosition(RZone.getPosition())
         broadcastToAll("For of a kind: Go Again",stringColorToRGB("White"))
         lastcardinfo.name = "None"
         lastcardinfo.numb = 0
      elseif Cards[#Cards].nickname  == "Ten" then
         lastcardinfo.name = "None"
         lastcardinfo.numb = 0
         Deck.setPosition(RZone.getPosition())
         broadcastToAll("Go Again",stringColorToRGB("White"))
      elseif Cards[#Cards].nickname == "Two" then
         lastcardinfo.name = "None"
         lastcardinfo.numb = 0
         broadcastToAll("Go Again",stringColorToRGB("White"))
      elseif Cards[#Cards].nickname == "Four" then
         broadcastToAll("Last Card: " .. lastcardinfo.name,stringColorToRGB("White"))
         Global.call("NextPlayer",{false})
         getTurn()
      else
         if Cards[#Cards].nickname == "Ace" then
            lastcardinfo.numb = 14
         else
            lastcardinfo.numb = tonumber(string.sub(Cards[#Cards].description,1,2))
         end
         lastcardinfo.name = Cards[#Cards].nickname
         Global.call("NextPlayer",{false})
         getTurn()
      end
   end
   lockout = false
   return 1
end

function DealCards(tbl)
   local hand = Player[tbl[1]].getHandObjects()
   if #hand < 3 then
      local num = 3 - #hand
      local Deck = findDeck(GZone)
      if Deck ~= false then
         Deck.deal(num,tbl[1])
      end
   end
   lockout2 = false
end

function findDeck(zone)
   for i, obj in ipairs(zone.getObjects()) do
      if obj.tag == "Deck" then
         return obj
      end
   end
   for i, obj in ipairs(zone.getObjects()) do
      if obj.tag == "Card" then
         return obj
      end
   end
   return false
end

function rotateLocalCoordinates(desiredPos,color)
   local objPos, objRot = Player[color].getHandTransform().position, Player[color].getHandTransform().rotation
   local angle = -math.rad(objRot.y)
   local x = desiredPos[1] * math.cos(angle) - desiredPos[3] * math.sin(angle)
   local z = desiredPos[1] * math.sin(angle) + desiredPos[3] * math.cos(angle)
   return {objPos.x+x, objPos.y+desiredPos[2], objPos.z+z}
end

function waitFrames(frames)
   while frames > 0 do
      coroutine.yield(0)
      frames = frames - 1
   end
end

function delayedCallback(func, table, time)
   local params = table
   params.id = 'Palace_' ..timerTick
   Timer.create({identifier=params.id, function_name=func, parameters=params, delay=time})
   timerTick = timerTick + 1
end
