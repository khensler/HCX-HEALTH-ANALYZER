param ([string]$hcxserver,$exrCheck = $null)

#########
#
# Usage .\collect.ps1 -hcxserver <HCX IP> [-exrCheck $true|$false]
# If exrCheck true ensure Connect-AzAccount already run and connected
# Send output.zip to MS AVS team
#
#########

import-module vmware.powercli


connect-hcxserver $hcxserver

#Get local and remote HCX Sites
Get-HCXSite| convertto-json -depth 100 | out-file "site.json"
Get-HCXSite -destination | convertto-json -depth 100 | out-file "site-destination.json"

#Get Site Pairing
Get-HCXSitePairing| convertto-json -depth 100 | out-file "sitepairing.json"

#Get Local Inventory
Get-HCXService| convertto-json -depth 100 | out-file "service.json"
Get-HCXServiceMesh| convertto-json -depth 100 | out-file "servicemesh.json"
Get-HCXContainer| convertto-json -depth 100 | out-file "container.json"
Get-HCXDatastore| convertto-json -depth 100 | out-file "datastore.json"
Get-HCXInventoryCompute -ClusterComputeResource| convertto-json -depth 100 | out-file "inventorycompute.json"
Get-HCXInventoryCompute -ClusterComputeResource | Get-HCXInventoryDatastore | convertto-json -depth 100 | out-file "inventorydatastore.json"
Get-HCXInventoryDVS| convertto-json -depth 100 | out-file "inventorydvs.json"
Get-HCXInventoryNetwork| convertto-json -depth 100 | out-file "inventorynetwork.json"
Get-HCXNetwork| convertto-json -depth 100 | out-file "network.json"
Get-HCXNetworkBacking| convertto-json -depth 100 | out-file "networkbacking.json"
Get-HCXNetworkExtension| convertto-json -depth 100 | out-file "networkextension.json"

#Get Profiles
Get-HCXComputeProfile| convertto-json -depth 100 | out-file "computeprofile.json"
Get-HCXNetworkProfile| convertto-json -depth 100 | out-file "networkprofile.json"
Get-HCXStorageProfile| convertto-json -depth 100 | out-file "storageprofile.json"


#Get Remote HCX NSX Gateways
foreach ($site in (get-hcxsite -destination)){
    Get-HCXGateway -destinationsite $site | convertto-json -depth 100 | out-file "$site-gateway.json"    
}

#Get Local Appliances
Get-HCXAppliance| convertto-json -depth 100 | out-file "appliance.json"

#Get Local Inerconnect Status
Get-HCXInterconnectStatus| convertto-json -depth 100 | out-file "interconnectstatus.json"

#Get Jobs
Get-HCXJob| convertto-json -depth 100 | out-file "job.json"

#Get Migrations
Get-HCXMigration| convertto-json -depth 100 | out-file "migration.json"
Get-HCXMobilityGroup| convertto-json -depth 100 | out-file "mobilitygroup.json"
Get-HCXReplication| convertto-json -depth 100 | out-file "replication.json"
write-host "exrCheck: $exrCheck"
if ($exrCheck -eq $false) {
    $exr_check = "N"
}elseif ($exrCheck -eq $true) {
    $exr_check = "Y"
}elseif ($null -eq $exrCheck){
    $exr_check = Read-host "Collect Express Route Details? (You must already be connect to Azure via Connect-AzAccount) [y/N]"
}
if ($exr_check.ToUpper()[0] -eq "Y"){
    $exr_resource_group = Read-host "Enter Express Route Resource Group"
    $exr_name = Read-host "Enter Express Route Name"
    Get-AzExpressRouteCircuit -ResourceGroupName $exr_resource_group -Name $exr_name | convertto-json -depth 100 | out-file "expressroute.json"
}


$compress =  @{
    Path = ".\*.json"
    DestinationPath = ".\output.zip"
}
compress-archive @compress -force
remove-item ".\*.json"


write-host "Pleaes generate a support bundle from HCX Manager including all appliance logs"
write-host "Please send the output.zip file and the support bundle"

