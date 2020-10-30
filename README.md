# Extract-PSScriptBlocks
Extracts scripts from powershell operational log

    .Synopsis
      Tool for extracting powershell scripts from the powershell operational log. Only reads 4104 events.
    .Description
        tldr
    .Example
        C:\PS>Extract-PSScriptBlocks -Path C:\LogFiles\Microsoft-Windows-PowerShell4Operational.evtx
        
        This example will return scripts as a PSCustomObject. There are 2 properties, ScriptBlockID (Extracted from the event), and ScriptBLockText (script text)
        
    .Example
        C:\PS>Extract-PSScriptBlocks -Path C:\LogFiles\Microsoft-Windows-PowerShell4Operational.evtx -dumpDir C:\usermcuser\PowershellDump\
        
        This example will dump the script files to the provided directory. Each file is named after its Script ID
