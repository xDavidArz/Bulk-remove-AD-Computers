<# Script to delete computers off of AD

Manually input computer names with carriage returns(Enter) and create an array.
#>

$computernames = @()

<# Asks user to start entering computer names and then stops accepting input as soon as enter is pressed while input is blank
#>

while ($true){
$inputName = Read-Host "Copy and Paste (Ctrl + V) a list of Computers or manually write it.(When it's blank press "ENTER" to finish)"
if ([string]::IsNullOrWhiteSpace($inputName)) {
break}

<#Regex - Split computer names by "123" Prefix Change the "123" to what your company prefix starts with. 
For example : "X Company uses 123SERIALNUMBER"  as their naming convention. I will edit the pattern below to split start a new line each time "123" is found  
#>


<#The Regex pattern prefix ?= should be left alone as this is looking for the characters after 123 and starting a new line everytime 123 is found
#>
$pattern ='(?=123)'
$computernames +=($inputName -split $pattern | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })}


<# Show computer names
#>

Write-Host "Computer names that were entered:" -Foregroundcolor Yellow
$computernames | ForEach-Object {Write-Host $_ -ForegroundColor Yellow}

<# Asks user to accept deletion of AD Computers and to remove the ADObject if not a leaf object

#> 

do{
$ConfirmDelete = Read-Host "Are you sure you want to delete these computers from AD? Press `"Y`" to continue / `"N`" to cancel."
switch($ConfirmDelete){
'Y'{foreach($computer in $computernames){try{
Remove-ADComputer -Identity $computer -Confirm:$False -ErrorAction Stop -verbose
} catch {
Write-Host "An error occurred while trying to remove computer due to it not being a leaf object $computer." -ForegroundColor Red
Write-Host "Attempting to solve" -ForegroundColor Yellow
$computerObject = Get-ADComputer -Filter { Name -eq $computer } | Select-Object -Property Name,ObjectGUID
Remove-ADObject -Identity $computerObject.ObjectGUID -Recursive -Confirm:$False -Verbose}}}
'N' {Write-Host "Aborting script" -Foregroundcolor Red}
default{Write-Host "Invalid option selected." -ForegroundColor Yellow}
}
} while ($ConfirmDelete -ne 'Y' -and $ConfirmDelete -ne 'N')

<#Clear out $Computername Variable
#>

Write-Host "Disposing `$ComputerNames values so that the script can run again if needed" -Foregroundcolor green
$Computernames.Clear()

