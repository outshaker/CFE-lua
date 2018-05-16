function deal(s,bag)
	assert(_isBasicZid(s.zid),"zid is invalid basic rule zen id") --test basic rule zen id
	--Note:fix data. If don't need val, then make val nil
	if not _needVal(s.zid) and s.val then s.val=nil end

	--Note: only needVal will be tested. not always has val -> add if _needVal then ...
	if _needVal(s.zid) then
		assert(s.val and type(s.val)=="number","val is nil or invalid")
	end

	assert(_isBasicZid(bag.lastDeal),"X's lastDeal is invalid basic rule zen id") --test basic rule zen id
	assert(type(bag.xShell)=="boolean","X's shell state is unknown") --test X player's shell state Note:can't test false
	assert(type(bag.oShell)=="boolean","O's shell state is unknown") --test O player's shell state Note:can't test false

	--Note:zid22 should be dealed before send to deal()
	--Note:only sid22 need xHands... TODO: rewrite it
	assert(bag.xHands and type(bag.xHands)=="number" and (bag.xHands>=0 and bag.xHands<=5),"xHands is invalid") --test xHands
	if s.zid==22 then s.val=bag.xHands*15 end

	return checkAorD(s,bag)
end

function _needVal(i)
	assert(_isBasicZid(i),"zid is invalid basic rule zen id") --test basic rule zen id
	return (i>=1 and i<=6) or (i>=10 and i<=15) or (i>=17 and i<=19) or (i>=22 and i<=24) --zid:1-6,10-15,17-19,22-24 needVal
end

function _isBasicZid(i)
	return i and type(i)=="number" and (i>=1 and i<=25) --test basic rule zen id
end

function _isBasicAtk(i)
	--A:1-5,6,11-15,19,22
	--D:7-10,16-18,20-21,23-25
	local zid2rs={1,1,1,1,1,
	1,14,14,14,0,
	1,1,1,1,1,
	8,9,10,1,11,
	12,1,9,13,15}
	return zid2rs[i]==1
end

function checkAorD(s,bag)
	if _isBasicAtk(s.zid) then
		return dealA(s,bag)
	else
		return dealD(s,bag)
	end
end

function dealA(s,bag)
	--check attck is valid
	if bag.lastDeal==8 then --Denfense
		return nothing(s,bag),nil,"Denfense is work"
	--deal attack
	elseif bag.lastDeal==9 then --Reflection
		return getHurtBoth(s,bag)
	else --normal case
		return getHurt(s,bag)
	end
end

function dealD(s,bag)
	local zid2rs={1,1,1,1,1,
	1,14,14,14,0,
	1,1,1,1,1,
	8,9,10,1,11,
	12,1,9,13,15}

	if bag.lastDeal==7 then --spellCounter
		return nothing(s,bag),nil,"Spell counter is work"
	elseif s.zid==10 then s.zid,s.val=_mimicry(bag.lastDeal,s.val)
		return deal(s,bag) --send back to recall it
	elseif s.zid==24 and bag.xShell==false then --Note: X has no shell -> pass it
		return nothing(s,bag),nil,"X has no shell"
	elseif s.val then --has val
		return zid2rs[s.zid], s.val
	else --has no val, just functional spell.
		return zid2rs[s.zid]
	end
end

function _mimicry(target,v)
	if not _isBasicZid(target) then return 25 end --only used in basic zid
	--zid:1-6,10-15,17-19,22-24 needVal
	if target>=1 and target<=5 then return target,v+4
	elseif target==6 then return target,v*2
	elseif target>=11 and target<=15 then return target, v*3
	elseif target>=17 and target<=19 then return target, v*4
	--TODO: zid22 deal v later
	elseif target>=23 and target<=24 then return target, v*3
	else return target,nil --don't need val
	end
end

function getHurtBoth(s,bag)
	local offset,v1,v2=0, math.ceil(s.val/2), math.ceil(s.val/2)
	if bag.xShell then offset=offset+1 end
	if bag.oShell then offset=offset+2 end
	if _isPhyAtk(s.zid) then
		if bag.oShell then v1=v1*2 end
		if bag.xShell then v2=v2*2 end
	end
	--Note: r4-7, return two values -> return a value pairs
	return 4+offset,{v1,v2},"Reflection is work"
end

function getHurt(s,bag)
	local v=s.val
	if bag.xShell then --shell Damage
		if _isPhyAtk(s.zid) then
			return 2, v*2, "2x"
		else
			return 2, v
		end
		--return shellDamage(s,bag)
	elseif _isEleAtk(s.zid) and _isEleAtk(bag.lastDeal) then --element attack
		local c=_getEleRel(_getEleType(s.zid),_getEleType(bag.lastDeal))
		if c==1 then return 1, math.ceil(v/2), "0.5x"
		elseif c==3 then return 1, v*2, "2x"
		elseif c==2 then return 3, v, "-x"
		else return 1, v
		end
		--return eleDamage(s,bag)
	else
		return 1, v
		--return damage(s,bag)
	end
end

function _getEleType(i)
	if i>=1 and i<=5 then return i end
	if i>=11 and i<=15 then return i-10 end
	return 0 --return error
end

function _isEleType(i) return i and type(i)=="number" and (i>=1 and i<=5) end

function _isEleAtk(i) return (i>=1 and i<=5) or (i>=11 and i<=16) end
function _isPhyAtk(i) return i==6 or i==19 end
function _getEleRel(o,x) --get Elements' Relation o is self, x is Previous player
	assert(_isEleType(o) and _isEleType(x),"one of EleType is wrong")
	local v=x-o
	if v==0 then return 1 --same
	elseif v==1 or v==-4 then return 2 --generate
	elseif v==2 or v==-3 then return 3 --terminate
	elseif v==3 or v==-2 then return 4 --be terminaed Note:not use yet
	elseif v==4 or v==-1 then return 5 --be generated Note:not use yet
	end
end

function nothing(s,bag)	return 15 end

--defination test function
--s{zid,(val)}
--bag{lastDeal,oShell,xShell,xHands}

function test(s,bag) --get deal(s,bag) and print it
	printR(deal(s,bag))
	return
end

function _isRslt(r) return r and type(r)=="number" and (r>=1 and r<=15) end

function printR(r,v,els)
	assert(_isRslt(r),"r is invalid result")
	if r>=4 and r<=7 then print(r,v[1],v[2],els) --component result
	elseif els then print(r,v,els)
	else print(r,v)
	end
	return
end

function testLoop()
	local b={lastDeal=2,xShell=false,oShell=false,xHands=3}
	local s={}
	for i=1,25 do
		s.zid=i
		s.val=5
		test(s,b)
	end
	return
end

--main
testLoop()
