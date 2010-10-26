-- Oscillator
-- some parts shamelessly copied from http://github.com/vrld/love-tunes/blob/master/live/main.lua


Oscillator = {}

function Oscillator:new(o, mode)
	o = o or {} 
	setmetatable(o, self)
	self.__index = self
	o.mode = mode or "sin"
	return o
end

function Oscillator:func(f,r)
	if self.mode == "sin" then
		-- placeholder : a simple sine wave
	 return math.sin(2 * math.pi *f)
	elseif self.mode == "saw" then
	-- a simple saw wave
		return f%1
	elseif self.mode == "square" then
	-- a simple square wave
	if f%1 < .5 then return -1 else return 1 end
	elseif self.mode == "whitenoise" then
	-- whitenoise
	return math.random()*2-1
	end
end

-- pitch helper stuff
--
--

Pitch = {}
function Pitch:new()
	o = o or {} 
	setmetatable(o, self)
	self.__index = self
	o.fractions = {
		["c"] = Pitch:step(-9),
		["c#"] = Pitch:step(-8),
		["d"] = Pitch:step(-7),
		["d#"] = Pitch:step(-6),
		["e"] = Pitch:step(-5),
		["f"] = Pitch:step(-4),
		["f#"] = Pitch:step(-3),
		["g"] = Pitch:step(-2),
		["g#"] = Pitch:step(-1),
		["a"] = 1,
		["a#"] = Pitch:step(1),
		["h"] = Pitch:step(2)
	}
	o.tone = "c"
	o.rate = self:base(4) * o.fractions[o.tone]
	return o
end

function Pitch:step(k)
    return math.pow(math.pow(2, 1/12), k)
end

function Pitch:base(n)
    return 440 * math.pow(2, n - 4)
end

function Pitch:set(tone, base)
	self.tone = tone
	self.rate = self:base(base) * self.fractions[self.tone]
end

-- not working
function Pitch:get(p, octave)
    local base = self:base(octave or 4)
    return Pitch.fractions[p] * base
end

-- Envelope
Envelope = {}

function Envelope:new(o)
	o = o or {} 
	setmetatable(o, self)
	self.__index = self
	return o
end



-- Synth
-- see above

Synth = {}

function Synth:new(o)
	o = o or {} 
	setmetatable(o, self)
	self.__index = self
	o.syn = {}
	o.len = 0.25
	o.amp = 1
	return o
end

function Synth:init()
	self.oscillator = Oscillator:new()
	self.amp = 0.5
	local pitch = Pitch:new()
	self.pitch = pitch
	self:makeSample()
end

function Synth:setOsc(mode)
	self.oscillator.mode = mode
	local pitch = Pitch:new()
	self.pitch = pitch
	self:makeSample()
end

function Synth:set(tone,base, len)
	self.pitch:set(tone,base or 4)
	self.len = len or 0.25
	self:makeSample()
end

function Synth:makeSample()
	local sr = 44100 --44100
	local rate = self.pitch.rate
	local len = self.len
	local samples = math.floor(len*sr)
    local sd = love.sound.newSoundData(samples, sr, 16, 1)
	local declick = 0
    k = 0
	for i = 0,samples do
        k = k + 1/sr
		if k > 2 * math.pi then k = k - 2*math.pi end
		local f = k*rate
		if declick<1 and i<500 then declick = declick + 2000/44100 end
		if i>samples-500 and declick>0 then declick = declick - 2000/44100 end
		-- first synth stage
		local osc = self.oscillator:func(f,k)* declick
		
		
		
		-- #################################
		-- insert auxiliary DSP stages here
		-- #################################
		
		-- sample distortion | cubic soft clipper https://ccrma.stanford.edu/~jos/pasp/Cubic_Soft_Clipper.html
		-- better distortion would need oversampling
		
		osc = 1.8 * osc
		if osc <= -1 then osc = -2/3 end
		if osc>-1 and osc<1 then osc = osc - math.pow(osc,3)/3 end
		if osc >= 1 then osc = 2/3 end
		
		
		osc = osc * self.amp
		sd:setSample(i, osc)
		
    end
	self.sd = sd
    return sd
end

function Synth:play()
	found = false
	i = 1
	while(not found) do
		i = i + 1
		local v = self.syn[i]
		if not v or v:isStopped() then
				v = love.audio.newSource(self.sd)
				table.insert(self.syn, v)
				love.audio.play(v)
				found = true
		end
	end
	
	-- normalize the volume on all playing synths, remove the stopped ones
	rem = 0
	for i,v in ipairs(self.syn) do
		v:setVolume(self.amp *  1/#self.syn)
		if v:isStopped() then rem = i end
	end
	if rem ~=0 then
		table.remove(self.syn,rem)
	end
end

