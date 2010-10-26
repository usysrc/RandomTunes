-- Scale Class
--
-- probleme mit enharmonischer verwechslung


Scale = {}
function Scale:new(o,tonic,scale)
	o = o or {} 
	setmetatable(o, self)
	self.__index = self
	o.distScaleMajor = {1,1,0.5,1,1,1,0.5,1}
	o.distScaleNaturalMinor = {1,0.5,1,1,0.5,1,1}
	o.scaleName = scale
	o.tonic = tonic
	o.refScale = {"c","c#","d","d#","e","f","f#","g","g#","a","a#","h"}
	o.refScaleRev = {["c"]=1,["c#"]=2,["d"]=3,["d#"]=4,["e"]=5,["f"]=6,["f#"]=7,["g"]=8,["g#"]=9,["a"]=10,["a#"]=11,["h"]=12}
	
	o.scale = {}
	if o.scaleName ==  "Major" or o.scaleName ==  "major" or 
	o.scaleName ==  "mj" or o.scaleName ==  "dur" or o.scaleName ==  "Dur" then
		local k = o.refScaleRev[o.tonic]
		for	i=1,8 do
			if k>12 then k = k - 12 end
			o.scale[i] = o.refScale[math.ceil(k)]
			k = k + 2 * o.distScaleMajor[i]
		end
	else
		local k = o.refScaleRev[o.tonic]
		for	i=1,7 do
			if k>12 then k = k - 12 end
			o.scale[i] = o.refScale[k]
			k = k + 2 * o.distScaleNaturalMinor[math.floor(i)]
		end
	end
	return o
end

-- return a tone
function Scale:getRandomDegree()
	k = math.random(0,7)
	
	return self:getDegree(k)
end

function Scale:setScale(tonic, scaleName)
	self.tonic = tonic
	self.scaleName = scaleName
end

function Scale:setRandomScale(tonic, scaleName)
	local t = math.random(10)+1
	self.tonic = tonic or self.refScale[t]
	if math.random(10)>5 then
		self.scaleName = scaleName or "minor"
	else
		self.scaleName = scaleName or "major"
	end
end

-- return the scale as table
function Scale:getScale()
	ret = {}
	for	i=1,8 do
			table.insert(ret,self.scale[i])
	end
	return ret
end

-- returns the scale as a string
function Scale:printScale()
	ret = ""
	for	i=1,8 do
			ret = ret.." "..self.scale[i]
	end
	return ret
end

-- gets the tone <number> halfsteps from tonic
function Scale:getTone(halfsteps)
	local k = self.refScaleRev[self.tonic]+halfsteps
	if k > 12 then k = k - 12 end
	local ret = self.refScale[k]
	return ret
end


function Scale:getChord(fundmntl,interv1, interv2)
	local note1 = self:getTone(fundmntl)
	local note2 = self:getTone(interv1)
	local note3 = self:getTone(interv1+interv2)
	
	return {note1,note2,note3}
end

function Scale:isMajor()
	if self.scaleName == "Major" or self.scaleName == "major" or self.scaleName =="mj" 
	or self.scaleName =="dur" or self.scaleName =="Dur" then
		return true
	end
end

function Scale:tonicChord()
	local ret = ""
	if self:isMajor() then
		-- tonika/kl.Terz/gr.Terz
		local chord = self:getChord(0,4,3)
		ret = ret..chord[1].."/"..chord[2].."/"..chord[3]
	elseif self.scaleName == "Minor" or "minor" or "min" then
		local chord = self:getChord(0,3,4)
		ret = ret..chord[1].."/"..chord[2].."/"..chord[3]
	end
	return ret
end

-- return the tone to a degree
function Scale:getDegree(degree)
	if self:isMajor() then
		local hfstps = 0
		for i=1,degree do
			hfstps = hfstps + 2 * self.distScaleMajor[i]
		end
		if hfstps > 12 then hfstps = hfstps - 12 end
		local k = self.refScaleRev[self.tonic]+hfstps
		if k>12 then k = k - 12 end
		local key = self.refScale[k]
		return key, hfstps
	else
		local hfstps = 0
		for i=1,degree do
			hfstps = hfstps + 2 * self.distScaleNaturalMinor[i]
		end
		if hfstps > 12 then hfstps = hfstps - 12 end
		local k = self.refScaleRev[self.tonic]+hfstps
		if k>12 then k = k - 12 end
		local key = self.refScale[k]
		return key, hfstps
	
	end
	
end

-- returns 6 degrees
function Scale:getAllDegrees()
	local ret = ""
	for i=0,6 do
		ret = ret..","..self:getDegree(i)
	end
	return ret
end

-- return major chords of degree on scale
function Scale:getChordOfDegree(degree)
	if self:isMajor() then
		-- todo: verminderter akkord
		local chord = {}
		if degree == 1 or degree == 4 or degree == 5 then
			degree = degree - 1
			local ret = ""
			local x,b = self:getDegree(degree)
			local c =  b+4
			local d =  3
			chord = self:getChord(b,c,d)
		elseif degree == 7 then
			degree = degree - 1
			local ret = ""
			local x,b = self:getDegree(degree)
			local c =  b+3
			local d =  3
			chord = self:getChord(b,c,d)
		else
			degree = degree - 1
			local ret = ""
			local x,b = self:getDegree(degree)
			local c =  b+3
			local d =  4
			chord = self:getChord(b,c,d)
		end
		return chord
	else
		local chord = {}
		if degree == 1 or degree == 4 or degree == 5 then
			degree = degree - 1
			local ret = ""
			local x,b = self:getDegree(degree)
			local c =  b+3
			local d =  4
			chord = self:getChord(b,c,d)
		elseif degree == 2 then
			degree = degree - 1
			local ret = ""
			local x,b = self:getDegree(degree)
			local c =  b+3
			local d =  3
			chord = self:getChord(b,c,d)
		else
			degree = degree - 1
			local ret = ""
			local x,b = self:getDegree(degree)
			local c =  b+4
			local d =  3
			chord = self:getChord(b,c,d)
		end
		
		return chord
	end
end