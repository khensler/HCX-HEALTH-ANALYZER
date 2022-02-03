# HCX Health Analyzer
This repo is a tool to check configuration of HCX cloud connectors and thier service meshes.  It will collect data, output it to json, and compress the files.  The next part of the tool will read the data and produce a configuration report.  

## Collection

`.\check.ps1 -hcxserver <HCX IP> [-exrCheck $true|$false]`

If the envionrment is connected via an express route setting -exrCheck $true will request the express route resource group and name for the express route that connects from on premises to Azure.  Connect-AzAccount must already be run and connected to the Azure envionrment with the express route.  All commands are read only.

output.zip will be generated

## Check Output

Place the output.zip in the same directory as the check.ps1 file.

`.\check.ps1`

This script will extract the zip file, import the data, and generate a report on the console.
