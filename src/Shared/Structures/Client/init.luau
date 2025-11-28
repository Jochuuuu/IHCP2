local NOMBRES_HOMBRE = {
	"Carlos","José","Luis","Pedro","Miguel","Antonio","Francisco","Juan",
	"Manuel","David","Javier","Rafael","Sergio","Fernando","Daniel","Alejandro",
	"Roberto","Ángel"
}

local NOMBRES_MUJER = {
	"María","Ana","Carmen","Laura","Isabel","Elena","Rosa","Patricia","Sofía",
	"Lucía","Marta","Paula","Andrea","Cristina","Sara","Teresa","Beatriz","Silvia"
}

local APELLIDOS = {
	"Garcia","Fernandez","Gonzalez","Rodriguez","Lopez","Martinez","Sanchez",
	"Pérez","Gomez","Diaz","Torres","Flores","Ramos","Castillo","Campos",
	"Romero","Herrera","Vargas","Reyes","Morales","Castro"
}
 
 
 
local TIPOS_CLIENTE = {
	Rapido = {
		nombre = "Rápido",
		tiempoLimite = 36,  
  	},
	Normal = {
		nombre = "Normal", 
		tiempoLimite = 50,  
  	},
	Paciente = {
		nombre = "Paciente",
		tiempoLimite = 70,  
  	},
	Impaciente = {
		nombre = "Impaciente",
		tiempoLimite = 25,  
  	}
}

export type Client = {
	priority: number,
	name: string,
	gender: string,
	char: any?, -- Character/modelo del jugador 
	tag: any?,
	tel : string,
	dni: string,
	-- Métodos
	getPriority: (self: Client) -> number,
	getName: (self: Client) -> string,
	toString: (self: Client) -> string,

	-- Metamétodos internos
	__lt: (self: Client, other: Client) -> boolean,
	__le: (self: Client, other: Client) -> boolean,
}


local function generarNombreAleatorio(genero: string?)
	genero = genero or "Hombre" -- por defecto

	local nombreLista
	if genero == "Mujer" then
		nombreLista = NOMBRES_MUJER
	else
		nombreLista = NOMBRES_HOMBRE
	end

	local nombre = nombreLista[math.random(1, #nombreLista)]
	local apellido = APELLIDOS[math.random(1, #APELLIDOS)]

	return nombre .. " " .. apellido
end


local function GenerarSecNumeros(caracteres)
	local dni = ""
	for _ = 1, caracteres do
		dni ..= tostring(math.random(0, 9))
	end
	return dni
end


local Client = {}
Client.__index = Client

 function Client:__lt(other: Client): boolean
	return self.priority < other.priority
end

 function Client:__le(other: Client): boolean
	return self.priority <= other.priority
end

function Client.new(priority: number?, genero: string?, tipoCliente: string?): Client
	local gender = genero or "Hombre"
	local randomName = generarNombreAleatorio(gender)
	
	local tipo = tipoCliente or (function()
		local tipos = {"Rapido", "Normal", "Paciente", "Impaciente"}
		local pesos = {15, 50, 25, 10}  -- % de probabilidad
		local total = 0
		local rand = math.random(1, 100)

		for i, peso in ipairs(pesos) do
			total = total + peso
			if rand <= total then
				return tipos[i]
			end
		end
		return "Normal"
	end)()
	
 

	local self = setmetatable({
		priority = priority or 1,  
		name = randomName,
		gender = gender,
		dni = GenerarSecNumeros(8),
		tel = GenerarSecNumeros(9),
		char = nil,  
		problema = " INFORME DEL CLIENTE ",
		tag = nil,
		tipo = tipo,
	}, Client)

	return self :: any
end

-- Obtener prioridad
function Client:getPriority(): number
	return self.priority
end

function Client:CalcularPuntuacion(tiempo: number): number
	
	local tipoData = TIPOS_CLIENTE[self.tipo]
	
	local tiempoLimite = tipoData.tiempoLimite

	local porcentaje = tiempo / tiempoLimite

	local calificacion = 0

	if porcentaje <= 0.3 then
		-- Súper rápido (0-30% del tiempo límite)
		-- Cliente muy satisfecho: 5.0 estrellas
		calificacion = 5.0

	elseif porcentaje <= 0.5 then
		-- Rápido (30-50%)
		-- Interpolación: 5.0 → 4.5
		local factor = (porcentaje - 0.3) / 0.2
		calificacion = 5.0 - (factor * 0.5)

	elseif porcentaje <= 0.7 then
		-- Bueno (50-70%)
		-- Interpolación: 4.5 → 3.5
		local factor = (porcentaje - 0.5) / 0.2
		calificacion = 4.5 - (factor * 1.0)

	elseif porcentaje <= 1.0 then
		-- Aceptable (70-100%)
		-- Interpolación: 3.5 → 2.5
		local factor = (porcentaje - 0.7) / 0.3
		calificacion = 3.5 - (factor * 1.0)

	elseif porcentaje <= 1.3 then
		-- Lento (100-130%)
		-- Interpolación: 2.5 → 1.5
		local factor = (porcentaje - 1.0) / 0.3
		calificacion = 2.5 - (factor * 1.0)

	else
		-- Muy lento (>130%)
		-- Cliente muy insatisfecho: 1.0 estrella
		calificacion = 1.0
	end

	calificacion = math.floor(calificacion * 10 + 0.5) / 10

	calificacion = math.clamp(calificacion, 1.0, 5.0)

	return calificacion
end


function Client:Wave() : boolean

	if not self.char then return false end 

	local animaciones = {"rbxassetid://73906788644931","rbxassetid://86074172929360","rbxassetid://126258362222217"}

	local animacion = Instance.new("Animation")
	animacion.AnimationId = animaciones[math.random(1,#animaciones)]

	local animTrack = self.char.Humanoid:LoadAnimation(animacion)
	animTrack:Play()

	task.delay(1.45, function()
		animTrack:Stop()
	end)

    animacion:Destroy()

	return true
end

-- Obtener nombre
function Client:getName(): string
	return self.name
end

-- Representación en texto
function Client:toString(): string
	return string.format("Client(%s, priority=%d)", self.name, self.priority)
end

return Client
 