#[CmdletBinding()]
#Param(
#    [Parameter(Mandatory=$True, Position=0, HelpMessage="The name of the Azure Subscription for which you've imported a *.publishingsettings file.")]
#    [string]$Subscription,
#    [Parameter(Mandatory=$True, Position=1, HelpMessage="The name of the resource group.")]
#    [string]$ResourceGroup,
#    [Parameter(Mandatory=$True, Position=2, HelpMessage="The name of the Azure Region/Location: East US, Central US, West US.")]
#    [string]$AzureLocation,
#    [Parameter(Mandatory=$True, Position=3, HelpMessage="The common prefix for resources naming: looksfamiliar")]
#    [string]$Prefix,
#    [Parameter(Mandatory=$True, Position=4, HelpMessage="The suffix which is one of 'dev', 'test' or 'prod'")]
#    [string]$Suffix,
#    [Parameter(Mandatory=$True, Position=5, HelpMessage="debug or release.")]
#    [string]$Configuration
#)

$Subscription = "95ec29e1-405b-4df4-8d1a-8309f371f550"
$ResourceGroup = "kt-resource-group"
$AzureLocation ="East US"
$Prefix = "kt"
$Suffix = "dev"
$Configuration = "release"

$Path = Split-Path -parent $PSCommandPath
$path = Split-Path -parent $path

Write-Verbose "Start building models automation Build-Models.ps1" -Verbose
$command = $Path + "\models\automation\Build-Models.ps1"
&$command -Path $Path -configuration $Configuration

Write-Verbose "Start building  microservices common automation Build-Common.ps1" -Verbose
$command = $Path + "\microservices\common\automation\Build-Common.ps1"
&$command -Path $Path -configuration $Configuration

Write-Verbose "Start building \microservices\provision\automation\01-Build-ProvisionM.ps1" -Verbose
$command = $Path + "\microservices\provision\automation\01-Build-ProvisionM.ps1"
&$command -Path $Path -configuration $Configuration

Write-Verbose "Provision to cloud \microservices\provision\automation\02-Deploy-ProvisionM.ps1" -Verbose
$command = $Path + "\microservices\provision\automation\02-Deploy-ProvisionM.ps1"
&$command -Path $Path -Subscription $Subscription -ResourceGroup $ResourceGroup -AzureLocation $AzureLocation -Prefix $Prefix -Suffix $Suffix -DeployData:$true