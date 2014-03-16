class 'MySave'

function MySave:__init()
	SaveMySpawnInteger	=	360
	SaveMySpawnTimer	=	Timer()

	Events:Subscribe("Render", self, self.SaveMyLocation)
end

function MySave:SaveMyLocation()
	if SaveMySpawnTimer:GetSeconds() >= SaveMySpawnInteger then
		SaveMySpawnTimer:Restart()
		Network:Send("SaveMyLocation", LocalPlayer)
	end
end

mySave = MySave()