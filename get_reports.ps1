# Powershell script to access PowerBI metadata according to the following documentation:
#
# https://learn.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps
#
# License MIT

# Script parameters
[CmdletBinding()]
param 
(
	[Parameter(Mandatory = $True)]
	[string] $tenant, # e.g. contoso.onmicrosoft.com

	[Parameter(Mandatory = $True)]
	[string] $secret,
	
	# [Parameter(Mandatory = $True)]
	# [string] $certificate,

	[Parameter(Mandatory = $True)]
	[string] $applicationId
)

# Install PowerBI module if needed
if (-Not (Get-Module -ListAvailable -Name MicrosoftPowerBIMgmt)) {
	Install-Module -Name MicrosoftPowerBIMgmt
}

# Connect with service principal using passsword
$password = ConvertTo-SecureString $secret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($applicationId, $password)
Connect-PowerBIServiceAccount -Tenant $tenant -ServicePrincipal -Credential $credential | Out-Null

# Connect with service principal using certificate
# Connect-PowerBIServiceAccount -ServicePrincipal -CertificateThumbprint $certificate -ApplicationId $applicationId | Out-Null

# Exlude following workspaces from report retrieval (define if needed otherwise leave empty)
$excludedWorkspaces = @("Their Workspace2", "Other Workspace2")

# Get workspaces within organisation with related reports and datasets filter out excluded workspaces
$workspaces = Get-PowerBIWorkspace -Scope Organization -Include Reports, Datasets | Where-Object { $_.Name -notin $excludedWorkspaces }

$result = [PSObject]@{
	Reports  = New-Object -TypeName System.Collections.Arraylist
	Datasets = New-Object -TypeName System.Collections.Arraylist
}

# Iterate over workspaces and identify reports and datasets
$workspaces | ForEach-Object {
	$workspace = $_
	
	$workspace.Reports | ForEach-Object {
		# Add workspace information to report
		$report = $_ | Select-Object -Property * | Add-Member -NotePropertyMembers @{
			Workspace = @{
				Id   = $workspace.Id
				Name = $workspace.Name
			}
		} -PassThru
		
		$result.Reports.Add($report) | Out-Null
	}

	$workspace.Datasets | ForEach-Object {
		# Add workspace information to dataset
		$dataset = $_ | Select-Object -Property * | Add-Member -NotePropertyMembers @{
			Workspace = @{
				Id = $workspace.Id
				Name = $workspace.Name
			}
		} -PassThru
		
		$result.Datasets.Add($dataset) | Out-Null
	}
}

# Disconnect from PowerBI
Disconnect-PowerBIServiceAccount

# Output result as JSON
$result | ConvertTo-Json -Depth 10 