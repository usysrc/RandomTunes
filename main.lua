-- 
--
-- TODO: Lage, MOLL!!!?
require "Scale"
require "Oscillator"
math.randomseed(os.time())
math.random();math.random();math.random()
function love.load()
	CDur = Scale:new(CDur,"f","minor")
	
	-- a small lead synth
	lead = Synth:new()
	lead:init()
	lead.amp = 0.6
	lead:setOsc("saw")
	
	-- a small sin synth
	synthie = Synth:new()
	synthie:init()
	synthie.amp = 0.2
	synthie:setOsc("sin")
	
	-- a small bass synth
	bass = Synth:new()
	bass:init()
	bass:setOsc("square")
	
	-- a basic bassdrum
	bassdrum = Synth:new()
	bassdrum:init()
	bassdrum:setOsc("bassdrum")
	bassdrum:set("h",0, 0.1)
	bassdrum.amp = 0.3 
	
	-- some snare synthie
	snaresynth = Synth:new()
	snaresynth:init()
	snaresynth:setOsc("whitenoise")
	snaresynth:set("c", 3, 0.03)
	bars = 1
	bpm = 10
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
	volume = 0
	love.audio.setVolume(volume)
end

function love.update(dt)
	t = t + dt
	-- for 1/8th or 1/16th trigger
	--
	--
	if volume < 1 then
		volume = volume + dt * 0.1
		love.audio.setVolume(volume)
	end
	if bpm < 120 then
		bpm = bpm + dt * 10
	end
	if t>=(1/8) * 1/(bpm/60) then
		
		-- on 1/32th trigger
		if g%1 == 0 then
			-- arps make everything better
			arp = arp + udwn
			if arp == 3 then udwn= -1 end
			if arp ==1 then udwn = 1 end
			synthie:set(chord[arp], 4+n,(1/8)*(1/(bpm/60)))
			synthie:play()

		end
		
		if g%2 == 0 then
			bass:set(chord[1], 2,(1/5)*1/(bpm/60))
			bass:play()
		end
		-- on beat(1/4th) trigger
		if g%8	== 0 then
			bassdrum:play()
		end
		
		-- on beat(1/4th) trigger
		if g%4 == 0 then
			snaresynth:play()
			
			-- for the arps
			n = n + 1
			if n >2 then n = 0 end
			if math.random(0,10)>5 then
				--lead:set(chord[2], 4,2*(1/(bpm/60)))
				--lead:play()
			end
		end
		
		-- on new bar trigger
		if g%32 == 0 then
			-- random degree harmony
			degr = math.random(7)--degr + 2*math.random(0,1)-1
			if degr>6 then degr = 1 end
			if degr<1 then degr = 6 end
			x = x + 1
			if x >#fourchords then x = 0 end
			
			chord = CDur:getChordOfDegree(degr)
			if bars> 4 then
				lead:set(chord[math.random(2,3)], 4,4*(1/(bpm/60)))
				lead:play()
			end
		end
		g = g + 1
		if g > 32 then 
			bars = bars + 1
			g = 1 
		end

		t = 0
	end
	l = l +10* dt
	if l>math.pi*2 then l = l - math.pi*2 end
end

function love.mousepressed(x,y,button)
	if button == "wd" then
		bpm = bpm + 10
	end
	if button == "wu" then
		bpm = bpm - 10
	end
	if button == "r" then
		CDur:setRandomScale(nil, "minor")
	end
	if button == "l" then
		CDur:setRandomScale(nil, "major")
	end
end

function love.draw()
	love.graphics.print("left mousebutton: random major key,\nright mousebutton: random minor key\nmousewheel: tempo up/down", 0, 20)
	
	love.graphics.print("Key: "..CDur.tonic.."-"..CDur.scaleName,0,500)
	love.graphics.print("Played Chord:"..chord[1].."/"..chord[2].."/"..chord[3],0,520)	
	
	--[[
	-------------------- DON'T MIND THIS ---------------------------
	love.graphics.print("Tonic Major Chord:"..CDur:tonicChord(), 300, 320)
	love.graphics.print("All Degrees:"..CDur:getAllDegrees(),300,360)
	
	love.graphics.print("BPM: "..bpm, 300,380)
	love.graphics.print("Synthesizer 1 |\n Frequency:"..synthie.pitch.rate, 300, 400 )
	love.graphics.print("Polyphony:"..#synthie.syn,300,440)
	--]]
	
	-- crazy waveforms
	love.graphics.scale(7)
	local points = {}
	for i=1,100 do
		points[#points+1] = i*1
		points[#points+1] = 300/7 + synthie.sd:getSample(l*100+i*10)*50
	end
	love.graphics.line(points)
end