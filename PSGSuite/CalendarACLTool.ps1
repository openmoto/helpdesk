$Script = ([io.fileinfo]$MyInvocation.MyCommand.Definition)
$AppDir = $Script.DirectoryName
$Workspaces = Join-Path -Path $AppDir -ChildPath 'domains'
$Domains = (((Get-ChildItem $Workspaces -Directory).Name -notmatch "template" ) -notmatch $($domain))

foreach ($domain in $Domains)
{
. .\Update-CalendarACL.ps1 -domain $domain
}