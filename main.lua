-- 
--
-- TODO: Lage, MOLL!!!?
require "Scale"
require "Oscillator"
math.randomseed(os.time())
math.random();math.random();math.random()
function love.load()
	CDur = Scale:new(CDur,"e","minor")
	
	-- a small lead synth
	synthie = Synth:new()
	synthie:init()
	synthie:setOsc("sin")
	
	-- a small bass synth
	bass = Synth:new()
	bass:init()
	bass:setOsc("square")
	
	-- some snare synthie
	snaresynth = Synth:new()
	snaresynth:init()
	snaresynth:setOsc("whitenoise")
	snaresynth:set("c", 3, 0.03)
	
	bpm = 120
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

	if t>=(1/8) * 1/(bpm/60) then
		
		-- on 1/32th trigger
		if g%1 == 0 then
			-- arps make everything better
			arp = arp + udwn
			if arp == 3 then udwn= -1 end
			if arp ==1 then udwn = 1 end
			synthie:set(chord[arp], 4+g%3,(1/8)*(1/(bpm/60)))
			synthie:play()

		end
		
		if g%2 == 0 then
			bass:set(chord[1], 2+g%3,(1/4)*1/(bpm/60))
			bass:play()
		end
		
		-- on beat(1/4th) trigger
		if g%8 == 0 then
			--snaresynth:set("c", 3, 0.02)
			snaresynth:play()
			
			-- for the arps
			n = n + 1
			if n >2 then n = 0 end
			
		end
		
		-- on new bar trigger
		if g%32 == 0 then
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
			--synthie:set(chord[2], 4, 2 *1/(bpm/60))
			--synthie:play()
			--synthie:set(chord[1], 2,4*1/(bpm/60))
			--synthie:play()
			--synthie:setOsc("saw")
			
		end
		g = g + 1
		if g > 32 then g = 1 end
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
	love.graphics.print("Key: "..CDur.tonic.."-"..CDur.scaleName,300,280)
	love.graphics.print("left mousebutton: random major key,\nright mousebutton: random minor key\nmousewheel: tempo up/down", 300, 320)
	--[[
	-------------------- DON'T MIND THIS ---------------------------
	love.graphics.print("Tonic Major Chord:"..CDur:tonicChord(), 300, 320)
	love.graphics.print("All Degrees:"..CDur:getAllDegrees(),300,360)
	
	love.graphics.print("BPM: "..bpm, 300,380)
	love.graphics.print("Synthesizer 1 |\n Frequency:"..synthie.pitch.rate, 300, 400 )
	love.graphics.print("Polyphony:"..#synthie.syn,300,440)
	--]]
	love.graphics.print("Played Chord:"..chord[1].."/"..chord[2].."/"..chord[3],300,400)	
	
	love.graphics.scale(7)
	for i=1,100 do
		love.graphics.point(i*1, 300/7 + synthie.sd:getSample(l*100+i*10)*50)
	end
end