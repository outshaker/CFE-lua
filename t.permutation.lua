-- test for Permutation
require "table"
require "string"

function pf(s,...) return io.write(string.format(s,...)) end

function p(m,n) return pp(1,m,n) end


--[[
function perm(low,up,n)
	local lists={}
	if n==0 then return nil
	elseif n==1 then
		local lists={}
		for i=low,up do
			table.insert(lists,cons(i,nil))
		end
		return lists
	elseif up-low+1==n then
		local list=nil
		for i=low,up do
			list=cons(i,list)
		end
		return list
	else
		table.insert(lists,cons(low,perm(low+1,up,n-1)))
		table.insert(lists,perm(low+1,up,n))
		return
	end
end
]]--


function pp(l,u,n)
	local t={}
	pf("in pp(%d,%d,%d)\n",l,u,n)
	if n==1 then --pick one and put all in list
		for i=l,u do table.insert(t,{i}) end
		printLists(t)
	elseif u-l+1==n then --pick all
		local tmp={}
		for i=l,u do table.insert(tmp,i) end
		table.insert(t,tmp)
		printLists(t)
	else --merge basic case
		for i=l,u-n+1 do -- pick i, find others
			pf("pick %d, get p(%d,%d)\n",i,u-l+1,n)
			local tmp={}
			tmp=pp(i+1,u,n-1)
			pf("add %d to lists\n",i)
			addToLists(i,tmp)
			printLists(tmp)
			pf("merge list to lists\n")
			for _,l in ipairs(tmp) do table.insert(t,l) end --add tmp to t
			printLists(t)
		end
	end
	pf("out pp(%d,%d,%d)\n",l,u,n)
	return t
end

function addToLists(x,lists)
	for _,list in ipairs(lists) do
		if type(list)=="table" then
			table.insert(list,x)
		else print("not table")
		end
	end
end

function printLists(ls)
	for _,l in ipairs(ls) do
		printList(l)
	end
	return
end

function printList(l)
	pf("(")
	for _,v in ipairs(l) do
		pf("%d ",v)
	end
	pf(")\n")
	return
end

function ppp(low,up,n) --text version
	pf("in ppp(%d,%d,%d)\n",low,up,n)
	if n==1 then
		for i=low,up do
			pf("add %d to state\n",i)
		end
		pf("exit ppp(%d,%d,%d)\n",low,up,n)
		return
	elseif up-low+1==n then
		pf("pick all, add %d..%d to state\n",low,up)
		pf("exit ppp(%d,%d,%d)\n",low,up,n)
		return
	else
		pf("in pick %d..%d\n\n",low,up-n+1)
		for i=low,up-n+1 do -- size
			pf("pick %d, call p(%d,%d,%d)\n",i,i+1,up,n-1)
			ppp(i+1,up,n-1)
			pf("merge result of p(%d,%d,%d) to state\n",i+1,up,n-1)
			--TODO: merge code
		end
		pf("exit ppp(%d,%d,%d)\n\n",low,up,n)
	end
end

printLists(p(5,3))
