<#
clear-host
$Host.UI.RawUI.WindowTitle = "Synapse"


#INPUT SETUP:
#this was implemented so the clear command could return to the last function called 
$script:lastMainFunctionCalled = "mainMenu"
$script:ignoreFunctions = @(
    "handleMainInput",
    "printGreeting",
    "printGreetingNULL",
    "printQuoteOfTheDay"

)

#checks if function being called is not an ignoreFunction, if so lastMainFunctionCalled
#gets updated and the function gets invoked
function callMainFunction{
    param (
        $functionName
    )
    if ($script:ignoreFunctions -NotContains $functionName) {
        $script:lastMainFunctionCalled = $functionName
    }
    Invoke-Expression $functionName
}


#DATA SETUP:
$data_FileName = "SynData.json"
$data_Path = Join-Path -Path $PSScriptRoot -ChildPath $data_FileName #this is so we can find data locally
$data_Content = Get-Content -Path $data_Path -Raw
$data_ContentRetrieve = $data_Content | ConvertFrom-Json

$data_Name = $data_ContentRetrieve.Name
$data_ThemeColor = $data_ContentRetrieve.ThemeColor

$data_Quotes = $data_ContentRetrieve.Quotes
$quotesList = $data_Quotes | ForEach-Object { #runs for each object in $data_Quotes
    $_.PSObject.Properties | ForEach-Object {$_.Value}  #find value property of each object
}
$randomQuote = $quotesList | Get-Random

$data_TOD = $data_ContentRetrieve.TimeOfDayLog
function checkTOD {
    if ($null -eq $data_TOD) {
        Write-Host "null"
    } else {
        Write-host "not null"
    }
}

checkTOD
#>

# Source - https://stackoverflow.com/a
# Posted by mjolinor
# Retrieved 2025-11-24, License - CC BY-SA 3.0








<#

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
        Id = $id
        Path = $path
        Volume  = $volume
        AudioPlayer = $player
        State = "Stopped"
    }

    return $Global:AudioPlayers[$id]
}
#play audio  
function playAudio {
    param($id, $fade)
    $audioObject = $Global:AudioPlayers[$id]
    if ($fade) {
        $v = $audioObject.Volume = 0
        $audioObject.AudioPlayer.Play()
        $audioObject.State = "Playing"
        
        for ($v; $v -lt 1) {
            Start-Sleep -Milliseconds 100
            $v = $v + 0.001
            Write-host "fading $v"
            if ($v -eq 1) {
            }
        }
    } elseif (-not $fade) {
        $v = 1
        $audioObject.AudioPlayer.Play()
        $audioObject.State = "Playing"
    }
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

$kanye = createAudio -path "C:\Users\5223293797\Music\Kanye West\The College Dropout\19 Through The Wire.flac" 
playAudio -id $kanye.Id -fade $true
read-host "n"

#>


#(curl wttr.in/28532).Content

$weather = (Invoke-WebRequest http://wttr.in/"Havelock+NC"?T -UserAgent "curl" ).Content
Write-Host ($weather) -ForegroundColor Blue