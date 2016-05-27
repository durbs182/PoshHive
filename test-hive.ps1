
$global:Username = $null

$global:Websession = New-Object Microsoft.PowerShell.Commands.WebRequestSession  
$global:HubId = $null
$global:Useragent = "bg-hive-api/1.0.4"
$global:Domain = "api.bgchlivehome.co.uk"
$global:Baseuri = "https://$Domain/v5"

$global:DeviceId = $null
Function Get-ControlDeviceId
{
	$devicesnuri = $baseuri + "/users/$global:Username/hubs/$global:HubId/devices"

	$devices = Invoke-RestMethod -Uri $devicesnuri -UserAgent $useragent -WebSession $global:Websession

	$global:DeviceId = $devices | where {$_.type -like "HAHVACThermostat*"} | % {$_.id}
}

Function Start-HiveSession
{
	[CmdletBinding()] param (
    [Parameter(Mandatory=$false, Position = 0)]
        [string] $Username = "",
    [Parameter(Mandatory=$false, Position = 0)]
        [string] $Password = "" 
    )
	$body = @{}
	$body.Add("username", $Username)
	$body.Add("password", $Password)
	$body.Add("caller","HiveHome")
	$loginuri = $global:Baseuri + '/login'

	$r = Invoke-RestMethod -Body $body -Uri $loginuri -UserAgent $global:Useragent -Method "POST"
	$cookie = New-Object System.Net.Cookie 
	$cookie.Name = "ApiSession"
	$cookie.Value = $r.ApiSession
	$cookie.Domain = $global:Domain
	$global:Websession.Cookies.Add($cookie)

	$global:HubId = $r.hubIds[0]
	$global:Username = $Username
	
	Get-ControlDeviceId
}

Function Get-ClimateState
{
	$uri = $baseuri + "/users/$global:Username/widgets/climate/$global:DeviceId/control"
	return Invoke-RestMethod -Uri $uri -UserAgent $useragent -WebSession $global:Websession
}

Function Set-ClimateControlMode
{
	[CmdletBinding()] param (
    [Parameter(Mandatory=$true, Position = 0)]
	[ValidateSet("OFF","MANUAL","SCHEDULE","BOOST")]
        [string] $Mode
    )

	$modebody = @{}
	$modebody.Add("control", $Mode)
	
	$uri = $baseuri + "/users/$global:Username/widgets/climate/$global:DeviceId/control"
	
	Invoke-WebRequest -Uri $uri -UserAgent $useragent -WebSession $global:Websession -Body $modebody -Method Put -ContentType "application/x-www-form-urlencoded"
}

Function Get-ClimateSchedule
{
	$uri = $baseuri + "/users/$global:Username/widgets/climate/$global:DeviceId/controls/schedule"
	return Invoke-RestMethod -Uri $uri -UserAgent $useragent -WebSession $global:Websession
}

Function Get-TargetTemperature
{
	$uri = $baseuri + "/users/$global:Username/widgets/climate/$global:DeviceId/targetTemperature"
	return Invoke-RestMethod -Uri $uri -UserAgent $useragent -WebSession $global:Websession
}

Function Set-TargetTemperature
{
	[CmdletBinding()] param (
    [Parameter(Mandatory=$true, Position = 0)]
        [int] $Temperature
    )
	
	$tempbody = @{}
	$tempbody.Add("temperatureUnit", "C")
	$tempbody.Add("temperature", "$Temperature")

	$uri = $baseuri + "/users/$global:Username/widgets/climate/$global:DeviceId/targetTemperature"
	Invoke-WebRequest -Uri $uri -UserAgent $useragent -WebSession $global:Websession -Body $tempbody -Method Put -ContentType "application/x-www-form-urlencoded"
}

Function Get-TemperatureHistory
{
	[CmdletBinding()] param (
    [Parameter(Mandatory=$true, Position = 0)]
	[ValidateSet("thisHour","today","thisWeek","thisMonth","thisYear")]
        [string] $Period
    )
	
	$histbody = @{}
	$histbody.Add("period", $Period)
	
	$uri = $baseuri +"/users/pauldurbin69@gmail.com/widgets/temperature/$deviceId/history"
	
	return Invoke-RestMethod -Uri $uri -UserAgent $useragent -WebSession $global:Websession -Body $histbody
}

Start-HiveSession -Username "[YOUR USER NAME HERE]" -Password "[YOUR PASSWORD HERE]"


Set-TargetTemperature -Temperature 1

Get-ClimateState

Get-ClimateSchedule

Get-TargetTemperature

Set-ClimateControlMode -Mode "BOOST"
Set-ClimateControlMode -Mode "OFF"
Set-ClimateControlMode -Mode "MANUAL"
Set-ClimateControlMode -Mode "SCHEDULE"


Get-TemperatureHistory -Period "thisWeek"




