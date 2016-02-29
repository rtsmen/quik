Settings = {
Name = "*PSAR (Parabolic SAR)", 
round = "off",
Step = 0.02,
Max_step = 0.2, 
line = {{
		Name = "PSAR", 
		Type = TYPE_POINT, 
		Color = RGB(0, 255, 255),
		Width = 3
		}
		}
}

function Init() 
	func = PSAR()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end
function PSAR() --Parabolic SAR ("PSAR")
	local psar={}
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local Step = (Fsettings.Step or 0.02)
local Max_step = (Fsettings.Max_step or 0.2)
local R = (Fsettings.round or "off")
psar[I] = nil
local h=Value(I,"High",ds)
local l=Value(I,"Low",ds)
if I==2 then
	psar[I] = h
	long=true
	af = Step
	ep = l
	hp = h
	lp = l
end
if I>2 then
	if long then
		psar[I] = psar[I-1] + af * ( hp - psar[I-1])
	else
		psar[I] = psar[I-1] + af * ( lp - psar[I-1])
	end
	reverse = false
	if long then
		if (l < psar[I]) then
			long = false 
			reverse = true
			psar [I] =  hp
			lp = l
			af = Step
		end
	else
		if (h > psar[I]) then
			long = true 
			reverse = true
			psar [I] = lp
			hp = h
			af = Step
		end
	end
	if not reverse then
		if long then
			if (h > hp) then
				hp = h
				af = af + Step
				if (af > Max_step) then af = Max_step end
			end
			if (Value(I-1,"Low",ds) < psar[I]) then psar[I] = Value(I-1,"Low",ds) end
			if (Value(I-2,"Low",ds) < psar[I]) then psar[I] = Value(I-2,"Low",ds) end
		else
			if (l < lp) then
				lp = l 
				af = af + Step
				if (af > Max_step) then af = Max_step end
			end
			if (Value(I-1,"High",ds) > psar[I]) then psar[I] = Value(I-1,"High",ds) end
			if (Value(I-2,"High",ds) > psar[I]) then psar[I] = Value(I-2,"High",ds) end
		end
	end
end
return rounding(psar[I], R)
end
end

function rounding(num, round) 
if round and string.upper(round)== "ON" then round=0 end
if num and tonumber(round) then
	local mult = 10^round
	if num >= 0 then return math.floor(num * mult + 0.5) / mult
	else return math.ceil(num * mult - 0.5) / mult end
else return num end
end

function Value(I,VType,ds) 
local Out = nil
VType=(VType and string.upper(string.sub(VType,1,1))) or "A"
	if VType == "O" then		--Open
		Out = (O and O(I)) or (ds and ds:O(I))
	elseif VType == "H" then 	--High
		Out = (H and H(I)) or (ds and ds:H(I))
	elseif VType == "L" then	--Low
		Out = (L and L(I)) or (ds and ds:L(I))
	elseif VType == "C" then	--Close
		Out = (C and C(I)) or (ds and ds:C(I))
	elseif VType == "V" then	--Volume
		Out = (V and V(I)) or (ds and ds:V(I)) 
	elseif VType == "M" then	--Median
		Out = ((Value(I,"H",ds) + Value(I,"L",ds)) / 2)
	elseif VType == "T" then	--Typical
		Out = ((Value(I,"M",ds) * 2 + Value(I,"C",ds))/3)
	elseif VType == "W" then	--Weighted
		Out = ((Value(I,"T",ds) * 3 + Value(I,"O",ds))/4) 
	elseif VType == "D" then	--Difference
		Out = (Value(I,"H",ds) - Value(I,"L",ds))
	elseif VType == "A" then	--Any
		if ds then Out = ds[I] else Out = nil end
	end
return Out
end