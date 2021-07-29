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
    Process
    {
        $infile = Import-Csv $inFilePath
        $infile | 
        ForEach-Object {
            $querySubDomain = $_.{Sub Domain}
            if ($_.{Sub Domain} -eq "@" -or $_.{Sub Domain} -eq ""){
                $querySubDomain = ""
            }
            else {
                $querySubDomain = $querySubDomain + "."
            }
            $_ | Add-Member -NotePropertyMembers @{domain = $querySubDomain+$domain}
        }
        Write-Output "Queries are" $infile
        
        $outRecords = @()

        $infile | 
        ForEach-Object {
            $recordResult = Resolve-DnsName $_.domain $_.{Record Type}
            $recordResult = $recordResult | Where-Object Type -eq $_.{Record Type}
            #$query = $_
            $recordResult | 
            ForEach-Object {
                $outRecords += $_
            }
        }
        $outRecords | Export-Csv -Path out.csv -NoTypeInformation
    }
}
