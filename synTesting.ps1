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



$path = "C:\Users\scljd\Music\MUSIC"
function music {
    Clear-Host
    Write-Host "Music" -ForegroundColor Blue
    Write-Host "______________________" -ForegroundColor Darkgray
    
    if (-not (Test-Path $path)) {
        Write-Host "You do not have a music folder set up in Synapse"
        Write-Host "Try typing 'setEdit' and adding one into settings"
        Write-Host ":("
        handleMainInput
    }

    $directory = Get-ChildItem -Path $path -Directory
    if ($directory.Count -eq 1) {
        Write-Host "Your music path doesnt contain folders with music" 
        Write-Host "Try adding music into folders inside your music directory"
        Write-Host ":("
        handleMainInput
    }

    for ($i = 0; $i -lt $directory.Count; $i++) {
        Write-Host "$($i): $($directory[$i].Name)"
    }

    Write-Host ""; Write-Host "What would you like to listen to?"



    Write-Host "________________________________________" -ForegroundColor Darkgray
    

}

music











<#
function writeNote {
    param (
        $text = ""
    )
    $data_PathWN = Join-Path -Path $contentsFolder -ChildPath "SynData.json"
    $data_ContentWN = Get-Content -Path $data_PathWN -Raw
    $data_ContentRetrieveWN = $data_ContentWN | ConvertFrom-Json

    [int]$value = $data_ContentRetrieveWN.NotesStorage.NotesIndex
    $data_ContentRetrieveWN.NotesStorage.NotesIndex = ($value + 1)
    $update = $data_ContentRetrieveWN 
    ConvertTo-Json $update | Format-Json | Set-Content -Path $data_Path

}      

writeNote
#>










# Source - https://stackoverflow.com/a
# Posted by Tim Abell, modified by community. See post 'Timeline' for change history
# Retrieved 2025-11-17, License - CC BY-SA 4.0
<#
$colors = [enum]::GetValues([System.ConsoleColor])
Foreach ($bgcolor in $colors){
    Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
    Write-Host " on $bgcolor"
}



[System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder

# Without [void], this line would output the StringBuilder object to the console
$sb.Append("Hello") 

# Using [void] discards the output
[void]$sb.Append(" World!")

Write-Host "The final string is: $($sb.ToString())"

#best example of void
[void] Get-ChildItem
#>



