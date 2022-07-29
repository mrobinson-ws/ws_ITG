$org = Get-ITGlueOrganizations -filter_name "Contoso Corporation"
$alltypes = Get-ITGlueFlexibleAssetTypes
$selectedtype = $alltypes.data.attributes.name | Sort-Object | Out-GridView -Title "Select the category to search for changes" -OutputMode Single
$type = Get-ITGlueFlexibleAssetTypes -filter_name $selectedtype
$assets = Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $type.data.id -filter_organization_id $org.data.id
$chosenassets = $assets.data.attributes.name | Sort-Object | Out-GridView -Title "Select $selectedtype items to Edit" -Passthru
foreach($chosenasset in $chosenassets){
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
    $changes = $data.attributes.traits | Sort-Object | Out-GridView -Title "Select Items to change on $($asset.data.attributes.name)" -Passthru
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
}