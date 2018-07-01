--201807101 implement player state: select, match, deal, draw, discard, turn

-- utility func()
require "string"
function str(s,...) return string.format(s,...) end
function pf(s,...) return io.write(string.format(s,...)) end
function p(...)
	local t={...}
	for i=1,#t do
		typeName=type(t[i])
		if typeName=="number" or typeName=="boolean" then t[i]=tostring(t[i])
		elseif typeName=="string" then
		else
			t[i]="("..tostring(t[i])..")"
		end
		io.write(t[i])
	end
end
function br() io.write("\n") end
function tab() io.write("\t") end
function see(t) -- major use for print stack
	if type(t)=="table" then
		p("[")
		for i,v in ipairs(t) do
			p(v," ")
		end
		p("]")
	else
		p(t)
	end
end

-- basic func()
function getCid(ty,lv) return (lv-1)*5+ty end
function getTy(cid) if cid%5==0 then return 5 else return cid%5 end end
function getLv(cid) return math.floor((cid-1)/5)+1 end

math.randomseed(os.time())
function r() return math.random(25) end
function s(id)
	local id2s={"G1","S1","M1","H1","T1","G2","S2","M2","H2","T2","G3","S3","M3","H3","T3","G4","S4","M4","H4","T4","G5","S5","M5","H5","T5"}
return id2s[id] end

-- build up application
function draw5()
    local h={}
    for i=1,5 do h[i]=r() end
    return h
end

function draw(n)
	local d={}
	for i=1,n do d[i]=r() end
	return d
end

function seeCardList(ls)
	p("[")
	for i=1,#ls do p(s(ls[i])," ") end
	p("]")
end
local scl=seeCardList --nickname

function _getHandS(h)
	local hs={}
	hs.tys={0,0,0,0,0}
	hs.lvs={0,0,0,0,0}
	hs.c=0 --n of Tys
	hs.n=#h
	hs.v=0 --val of hand

	for i=1,#h do --do all jobs in 1 loop
		hs.tys[getTy(h[i])]=hs.tys[getTy(h[i])]+1
		hs.lvs[getLv(h[i])]=hs.lvs[getLv(h[i])]+1
	end

	for i=1,5 do
		if hs.tys[i]>0 then hs.c=hs.c+1 end
		if hs.lvs[i]>0 then hs.v=hs.v+hs.lvs[i]*i end
	end

	return hs
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

function getZhenTable(h) --give hand[], get all possiable zhen
	local vt={
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

	local hs=_getHandS(h)
	local z={}
	for i=1,25 do z[i]=false end

	for i=1,21 do
		z[i]=__testVectInclude(hs.tys,vt[i])
	end

	--test: five stream to one
	for i=1,5 do if hs.lvs[i]==5 then z[22]=true break end end
	--test: sheng-Zhen
	for i=1,5 do if __testVectInclude(hs.tys,shengVT[i]) then z[23]=true break end end
	--test: ke-Zhen
	for i=1,5 do if __testVectInclude(hs.tys,keVT[i]) then z[24]=true end end
	--test: kong-cheng
	for i=1,10 do if __testVectInclude(hs.tys,kongVT[i]) then z[25]=true end end

	return z
end

function getActionList(z) --give zhen table, make possiable action list.
	local ls={}
	for i=1,25 do
		if z[i]==true then table.insert(ls,i) end
	end
	return ls
end

function seeActionList(ls) --pretty print
	local zhenT={}
	for i=1,#ls do zhen[ls[i]]=true end
	local order={1,2,3,4,5,6,7,8,9,10,25,11,12,13,14,15,23,24,16,17,18,19,20,21,22}

	p("n=",n,", ")
	for i=1,#order do
		if zhenT[order[i]] then p(order[i]," ") end
		if i==5 or i==11 or i==18 or i==23 then p("^ ") end
	end
	br()
end

function getZid(selc) --use selc[] to get zid. Note: may get two zids latter.
	local hs=_getHandS(selc)
	--local zid={}
	local ty
	if hs.c==1 then
		ty=assert(findTy(hs.tys,hs.n),"Where is your ty ??")
	end

	if hs.n==1 then return ty -- 1-5
	elseif hs.n==2 then
		if hs.c==1 then return 5+ty -- 6-10
		elseif hs.c==2 then return 25--25
		end
	elseif hs.n==3 then
		if hs.c==1 then return 10+ty -- 11-15
		elseif hs.c==3 then
			local z=assert(shengKeZhen(hs.tys),"BOOM! not sheng-zhen, ke-zhen")
			return z -- 23-24
		else return nil
		end
	elseif hs.n==4 then
		local z=matchFourTierZhen(hs.tys)
		if z then return z -- 16-20
		else return nil
		end
	elseif hs.n==5 then
		local z21,z22= hs.c==5,sameLv(hs.lvs,hs.n)
		if z21 and z22 then return 21,22 --both
		elseif z21 then return 21 --one
		elseif z22 then return 22 --one
		else return nil
		end
	end
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

--play: {...},z=zid
function match(play) --check play object is valid.
	local vt={
	{1,0,0,0,0},{0,1,0,0,0},{0,0,1,0,0},{0,0,0,1,0},{0,0,0,0,1}, --1~5
	{2,0,0,0,0},{0,2,0,0,0},{0,0,2,0,0},{0,0,0,2,0},{0,0,0,0,2}, --6~10
	{3,0,0,0,0},{0,3,0,0,0},{0,0,3,0,0},{0,0,0,3,0},{0,0,0,0,3}, --11~15
	{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2}, --16~20
	{1,1,1,1,1} --21
	}
	assert(type(play[1])=="table","play[] is "..type(play[1]))
	local hs=_getHandS(play[1])
	local z=play.z

	if z>=1 and z<=21 then return matchV(vt[z],hs.tys)
	elseif z==22 then return sameLv(hs.lvs,hs.n)
	elseif z==23 or z==24 then return hs.n==3 and hs.c==3 and shengKeZhen(hs.tys)==z
	elseif z==25 then return hs.n==2 and hs.c==2
	else return false --Note: This func() only use for Id:1-25
	end
end

function seePlay(play) --show sel[],zid
	assert(play.z,"zid is nil")
	p("[")
	for i=1,#play[1] do p(s(play[1][i])," ") end --selectCard
	p("]:",play.z)
end

function getSelcByI(h,sel) --give sel[]:<i[]> return selc[] from hand.
	assert(type(h)=="table" and type(sel)=="table","arg needs table")
	local selc={}
	for x=1,#sel do
		local i=sel[x]
		--print(sel[x],h[i])
		if h[i] then table.insert(selc,h[i]) end
	end
	return selc
end

function getSelcByB(h,sel) --give sel[]:<bool[5]> return selc[] from hand.
	assert(type(h)=="table" and type(sel)=="table","arg needs table")
	local selc={}
	for i=1,5 do
		--print(i,sel[i])
		if sel[i] and h[i] then table.insert(selc,h[i]) end --add h[i] to selectCard
	end
	return selc
end

function getSelc(h,sel) --package
	if type(sel[1])=="number" then return getSelcByI(h,sel)
	else return getSelcByB(h,sel)
	end
end

function getSel(l) --get line, return sel[]:<bool[5]>
	local keymap={z=1,x=2,c=3,v=4,b=5}
	local sel={false,false,false,false,false}
	local t={}

	if not l then return sel end

	l=string.lower(l)
	for i=1,string.len(l) do
		local c=string.sub(l,i,i)
		--print(c,keymap[c])
		if keymap[c] then
			--pf("find %s, is %d\n",c,keymap[c])
			sel[keymap[c]]=true
		end
	end
	return sel
end

function seeSel(sel) --only for sel[]:<bool[5]>
	pf("[")
	for i=1,5 do
		if sel[i] then pf("%d ",i) end
	end
	pf("]")
end

function selectCard(h,sel)
	assert(#h == #sel,"size no match")
	local selc,h2={},{}
	for i=1,#sel do
		if sel[i] then table.insert(selc,h[i])
		else table.insert(h2,h[i])
		end
	end
	return selc,h2
end

function chooseDiscard(d,i)
	assert(type(i)=="number" and i<=#d and i>=1,"i is invalid")
	local disc,d2=0,{}
	for x=1,#d do
		if x~=i then table.insert(d2,d[x])
		else disc=d[x]
		end
	end
	return disc,d2
end

function addToHand(h,d)
	local h2={}
	for i=1,#h do table.insert(h2,h[i]) end
	for i=1,#d do table.insert(h2,d[i]) end
	return h2
end

--ENV
sel_ids={
{1},{2},{3},{4},{5},
{2, 1},{3, 1},{4, 1},{5, 1},{3, 2},{4, 2},{5, 2},{4, 3},{5, 3},{5, 4},
{3, 2, 1},{4, 2, 1},{5, 2, 1},{4, 3, 1},{5, 3, 1},{5, 4, 1},{4, 3, 2},{5, 3, 2},{5, 4, 2},{4, 5, 3},
{4, 3, 2, 1},{5, 3, 2, 1},{5, 4, 2, 1},{4, 5, 3, 1},{3, 4, 5, 2},
{1, 2, 3, 4, 5}}

-- main loop
--======================================================================================
--test state translate.

h={11,2,1,12,16}
selc={}
h2={}
d={}
zid=0
disc=0

function start_state()
	select_state()
end

function select_state()
	p("in select\n")
	scl(h) br()
	io.write(">")
	local l=io.read()
	local sel=getSel(l)
	seeSel(sel) br()
	selc,h2=selectCard(h,sel)
	p("selc=") scl(selc) br()
	p("h=") scl(h2) br()
	p("exit select, to match\n")
	match_state()
end

function match_state()
	p("in match\n")
	zid=getZid(selc)
	if zid then
		p("you can use "..zid..",press [space] to deal it, others to return")
		local l=io.read(1) br()
		l=string.upper(l)
		if l==" " then
			p("exit match, to deal\n") deal_state()
		else p("exit match, to select\n") select_state()
		end
	else
		p("no match, back to select\n")
		select_state()
	end
end

function deal_state()
	p("in deal\n")
	p("you select ") scl(selc) p(" to call zid: "..zid) br()
	h=h2
	p("Hand=") scl(h) br()
	p("exit deal\n")
	draw_state()
end

function draw_state()
	p("in draw\n")
	local dn=2
	if zid==22 then dn=dn+1 end
	if #h+dn>5 then d=draw(6-#h) else d=draw(dn+1) end -- n = (h>3) ? 6-h : 3
	scl(d) br()
	p("exit draw\n")
	discard_state()
end

function discard_state()
	p("in disc\n")
	local i=0
	repeat
		p("d=") scl(d) br()
		p("choose one to discard. input number: ")
		i=io.read("*n")
	until i<=#d and i>0
	disc,d2=chooseDiscard(d,i)
	h=addToHand(h2,d2)
	scl(h) br()
	p("exit disc\n")
	turn_state()
end

function turn_state()
	p("in turn\n")
	selc={}
	h2={}
	d={}
	zid=0
	disc=0
	p("exit turn\n")
end

start_state()
