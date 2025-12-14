Synapse:
Synapse is a TUI (Terminal User Interface) programmed in Windows PowerShell.
It serves as a platform in Powershell, allowing you to utilize it while also serving features from Synapse to enhance your experience.


Synapse Set-up:
1: To set up Synapse, open PowerShell and type:
      notepad $PROFILE
   This will open or create a file called Microsoft.PowerShell_profile.
2: In the profile file, insert this code (replace the path with your Synapse path):

      New-Alias -Name syn -Value "C:\PATH\TO\Synapse.ps1"

       IF an error shows up, try running this, and then the code again:
      New-Item -Path (Split-Path -Parent $PROFILE) -ItemType Directory -Force

3: You may need to run this command on your Synapse folder:
      Get-ChildItem "C:\PATH\TO\SYNAPSE" -Recurse | Unblock-File
   Then, restart PowerShell. You can now open Synapse by typing the command "syn".


Tips:
- You can use your up and down keys to go to previous commands you typed
- You can use Powershell cmdlets in Synapse
- If you are missing a Synapse component (find from diagnostics), try redownloading
  and replacing your copy from: https://github.com/water890909/Synapse
