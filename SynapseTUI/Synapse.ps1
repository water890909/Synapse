clear-host
$Host.UI.RawUI.WindowTitle = "Synapse"
$script:SynapseVersion = "0.1 12/4/25"
$script:psVer = $PSVersionTable.PSVersion.Major

#KNOWN BUGS:
#1: music can play multiple times in the terminal. make sure to make it so quit stops music, and also, invoking powershell commands with "syn" -
#should also stop music

$smiley = " :)"
$mrMcMad = " :("
#Seperators used for design on things like settings, help, etc
<#
    Write-Host "______________________" -ForegroundColor Darkgray
    Write-Host "________________________________________" -ForegroundColor Darkgray
#>


#INPUT SETUP:
#this was implemented so the clear command could return to the last function called 
$script:lastMainFunctionCalled = $null
$script:ignoreFunctions = @(
    "handleMainInput",
    "printGreeting",
    "printGreetingNULL", 
    "printQuoteOfTheDay",
    "TC",
    "printDiagnostics",
    "gamesMS",
    "displayModules",
    "hangman",
    "displayWeather"

)


#checks if function being called is not an ignoreFunction, if so lastMainFunctionCalled
#gets updated and the function gets invoked
function callMainFunction {
    param (
        $functionName
    )
    if ($script:ignoreFunctions -NotContains $functionName) {
        $script:lastMainFunctionCalled = $functionName
    }
    & $functionName #call function
}


#DATA SETUP:
$contentsFolder = Join-Path -Path $PSScriptRoot -ChildPath "Contents"
$data_Path = Join-Path -Path $contentsFolder -ChildPath "SynData.json"
$gamesFolder = Join-Path -Path $contentsFolder -ChildPath "Games"
$mindSweeperFolder = Join-Path -Path $gamesFolder -ChildPath "MineSweeper"
$hangManFolder = Join-Path -Path $gamesFolder -ChildPath "Hangman"
$blackJackFolder = Join-Path -Path $gamesFolder -ChildPath "BlackJack"

$data_Content = Get-Content -Path $data_Path -Raw
$data_ContentRetrieve = $data_Content | ConvertFrom-Json

$data_Name = $data_ContentRetrieve.Name
$data_WeatherLocation = $data_ContentRetrieve.WeatherLocation
$data_ThemeColor = $data_ContentRetrieve.ThemeColor
$data_NotesStorage = $data_ContentRetrieve.NotesStorage
if ([string]::IsNullOrEmpty($data_ThemeColor)) {
    $data_ThemeColor = "Blue"
}

#$data_TheCube = $data_ContentRetrieve.TheCube
#$data_TOD = $data_ContentRetrieve.TimeOfDayLog

$data_Miscell = $data_ContentRetrieve.MiscellaneousData
$data_OpenAiKey = $data_Miscell.OpenAI_APIKey

$data_Facts = $data_ContentRetrieve.Facts
$factsList = $data_Facts | ForEach-Object { #runs for each object in $data_Quotes
    $_.PSObject.Properties | ForEach-Object { $_.Value }  #find value property of each object
}

$data_Quotes = $data_ContentRetrieve.Quotes
$quotesList = $data_Quotes | ForEach-Object { #runs for each object in $data_Quotes
    $_.PSObject.Properties | ForEach-Object { $_.Value }  #find value property of each object
}
$randomQuote = $quotesList | Get-Random






#audio playing logic
#can create, play, pause, stop audio
$Global:AudioPlayers = @{} #hash table for storing media player objects
#create audio media player object thingy
function createAudio {
    param (
        $path,
        $volume = 1.0
    )
    Add-Type -AssemblyName PresentationCore
    $player = New-Object System.Windows.Media.MediaPlayer
    $player.Open($path)
    $player.Volume = $volume

    $id = (New-Guid).ToString() #a guid is an id made to not match any other id's

    #apparently psCustomObjects are better for this stuff somehow so thats why its defined
    $Global:AudioPlayers[$id] = [PSCustomObject]@{
        Id          = $id
        Path        = $path
        Volume      = $volume
        AudioPlayer = $player
        State       = "Stopped"
    }

    return $Global:AudioPlayers[$id]
}
#play audio 
function playAudio {
    param($id)
    $audioObject = $Global:AudioPlayers[$id]
    $audioObject.AudioPlayer.Play()
    $audioObject.State = "Playing"
}
#pause audio
function pauseAudio {
    param($id)
    $audioObject = $Global:AudioPlayers[$id]
    $audioObject.AudioPlayer.Pause()
    $audioObject.State = "Stopped"
}
#stop audio 
function stopAudio {
    param($id)
    $audioObject = $Global:AudioPlayers[$id]
    $audioObject.AudioPlayer.Stop()
    $audioObject.AudioPlayer.Close()
    $Global:AudioPlayers.Remove($id)
}

#$kanye = createAudio -path "C:\Users\5223293797\Music\AsapRocky\AT.LONG.LAST.ASAP\09. Jukebox Joints (Feat. Joe Fox & Kanye West).mp3" -volume 1
#playAudio -id $kanye.Id

function music {
    Clear-Host
    Write-Host "Music" -ForegroundColor $data_ThemeColor
    Write-Host "______________________" -ForegroundColor Darkgray

    Write-Host "________________________________________" -ForegroundColor Darkgray
    

}



#TIME SETUP:
#example: 9:16:30 = 91630
#morning: 00:00:00 - 12:00:00
#afternooon: 12:00:00 - 17:00:00 
#evening: 17:00:00 - 19:00:00
#night - 19:00:00 - 23:59:59
function greeting { 
    #function for greeting if name is stored in SynData.json
    function printGreetingName {
        $script:todaysDate = Get-Date
        $script:clockTime = (Get-Date -Format "HHmmss" ) -as [int]
        if ($clocktime -le 120000) {
            write-host "Good morning, $data_Name, it is $todaysDate" -ForegroundColor $data_ThemeColor
        }
        elseif (($clockTime -ge 120001) -and ($clockTime -le 170000)) {
            write-host "Good afternoon, $data_Name, it is $todaysDate" -ForegroundColor $data_ThemeColor
        }
        elseif (($clockTime -ge 170001) -and ($clockTime -le 190000)) {
            write-host "Good evening, $data_Name, it is $todaysDate" -ForegroundColor $data_ThemeColor
        }
        elseif (($clockTime -ge 190001) -and ($clockTime -lt 235959)) {
            write-host "Greetings, $data_Name, its a nice night on $todaysDate" -ForegroundColor $data_ThemeColor
        }
    }
    #if user has no name set in data, use this
    function printGreetingNULL {
        $todaysDate = Get-Date
        $clockTime = (Get-Date -Format "HHmmss" ) -as [int]
        if ($clocktime -le 120000) {
            write-host "Good morning, it is $todaysDate" -ForegroundColor $data_ThemeColor
        }
        elseif (($clockTime -ge 120001) -and ($clockTime -le 170000)) {
            write-host "Good afternoon, it is $todaysDate" -ForegroundColor $data_ThemeColor
        }
        elseif (($clockTime -ge 170001) -and ($clockTime -le 190000)) {
            write-host "Good evening, it is $todaysDate" -ForegroundColor $data_ThemeColor
        }
        elseif (($clockTime -ge 190001) -and ($clockTime -lt 235959)) {
            write-host "Greetings, it is a nice night on $todaysDate" -ForegroundColor $data_ThemeColor
        }
    }

    #decide which function to use and print greeting
    if ([string]::IsNullOrEmpty($data_Name)) {
        printGreetingNULL
    }
    else {
        printGreetingName
    }
}


function games {
    Clear-Host
    Write-Host "______________________" -ForegroundColor Darkgray
    Write-Host "        GAMES"          -ForegroundColor $data_ThemeColor
    Write-Host ""
    Write-Host "Mind Sweeper: " -ForegroundColor $data_ThemeColor
    Write-Host "ms " -ForegroundColor White -NoNewline; write-host "OR " -Foregroundcolor Darkgray -NoNewLine; Write-Host "minesweeper" -ForegroundColor White -NoNewline; Write-Host " - opens a window to play mine-sweeper made in powershell" -ForegroundColor DarkGray
    Write-Host "Made by: " -ForegroundColor DarkGray -NoNewLine; Write-Host "jbMVS" -ForegroundColor $data_ThemeColor
    Write-Host "Github source: https://github.com/jbMVS/Buttonsweeper" -ForegroundColor DarkGray
    write-host ""
    Write-Host "Hangman: " -ForegroundColor $data_ThemeColor
    Write-Host "hm " -ForegroundColor White -NoNewline; write-host "OR " -Foregroundcolor Darkgray -NoNewLine; Write-Host "hangman" -ForegroundColor White -NoNewline; Write-Host " - runs hangman made from powershell within Synapse" -ForegroundColor DarkGray
    Write-Host "Made by: " -ForegroundColor DarkGray -NoNewLine; Write-Host "smithcbp" -ForegroundColor $data_ThemeColor
    Write-Host "Github source: https://github.com/smithcbp/Powershell-Hangman" -ForegroundColor DarkGray
    write-host ""
    Write-Host "Blackjack: " -ForegroundColor $data_ThemeColor
    Write-Host "bj " -ForegroundColor White -NoNewline; write-host "OR " -Foregroundcolor Darkgray -NoNewLine; Write-Host "blackjack" -ForegroundColor White -NoNewline; Write-Host " - runs blackjack made from powershell within Synapse" -ForegroundColor DarkGray
    Write-Host "Made by: " -ForegroundColor DarkGray -NoNewLine; Write-Host "ThyCitrus" -ForegroundColor $data_ThemeColor

    Write-Host ""
    Write-Host "________________________________________" -ForegroundColor Darkgray
    Write-Host ""
    handleMainInput
}

#gambling simulator game
function gamblingSim {
    Clear-Host
    Write-Host "gamble your savings away simulator 2025 Premium Edition" -ForegroundColor $data_ThemeColor
    Write-Host ""
    $i = Read-host "play"
}


function gamesMS { 
    $file = Join-Path -Path $mindSweeperFolder -ChildPath "ButtonSweeper.ps1"
    $test = Test-Path -Path $file
    if (-not $test) {
        Write-Host 'MindSweeper does not exist. You may have deleted the "Games" folder, or the "ButtonSweeper.ps1" file'
        Write-Host "You can recover by redownloading at: github.com or sum"
        handleMainInput
    }
    else {
        & $file 2>$null #idk why this works just go look at https://stackoverflow.com/questions/8388650/powershell-how-can-i-stop-errors-from-being-displayed-in-a-script
    }
}

function hangman {
    $file = Join-Path -Path $hangManFolder -ChildPath "Hangman.ps1"
    $test = Test-Path -Path $file
    if (-not $test) {
        Write-Host 'Hangman does not exist. You may have deleted the "Games" folder, or the "Hangman.ps1" file'
        Write-Host "You can recover by redownloading at: github.com or sum"
        handleMainInput
    }
    else {
        & $file 2>$null #idk why this works just go look at https://stackoverflow.com/questions/8388650/powershell-how-can-i-stop-errors-from-being-displayed-in-a-script
        callMainFunction -functionName $script:lastMainFunctionCalled
    }
}

function blackjack {
    $file = Join-Path -Path $blackJackFolder -ChildPath "Blackjack.ps1"
    $test = Test-Path -Path $file
    if (-not $test) {
        Write-Host 'Blackjack does not exist. You may have deleted the "Games" folder, or the "Blackjack.ps1" file'
        Write-Host "You can recover by redownloading at: github.com or sum"
        handleMainInput
    }
    else {
        & $file 2>$null #idk why this works just go look at https://stackoverflow.com/questions/8388650/powershell-how-can-i-stop-errors-from-being-displayed-in-a-script
        callMainFunction -functionName $script:lastMainFunctionCalled
    }
}

#the cube
function TC { 
    Clear-Host
    $file = Join-Path -Path $script:contentsFolder -ChildPath "TC.ps1"
    $test = Test-Path -Path $file
    if (-not $test) {
        Write-Host 'Cube function does not exist. You may have deleted the "Contents" folder in Synapse'
        Write-Host "You can recover by redownloading at: github.com or sum"
        handleMainInput
    }
    else {
        . $file
        X1
        callMainFunction -functionName $script:LastMainFunctionCalled
    }
}



#show source code for Synapse.ps1, TC.ps1
function displaySourceCode {
    Clear-Host
    $text = Get-Content -Path $PSCommandPath | Out-String #turn it into a string so we can keep format in var
    Write-Host $text -ForegroundColor Darkgray
    Write-Host "Version: $script:SynapseVersion"
    handleMainInput
}


function displayWeather {
    Write-Host ""
    Write-Host "Loading Weather" -ForegroundColor $data_ThemeColor
    Write-Host "(This could take a while)" -ForegroundColor $data_ThemeColor
    try {
        $wx1 = "https://wttr.in/"
        $wx2 = $data_WeatherLocation
        $wx3 = "?uT"
        $url = [string]::Concat($wx1, $wx2, $wx3)

        $weatherRequest = (Invoke-WebRequest $url -UserAgent "curl" ).Content
        $removeLabel = "Follow @igor_chubin for wttr.in updates"
        $weather = $weatherRequest.Replace($removeLabel, "")
        
        Clear-Host
        Write-Host ($weather) -ForegroundColor $data_ThemeColor
        handleMainInput
    }
    catch {
        Write-Host ""
        Write-Host "Sorry, either weather data is not avalable right now, or your internet is not connected." -ForegroundColor $data_ThemeColor
        Write-Host "Please try again later." -ForegroundColor $data_ThemeColor
        Write-Host ":(" -ForegroundColor $data_ThemeColor
        handleMainInput
    }
}


function displayModules {
    Write-Host '- Use: "Install-Module MODULENAME" to install a module' -ForegroundColor DarkGray
    Write-Host '- Use: "Get-Command -Module MODULENAME" to find commands linked to the module you have installed' -ForegroundColor DarkGray
    Write-Host "ShellGPT" -ForegroundColor White -NoNewline
    Write-Host " - Allows you to use ChatGPT from Powershell, requires an API key" -ForegroundColor DarkGray
    Write-Host "PSWordle" -ForegroundColor White -NoNewline
    Write-Host " - Allows you to play Wordle from Powershell" -ForegroundColor DarkGray
    Write-Host "Posh-Git" -ForegroundColor White -NoNewline
    Write-Host " - Adds Git status info to your prompt, plus tab completion and branch indicators in Powershell" -ForegroundColor DarkGray
}


function displayNotes {
    Clear-Host 
    Write-Host "Notes"
    Write-Host "______________________" -ForegroundColor Darkgray
    Write-Host "________________________________________" -ForegroundColor Darkgray
}

function writeNote {
    param (
        $text = ""
    )
    Write-Host "na"
    Read-host "q"
    $noteIndex = [int]$data_NotesStorage.NoteIndex
    $updatedIndex = ($noteIndex + 1) | ConvertTo-Json -Depth 100
    $data_Content.NotesStorage.NoteIndex = $updatedIndex
    Set-Content -Path $data_Content -Value $updatedIndex

}


#display description, synapse setup, and commands
function help {
    Clear-Host
    Write-Host "Help" -ForegroundColor $data_ThemeColor
    Write-Host "______________________" -ForegroundColor Darkgray
    Write-Host "       OVERVIEW" -ForegroundColor $data_ThemeColor
    Write-Host ""
    Write-Host "Synapse:" -ForegroundColor $data_ThemeColor
    Write-Host "Synapse is a TUI (Terminal User Interface) programmed in Windows PowerShell." -ForegroundColor Darkgray
    Write-Host "It serves utilities such as timers, alarms, stopwatch, to-do lists, music player, and even games." -ForegroundColor Darkgray
    write-host ""
    write-host ""

    Write-Host "Synapse Set-up:" -ForegroundColor $data_ThemeColor
    Write-Host "1: To set up Synapse, open PowerShell and type:" -ForegroundColor Darkgray
    Write-Host '      notepad $PROFILE' 
    Write-Host "   This will open or create a file called Microsoft.PowerShell_profile." -ForegroundColor Darkgray
    Write-Host "2: In the profile file, insert this code (replace the path with your Synapse path):" -ForegroundColor Darkgray
    Write-Host '      New-Alias -Name syn -Value "C:\PATH\TO\Synapse.ps1"' 
    Write-Host '3: Restart PowerShell. You can now open Synapse by typing the command "syn".' -ForegroundColor Darkgray
    write-host ""
    write-host ""
    Write-Host "Tips:" -ForegroundColor $data_ThemeColor
    Write-Host "- You can use your up and down keys to go to previous commands you typed" -ForegroundColor Darkgray
    Write-Host "- You can use Powershell cmdlets in Synapse" -ForegroundColor Darkgray
    Write-Host "- If you are missing a Synapse component (find from diagnostics), try redownloading and replacing your copy from: githublink/.com" -ForegroundColor Darkgray
    Write-Host "________________________________________" -ForegroundColor Darkgray
    Write-Host ""
    write-host ""
    Write-Host "______________________" -ForegroundColor Darkgray
    Write-Host "       COMMANDS" -ForegroundColor $data_ThemeColor
    Write-Host ""


    Write-Host "Utilities:" -ForegroundColor $data_ThemeColor
    Write-Host 'Note: For Powershell commands, type "Get-Command" or "Show-Command"' -ForegroundColor DarkGray
    Write-Host "syn " -NoNewLine 
    Write-Host "- opens Synapse (can be used to refresh Synapse too)" -ForegroundColor DarkGray
    Write-Host "home " -NoNewLine 
    Write-Host "- opens the main menu" -ForegroundColor DarkGray
    Write-Host "set " -NoNewLine
    Write-Host "OR" -NoNewLine -ForegroundColor DarkGray
    Write-Host " settings " -NoNewLine
    Write-Host "- opens settings" -ForegroundColor DarkGray
    Write-Host "help " -NoNewLine
    Write-Host "- opens the help page" -ForegroundColor DarkGray
    Write-Host "dx" -NoNewLine
    Write-Host " OR" -NoNewLine -ForegroundColor DarkGray
    Write-Host " diagnostics " -NoNewLine
    Write-Host "- displays synapse diagnostics" -ForegroundColor DarkGray
    Write-Host "re" -NoNewLine
    Write-Host " OR" -NoNewLine -ForegroundColor DarkGray
    Write-Host " refresh " -NoNewLine
    Write-Host "- clear the terminal" -ForegroundColor DarkGray
    Write-Host "quit " -NoNewLine
    Write-Host "- close synapse" -ForegroundColor DarkGray
    Write-Host ""
    write-host ""
    Write-Host "Miscellaneous:" -ForegroundColor $data_ThemeColor
    Write-Host "mod " -NoNewline
    Write-Host "- lists interesting PS modules to enhance Powershell (can be used in Synapse)" -ForegroundColor DarkGray
    Write-Host "games " -NoNewLine
    Write-Host "- shows commands and info for games in Synapse" -ForegroundColor DarkGray
    Write-Host "wx" -NoNewLine
    Write-Host " OR" -NoNewLine -ForegroundColor DarkGray
    Write-Host " weather " -NoNewLine
    Write-Host '- shows the weather forecast' -ForegroundColor DarkGray
    Write-Host "cube " -NoNewLine
    Write-Host '- displays a 3D spinning cube, "esc" to leave' -ForegroundColor DarkGray
    Write-Host "source " -NoNewLine
    Write-Host "- shows the source code of synapse" -ForegroundColor DarkGray
    Write-Host "fact " -NoNewLine
    Write-Host "- prints a random fact (some may be inaccurate)" -ForegroundColor DarkGray
    Write-Host "________________________________________" -ForegroundColor Darkgray
    Write-Host ""
    write-host ""
    handleMainInput
}


function settings {
    Clear-Host
    Write-Host "Settings" -ForegroundColor $data_ThemeColor
    Write-Host "______________________" -ForegroundColor Darkgray
    Write-Host "      OVERVIEW" -ForegroundColor $data_ThemeColor
    Write-Host ""
    Write-Host '- To edit settings, use the "setEdit" or "settingsEdit" command' -ForegroundColor DarkGray
    Write-Host "- It will open a file called SynData.json. In it, you can modify your Synapse data" -ForegroundColor DarkGray
    Write-Host "- Any changes made to your data may not go into effect until you restart Synapse (save data file, then type syn into Synapse to restart)" -ForegroundColor DarkGray
    Write-Host "- Be cautious of deleting sections of data, or providing incorrect data (like unsupported colors in ThemeColor)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host ""
    Write-Host "Restraints:" -ForegroundColor $data_ThemeColor


    Write-Host "Name:" -ForegroundColor White
    $list = ' ` " $ $() | ; & = , > >> () {} [] * ? '
    if ($script:psVer -le 5) {
        Write-Host "Your version of Powershell has console limitations for text. You may want to install Powershell 7+" -ForegroundColor DarkGray
        Write-Host "By default, characters that may cause error are:" -NoNewLine -ForegroundColor DarkGray; Write-host $list
    }
    else {
        Write-Host "Your version of Powershell supports most types of text in the console" -ForegroundColor DarkGray
        Write-Host "But, by default, characters that may cause error are:" -NoNewLine -ForegroundColor DarkGray; Write-host $list
        
    }
    Write-Host ""


    Write-Host "ThemeColor:" -ForegroundColor White
    Write-Host "Theme color changes the overall color of the TUI for its many different parts" -ForegroundColor DarkGray
    Write-Host "Allowed Colors Are: " -NoNewline -ForegroundColor DarkGray
    Write-Host "Black, " -ForegroundColor Black -NoNewline
    Write-Host "Blue, " -ForegroundColor Blue -NoNewline
    Write-Host "Green, " -ForegroundColor Green -NoNewline
    Write-Host "Cyan, " -ForegroundColor Cyan -NoNewline
    Write-Host "Red, " -ForegroundColor Red -NoNewline
    Write-Host "Magenta, " -ForegroundColor Magenta -NoNewline
    Write-Host "Yellow, " -ForegroundColor Yellow -NoNewline
    Write-Host "White, " -ForegroundColor White
    Write-Host "DarkBlue, " -ForegroundColor DarkBlue -NoNewline
    Write-Host "DarkGreen, " -ForegroundColor DarkGreen -NoNewline
    Write-Host "DarkCyan, " -ForegroundColor DarkCyan -NoNewline
    Write-Host "DarkRed, " -ForegroundColor DarkRed -NoNewline
    Write-Host "DarkMagenta, " -ForegroundColor DarkMagenta -NoNewline
    Write-Host "DarkYellow, " -ForegroundColor DarkYellow -NoNewline
    Write-Host "Gray, " -ForegroundColor Gray -NoNewline
    Write-Host "DarkGray" -ForegroundColor DarkGray
    Write-Host ""


    Write-Host "Weather:" -ForegroundColor White
    Write-Host '- To have the weather command show your specific location, type in the name of your city. If there is a space, use "_". Ex: "Havelock"' -ForegroundColor DarkGray
    Write-Host '- If you want to ensure it is specific to your state, you can add it in with a "+" and then the state abbreviation. Ex: "Havelock+NC"' -ForegroundColor DarkGray 
    Write-Host '- Some cities can be abbreviated, for example: New York City -> NYC | This would be valid and provide weather for NYC' -ForegroundColor DarkGray
    
    Write-Host "________________________________________" -ForegroundColor Darkgray
    Write-Host ""
    Write-Host "______________________" -ForegroundColor Darkgray
    Write-Host "        DATA" -ForegroundColor $data_ThemeColor
    Write-Host ""
    Write-Host "Name: " -NoNewLine; Write-Host $data_Name -ForegroundColor $data_ThemeColor
    Write-Host "ThemeColor: " -NoNewLine; Write-Host $data_ThemeColor -ForegroundColor $data_ThemeColor
    Write-Host "WeatherLocation: " -NoNewLine; Write-Host $data_WeatherLocation -ForegroundColor $data_ThemeColor
    Write-Host "OpenAI_APIKey: " -NoNewLine; Write-Host $data_OpenAiKey -ForegroundColor $data_ThemeColor
    Write-Host "________________________________________" -ForegroundColor Darkgray
    handleMainInput

    #Invoke-Item $data_Path 

}


function printDiagnostics {
    Write-Host ""
    Write-Host ""
    Write-Host "Synapse Diagnostics:" -ForegroundColor White
    Write-Host " -If a part does not exist, it may have either been deleted, or moved from its correct path" -ForegroundColor DarkGray
    Write-Host " -You can redownload parts, or the entirety of Synapse from: githublink" -ForegroundColor DarkGray

    Write-Host "Synapse Path: " -NoNewLine; Write-Host $PSCommandPath -ForegroundColor DarkGray

    Write-Host "Synapse Version: " -NoNewline
    Write-Host $script:SynapseVersion -ForegroundColor DarkGray

    Write-Host "Powershell Version: " -NoNewLine; Write-Host $script:psVer -ForegroundColor DarkGray

    Write-Host "Last MainFunction Called: " -NoNewline
    Write-Host $script:lastMainFunctionCalled -ForegroundColor DarkGray


    #content folder
    $contentFolderExists = Test-Path $script:contentsFolder
    $contentColor = ""
    if ($contentFolderExists) {
        $contentColor = "Green"
    }
    elseif (-not $contentFolderExists) {
        $contentColor = "Red"
    }
    Write-Host "Contents Folder exists: " -NoNewLine
    Write-Host $contentFolderExists -ForegroundColor $contentColor


    #data file
    $dataExists = Test-Path $data_Path
    $dataColor = ""
    if ($dataExists) {
        $dataColor = "Green"
    }
    elseif (-not $dataExists) {
        $dataColor = "Red"
    }
    Write-Host "Data file exists: " -NoNewLine
    Write-Host $dataExists -ForegroundColor $dataColor


    #check TC module
    $file = Join-Path -Path $script:contentsFolder -ChildPath "TC.ps1"
    $tcExists = Test-Path -Path $file
    if ($tcExists) {
        $tcColor = "Green"
    }
    elseif (-not $tcExists) {
        $tcColor = "Red"
    }
    Write-Host "Cube Module exists: " -NoNewLine
    Write-Host $tcExists -ForegroundColor $tcColor


    #check mind sweeper
    $msFile = Join-Path -Path $mindSweeperFolder -ChildPath "ButtonSweeper.ps1"
    $msExists = Test-Path -Path $msFile
    if ($msExists) {
        $msColor = "Green"
    }
    elseif (-not $msTest) {
        $msColor = "Red"
    }
    Write-Host "MindSweeper Module exists: " -NoNewLine
    Write-Host $msExists -ForegroundColor $msColor

    
    #removed weather check because it made diagnostics too slow
    <#
    try {
        $weather = (Invoke-WebRequest http://wttr.in/"Havelock+NC"?T -UserAgent "curl" ).Content
        Write-Host "Weather Data: " -NoNewline
        Write-Host "True" -ForegroundColor Green
    }
    catch {
        Write-Host "Weather Data: " -NoNewline
        Write-Host "False" -ForegroundColor Red
    }
    #>


    #Write-Host "Last main function called: " -NoNewLine
    #Write-Host $script:LastMainFunctionCalled -ForegroundColor $data_ThemeColor
    Write-Host ""
}



#MENU INPUT HANDLER:
#MAIN FUNCTION INFO: if you need to be able to return to the function after using a non essential one, use callMainFunction
function handleMainInput {
    while ($true) {
        Write-Host ""
        Write-Host "PS:\syn\$script:lastMainFunctionCalled>" -NoNewLine -ForegroundColor $data_ThemeColor
        $inputMain = ([Console]::ReadLine()).Trim() 
        if ([string]::IsNullOrEmpty($inputMain)) { continue } #continue runs from the top of a while loop, which is the same as calling handleMainInput

        $cmdName = ($inputMain -split '\s+')[0] #s+ peram makes it so string is divided from spaces or multiple spaces

        switch ($inputMain) {
            "set" { callMainFunction -functionName "settings" }; "settings" { callMainFunction -functionName "settings" }
            "setedit" { Start-Process -FilePath $data_Path -Wait; continue }; "settingsedit" { Start-Process -FilePath $data_Path -Wait; continue } #start process to fix bug with input main going under line
            "home" { callMainFunction -functionName "home" }
            "help" { callMainFunction -functionName "help" }
            "source" { callMainFunction -functionName "displaySourceCode" }
            "cube" { TC; continue }
            "mod" { displayModules; continue }
            "dx" { printDiagnostics; continue }; "diagnostics" { printDiagnostics; continue }
            "wx" { callMainFunction -functionName "displayWeather" }; "weather" { callMainFunction -functionName "displayWeather" }
            "games" { callMainFunction -functionName "games" }
            "ms" { gamesMS; continue }; "minesweeper" { gamesMS; continue }
            "hm" { hangman; continue }; "hangman" { hangman; continue }
            "bj" { blackjack; continue }; "blackjack" { blackjack; continue }
            "fact" { $factsList | Get-Random; continue }
            "re" { callMainFunction -functionName $script:lastMainFunctionCalled }
            "refresh" { callMainFunction -functionName $script:lastMainFunctionCalled }
            "quit" { exit }
            default {
                #try is so if Get-Command breaks, handleMainInput can still run after
                $psCommand = try { Get-Command $cmdName -ErrorAction Stop; $true } catch { $false }
                #if cmdName doesnt exist, stop terminates it, if no termination then psCommand is true. 
                #catch returns false for psCommand if termination happened
                #return works because we are doing psCommand EQUALS
                #ok thats it bye

                if ($psCommand) {
                    try {
                        Invoke-Expression $inputMain
                    }
                    catch {
                        Write-Host "Powershell command failed: `"$($inputMain)`"" -ForegroundColor DarkRed
                    }
                }
                else {
                    Write-Host "`"$($inputMain)`" is not registered as a command" -ForegroundColor DarkRed
                }
                continue #if everything goes wrong somehow then just do main input again
            }
        }
    }
}




#MAIN MENU SETUP:
function home {
    clear-host
    #first print greeting
    greeting
    #second print cool quote
    Write-Host $randomQuote -ForegroundColor DarkGray
    #third make the thing that handles input
    handleMainInput
}

$script:lastMainFunctionCalled = "home"
home