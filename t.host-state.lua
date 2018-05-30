--~ function isActive(turnId,playerId,playerNumber)
--~ 	local t=turnId % playerNumber
--~ 	if t==0 then t=playerNumber end -- 0->N
--~ 	return t==playerId
--~ end

--send(x)
--x=recv()

-- write(x)
--x=read()

-- host side, actived player turn
-- turnId:x , playerId:p

function ENV:getActivedPlayerId() --TODO
	local i=self.tId % self.pNum
	if i==0 then i=self.pNum end
	return i
end

function ENV:getPlayerHand(pId) return ENV.P[pId].hands.tostring() end --TODO

function S1(p) --notify player
	local now=ENV:getActivedPlayerId() --TODO
	if p.pId == now then
		p:send("[YOURTURN]")
		p:send(ENV:getPlayerHand(pId)) --TODO
	else
		p:send("[NOTYOURTURN]")
		return S7(p)
	end
	local r
	repeat --while loop: wait ACK
		r=p:recv()
	until r=="ACK"
	return S2(p)
end

function S2(p) --recv player's <Z>:[H] , keep-waiting
	local s
	local z,v --zId, val
	local flag
	-- check zen validity
	repeat
		s=p:recv()
		p.zen=ToZen(s) --TODO
		flag=checkZen(s) --TODO
		if flag then p:send("ACK") end
	until flag
	return S3(p)
end

function S3(p) --deal player zen, send update info
	local rslt=ENV:deal() --TODO
	ENV:update(rslt)
	p:sendToAll(rslt)

	if ENV:testEnd() then
		p:sendToAll("[END]")
		return finish(p)
	else
		return S4(p)
	end
end

function S4(p) --draw card
	local r
	local d=ENV:draw() --TODO
	repeat
		p:send(tostring(d))
		r=p:recv()
	until r=="[ACK]"
	return S5(p)
end

function S5(p) --discard, keep-waiting
	local s
	local disc
	repeat
		s=p:recv()
		disc=toDisc(s)
		if disc then
			ENV:updateDisc(disc)
			p:sendToAll("Disc",disc) --TODO
			--p:send("[ACK]")
			return S6(p)
		end
	until disc
end

function S6(p)
	local now=ENV:nextPId()
	p:sendToAll("TURN",now) --TODO
	return S1(p)
end

function S7(p) --empty while loop , get out when sendToAll("TURN")
	local s
	while inbox do
		p:send(inbox)
		if inbox=="TURN" then return S1(p) end
	end
end

