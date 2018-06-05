--20180605 matchZen.lua
--original: onRepl-v170323.lua

--ENV
idList={9,10,11,12,13,17,18,19,20,21,25,26,27,28,29,33,34,35,36,37,41,42,43,44,45}
-- i <- 1,25 id=ty*8+lv
ty2s={"G","S","M","H","T"}
--~ ty2i={G=1,S=2,M=3,H=4,T=5} --enum
--Note: VT match 1-21
VT={
{1,0,0,0,0},{0,1,0,0,0},{0,0,1,0,0},{0,0,0,1,0},{0,0,0,0,1},
{2,0,0,0,0},{0,2,0,0,0},{0,0,2,0,0},{0,0,0,2,0},{0,0,0,0,2},
{3,0,0,0,0},{0,3,0,0,0},{0,0,3,0,0},{0,0,0,3,0},{0,0,0,0,3},
{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2},
{1,1,1,1,1}
}

shengVT={{1,1,1,0,0},{0,1,1,1,0},{0,0,1,1,1},{1,0,0,1,1},{1,1,0,0,1}}
keVT={{1,0,1,0,1},{1,1,0,1,0},{0,1,1,0,1},{1,0,1,1,0},{0,1,0,1,1}}

kongVT={
{1,1,0,0,0},{1,0,1,0,0},{1,0,0,1,0},{1,0,0,0,1},{0,1,1,0,0},
{0,1,0,1,0},{0,1,0,0,1},{0,0,1,1,0},{0,0,1,0,1},{0,0,0,1,1},
}

sel={}
sel[1]={{1},{2},{3},{4},{5}}
sel[2]={{2, 1},{3, 1},{4, 1},{5, 1},{3, 2},{4, 2},{5, 2},{4, 3},{5, 3},{5, 4}}
sel[3]={{3, 2, 1},{4, 2, 1},{5, 2, 1},{4, 3, 1},{5, 3, 1},{5, 4, 1},{4, 3, 2},{5, 3, 2},{5, 4, 2},{4, 5, 3}}
sel[4]={{4, 3, 2, 1},{5, 3, 2, 1},{5, 4, 2, 1},{4, 5, 3, 1},{3, 4, 5, 2}}
sel[5]={{1, 2, 3, 4, 5}}
--(5,10,10,5,1)=31

vect={}
vect[1]={{1,0,0,0,0},{0,1,0,0,0},{0,0,1,0,0},{0,0,0,1,0},{0,0,0,0,1}}
vect[2]={{2,0,0,0,0},{0,2,0,0,0},{0,0,2,0,0},{0,0,0,2,0},{0,0,0,0,2}}
vect[3]={{3,0,0,0,0},{0,3,0,0,0},{0,0,3,0,0},{0,0,0,3,0},{0,0,0,0,3}}
vect[4]={{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2}}
vect[5]={{1,1,1,1,1}}
--{{1,0,0,0,0},{0,1,0,0,0},{0,0,1,0,0},{0,0,0,1,0},{0,0,0,0,1}} --22
--{{1,1,1,0,0},{0,1,1,1,0},{0,0,1,1,1},{1,0,0,1,1},{1,1,0,0,1}} --23
--{{1,0,1,0,1},{1,1,0,1,0},{0,1,1,0,1},{1,0,1,1,0},{0,1,0,1,1}} --24
--{{1,1,0,0,0},{1,0,1,0,0},{1,0,0,1,0},{1,0,0,0,1},{0,1,1,0,0},{0,1,0,1,0},{0,1,0,0,1},{0,0,1,1,0},{0,0,1,0,1},{0,0,0,1,1}} --25

-- utility func()
require "string"
function pf(s,...) return io.write(string.format(s,...)) end
function br() print("") end
function see(t) -- major use for print stack
	if type(t)=="table" then
		for i,v in ipairs(t) do
			pf("%d ",v)
		end
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
	for i=1,#H do
		io.write(s(H[i])," ")
	end
	return
end

function getHandS(H)
	local hs={}
--~ 	hs.ty={}
--~ 	hs.lv={}
	hs.tys={0,0,0,0,0}
	hs.lvs={0,0,0,0,0}
	hs.c=0 --n of Tys
	hs.n=#H
	hs.v=0 --val of hand

	for i=1,#H do --do all jobs in 1 loop
--~ 		if hs.ty[getTy(H[i])]==nil then hs.ty[getTy(H[i])]={} end
--~ 		table.insert(hs.ty[getTy(H[i])],H[i]) -- add self to table, inverse table.
--~ 		if hs.lv[getLv(H[i])]==nil then hs.lv[getLv(H[i])]={} end
--~ 		table.insert(hs.lv[getLv(H[i])],H[i]) -- add self to table, inverse table.

		hs.tys[getTy(H[i])]=hs.tys[getTy(H[i])]+1
		hs.lvs[getLv(H[i])]=hs.lvs[getLv(H[i])]+1
	end

	for i=1,5 do
		if hs.tys[i]>0 then hs.c=hs.c+1 end
		if hs.lvs[i]>0 then hs.v=hs.v+hs.lvs[i]*i end
	end

	if hs.n==1 then hs.v=hs.v+4
	elseif hs.n==2 then hs.v=hs.v*2
	elseif hs.n==3 then hs.v=hs.v*3
	elseif hs.n==4 then hs.v=hs.v*4
	elseif hs.n==5 then hs.v=15
	end
	return hs
end

function _needVal(i)
--~ 	assert(_isBasicZid(i),"zid is invalid basic rule zen id") --test basic rule zen id
	return (i>=1 and i<=6) or (i>=10 and i<=15) or (i>=17 and i<=19) or (i>=22 and i<=24) --zid:1-6,10-15,17-19,22-24 needVal
end

function seeHandS(hs)
	seePatternStr(hs.tys,{"G","S","M","H","T"}) seePatternStr(hs.lvs,{"v1","v2","v3","v4","v5"})
	pf(",(n,c,v)=%d,%d,%d",hs.n,hs.c,hs.v)
	br()

--~ 	pf("(G,S,M,H,T)=")
--~ 	printArray(hs.tys)
--~ 	pf(",(lv1,lv2,lv3,lv4,lv5)=")
--~ 	printArray(hs.lvs)
--~ 	pf(",(n,c)=%d,%d",hs.n,hs.c)
--~ 	br()

--~ 	for i=1,5 do
--~ 		if hs.ty[i] then
--~ 			pf("[%s]=",ty2s[i])
--~ 			printArray(hs.ty[i])
--~ 		end
--~ 	end
--~ 	pf("\n")
--~ 	for i=1,5 do
--~ 		if hs.lv[i] then
--~ 			pf("[lv%d]=",i)
--~ 			printArray(hs.lv[i])
--~ 		end
--~ 	end
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

function __testVectMatch(v1,v2) --test v1==v2
	local d=__diffVect(v1,v2)
	for i=1,5 do
		if d[i]~=0 then return false,d end
	end
	return true,d
end

function __mk_vects(v0) --v0: base make 5 vects.
	local __shiftIn1to5 = function (x,i) if (x+i)%5==0 then return 5 else return (x+i)%5 end end
	local vts={}
	for n=1,5 do vts[n]={}
		for i=1,5 do vts[n][__shiftIn1to5(i,n-1)]=v0[i] end
	end
	return vts
end


function matchAllZen(hs)
	local z={}
	for i=1,21 do
		z[i]=__testVectInclude(hs.tys,VT[i])
	end

	--test: five stream to one
	z[22]=false
	for i=1,5 do
		if hs.lvs[i]==5 then z[22]=true end
	end

	--test: sheng-Zhen
	z[23]=false
	for i=1,5 do
		if __testVectInclude(hs.tys,shenVT[i]) then
			z[23]=true
			if z.shenTy==nil then z.shenTy={} end
			table.insert(z.shenTy,i)
		end
	end

	--test: ke-Zhen
	z[24]=false
	for i=1,5 do
		if __testVectInclude(hs.tys,keVT[i]) then
			z[24]=true
			if z.keTy==nil then z.keTy={} end
			table.insert(z.keTy,i)
		end
	end

	--test: kong-cheng
	z[25] = false
	for i=1,10 do
		if __testVectInclude(hs.tys,kongVT[i]) then
			z[25]=true
			if z.kongTy==nil then z.kongTy={} end
			table.insert(z.kongTy,i)
		end
	end

	return z
end

function seeZ(z)
	for i=1,25 do
		if z[i] then pf("O ") else pf("X ") end
		if i%5==0 then pf("\n") end
	end
	pf("\n")
end

function getActionList(z)
	local ls={}
	for i=1,25 do
		if z[i]==true then table.insert(ls,i) end
	end

	if z[23] then ls.shenTy=z.shenTy end
	if z[24] then ls.keTy=z.keTy end
	if z[25] then ls.kongTy=z.kongTy end

	return ls
end

function seeActionList(ls)
	for _,i in ipairs(ls) do
		pf("%d ",i)
		if i>=1 and i<=21 then
			seePatternStr(VT[i])
			pf("\n")
		elseif i==23 then
			for _,i in ipairs(ls.shenTy) do
				seePatternStr(shenVT[i])
			end
			pf("\n")
		elseif i==24 then
			for _,i in ipairs(ls.keTy) do
				seePatternStr(keVT[i])
			end
			pf("\n")
		elseif i==25 then
			for _,i in ipairs(ls.kongTy) do
				seePatternStr(kongVT[i])
			end
			pf("\n")
		end
	end
end

function seePatternStr(vt,tok)
--~ 	local tok={"G","S","M","H","T"}
	local function printNtimes(n,s) for i=1,n do pf(s) end end

	for i=1,5 do
		if vt[i]>0 then
			printNtimes(vt[i],tok[i])
		end
	end
	pf(" ")
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

function getZid(hs) --use hs return zId,val
	local zId
	local val=hs.v
	if (hs.n==1 or hs.n==2 or hs.n==3) and hs.c==1 then --1-15
		local ty=findTy(hs.tys,hs.n)

		if ty then zId=(hs.n-1)*5+ty
		else return nil --error
		end

	elseif hs.n==4 then zId=matchFourTierZhen(hs.tys) --16-20
	elseif hs.n==5 and hs.c==5 then zId=21
	elseif hs.n==5 and sameLv(hs.lvs,hs.n) then zId=22
	elseif hs.n==3 and hs.c==3 then zId=shengKeZhen(hs.tys) --23-24
	elseif hs.n==2 and hs.c==2 then zId=25
	else zId=nil --error
	end

	if zId and _needVal(zId) then return zId,val
	else return zId
	end
end

function seePlay(p) --show play:zId match
	if p.z then
		for i=1,#p do pf(s(p[i]).." ") end
		if _needVal(p.z) then pf(":=%d,%d",p.z,p.v)
		else pf(":=%d",p.z)
		end
		br()
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
	local vect={{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2}} --zId:16-20
	for i=1,#vect do
--~ 		print(i,matchV(tys,vect[i])) --info
		if matchV(tys,vect[i]) then return 15+i end
	end
	return nil --error
end

function match(play,z,v)
	local VT={
	{1,0,0,0,0},{0,1,0,0,0},{0,0,1,0,0},{0,0,0,1,0},{0,0,0,0,1}, --1~5
	{2,0,0,0,0},{0,2,0,0,0},{0,0,2,0,0},{0,0,0,2,0},{0,0,0,0,2}, --6~10
	{3,0,0,0,0},{0,3,0,0,0},{0,0,3,0,0},{0,0,0,3,0},{0,0,0,0,3}, --11~15
	{2,1,0,1,0},{0,2,1,0,1},{1,0,2,1,0},{0,1,0,2,1},{1,0,1,0,2}, --16~20
	{1,1,1,1,1} --21
	}
	local hs=getHandS(play)
	if z>=1 and z<=21 then
		if _needVal(z) then return matchV(VT[z],hs.tys) and v==hs.v
		else return matchV(VT[z],hs.tys)
		end
	elseif z==22 then return sameLv(hs.lvs,hs.n) and v%15==0
	elseif z==23 or z==24 then return hs.n==3 and hs.c==3 and shengKeZhen(hs.tys)==z and v==hs.v
	elseif z==25 then return hs.n==2 and hs.c==2
	else return false --Note: This func() only use for Id:1-25
	end
end

-- main loop
--~ for i=1,5 do
--~ 	H=draw5()
--~ 	seeH(H)
--~ 	hs=getHandS(H)
--~ 	seeHandS(hs)
--~ 	z=matchAllZen(hs)
--~ 	seeZ(z)
--~ 	ls=getActionList(z)
--~ 	seeActionList(ls)
--~ end

-- test code
--~ for i=1,21 do seePatternStr(VT[i]) end br() --show zId:1-21
--~ for i=1,5 do seePatternStr(shenVT[i]) end br() --show zId:23
--~ for i=1,5 do seePatternStr(keVT[i]) end br() --show zId:24
--~ for i=1,10 do seePatternStr(kongVT[i]) end br() --show zId:25
--~ print(findTy({0,0,2,0,0},2)) --test findTy
--~ print(sameLv({0,3,0,0,0},3)) --test sameLv

--~ print(shengKeZhen({0,1,1,0,1})) br()
--~ print(shengKeZhen({1,1,0,0,1})) br()
--~ for i=1,#shengVT do print(shengKeZhen(shengVT[i])) end  br()--test all sheng-zhen
--~ for i=1,#keVT do print(shengKeZhen(keVT[i])) end  br()--test all ke-zhen
--~ print(matchFourTierZhen({0,1,0,2,1})) br() --test matchFourTierZhen

--H={11,21,31,41,51}
--H={17,18,19,20,21}
H=draw5()
see(H) br()
seeH(H) br()
play={}

print("test play")
for tier=1,5 do
	play[tier]={}
	for i=1,#sel[tier] do
		local hs
		play[tier][i]=selectH(H,sel[tier][i]) --sle[] -> play[]
--~ 		seeH(play[tier][i]) br()
		hs=getHandS(play[tier][i]) --play[] -> hs[]
--~ 		seeHandS(hs)
		play[tier][i].z,play[tier][i].v=getZid(hs) --match(hs[]) -> zId,val
		seePlay(play[tier][i])
	end
end

print("test match")
for tier=1,5 do
	for i=1,#play[tier] do
		seePlay(play[tier][i])
		if play[tier][i].z and match(play[tier][i],play[tier][i].z,play[tier][i].v) then
			pf("pass\n")
		else pf("NO PASS\n")
		end
	end
end
