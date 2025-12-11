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
    $noteIndex = [int]$data_NotesStorage.NoteIndex.Value
    $updatedIndex = ($noteIndex + 1)
    write-host $updatedIndex

    $data_Content.NotesStorage.NoteIndex = $updatedIndex
    $updated_dataContent = $data_Content | ConvertTo-Json -Depth 100
    $updated_dataContent = Set-Content -Path $data_Path 
    Write-Host "set"
}      

writeNote










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



