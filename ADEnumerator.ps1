#Gives you the list of active accounts, when they were created, last used and password last set. (Can help pick targets/create pw list)

Import-Module ActiveDirectory

$filename = Read-Host "Enter Name for Output File: "

 $scroll = "\|/"
$idx = 0
$job = Invoke-Command -ComputerName $env:ComputerName -ScriptBlock { Start-Sleep -Seconds 3 } -AsJob

$origpos = $host.UI.RawUI.CursorPosition
$origpos.Y += 1

while ($job.State -eq "Running")
{
	$host.UI.RawUI.CursorPosition = $origpos
	Write-Host $scroll[$idx] -NoNewline
	$idx++
	if ($idx -ge $scroll.Length)
	{
		$idx = 0
	}
	Start-Sleep -Seconds 1
}

# It's over - clear the activity indicator.
$host.UI.RawUI.CursorPosition = $origpos
Write-Host 'Compiling....Please Wait' 

Get-ADUser -filter {Enabled -eq $true} -Properties whencreated, lastlogondate, PasswordLastSet | Where-Object{$_.DistinguishedName -like "*OU=*" } | select Name, WhenCreated, PasswordLastSet, LastLogonDate | Export-Csv -path "c:\temp\$filename.csv"

echo "Results have been exported to c:\temp\$filename.csv"

 Start-sleep -Seconds 10

stop-process -Id $PID 
