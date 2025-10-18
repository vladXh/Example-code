local FL = require(game.ReplicatedStorage.functionLibrary)
local gameData = require(game.ReplicatedStorage.gameData)

local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local bindableFunction = script:WaitForChild("Function")

local camera = game.Workspace.Camera
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local textLines = gameData.NPCTextLines

local cam1 = game.Workspace:WaitForChild("cutscenes"):WaitForChild("starterCutscene"):WaitForChild("cam1")
local cam2 = game.Workspace:WaitForChild("cutscenes"):WaitForChild("starterCutscene"):WaitForChild("cam2")
local cam3 = game.Workspace:WaitForChild("cutscenes"):WaitForChild("starterCutscene"):WaitForChild("cam3")
local c1c1 = cam1:WaitForChild("c1")
local c2c1 = cam2:WaitForChild("c2")

local cutsceneStart = game.Workspace:WaitForChild("cutsceneSpawn"):WaitForChild("touchPart1")
local cutsceneRoom = game.Workspace.cutscenes.starterCutscene.starterCutsceneBedroom

local MC = cutsceneRoom.Parent.MC
local MChum = MC:WaitForChild("Humanoid")

local anims = {}
anims.sleepingPose1 = MC.animations.sleepingPose1
anims.sleepingWakingUp1 = MC.animations.sleepingWakingUp1
anims.sleepingWakingUpPose1 = MC.animations.sleepingWakingUpPose1
anims.sittingOnBedPose1 = MC.animations.sittingOnBedPose1
anims.sittingOnBedHeadTilt = MC.animations.sittingOnBedHeadTilt
anims.Cutscene1Scene2HeadTiltPose = MC.animations.Cutscene1Pose2HeadTiltPose

anims.loadedSittingOnBedPose1 = MChum:LoadAnimation(anims.sittingOnBedPose1)
anims.loadedSleepingPose1 = MChum:LoadAnimation(anims.sleepingPose1)
anims.loadedSleepingWakingUp1 = MChum:LoadAnimation(anims.sleepingWakingUp1)
anims.loadedSleepingWakingUpPose1 = MChum:LoadAnimation(anims.sleepingWakingUpPose1)
anims.loadedSittingOnBedHeadTilt = MChum:LoadAnimation(anims.sittingOnBedHeadTilt)
anims.loadedCutscene1Scene2HeadTiltPose = MChum:LoadAnimation(anims.Cutscene1Scene2HeadTiltPose)

anims.loadedSleepingWakingUpPose1.Priority = Enum.AnimationPriority.Action2
anims.loadedSittingOnBedHeadTilt.Priority = Enum.AnimationPriority.Action2
anims.loadedCutscene1Scene2HeadTiltPose.Priority = Enum.AnimationPriority.Action2


FL.turnCamsInvisible(game.Workspace.cutscenes.starterCutscene)

local Scene1 = {}
Scene1.endPosition = c2c1.CFrame
Scene1.tweenInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 2)
Scene1.tween = tweenService:Create(c1c1, Scene1.tweenInfo, {CFrame = Scene1.endPosition})
Scene1.DoorOpenSound = cutsceneRoom.walls.door.Sound
Scene1.DoorOpenSound.TimePosition = 2
Scene1.CameraPanFinished = false -- debounce
Scene1.Finshed = false

local Scene2 = {}
Scene2.Finished = false
Scene2.Started = false

local skipCutscene = {}
skipCutscene.screenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("skip")
skipCutscene.contents = skipCutscene.screenGui:WaitForChild("contents")
skipCutscene.loadingBar = skipCutscene.contents:WaitForChild("loadingBar")

skipCutscene.loadingBarSize = skipCutscene.loadingBar.Size
skipCutscene.framePos = skipCutscene.contents.Position
skipCutscene.pressed = false

local tween1 = {}
tween1.tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
tween1.tween = tweenService:Create(skipCutscene.contents, tween1.tweenInfo, {Position = skipCutscene.framePos})

local tween2 = {}
tween2.tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
tween2.tween = tweenService:Create(skipCutscene.loadingBar, tween2.tweenInfo, {Size = skipCutscene.loadingBarSize})

local function endCutscene()
	FL.blackScreen(true, 1)
	
	game.Lighting.TimeOfDay = gameData.timeOfDay
	camera.CameraType = Enum.CameraType.Custom
	humanoid.WalkSpeed = gameData.PlayerSpeed.WalkSpeed
	
	skipCutscene.screenGui.Enabled = false
	script.Enabled = false
	
	FL.blackScreen(false, 2)
end

game.ReplicatedStorage.RemoteEvents.SkipStarterCutscene.Event:Connect(function()
	endCutscene()
end)

local blackScreenRan = false

cutsceneStart.Touched:Connect(function()
	cutsceneStart:Destroy()
	
	UIS.InputBegan:Connect(function(input, gameProcessedEvent) -- skip cutscene
		if gameProcessedEvent then return end

		if input.KeyCode == gameData.keybinds.SkipCutscene then
			
			skipCutscene.pressed = true
			if skipCutscene.screenGui.Enabled == false then
				skipCutscene.contents.Position += UDim2.new(0, 0, 0.2, 0)
				skipCutscene.loadingBar.Size = UDim2.new(0, 0, 0.147, 0)
				
				skipCutscene.screenGui.Enabled = true
				tween1.tween:Play()
				tween1.tween.Completed:Wait()
			end	
			if skipCutscene.pressed then
				tween2.tween:Play()	
			end
		end
	end)

	UIS.InputEnded:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end

		if input.KeyCode == gameData.keybinds.SkipCutscene then
			if skipCutscene.loadingBar.Size ~= skipCutscene.loadingBarSize then
				tween2.tween:Cancel()
				skipCutscene.pressed = false
				skipCutscene.loadingBar.Size = UDim2.new(0, 0, 0.147, 0)	
			else
				FL.blackScreen(true, 2)
				task.wait(2)
				endCutscene()
			end
		end	
	end)
	
	
	camera.CameraType = Enum.CameraType.Scriptable
	game.Lighting.TimeOfDay = gameData.timeOfDay
	humanoid.WalkSpeed = 0
	
	anims.loadedSleepingPose1:Play()
	
	if blackScreenRan == false  then
		camera.CFrame =  CFrame.new(cam1:WaitForChild("c1").Position, cam1:WaitForChild("c2").Position)
		FL.blackScreen(false, 2)
		blackScreenRan = true
	end

	Scene1.tween:Play()
	
	local connection
	--set camera
	connection = runService.RenderStepped:Connect(function()
		
		if not Scene1.Finshed then
			camera.CFrame =  CFrame.new(cam1:WaitForChild("c1").Position, cam1:WaitForChild("c2").Position)
		elseif Scene1.Finshed and not Scene2.Started then
			Scene2.Started = true
			camera.CFrame =  CFrame.new(cam3:WaitForChild("c1").Position, cam2:WaitForChild("c2").Position) -- Scene 2
			
			anims.loadedSittingOnBedPose1:Play()
			FL.blackScreen(false, 1.5)

			FL.chatBox(textLines.Mom.Name, textLines.Mom.cutscene1Text.scene2.text1, 2)
			FL.chatBox(textLines.Mom.Name, textLines.Mom.cutscene1Text.scene2.text2, 3)
			FL.chatBox(textLines.Mom.Name, textLines.Mom.cutscene1Text.scene2.text3, 3)
			
			anims.loadedSittingOnBedHeadTilt:Play()
			anims.loadedSittingOnBedHeadTilt.Stopped:Wait()
			anims.loadedCutscene1Scene2HeadTiltPose:Play()

			FL.chatBox(textLines.MainCharacter.Name, textLines.MainCharacter.Cutscene1Text.scene2.text1, 1)
			FL.chatBox(textLines.MainCharacter.Name, textLines.MainCharacter.Cutscene1Text.scene2.text2, 1.2)

			FL.chatBox(textLines.Mom.Name, textLines.Mom.cutscene1Text.scene2.text4, 3)


			FL.chatBox(textLines.MainCharacter.Name, textLines.MainCharacter.Cutscene1Text.scene2.text3, 1.2)
			FL.chatBox(textLines.MainCharacter.Name, textLines.MainCharacter.Cutscene1Text.scene2.text4, 1.2)
			
			FL.chatBox(textLines.Mom.Name, textLines.Mom.cutscene1Text.scene2.text5, 1)	
			
			FL.chatBox(textLines.MainCharacter.Name, textLines.MainCharacter.Cutscene1Text.scene2.text5, 1.2)
			
			FL.blackScreen(true, 2) -- Cutscene finished
			local blackScreenGui = Instance.new("ScreenGui")
			blackScreenGui.Parent = player.PlayerGui
			local blackScreenFrame = Instance.new("Frame")
			blackScreenFrame.Parent = blackScreenGui
			
			blackScreenGui.IgnoreGuiInset = true
			blackScreenFrame.Size = UDim2.new(1, 0, 1, 0)
			blackScreenFrame.BackgroundColor3 = Color3.new(0, 0, 0)
			
			local text = Instance.new("TextLabel")
			text.Parent = blackScreenFrame
			text.Position = UDim2.new(0.5, 0, 0.5, 0)
			text.BackgroundTransparency = 1
			text.Font = Enum.Font.Ubuntu
			text.TextColor3 = Color3.new(255, 255, 255)
			text.TextSize = 25
			text.Text = ""
			
			local function centerText(chatText, duration)
				local textBlip = game.ReplicatedStorage.soundEffects.chatbox.textBlipSound
				local insertionText = ""
				
				textBlip:Play()
				print("TextCenter")
				for i = 0, chatText:len(), 1 do
					insertionText = insertionText .. string.sub(chatText, i, i)
					task.wait(0.02)
					text.Text = insertionText
				end
				textBlip:Stop()
				task.wait(duration)
			end
			
			centerText(gameData.NPCTextLines.game.cutscene1Text.text1, 3)
			centerText(gameData.NPCTextLines.game.cutscene1Text.text2, 3)
			centerText(gameData.NPCTextLines.game.cutscene1Text.text3, 3)
			centerText(gameData.NPCTextLines.game.cutscene1Text.text4, 3)
			centerText(gameData.NPCTextLines.game.cutscene1Text.text5, 3)
			
			
			game.Lighting.TimeOfDay = gameData.timeOfDay
			camera.CameraType = Enum.CameraType.Custom
			humanoid.WalkSpeed = gameData.PlayerSpeed.WalkSpeed
			
			text:Destroy()
			blackScreenFrame:Destroy()
			blackScreenGui:Destroy()
			
			FL.blackScreen(false, 3)
		end

		if c1c1.CFrame == c2c1.CFrame and Scene1.CameraPanFinished == false then -- Scene 1
			Scene1.CameraPanFinished = true -- debounce

			Scene1.DoorOpenSound:Play()
			Scene1.DoorOpenSound.Ended:Wait()

			FL.chatBox(textLines.Mom.Name, textLines.Mom.cutscene1Text.scene1.text1, 2)
			FL.chatBox(textLines.Mom.Name, textLines.Mom.cutscene1Text.scene1.text2, 3)
			wait(1.5)

			anims.loadedSleepingPose1:Stop()
			anims.loadedSleepingWakingUp1:Play()
			anims.loadedSleepingWakingUp1.Stopped:Wait()
			anims.loadedSleepingWakingUpPose1:Play()

			FL.chatBox(textLines.MainCharacter.Name, textLines.MainCharacter.Cutscene1Text.scene1.text1, 2)
			FL.chatBox(textLines.MainCharacter.Name, textLines.MainCharacter.Cutscene1Text.scene1.text2, 3)
			
			FL.blackScreen(true, 1.5)
			Scene1.Finshed = true
			
			anims.loadedSleepingWakingUpPose1:Stop()
		end
	end)
		
end)
