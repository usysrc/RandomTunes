-- 
--
-- TODO: Lage, MOLL!!!?
require "Scale"
require "Oscillator"
math.randomseed(os.time())
math.random();math.random();math.random()
function love.load()
	CDur = Scale:new(CDur,"e","minor")
	
	-- a small lead synthie
	synthie = Synth:new()
	synthie:init()
	synthie:setOsc("sin")
	
	-- some snare synthie
	snaresynth = Synth:new()
	snaresynth:init()
	snaresynth:setOsc("whitenoise")
	snaresynth:set("c", 3, 0.03)
	
	bpm = 240
	fourchords = {1,4,5,1}
	udwn = 1
	n = 0
	t = 0
	arp = 0
	half = 1
	l = 0
	g = 0
	degr = 1
	chord = CDur:getChordOfDegree(degr)
	x = 1
end

function love.update(dt)
	t = t + dt
	-- for 1/8th or 1/16th trigger
	--
	--

	if t>=(1/4) * 1/(bpm/60) then
		
		-- on 1/16th
		if g%1 == 0 then
			arp = arp + udwn
			if arp == 3 then udwn= -1 end
			if arp ==1 then udwn = 1 end
			synthie:set(chord[arp], 4+n,(1/4)*(1/(bpm/60)))
			synthie:play()
		end
	
		-- on beat(1/4th) trigger
		if g%4 == 0 then
			--snaresynth:set("c", 3, 0.02)
			--snaresynth:play()
			n = n + 1
			if n >2 then n = 0 end
		end
		
		if g%16 == 0 then
			-- random degree harmony
			degr = math.random(7)--degr + 2*math.random(0,1)-1
			if degr>7 then degr = degr-7 end
			if degr<1 then degr = degr + 7 end
			x = x + 1
			if x >#fourchords then x = 0 end
			
			chord = CDur:getChordOfDegree(degr)
			--synthie:set(chord[1], 4,(1/(bpm/60)))
			--synthie:play()
			--synthie:setOsc("sin")
			synthie:set(chord[2], 4, 2 *1/(bpm/60))
			synthie:play()
			synthie:set(chord[1], 2,4*1/(bpm/60))
			synthie:play()
			--synthie:setOsc("saw")
			
		end
		g = g + 1
		if g > 16 then g = 1 end
		t = 0
	end
	l = l +10* dt
	if l>math.pi*2 then l = l - math.pi*2 end
end

function love.mousepressed(x,y,button)
	if button == "wd" then
		degr = degr + 1
	end
	if button == "wu" then
		degr = degr - 1
	end
end
	
function love.draw()
	love.graphics.print(CDur.tonic.."-"..CDur.scaleName,300,280)
	--[[
	-------------------- DON'T MIND THIS ---------------------------
	love.graphics.print("Tonic Major Chord:"..CDur:tonicChord(), 300, 320)
	love.graphics.print("All Degrees:"..CDur:getAllDegrees(),300,360)
	
	love.graphics.print("BPM: "..bpm, 300,380)
	love.graphics.print("Synthesizer 1 |\n Frequency:"..synthie.pitch.rate, 300, 400 )
	love.graphics.print("Polyphony:"..#synthie.syn,300,440)
	--]]
	love.graphics.print("Played Chord:"..chord[1].."/"..chord[2].."/"..chord[3],300,340)	
	
	size = 100
	for i=1,100 do
		love.graphics.point(100+i*2, 100 + synthie.sd:getSample(l*100+i*10)*100)
	end
end