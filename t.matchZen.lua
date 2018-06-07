--20180607 matchAllZen.lua
--20180605 matchZen.lua
--original: onRepl-v170323.lua

--ENV
idList={9,10,11,12,13,17,18,19,20,21,25,26,27,28,29,33,34,35,36,37,41,42,43,44,45}
ty2s={"G","S","M","H","T"}

sel={
{1},{2},{3},{4},{5},
{2, 1},{3, 1},{4, 1},{5, 1},{3, 2},{4, 2},{5, 2},{4, 3},{5, 3},{5, 4},
{3, 2, 1},{4, 2, 1},{5, 2, 1},{4, 3, 1},{5, 3, 1},{5, 4, 1},{4, 3, 2},{5, 3, 2},{5, 4, 2},{4, 5, 3},
{4, 3, 2, 1},{5, 3, 2, 1},{5, 4, 2, 1},{4, 5, 3, 1},{3, 4, 5, 2},
{1, 2, 3, 4, 5}}

-- utility func()
require "string"
function pf(s,...) return io.write(string.format(s,...)) end
function p(...) return io.write(...) end
function br() print("") end
function see(t) -- major use for print stack
	if type(t)=="table" then
		for i,v in ipairs(t) do
			pf("%s ",tostring(v))
		end
		br()
	else
		print(t)
	end
end

function printArray(t) --printArray in (v v ... v )
	if type(t)=="table" then
		pf("(")
		for i,v in ipairs(t) do
			pf("%d ",v)
		end
		pf(")")
	end
end

-- basic func()
function getId(ty,lv) return ty*8+lv end
function getTy(id) return math.floor(id/8) end
function getLv(id) return id%8 end

math.randomseed(os.time())
function r() return idList[math.random(25)] end
function s(id) return ty2s[getTy(id)] .. getLv(id) end

-- build up application
function draw5()
    local H={}
    for i=1,5 do table.insert(H,r()) end
    return H
end

function seeH(H)
	for i=1,#H do io.write(s(H[i])," ") end
	br()
end

function getHandS(H)
	local hs={}
	hs.tys={0,0,0,0,0}
	hs.lvs={0,0,0,0,0}
	hs.c=0 --n of Tys
	hs.n=#H
	hs.v=0 --val of hand

	for i=1,#H do --do all jobs in 1 loop
		hs.tys[getTy(H[i])]=hs.tys[getTy(H[i])]+1
		hs.lvs[getLv(H[i])]=hs.lvs[getLv(H[i])]+1
	end

	for i=1,5 do
		if hs.tys[i]>0 then hs.c=hs.c+1 end
		if hs.lvs[i]>0 then hs.v=hs.v+hs.lvs[i]*i end
	end

	return hs
end

function _needVal(i)
--~ 	assert(_isBasicZid(i),"zid is invalid basic rule zen id") --test basic rule zen id
	return (i>=1 and i<=6) or (i>=10 and i<=15) or (i>=17 and i<=19) or (i>=22 and i<=24) --zid:1-6,10-15,17-19,22-24 needVal
end

function seeHandS(hs)
	local function patternStr(patVt,tok)
		local tok=tok or {"G","S","M","H","T"}
		local s=""
		for i=1,#patVt do
			if patVt[i]>0 then s=s..string.rep(tok[i],patVt[i]) end
		end
		return s
	end

	local line=""
	line=line..patternStr(hs.tys,{"G","S","M","H","T"}).." "
	line=line..patternStr(hs.lvs,{"v1","v2","v3","v4","v5"})
	line=line..string.format(",(n,c,v)=%d,%d,%d",hs.n,hs.c,hs.v)
	print(line)
end

function __diffVect(v1,v2) -- diff=v1-v2
	local diff={0,0,0,0,0}
	for i=1,5 do diff[i]=v1[i]-v2[i] end
	return diff
end

function __testVectInclude(v1,v2) --test v1 >= v2
	local d=__diffVect(v1,v2)
		for i=1,5 do
			if d[i]<0 then return false,d end
		end
		return true,d
end

function matchAllZen(H)
	local VT={
	{1,0,0,0,0},{0,1,0,0,0},{0,0,1,0,0},{0,0,0,1,0},{0,0,0,0,1},
	{2,0,0,0,0},{0,2,0,0,0},{0,0,2,0,0},{0,0,0,2,0},{0,0,0,0,2},
	{3,0,0,0,0},{0,3,0,0,0},{0,0,3,0,0},{0,0,0,3,0},{0,0,0,0,3},
	{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2},
	{1,1,1,1,1}}

	local shengVT={{1,1,1,0,0},{0,1,1,1,0},{0,0,1,1,1},{1,0,0,1,1},{1,1,0,0,1}}
	local keVT={{1,0,1,0,1},{1,1,0,1,0},{0,1,1,0,1},{1,0,1,1,0},{0,1,0,1,1}}

	local kongVT={
	{1,1,0,0,0},{1,0,1,0,0},{1,0,0,1,0},{1,0,0,0,1},{0,1,1,0,0},
	{0,1,0,1,0},{0,1,0,0,1},{0,0,1,1,0},{0,0,1,0,1},{0,0,0,1,1}}

	local hs=getHandS(H)
	local z={}
	for i=1,25 do z[i]=false end

	for i=1,21 do
		z[i]=__testVectInclude(hs.tys,VT[i])
	end

	--test: five stream to one
	for i=1,5 do if hs.lvs[i]==5 then z[22]=true break end end

	--test: sheng-Zhen
	for i=1,5 do if __testVectInclude(hs.tys,shengVT[i]) then z[23]=true break end end

	--test: ke-Zhen
	for i=1,5 do if __testVectInclude(hs.tys,keVT[i]) then z[24]=true end end

	--test: kong-cheng
	for i=1,10 do if __testVectInclude(hs.tys,kongVT[i]) then z[25]=true end end

	return getActionList(z)
end

function seeZ(z)
	local zByTier={{1,2,3,4,5},{6,7,8,9,10,25},{11,12,13,14,15,23,24},{16,17,18,19,20},{21,22}}
	local n=0
	for tier=1,5 do
		for i=1,#zByTier[tier] do
			if z[zByTier[tier][i]] then pf("%d ",zByTier[tier][i]) n=n+1 end
		end
		pf("^ ")
	end
	pf("[%d]",n)
	br()
end

function getActionList(z)
	local ls={}
	for i=1,25 do
		if z[i]==true then table.insert(ls,i) end
	end
	return ls
end

function selectH(H,sel) --give select return list from hand.
	local t={}
	for _,i in ipairs(sel) do
--~ 		print(i,H[i])
		if i>0 and H[i] then
			table.insert(t,H[i])
		end
	end
	return t
end

function getZid(hs) --use "hs" to get zid. Note: may has two match latter.
	local zid
	if (hs.n==1 or hs.n==2 or hs.n==3) and hs.c==1 then --1-15
		local ty=findTy(hs.tys,hs.n)
		if ty then zid=(hs.n-1)*5+ty
		else return nil,"can't find major ty" --error
		end
	elseif hs.n==4 then zid=matchFourTierZhen(hs.tys) --16-20
	elseif hs.n==5 and hs.c==5 then zid=21
	elseif hs.n==5 and sameLv(hs.lvs,hs.n) then zid=22
	elseif hs.n==3 and hs.c==3 then zid=shengKeZhen(hs.tys) --23-24
	elseif hs.n==2 and hs.c==2 then zid=25
	else zid=nil --error
	end
	if zid then return zid
	else return nil,"can't match"
	end
end

function seePlay(p) --show sel[],zid
	assert(p.z,"zid is nil")
	pf("[")
	for i=1,#p[1] do pf(s(p[1][i]).." ") end --selectCard
	pf("]:"..p.z.."\n")
end

function findTy(tys,n) --find major ty and match n
	for i=1,5 do
		if tys[i]==n then return i end
	end
	return nil --error
end

function sameLv(lvs,n) --check all level is same
	for i=1,5 do
		if lvs[i]==n then return true end
	end
	return false
end

function shengKeZhen(tys) --check sheng-zhen or ke-zhen
	local t={}
	for i=1,5 do if tys[i]==0 then table.insert(t,i) end end --find two ty
	c=math.abs(t[1]-t[2]) --check Element's Relationship
	if c==1 or c==4 then return 23,"sheng-zhen"
	elseif c==2 or c==3 then return 24,"ke-zhen"
	else return nil --error
	end
end
function matchV(u,v) --check vect is same
	if type(u)=="table" and type(v)=="table" then
		for i=1,5 do
			if u[i]~= v[i] then return false end
		end
		return true
	end
end
function matchFourTierZhen(tys) --match all four card zhen
	local vect={{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2}} --zid:16-20
	for i=1,#vect do
--~ 		print(i,matchV(tys,vect[i])) --info
		if matchV(tys,vect[i]) then return 15+i end
	end
	return nil --error
end

function match(play) --{{...},z=zid}
	local VT={
	{1,0,0,0,0},{0,1,0,0,0},{0,0,1,0,0},{0,0,0,1,0},{0,0,0,0,1}, --1~5
	{2,0,0,0,0},{0,2,0,0,0},{0,0,2,0,0},{0,0,0,2,0},{0,0,0,0,2}, --6~10
	{3,0,0,0,0},{0,3,0,0,0},{0,0,3,0,0},{0,0,0,3,0},{0,0,0,0,3}, --11~15
	{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2}, --16~20
	{1,1,1,1,1} --21
	}
	assert(type(play[1])=="table","play[] is "..type(play[1]))
	local hs=getHandS(play[1])
	local z=play.z

	if z>=1 and z<=21 then return matchV(VT[z],hs.tys)
	elseif z==22 then return sameLv(hs.lvs,hs.n)
	elseif z==23 or z==24 then return hs.n==3 and hs.c==3 and shengKeZhen(hs.tys)==z
	elseif z==25 then return hs.n==2 and hs.c==2
	else return false --Note: This func() only use for Id:1-25
	end
end

	-- if hs.n==1 then hs.v=hs.v+4
	-- elseif hs.n==2 then hs.v=hs.v*2
	-- elseif hs.n==3 then hs.v=hs.v*3
	-- elseif hs.n==4 then hs.v=hs.v*4
	-- end

-- main loop
--======================================================================================
H=draw5()
see(H)
seeH(H)

print("test matchAllZen()")
see(matchAllZen(H))

print("test all selects in select card")
local selectCard={}
local play={}
for i=1,#sel do
	selectCard[i]=selectH(H,sel[i]) --sel[] -> selectCard[]
	seeH(selectCard[i])
	local hs,z
	hs=getHandS(selectCard[i]) --selectCard[] -> hs[]
	seeHandS(hs)
	z=getZid(hs)
	p("z="..tostring(z).."\n")
	if z then table.insert(play,{selectCard[i],z=z}) end -- {selectCard[],z} -> play[]
end

print("test match(play)")
print("play[]",#play)
for i=1,#play do
	seePlay(play[i])
	if match(play[i]) then
		pf("pass\n")
	else pf("NO PASS!\n")
	end
end

