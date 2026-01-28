local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local roundGui = playerGui:WaitForChild("RoundGui")

local RoundState = ReplicatedStorage:WaitForChild("RoundState")
local AnswerEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AnswerEvent")
local RemoveMathGuiEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoveMathGuiEvent")

local questionBox = roundGui:WaitForChild("QuestionBox")
local answerBox = roundGui:WaitForChild("AnswerBox")
local answerButton = roundGui:WaitForChild("Answer")

local debounce = false
local currentAnswer = nil

-- Hide by default
roundGui.Enabled = false

-- Generate random math question
local function generateQuestion()
	local a = math.random(1, 20)
	local b = math.random(1, 20)
	local operators = {"+", "-", "*"}
	local op = operators[math.random(1, #operators)]
	questionBox.Text = a.." "..op.." "..b.." = ?"

	if op == "+" then
		currentAnswer = a + b
	elseif op == "-" then
		currentAnswer = a - b
	elseif op == "*" then
		currentAnswer = a * b
	end
end

-- Update GUI when round state changes
local function updateMathGui()
	if RoundState.Value == "InRound" then
		roundGui.Enabled = true
		generateQuestion()
		answerBox.Text = ""
		answerBox:CaptureFocus()
	else
		roundGui.Enabled = false
		questionBox.Text = ""
		answerBox.Text = ""
	end
end

-- Initial check
updateMathGui()

-- Listen for round state changes
RoundState.Changed:Connect(updateMathGui)

-- Handle answer submission
local function submitAnswer()
	if debounce then return end
	debounce = true

	local userAnswer = tonumber(answerBox.Text:match("%S+")) -- trim whitespace
	local isCorrect = (userAnswer ~= nil and userAnswer == currentAnswer)

	-- send result to server
	AnswerEvent:FireServer(isCorrect)

	-- generate next question
	answerBox.Text = ""
	generateQuestion()
	answerBox:CaptureFocus()

	task.delay(0.5, function()
		debounce = false
	end)
end

-- Button click
answerButton.MouseButton1Click:Connect(submitAnswer)

-- Press Enter in the TextBox
answerBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitAnswer()
	end
end)

-- Force-hide GUI from server
RemoveMathGuiEvent.OnClientEvent:Connect(function()
	roundGui.Enabled = false
	questionBox.Text = ""
	answerBox.Text = ""
end)
