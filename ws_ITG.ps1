$org = Get-ITGlueOrganizations -filter_name "Contoso Corporation"
$types = Get-ITGlueFlexibleAssetTypes -filter_name "Licensing"
$assets = Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $types.data.id -filter_organization_id $org.data.id

$data = @{
    type = $assets.data.type
    attributes = @{
        traits = @{
                      
        }
    }
}

[array]$NoteProperty = $assets.data.attributes.traits | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}
    for ($i = 0; $i -lt $NoteProperty.Count; $i ++)
    {
        $NoteProperty[$i]
    }

foreach($name in $NoteProperty.Name){
    $data.attributes.traits += @{
            "$name" = $assets.data.attributes.traits."$name"
    }
}

$changes = $data.attributes.traits | Out-GridView -Passthru
foreach($change in $changes){
    $newvalue = Read-Host "Enter new value for $($change.name), the current value is $($Change.value)"
    if($newvalue){
        $data.attributes.traits."$($Change.Name)" = $newvalue
        Write-Host "Value has been changed to $($Data.attributes.traits."$($Change.Name)")"
    }
    else
    {
        Write-Host "No changes made"
    }
}
Try{
    Set-ITGlueFlexibleAssets -id $assets.data.id -Data $data -ErrorAction Stop
    Write-Host "Updated ITG with changes"
}
Catch {
    Write-Host "ITG Update Failed"
}