<#
.Synopsis
   Utility to resolve DNS queries stored in a CSV file.
.DESCRIPTION
   Utility to resolve DNS queries stored in a CSV file.
   CSV file must contain two columns: (Subdomain, Record Type)
   Command outputs a CSV with three columns (Subdomain, Record Type, DNS Record)
.EXAMPLE
    Get-DnsRecordFromCsv Domain InputFile [-o OutputFile]
#>
function Get-DnsRecordFromCsv
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Host domain for sending queries to
        [string]
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $domain,

        # Input file CSV containing queries to send
        [string]
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $inFilePath
    )

    function Get-QueriesFromCsv {
        Param
        (
            # Host domain for sending queries to
            [string]
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            $domain,

            # Input file CSV containing queries to send
            [string]
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            $inFilePath
        )
        
        $infile = Import-Csv $inFilePath
        $infile | 
        ForEach-Object {
            $querySubDomain = $_.{Sub Domain}
            if ($_.{Sub Domain} -eq "@" -or $_.{Sub Domain} -eq ""){
                $querySubDomain = ""
            }
            $_ = $_ | Add-Member -NotePropertyMembers @{querySubDomain= $querySubDomain+"."}
        }
    }

    Process
    {
        Get-QueriesFromCsv -domain $domain -inFilePath $inFilePath
    }
}
