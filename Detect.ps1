# Region Config
$AppName = "DynamicWallpaper"
$RegistryPath = "HKLM:\Software\$AppName"
$DesktopRegistryURL = "DesktopImageUrl"
$DesktopImageUrl = (Get-ItemProperty -Path $RegistryPath -Name $DesktopRegistryURL -ErrorAction SilentlyContinue).$DesktopRegistryURL
$LockScreenRegistryURL = "LockScreenURL"
$LockScreenImageUrl = (Get-ItemProperty -Path $RegistryPath -Name $LockScreenRegistryURL -ErrorAction SilentlyContinue).$LockScreenRegistryURL
$desktopSuccess = $false
$lockScreenSuccess = $false
$output = $null
# End Region

# Region Detect Desktop image
if ($DesktopImageUrl) {
    # Check if the file exists online
    $DesktopImagetrue = $true
    $DesktopRegistryKeyName = "DesktopImageHash"
    $CurrentDesktopImageHash = (Get-ItemProperty -Path $RegistryPath -Name $DesktopRegistryKeyName -ErrorAction SilentlyContinue).$DesktopRegistryKeyName
    $DesktopImageHash = (Invoke-WebRequest -usebasicparsing -Uri $DesktopImageUrl -Method Head).Headers.ETag
    $DesktopImageHash = $DesktopImageHash -replace '^[^"]+"|"[^"]*$', ''

    # Compare hashes
    if ($CurrentDesktopImageHash -eq $DesktopImageHash) {
        $desktopSuccess = $true
    }
}
# End Region

# Region Detect Lock Screen image
if ($LockScreenImageUrl) {
    # Check if the file exists online
    $LockScreenRegistryKeyName = "LockScreenImageHash"
    $CurrentLockScreenImageHash = (Get-ItemProperty -Path $RegistryPath -Name $LockScreenRegistryKeyName -ErrorAction SilentlyContinue).$LockScreenRegistryKeyName
    $LockScreenImageHash = (Invoke-WebRequest -usebasicparsing -Uri $LockScreenImageUrl -Method Head).Headers.ETag
    $LockScreenImageHash = $LockScreenImageHash -replace '^[^"]+"|"[^"]*$', ''

    # Compare hashes
    if ($CurrentLockScreenImageHash -eq $LockScreenImageHash) {
        $lockScreenSuccess = $true
    }
}
# End Region

# Region Output
if ($DesktopImageUrl -and $LockScreenImageUrl) {
    if ($desktopSuccess -and $lockScreenSuccess) {
        $output = "Detected"
    }
} elseif ($LockScreenImageUrl) {
    if ($lockScreenSuccess) {
        $output = "Detected"
    }
} elseif ($DesktopImagetrue) {
    if ($desktopSuccess) {
        $output = "Detected"
    }
}
write-host $output
# End Region