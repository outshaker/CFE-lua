-- zId in (1,25)
-- c in (Ty,Lv) Ty in (1,5) Lv in (1,5)
-- c {["Ty"]=s,["Lv"]=l}

--[v] mkC(Ty,Lv) > return c
--[v] mkC(id) > return c

--[v] c.getTy() > return Ty of c
--[v] c.getLv() > return Lv of c

-- play.add(cId) > add cId to play
-- play.remove(cId) > remove cId from play

-- play.match() > zId[]: match this play
-- play.match(zId) > bool: zId match cId[] ?

-- hand.match() > zId[]: match this hand
-- {zId:h[], zId:h[], zId:h[], ...}

function _isC(c) return c and _isTy(C.getTy(c)) and _isLv(C.getLv(c)) end

function _isTy(x)
	if not type(x)=="string" then return false end
	local s={"G","S","M","H","T"}
	for i=1,5 do
		if x==s[i] then return true end
	end
	return false
end

function _isLv(x)
	if not type(x)=="number" then return false end
	return x>=1 and x<=5
end

C={}
function C.getTy(c) if c and type(c)=="table" then return c["Ty"] else return nil end end
function C.getLv(c) if c and type(c)=="table" then return c["Lv"] else return nil end end

function _isCId(cId) return cId and type(cId)=="number" and cId>=1 and cId<=25 end

function printC(c)
	if _isC(c) then print(c["Ty"]..c["Lv"])
	elseif _isCId(c) then printC(_mkC(c)) --if c is cId, then make C and print it.
	end
end

function mkC(arg1,arg2)
	if _isTy(arg1) and _isLv(arg2) then --(Ty,Lv)
		return {["Ty"]=arg1,["Lv"]=arg2}
	elseif _isCId(arg1) then --(cId)
		return _mkC(arg1)
	elseif arg1==nil and arg2==nil then --()
		local rcId=math.random(25)
		return _mkC(rcId)
	end
end

function _mkC(cId)
	local s={"T","G","S","M","H"}
	local ty,lv
	--id:12345->Ty loc:23451,i>Ty:51234
	ty=cId%5+1
	lv=math.floor((cId-1)/5)+1 --(1,25)>(1,5)

	--print(ty,lv) --DEBUG
	return {["Ty"]=s[ty],["Lv"]=lv}
end

function toCid(c)
	if _isC(c) then
		local s={"G","S","M","H","T"}
		local ty_s=C.getTy(c)
		local ty
		for i=1,5 do
			if s[i]==ty_s then ty=i break end
		end
		return (C.getLv(c)-1)*5+ty --(1,25)
	else return 0
	end
end

function _map(f,x) return f(x) end

function map(f,t)
	if t and type(t)=="table" and type(f)=="function" then
		local m={}
		for i,v in ipairs(t) do
			m[i]=_map(f,v)
			print(i,v,m[i]) --test
		end
		return m --m[i] WTF?!
	end
end

function reduce(f,t)
	if t and type(t)=="table" then
		local s
		local now,nxt
		for i=1,table.getn(t) do
			s=f(s,t[i])
		end
		return s
	end
end

function allSame(t)
	local s=_mkSum(t)
	printT(t)
	printT(s)
	for i,v in pairs(s) do --NOTE: ipairs(s) can't get value of s[0]
		print(i,v)
		if v and v>0 then return v==table.getn(t) end
	end
	return false
end

function allDiff(t)
	local s=_mkSum(t)
	local n=0
	for i,v in pairs(t) do
		if v and v>0 then n=n+1 end
	end
	return n==table.getn(t)
end


function _mkSum(t) -- make summary table
	if t==nil or type(t)~="table" then return nil end
	local s={}
	for i,v in ipairs(t) do
		if s[v]==nil then s[v]=1
		elseif s[v] then s[v]=s[v]+1
		end
	end
	return s
end

function matchN(t,n) if type(t)=="table" and type(n)=="number" then return table.getn(t)==n end end

function matchV(u,v)
	if type(u)=="table" and type(v)=="table" and table.getn(u)==table.getn(v) then
		for i=1,table.getn(u) do
			if u[i]~= v[i] then return false end
		end
		return true
	end
end

function printT(t)
	if type(t)=="table" then
		io.write("{")
		for i,v in pairs(t) do
			io.write(i,":",v," ")
		end
		io.write("} \n")
	end
end

-- test all cId
print("test all cId")
for i=1,25 do printC(mkC(i)) end

--test mkC(ty,lv)
print("test mkC(ty,lv)")
printC(mkC("G",3))

--test toCid
print("test toCid")
local c={}
for i=1,25 do c[i]=mkC(i) end
for i=1,25 do print(toCid(c[i])) end

--test printC(Cid)
print("test printC(Cid)")
for i=1,25 do printC(i) end

--test map(t,f)
print("test map(t,f)")
double=function (x) return x*2 end
printT(map(double,{1,2,3,4}))

-- test map of getTy
print("test map of getTy")
local f=C.getTy
local t={}
for i=2,15,5 do --make {2,7,12}
	print(i)
	table.insert(t,mkC(i))
end

for i in ipairs(t) do printC(t[i]) end
printT(map(f,t))

--test matchN
print("test matchN")
print(matchN({1,2,3},3))
print(matchN({{},{},{}},3))

--test matchV
print("test matchV")
print(matchV({2,1,0,0,1},{2,1,0,0,1}))
print(matchV({1,1,1},{1,1,1}))

--test mkSum
print("test mkSum")
printT(_mkSum({1,1,2,0,1,0}))

--test allSame
print("test allSame")
print(allSame({0,0,0,0}))
print(allSame({1,1,1,1}))

--test allDiff
print("test allDiff")
print(allDiff({3,1,2}))

--test Sen Zen
print("test Sen Zen")
v={1,2,3}
vs={{1,2,3},{2,3,4},{3,4,5},{4,5,1},{5,1,2}}
for i=1,5 do
	if matchV(v,vs[i]) then print("match",i) break end
end
