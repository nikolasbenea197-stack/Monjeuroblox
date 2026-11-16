--[[
	ŒUF CÉLESTE (Œuf de cristal violet avec couronne, ailes et anneaux dorés)
	------------------------------------------------------------------------
	COMMENT L'UTILISER :
	1. Dans Roblox Studio, ouvre l'Explorer.
	2. Clic droit sur "ServerScriptService" > Insert Object > Script.
	3. Supprime le texte par défaut et colle TOUT ce script.
	4. Appuie sur Play : l'œuf apparaît à la position POSITION ci-dessous.

	Tu peux changer la position, la taille et le prix dans la section CONFIG.
	Les joueurs peuvent appuyer sur "E" près de l'œuf pour l'ouvrir.
]]

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------
local POSITION = Vector3.new(0, 0, 0) -- où poser le socle (au sol)
local TAILLE = 1                      -- 1 = normal, 2 = deux fois plus grand
local NOM_OEUF = "Œuf Céleste"
local PRIX = 500                      -- prix en "Coins" (leaderstats)

-- Pets possibles et leur chance (en %)
local PETS = {
	{ nom = "Licorne Étoilée", chance = 50, couleur = Color3.fromRGB(230, 200, 255) },
	{ nom = "Griffon Doré",    chance = 30, couleur = Color3.fromRGB(255, 205, 80) },
	{ nom = "Dragon Améthyste",chance = 15, couleur = Color3.fromRGB(150, 70, 255) },
	{ nom = "Ange Céleste",    chance = 5,  couleur = Color3.fromRGB(255, 255, 255) },
}

----------------------------------------------------------------------
-- COULEURS
----------------------------------------------------------------------
local OR = Color3.fromRGB(255, 196, 60)
local OR_CLAIR = Color3.fromRGB(255, 230, 140)
local VIOLET = Color3.fromRGB(160, 80, 255)
local VIOLET_CLAIR = Color3.fromRGB(215, 180, 255)
local BLANC_VIOLET = Color3.fromRGB(235, 225, 255)
local PIERRE = Color3.fromRGB(200, 190, 240)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

----------------------------------------------------------------------
-- OUTILS
----------------------------------------------------------------------
local modele = Instance.new("Model")
modele.Name = NOM_OEUF

local base = Instance.new("Part")
base.Name = "Base"
base.Anchored = true
base.Transparency = 1
base.CanCollide = false
base.Size = Vector3.new(1, 1, 1)
base.CFrame = CFrame.new(POSITION)
base.Parent = modele
modele.PrimaryPart = base

local function S(v) return v * TAILLE end
local ORIGINE = CFrame.new(POSITION)

-- Crée une pièce
local function piece(props)
	local p = Instance.new(props.Classe or "Part")
	p.Anchored = true
	p.CanCollide = props.Collision or false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = props.Matiere or Enum.Material.SmoothPlastic
	p.Color = props.Couleur or Color3.new(1, 1, 1)
	p.Transparency = props.Transparence or 0
	p.Reflectance = props.Reflet or 0
	if props.Forme then p.Shape = props.Forme end
	p.Size = props.Taille
	p.CFrame = ORIGINE * props.CF
	p.Name = props.Nom or "Piece"
	p.Parent = props.Parent or modele
	if props.Lumiere then
		local l = Instance.new("PointLight")
		l.Color = props.Couleur or Color3.new(1, 1, 1)
		l.Brightness = props.Lumiere
		l.Range = S(10)
		l.Parent = p
	end
	return p
end

-- Gemme en forme de losange (cube tourné à 45°)
local function gemme(cf, taille, parent)
	local g = piece({
		Nom = "Gemme", Taille = Vector3.new(S(taille), S(taille), S(taille * 0.4)),
		CF = cf * CFrame.Angles(0, 0, math.rad(45)),
		Couleur = VIOLET, Matiere = Enum.Material.Neon, Parent = parent,
	})
	-- cadre doré autour
	piece({
		Nom = "CadreGemme", Taille = Vector3.new(S(taille * 1.35), S(taille * 1.35), S(taille * 0.3)),
		CF = cf * CFrame.new(0, 0, S(0.05)) * CFrame.Angles(0, 0, math.rad(45)),
		Couleur = OR, Matiere = Enum.Material.Metal, Reflet = 0.2, Parent = parent,
	})
	return g
end

-- Anneau (cercle de petits segments)
local function anneau(cf, rayon, epaisseur, nbSegments, couleur, matiere, parent)
	local dossier = Instance.new("Model")
	dossier.Name = "Anneau"
	dossier.Parent = parent or modele
	local longueur = 2 * math.pi * rayon / nbSegments * 1.08
	for i = 1, nbSegments do
		local a = (i / nbSegments) * math.pi * 2
		piece({
			Nom = "Segment",
			Taille = Vector3.new(longueur, epaisseur, epaisseur),
			CF = cf * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -rayon),
			Couleur = couleur, Matiere = matiere or Enum.Material.Neon,
			Parent = dossier,
		})
	end
	return dossier
end

-- Cristal pointu (corps + pointe)
local function cristal(cf, hauteur, parent)
	local c = Instance.new("Model")
	c.Name = "Cristal"
	c.Parent = parent or modele
	piece({
		Nom = "Corps", Taille = Vector3.new(S(hauteur * 0.45), S(hauteur * 0.7), S(hauteur * 0.45)),
		CF = cf * CFrame.new(0, S(hauteur * 0.35), 0) * CFrame.Angles(0, math.rad(45), 0),
		Couleur = VIOLET_CLAIR, Matiere = Enum.Material.Glass, Transparence = 0.15, Parent = c,
	})
	-- pointe : un cube posé sur un coin pour faire un sommet pointu
	local pointe = piece({
		Nom = "Pointe", Taille = Vector3.new(S(hauteur * 0.32), S(hauteur * 0.32), S(hauteur * 0.32)),
		CF = cf * CFrame.new(0, S(hauteur * 0.72), 0) * CFrame.Angles(math.rad(45), 0, math.rad(35.26)),
		Couleur = VIOLET, Matiere = Enum.Material.Neon, Parent = c,
	})
	local l = Instance.new("PointLight")
	l.Color = VIOLET
	l.Brightness = 1.5
	l.Range = S(8)
	l.Parent = pointe
	return c
end

----------------------------------------------------------------------
-- 1) LE SOCLE (plateforme ronde violette et dorée)
----------------------------------------------------------------------
piece({ Nom = "SolNuage", Classe = "Part", Forme = Enum.PartType.Cylinder,
	Taille = Vector3.new(S(1), S(30), S(30)), CF = CFrame.new(0, S(0.5), 0) * CFrame.Angles(0, 0, math.rad(90)),
	Couleur = PIERRE, Matiere = Enum.Material.Marble, Collision = true })

piece({ Nom = "SocleBas", Forme = Enum.PartType.Cylinder,
	Taille = Vector3.new(S(1.5), S(20), S(20)), CF = CFrame.new(0, S(1.75), 0) * CFrame.Angles(0, 0, math.rad(90)),
	Couleur = Color3.fromRGB(110, 70, 220), Matiere = Enum.Material.SmoothPlastic, Collision = true })

piece({ Nom = "BordOr", Forme = Enum.PartType.Cylinder,
	Taille = Vector3.new(S(0.5), S(20.6), S(20.6)), CF = CFrame.new(0, S(2.6), 0) * CFrame.Angles(0, 0, math.rad(90)),
	Couleur = OR, Matiere = Enum.Material.Metal, Reflet = 0.25, Collision = true })

piece({ Nom = "SocleHaut", Forme = Enum.PartType.Cylinder,
	Taille = Vector3.new(S(1), S(16), S(16)), CF = CFrame.new(0, S(3.3), 0) * CFrame.Angles(0, 0, math.rad(90)),
	Couleur = BLANC_VIOLET, Matiere = Enum.Material.Marble, Collision = true })

local portail = piece({ Nom = "PortailLumineux", Forme = Enum.PartType.Cylinder,
	Taille = Vector3.new(S(0.2), S(11), S(11)), CF = CFrame.new(0, S(3.85), 0) * CFrame.Angles(0, 0, math.rad(90)),
	Couleur = Color3.fromRGB(170, 220, 255), Matiere = Enum.Material.Neon, Transparence = 0.2, Lumiere = 3 })

-- Anneau lumineux au sol
anneau(CFrame.new(0, S(1.05), 0), S(14), S(0.2), 48, OR_CLAIR)

-- Gemmes + cristaux autour du socle
for i = 0, 5 do
	local a = math.rad(i * 60)
	local cf = CFrame.Angles(0, a, 0) * CFrame.new(0, S(1.75), -S(10.1))
	gemme(cf, 1.1)
	cristal(CFrame.Angles(0, a + math.rad(30), 0) * CFrame.new(0, S(2.85), -S(9)), 2.2)
end

----------------------------------------------------------------------
-- 2) L'ŒUF EN CRISTAL (tout ce qui flotte va dans "Flottant")
----------------------------------------------------------------------
local flottant = Instance.new("Model")
flottant.Name = "Flottant"
flottant.Parent = modele

local HAUT_OEUF = S(12) -- hauteur du centre de l'œuf

local coque = piece({ Nom = "Coque", Classe = "Part", Forme = Enum.PartType.Ball,
	Taille = Vector3.new(S(11), S(11), S(11)), CF = CFrame.new(0, HAUT_OEUF, 0),
	Couleur = VIOLET_CLAIR, Matiere = Enum.Material.Glass, Transparence = 0.35, Reflet = 0.15, Parent = flottant })
-- Forme d'œuf : on étire la boule avec un SpecialMesh
local mesh = Instance.new("SpecialMesh")
mesh.MeshType = Enum.MeshType.Sphere
mesh.Scale = Vector3.new(1, 1.3, 1)
mesh.Parent = coque

-- Nuages / énergie à l'intérieur
local coeur = piece({ Nom = "CoeurNuage", Forme = Enum.PartType.Ball,
	Taille = Vector3.new(S(8), S(8), S(8)), CF = CFrame.new(0, HAUT_OEUF, 0),
	Couleur = Color3.fromRGB(190, 140, 255), Matiere = Enum.Material.Neon, Transparence = 0.55,
	Lumiere = 4, Parent = flottant })
local meshCoeur = Instance.new("SpecialMesh")
meshCoeur.MeshType = Enum.MeshType.Sphere
meshCoeur.Scale = Vector3.new(1, 1.3, 1)
meshCoeur.Parent = coeur

-- Bandes dorées qui entourent l'œuf (forme de "V" comme sur l'image)
local function bande(y, rayon)
	anneau(CFrame.new(0, y, 0), rayon, S(0.55), 32, OR, Enum.Material.Metal, flottant)
end
bande(HAUT_OEUF + S(1.5), S(5.55))
bande(HAUT_OEUF - S(4.5), S(4.45))
bande(HAUT_OEUF + S(6), S(3.4))

-- Gemmes sur le devant et l'arrière de l'œuf
for _, cote in ipairs({ 0, 180 }) do
	local r = CFrame.Angles(0, math.rad(cote), 0)
	gemme(r * CFrame.new(0, HAUT_OEUF + S(1.5), -S(5.7)), 1.8, flottant)
	gemme(r * CFrame.new(0, HAUT_OEUF - S(4.5), -S(4.75)), 1.2, flottant)
	gemme(r * CFrame.Angles(0, math.rad(40), 0) * CFrame.new(0, HAUT_OEUF + S(1.5), -S(5.6)), 0.9, flottant)
	gemme(r * CFrame.Angles(0, math.rad(-40), 0) * CFrame.new(0, HAUT_OEUF + S(1.5), -S(5.6)), 0.9, flottant)
end

----------------------------------------------------------------------
-- 3) LA COURONNE
----------------------------------------------------------------------
local HAUT_COURONNE = HAUT_OEUF + S(7.6)
anneau(CFrame.new(0, HAUT_COURONNE, 0), S(3.2), S(1), 24, OR, Enum.Material.Metal, flottant)

for i = 0, 7 do
	local a = math.rad(i * 45)
	local grande = (i % 2 == 0)
	local h = grande and S(3) or S(1.8)
	-- deux demi-pointes (WedgePart) dos à dos = un pic triangulaire
	local centre = CFrame.Angles(0, a, 0) * CFrame.new(0, HAUT_COURONNE + S(0.5) + h / 2, -S(3.2))
	for _, sens in ipairs({ 90, -90 }) do
		local pic = Instance.new("WedgePart")
		pic.Anchored = true
		pic.CanCollide = false
		pic.CastShadow = false
		pic.Material = Enum.Material.Metal
		pic.Color = OR
		pic.Reflectance = 0.2
		pic.Size = Vector3.new(S(0.5), h, S(0.7))
		pic.CFrame = ORIGINE * centre * CFrame.Angles(0, math.rad(sens), 0) * CFrame.new(0, 0, -S(0.35))
		pic.Name = "PicCouronne"
		pic.Parent = flottant
	end
	if grande then
		gemme(CFrame.Angles(0, a, 0) * CFrame.new(0, HAUT_COURONNE + S(1.3), -S(3.45)), 0.9, flottant)
	end
end

----------------------------------------------------------------------
-- 4) LES AILES (plumes blanches/violettes bordées d'or)
----------------------------------------------------------------------
local function aile(cote) -- cote = 1 (droite) ou -1 (gauche)
	local dossier = Instance.new("Model")
	dossier.Name = cote == 1 and "AileDroite" or "AileGauche"
	dossier.Parent = flottant
	local pivot = CFrame.new(cote * S(5.2), HAUT_OEUF + S(1.5), 0)
	for i = 1, 6 do
		local longueur = S(5 + i * 0.9)
		local angle = math.rad(-20 + i * 14) -- éventail de plumes
		local cf = pivot
			* CFrame.Angles(0, 0, cote * angle)
			* CFrame.new(cote * longueur / 2, 0, 0)
		piece({ Nom = "Plume", Taille = Vector3.new(longueur, S(1.1), S(0.4)), CF = cf,
			Couleur = (i % 2 == 0) and Color3.new(1, 1, 1) or VIOLET_CLAIR,
			Matiere = Enum.Material.Neon, Transparence = 0.1, Parent = dossier })
		piece({ Nom = "BordPlume", Taille = Vector3.new(longueur * 0.95, S(0.35), S(0.5)),
			CF = cf * CFrame.new(0, S(0.6), 0),
			Couleur = OR, Matiere = Enum.Material.Metal, Reflet = 0.2, Parent = dossier })
	end
	gemme(pivot * CFrame.new(cote * S(1.5), S(2.5), -S(0.3)), 1, dossier)
end
aile(1)
aile(-1)

----------------------------------------------------------------------
-- 5) ANNEAUX MAGIQUES QUI TOURNENT
----------------------------------------------------------------------
local anneauxTournants = {
	{ modele = anneau(CFrame.new(0, 0, 0), S(9), S(0.25), 48, OR_CLAIR), y = HAUT_OEUF - S(2), incl = 15, vitesse = 0.6 },
	{ modele = anneau(CFrame.new(0, 0, 0), S(8), S(0.2), 48, Color3.fromRGB(255, 240, 200)), y = HAUT_OEUF + S(9), incl = -8, vitesse = -0.4 },
	{ modele = anneau(CFrame.new(0, 0, 0), S(10), S(0.2), 48, OR_CLAIR), y = HAUT_OEUF + S(4), incl = -12, vitesse = 0.3 },
}
for _, a in ipairs(anneauxTournants) do
	a.modele.Name = "AnneauMagique"
	a.modele.WorldPivot = ORIGINE -- le centre de l'anneau sert de pivot
end

----------------------------------------------------------------------
-- 6) EFFETS : étincelles, rayon de lumière, halo
----------------------------------------------------------------------
local att = Instance.new("Attachment")
att.Parent = coque

local etincelles = Instance.new("ParticleEmitter")
etincelles.Name = "Etincelles"
etincelles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
etincelles.Color = ColorSequence.new(OR_CLAIR, VIOLET_CLAIR)
etincelles.LightEmission = 1
etincelles.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, S(0.6)), NumberSequenceKeypoint.new(1, 0),
})
etincelles.Lifetime = NumberRange.new(1.5, 3)
etincelles.Rate = 40
etincelles.Speed = NumberRange.new(S(2), S(5))
etincelles.SpreadAngle = Vector2.new(180, 180)
etincelles.Parent = att

local rayon = Instance.new("ParticleEmitter")
rayon.Name = "RayonLumiere"
rayon.Texture = "rbxasset://textures/particles/sparkles_main.dds"
rayon.Color = ColorSequence.new(Color3.new(1, 1, 1))
rayon.LightEmission = 1
rayon.Size = NumberSequence.new(S(0.4))
rayon.Lifetime = NumberRange.new(2)
rayon.Rate = 15
rayon.Speed = NumberRange.new(S(10))
rayon.EmissionDirection = Enum.NormalId.Top
rayon.SpreadAngle = Vector2.new(5, 5)
rayon.Parent = att

local halo = Instance.new("PointLight")
halo.Color = Color3.fromRGB(220, 180, 255)
halo.Brightness = 5
halo.Range = S(25)
halo.Parent = coque

-- Nom de l'œuf + prix au-dessus
local bb = Instance.new("BillboardGui")
bb.Size = UDim2.new(0, 260, 0, 80)
bb.StudsOffsetWorldSpace = Vector3.new(0, S(14), 0)
bb.AlwaysOnTop = true
bb.Parent = coque
local titre = Instance.new("TextLabel")
titre.Name = "Titre"
titre.Size = UDim2.new(1, 0, 0.6, 0)
titre.BackgroundTransparency = 1
titre.Text = NOM_OEUF
titre.Font = Enum.Font.FredokaOne
titre.TextScaled = true
titre.TextColor3 = OR_CLAIR
titre.TextStrokeColor3 = Color3.fromRGB(80, 30, 150)
titre.TextStrokeTransparency = 0
titre.Parent = bb
local prixTxt = titre:Clone()
prixTxt.Name = "Prix"
prixTxt.Position = UDim2.new(0, 0, 0.6, 0)
prixTxt.Size = UDim2.new(1, 0, 0.4, 0)
prixTxt.Text = "💰 " .. PRIX .. " Coins"
prixTxt.TextColor3 = Color3.new(1, 1, 1)
prixTxt.Parent = bb

modele.Parent = workspace

----------------------------------------------------------------------
-- 7) ANIMATION (l'œuf flotte, les anneaux tournent, le portail pulse)
----------------------------------------------------------------------
local flottantDepart = {}
for _, p in ipairs(flottant:GetDescendants()) do
	if p:IsA("BasePart") then flottantDepart[p] = p.CFrame end
end

TweenService:Create(portail, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ Transparency = 0.6 }):Play()
TweenService:Create(halo, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ Brightness = 2 }):Play()

local t = 0
local enOuverture = false
RunService.Heartbeat:Connect(function(dt)
	t += dt
	if not enOuverture then
		-- flottement + légère rotation
		local decal = CFrame.new(POSITION) * CFrame.new(0, math.sin(t * 1.5) * S(0.5), 0)
			* CFrame.Angles(0, math.sin(t * 0.5) * 0.15, 0) * CFrame.new(POSITION):Inverse()
		for p, cf in pairs(flottantDepart) do
			p.CFrame = decal * cf
		end
	end
	for _, a in ipairs(anneauxTournants) do
		a.modele:PivotTo(ORIGINE * CFrame.new(0, a.y, 0)
			* CFrame.Angles(math.rad(a.incl), t * a.vitesse, 0))
	end
end)

----------------------------------------------------------------------
-- 8) OUVRIR L'ŒUF (touche E)
----------------------------------------------------------------------
-- Crée les Coins dans leaderstats si ton jeu n'en a pas déjà
Players.PlayerAdded:Connect(function(joueur)
	if joueur:FindFirstChild("leaderstats") then return end
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	ls.Parent = joueur
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 1000 -- argent de départ pour tester
	coins.Parent = ls
end)

local function tirerPet()
	local total = 0
	for _, p in ipairs(PETS) do total += p.chance end
	local r = math.random() * total
	for _, p in ipairs(PETS) do
		r -= p.chance
		if r <= 0 then return p end
	end
	return PETS[1]
end

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Ouvrir (" .. PRIX .. " Coins)"
prompt.ObjectText = NOM_OEUF
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = S(20)
prompt.RequiresLineOfSight = false
prompt.Parent = coque

prompt.Triggered:Connect(function(joueur)
	if enOuverture then return end
	local ls = joueur:FindFirstChild("leaderstats")
	local coins = ls and ls:FindFirstChild("Coins")
	if not coins or coins.Value < PRIX then
		prompt.ActionText = "Pas assez de Coins !"
		task.delay(1.5, function() prompt.ActionText = "Ouvrir (" .. PRIX .. " Coins)" end)
		return
	end
	coins.Value -= PRIX
	enOuverture = true
	prompt.Enabled = false

	-- L'œuf tremble
	for i = 1, 12 do
		local secousse = CFrame.new(POSITION) * CFrame.Angles(0, 0, math.rad((i % 2 == 0 and 1 or -1) * 6))
			* CFrame.new(POSITION):Inverse()
		for p, cf in pairs(flottantDepart) do p.CFrame = secousse * cf end
		task.wait(0.08)
	end

	-- Explosion de lumière
	etincelles:Emit(150)
	halo.Brightness = 20
	local pet = tirerPet()

	-- Le pet apparaît (une boule lumineuse avec son nom)
	local petPart = Instance.new("Part")
	petPart.Shape = Enum.PartType.Ball
	petPart.Size = Vector3.new(S(4), S(4), S(4))
	petPart.Material = Enum.Material.Neon
	petPart.Color = pet.couleur
	petPart.Anchored = true
	petPart.CanCollide = false
	petPart.CFrame = ORIGINE * CFrame.new(0, HAUT_OEUF, 0)
	petPart.Parent = workspace
	local nomGui = bb:Clone()
	nomGui.StudsOffsetWorldSpace = Vector3.new(0, S(4), 0)
	nomGui.Titre.Text = pet.nom
	nomGui.Prix.Text = joueur.DisplayName .. " a obtenu (" .. pet.chance .. "%)"
	nomGui.Parent = petPart
	TweenService:Create(petPart, TweenInfo.new(1, Enum.EasingStyle.Back), {
		CFrame = petPart.CFrame * CFrame.new(0, S(8), 0) * CFrame.Angles(0, math.pi, 0),
	}):Play()

	-- Enregistre le pet dans le joueur (dossier "Pets")
	local dossierPets = joueur:FindFirstChild("Pets") or Instance.new("Folder")
	dossierPets.Name = "Pets"
	dossierPets.Parent = joueur
	local v = Instance.new("StringValue")
	v.Name = pet.nom
	v.Value = pet.nom
	v.Parent = dossierPets

	print(joueur.Name .. " a obtenu : " .. pet.nom)

	task.wait(3)
	petPart:Destroy()
	halo.Brightness = 5
	enOuverture = false
	prompt.Enabled = true
end)
