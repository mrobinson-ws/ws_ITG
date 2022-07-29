$org = Get-ITGlueOrganizations -filter_name "Contoso Corporation"
$alltypes = Get-ITGlueFlexibleAssetTypes
$selectedtype = $alltypes.data.attributes.name | Sort-Object | Out-GridView -Title "Select the category to search for changes" -Passthru
$type = Get-ITGlueFlexibleAssetTypes -filter_name $selectedtype
$assets = Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $type.data.id -filter_organization_id $org.data.id
$chosenasset = $assets.data.attributes.name | Out-GridView -Title "Select Item to Edit" -Passthru
$asset = Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $type.data.id -filter_organization_id $org.data.id -filter_name $chosenasset
$data = @{
    type = $asset.data.type
    attributes = @{
        traits = @{
                    
        }
    }
}

[array]$NoteProperty = $asset.data.attributes.traits | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}
    for ($i = 0; $i -lt $NoteProperty.Count; $i ++)
    {
        $NoteProperty[$i]
    }

foreach($name in $NoteProperty.Name){
    $data.attributes.traits += @{
            "$name" = $asset.data.attributes.traits."$name"
    }
}

$changes = $data.attributes.traits | Out-GridView -Passthru
foreach($change in $changes){
    Clear-Variable newvalue -ErrorAction SilentlyContinue
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
    Set-ITGlueFlexibleAssets -id $asset.data.id -Data $data -ErrorAction Stop
    Write-Host "Updated ITG with changes"
}
Catch {
    Write-Host "ITG Update Failed"
}