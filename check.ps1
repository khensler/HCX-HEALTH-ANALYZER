function load_json{
    param($file)
    return Get-Content -raw -path $file -ErrorAction Ignore | convertfrom-json 
}

function write-enpointname{
    param($objects,
        $name
    )
    foreach ($object in $objects){
        write-host $name":`t`t" -nonewline
        write-host -foregroundcolor cyan $object.endpointname -nonewline
        if ($object.IsLocal -eq $false){
            write-host -foregroundcolor cyan " ("$object.EndpointUrl")" -nonewline
        }
        write-host ""
    }
}

function check-site-pairings{
    param($sitepairing)
    Write-host "Site Pairing Status:"
    foreach ($pairing in $sitepairing){
        Write-host "`tSite Pairing:`t" -nonewline
        write-host -foregroundcolor cyan $pairing.Name
        write-host "`t`tStatus:`t" -nonewline
        write-host "`t" -nonewline
        if ($pairing.Status -eq "ok"){
            write-host -ForegroundColor Green $pairing.Status
        }else{
            write-host -ForegroundColor Red $pairing.Status
        }
        write-host "`t`tUsername:`t" -nonewline
        if ($pairing.username -ne "cloudadmin@vsphere.local"){
            write-host -ForegroundColor Green $pairing.username
        }else{
            write-host -ForegroundColor Red $pairing.username
        }
    }
}

function check-interconnect-status{
    param($interconnects)
    write-host "Check Interconnect Status"
    foreach ($interconnect in $interconnects){
        write-host "`tComponent:`t" -nonewline
        write-host -foregroundcolor cyan $interconnect.ServiceComponent
        write-host "`t`t`tStatus:`t" -nonewline
        if ($interconnect.Status -eq "up"){
            write-host -ForegroundColor Green $interconnect.Status
        }else{
            write-host -ForegroundColor Red $interconnect.Status
        }
        write-host "`t`t`tTunnel:`t" -nonewline
        if ($interconnect.Tunnel -eq "up"){
            write-host -ForegroundColor Green $interconnect.Tunnel
        }else{
            write-host -ForegroundColor Red $interconnect.Tunnel
        }
        write-host "`t`t`tIP Addresses:"
        foreach ($ip in $interconnect.Ipaddress.split(";")){
            write-host "`t`t`t`t" -nonewline
            ($type,$ip) = $ip.split(":")
            write-host $type  ":`t"$ip
        }

    }
}

function check-service-mesh{
    param($servicemesh)
    write-host "Check Service Mesh Service Status"
    foreach ($sm in $servicemesh){
        write-host "`tService Mesh:`t" -nonewline
        write-host -foregroundcolor cyan $sm.name":"
        foreach ($comp_profile in $sm.computeprofile){
            if ($comp_profile.network){
                write-host -foregroundcolor Yellow "`tMultiple Network Profiles Detected Verify No Overlaping Subnets"
            }
        }
        foreach ($servicestatus in $sm.servicestatus){
            write-host "`t`t`t" -nonewline
            write-host $servicestatus.ServiceName -nonewline
            if ($servicestatus.ServiceName.length -lt 8){
                write-host "`t" -nonewline
            }
            if ($servicestatus.ServiceName.length -lt 17){
                write-host "`t" -nonewline
            }
            write-host "`t" -nonewline
            if ($servicestatus.status -eq "up"){
                write-host -ForegroundColor Green $servicestatus.status
            }else{
                write-host -ForegroundColor Red $servicestatus.status --nonewline
                write-host "t"$servicestatus.reason
            }
        }
    }
}

function check-network-profiles{
    param($profiles)
    write-host "Checking Network Profiles:"
    foreach ($profile in $profiles){
        write-host "`tProfile Name:`t" -nonewline
        write-host -foregroundcolor cyan $profile.name
        write-host "`t`t`tPortGroup Name:`t" -nonewline
        write-host $profile.networkbacking.Name
        write-host "`t`t`tCIDR:`t`t" -nonewline
        write-host $profile.gateway"/"$profile.prefixlength
        write-host "`t`t`tMTU:`t`t" -nonewline
        if (($profile.mtu -lt 1150) -or ($profile.mtu -gt 1500)){
            write-host -ForegroundColor Red $profile.MTU
        }else{
            write-host -ForegroundColor Green $profile.MTU
        }

    }
}

function check-jobs{
    param($jobs)
    write-host "Check For Failed Jobs"
    foreach ($job in $jobs){
        if ($job.state -ne "SUCCESS"){
            write-host "Job ID: "$job.id
            write-host "`tState:`t`t" -nonewline
            write-host -ForegroundColor Red $job.state
            write-host "`tError:`t`t" -nonewline
            write-host $job.ErrorMessage
            write-host "`tMessage:`t" -nonewline
            write-host -ForegroundColor Yellow $job.Message
        }
    }
}

function check-network-ext{
    param($exts)
    write-host "Check Network Extension"
    foreach ($ext in $exts){
        write-host "Extension:`t" -nonewline
        write-host -ForegroundColor cyan $ext.Network.Name
        write-host "`tSource Site:`t`t" -nonewline
        write-host -ForegroundColor cyan $ext.Source.endpointname
        write-host "`tDestination Site:`t" -nonewline
        write-host -ForegroundColor cyan $ext.Destination.endpointname
        write-host "`tIP Subnet:`t`t" -nonewline
        write-host -ForegroundColor cyan $ext.gatewayip
        write-host "`tMask:`t`t`t" -nonewline
        write-host -ForegroundColor cyan $ext.netmask
        write-host "`tEgress Optimization:`t" -nonewline
        write-host $ext.EgressOptimization
        write-host "`tProximity Routing:`t" -NoNewline
        write-host $ext.ProximityRouting
        write-host "`tExtension Status:`t" -NoNewline
        if ($ext.status -eq "Extension complete"){
            write-host -ForegroundColor Green $ext.status
        }else{
            write-host -ForegroundColor Red $ext.status
        }
    }
}

function check-exr{
    param($exr)
    write-host "Express Route:"
    write-host "`tName:`t`t`t" -NoNewline
    write-host -ForegroundColor cyan $exr.name
    write-host "`tBandwidth Mbps:`t`t" -NoNewline
    if ($exr.ServiceProviderProperties.BandwidthInMbps -ge 10000){
        write-host -ForegroundColor green $exr.ServiceProviderProperties.BandwidthInMbps
        write-host -ForegroundColor green "`t`t`t`tAll HCX Services Supported"
    }elseif($exr.ServiceProviderProperties.BandwidthInMbps -ge 150){
        write-host -ForegroundColor yellow $exr.ServiceProviderProperties.BandwidthInMbps
        write-host -ForegroundColor green "`t`t`t`tAll HCX Services Supported"
    }elseif($exr.ServiceProviderProperties.BandwidthInMbps -ge 100){
        write-host -ForegroundColor yellow $exr.ServiceProviderProperties.BandwidthInMbps
        write-host -ForegroundColor yellow "`t`t`t`tReplication Assisted VMotion Not Supported"
    }elseif($exr.ServiceProviderProperties.BandwidthInMbps -ge 50){
        write-host -ForegroundColor yellow $exr.ServiceProviderProperties.BandwidthInMbps
        write-host -ForegroundColor yellow "`t`t`t`tHCX vMotion and Replication Assisted VMotion Not Supported"
    }else{
        write-host -ForegroundColor red $exr.ServiceProviderProperties.BandwidthInMbps
        write-host -ForegroundColor red "`t`t`t`tNo HCX Services Supported"
    }
    write-host "`tProvisioning Status:`t" -NoNewline
    if ($exr.ProvisioningState -eq "Succeeded"){
        write-host -ForegroundColor green $exr.ProvisioningState
    }else{
        write-host -ForegroundColor red $exr.ProvisioningState
    }
}


$fname = ".\output"
if ($args[0]){
    $fname = $args[0]
}
expand-archive -path $fname -destinationpath ".\" -force

Write-host "Checking Site:`t`t" -nonewline
write-host (load_json(".\site.json")).endpointname -ForegroundColor cyan


write-enpointname -object (load_json( ".\site-destination.json")) -name "Remote Site"

check-site-pairings -sitepairing (load_json(".\sitepairing.json"))

check-interconnect-status -interconnects (load_json("interconnectstatus.json"))

check-service-mesh -servicemesh (load_json( "servicemesh.json"))

check-network-profiles -profiles (load_json("networkprofile.json"))

check-network-ext -exts (load_json("networkextension.json"))

check-exr -exr (load_json("expressroute.json"))

check-jobs -jobs (load_json("job.json"))