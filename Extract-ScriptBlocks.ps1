function Extract-PSScriptBlocks {
    <#
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
        
    .Notes
        Name: Extract-ScriptBlocks
        Author: DarthCyber
        Last Edit: 10/30/2020
        Keywords: 
    .Link
    https://github.com/DarthCyber
    .Inputs
        None
    .Outputs
        None
    #>
    [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$true)]
            [string]$Path,
            [Parameter(Mandatory=$false)]
            [String]$dumpDirr
        )
        PROCESS {
                        
            [System.Collections.ArrayList]$rebuiltscripts = @()
            [System.Collections.Stack]$blocks = @()
            
            $strBlock = ''            
            $ScriptBlockId = ''

            $i = 0

            $hFile = Get-Item $Path

            $4104Events = Get-WinEvent -Path $hFile -FilterXPath 'Event[System[EventID=4104]]'
            
            foreach ($event in $4104Events){
            
                $xml = [xml]::new()
                $xml.LoadXml($event.toxml())
                $eventData = $xml.GetElementsByTagName('Data')
            
                foreach($data in $eventData){
            
                    switch ($data.GetAttribute('Name')){
                        'MessageNumber'{$MessageNumber = $data.'#text'}
                        'MessageTotal'{$MessageTotal = $data.'#text'}
                        'ScriptBlockText'{$ScriptBlockText = $data.'#text'}
                        'ScriptBlockId'{$ScriptBlockId = $data.'#text'}
                        Default {continue}
                    }
                
                }
            
                #Write-Host "Numbers as they appear $MessageNumber of $MessageTotal ScriptID: $ScriptBlockId"
            
                if($ScriptBlockId -eq $prevScriptBlockId -or $i -eq 0){

                    $blocks.Push($ScriptBlockText)
                    
                }
                if(($ScriptBlockId -ne $prevScriptBlockId -or $i -eq $4104Events.Count) -and $i -ne 0){

                    $sCount = $blocks.Count
                    
                    for($s=0;$s -lt $sCount;$s++){
            
                        $strBlock += $blocks.pop()
                        
                    }
            
                    $rebuiltscripts.add([PSCustomObject]@{
                        ScriptBlockID = $prevScriptBlockId
                        ScriptBlockText = $strBlock
                    })
            
                   # $rebuiltscripts.Add($strBlock)
                    $blocks.push($ScriptBlockText)
                    $strBlock = ''
                }
            
                $prevScriptBlockId = $ScriptBlockId
                $i++
                #if($i -eq 8){break}
            }


            if($PSBoundParameters.ContainsKey('dumpDirr')){

                foreach($entry in $rebuiltscripts){

                    $file = New-Item -ItemType File -Name ($entry.ScriptBlockId + '.ps1') -Path $dumpDirr

                    Set-Content -Path $file -Value $entry.ScriptBlockText

                }

            }

            if(-not ($PSBoundParameters.ContainsKey('dumpDirr'))){
                return $rebuiltscripts
            }

        }
        
    } #End function