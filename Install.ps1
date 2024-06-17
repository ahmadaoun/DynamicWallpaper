# Region Config
param(
    [string]$DesktopImageUrl,
    [string]$LockScreenImageUrl
)

function Download-Image {
    param (
        [string]$Url,
        [string]$Destination
    )
    Invoke-WebRequest -Uri $Url -OutFile $Destination -ErrorAction Stop
}

function Set-DesktopWallpaper {
    param(
        [string]$DesktopImageUrl
    )

    Write-Host "Desktop Image URL: $DesktopImageUrl"
    
    # Check if the file exists online
    try {
        $response = Invoke-WebRequest -Uri $DesktopImageUrl -Method Head -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "File found at $DesktopImageUrl"
        } else {
            Write-Error "File not found at $DesktopImageUrl (Status code: $($response.StatusCode))"
            return
        }
    } catch {
        Write-Error "Error occurred while checking the URL: $_"
        return
    }

    # Paths and variables
    $AppName = "DynamicWallpaper"
    $DesktopRegistryKeyName = "DesktopImageHash"
    $DesktopRegistryURL = "DesktopImageUrl"
    $RegistryPath = "HKLM:\Software\$AppName"
    $CurrentDesktopImageHash = (Get-ItemProperty -Path $RegistryPath -Name $DesktopRegistryKeyName -ErrorAction SilentlyContinue).$DesktopRegistryKeyName
    $DesktopImageHash = (Invoke-WebRequest -Uri $DesktopImageUrl -Method Head).Headers.ETag
    $DesktopImageHash = $DesktopImageHash -replace '^[^"]+"|"[^"]*$', ''
    $fileExtension = [System.IO.Path]::GetExtension($DesktopImageUrl)
    $DesktopImagePath = "$env:ProgramData\$AppName\Images\desktop-background$fileExtension"
    $logPath = "$env:ProgramData\$AppName\logs"
    $logFile = "$logPath\Set-DesktopWallpaper.log"
    $imagespath = "$env:ProgramData\$AppName\Images"

    # Logging
    if (!(Test-Path -Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory -Force | Out-Null
    }
    Start-Transcript -Path $logFile -Force

    if (!(Test-Path -Path $imagespath)) {
        New-Item -Path $imagespath -ItemType Directory -Force | Out-Null
    }

    # Function to set wallpaper
    function Set-Wallpaper {
        param (
            [string]$DesktopImagePath
        )
    
        if (-not (Test-Path -Path $DesktopImagePath)) {
            Write-Host "The specified wallpaper path does not exist: $DesktopImagePath"
            return
        }
    
        $absolutePath = [System.IO.Path]::GetFullPath($DesktopImagePath)
    
        Write-Host "Attempting to set wallpaper: $absolutePath"
        try {
            $DesktopPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
            if (-not (Test-Path -Path $DesktopPath)) {
                New-Item -Path $DesktopPath -Force | Out-Null
            }

            Set-ItemProperty -Path $DesktopPath -Name "DesktopImagePath" -Value $absolutePath
            Set-ItemProperty -Path $DesktopPath -Name "DesktopImageUrl" -Value $DesktopImageUrl
            Set-ItemProperty -Path $DesktopPath -Name "DesktopImageStatus" -Value 1
            Write-Host "Wallpaper set successfully."
        } catch {
            Write-Host "Failed to set wallpaper! Error: $_"
        }
    }

    # Function to update registry key with image hash
    function Update-RegistryKey {
        param (
            [string]$KeyName,
            [string]$HashValue
        )
        Set-ItemProperty -Path $RegistryPath -Name $KeyName -Value $HashValue
        Set-ItemProperty -Path $RegistryPath -Name $DesktopRegistryURL -Value $DesktopImageUrl
    }

    try {
        if (-not (Test-Path $RegistryPath)) {
            New-Item -Path $RegistryPath -Force | Out-Null
            Download-Image -Url $DesktopImageUrl -Destination $DesktopImagePath
            Set-Wallpaper -DesktopImagePath $DesktopImagePath
            Update-RegistryKey -KeyName $DesktopRegistryKeyName -HashValue $DesktopImageHash
        } elseif ($CurrentDesktopImageHash -ne $DesktopImageHash) {
            Write-Host "Image has changed. Downloading..."
            Download-Image -Url $DesktopImageUrl -Destination $DesktopImagePath
            Set-Wallpaper -DesktopImagePath $DesktopImagePath
            Update-RegistryKey -KeyName $DesktopRegistryKeyName -HashValue $DesktopImageHash
        } else {
            Write-Host "Image has not changed."
        }
    } catch {
        Write-Warning $_.Exception.Message
        Stop-Transcript
        throw $_.Exception.Message
    } finally {
        Write-Host "Script completed successfully."
        Stop-Transcript
    }
}

function Set-LockScreenWallpaper {
    param(
        [string]$LockScreenImageUrl
    )

    Write-Host "Lockscreen Image URL: $LockScreenImageUrl"

    # Check if the file exists online
    try {
        $response = Invoke-WebRequest -Uri $LockScreenImageUrl -Method Head -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "File found at $LockScreenImageUrl"
        } else {
            Write-Error "File not found at $LockScreenImageUrl (Status code: $($response.StatusCode))"
            return
        }
    } catch {
        Write-Error "Error occurred while checking the URL: $_"
        return
    }

    # Paths and variables
    $AppName = "DynamicWallpaper"
    $LockScreenRegistryKeyName = "LockScreenImageHash"
    $LockScreenRegistryURL = "LockScreenURL"
    $RegistryPath = "HKLM:\Software\$AppName"
    $CurrentLockScreenImageHash = (Get-ItemProperty -Path $RegistryPath -Name $LockScreenRegistryKeyName -ErrorAction SilentlyContinue).$LockScreenRegistryKeyName
    $LockScreenImageHash = (Invoke-WebRequest -Uri $LockScreenImageUrl -Method Head).Headers.ETag
    $LockScreenImageHash = $LockScreenImageHash -replace '^[^"]+"|"[^"]*$', ''
    $fileExtension = [System.IO.Path]::GetExtension($LockScreenImageUrl)
    $LockScreenImagePath = "$env:ProgramData\$AppName\Images\lockscreen-background$fileExtension"
    $logPath = "$env:ProgramData\$AppName\logs"
    $logFile = "$logPath\Set-LockScreenWallpaper.log"
    $imagespath = "$env:ProgramData\$AppName\Images"

    # Logging
    if (!(Test-Path -Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory -Force | Out-Null
    }
    Start-Transcript -Path $logFile -Force

    if (!(Test-Path -Path $imagespath)) {
        New-Item -Path $imagespath -ItemType Directory -Force | Out-Null
    }

    function Set-LockScreen {
        if (-not (Test-Path -Path $LockScreenImagePath)) {
            Write-Host "The specified lock screen path does not exist: $LockScreenImagePath"
            return
        }

        $absolutePath = [System.IO.Path]::GetFullPath($LockScreenImagePath)
    
        Write-Host "Attempting to set lock screen: $absolutePath"
        try {
            $LockScreenPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
            if (-not (Test-Path -Path $LockScreenPath)) {
                New-Item -Path $LockScreenPath -Force | Out-Null
            }

            Set-ItemProperty -Path $LockScreenPath -Name "LockScreenImagePath" -Value $absolutePath
            Set-ItemProperty -Path $LockScreenPath -Name "LockScreenImageUrl" -Value $LockScreenImageUrl
            Set-ItemProperty -Path $LockScreenPath -Name "LockScreenImageStatus" -Value 1
            Write-Host "Lock screen wallpaper set successfully."
        } catch {
            Write-Host "Failed to set lock screen wallpaper! Error: $_"
        }
    }

    function Update-RegistryKey {
        param (
            [string]$KeyName,
            [string]$HashValue
        )
        Set-ItemProperty -Path $RegistryPath -Name $KeyName -Value $HashValue
        Set-ItemProperty -Path $RegistryPath -Name $LockScreenRegistryURL -Value $LockScreenImageUrl
    }

    try {
        if (-not (Test-Path $RegistryPath)) {
            New-Item -Path $RegistryPath -Force | Out-Null
            Download-Image -Url $LockScreenImageUrl -Destination $LockScreenImagePath
            Set-LockScreen
            Update-RegistryKey -KeyName $LockScreenRegistryKeyName -HashValue $LockScreenImageHash
        } elseif ($CurrentLockScreenImageHash -ne $LockScreenImageHash) {
            Write-Host "Image has changed. Downloading..."
            Download-Image -Url $LockScreenImageUrl -Destination $LockScreenImagePath
            Set-LockScreen
            Update-RegistryKey -KeyName $LockScreenRegistryKeyName -HashValue $LockScreenImageHash
        } else {
            Write-Host "Image has not changed."
        }
    } catch {
        Write-Warning $_.Exception.Message
        Stop-Transcript
        throw $_.Exception.Message
    } finally {
        Write-Host "Script completed successfully."
        Stop-Transcript
    }
}

if ($DesktopImageUrl) {
    Set-DesktopWallpaper -DesktopImageUrl $DesktopImageUrl
}

if ($LockScreenImageUrl) {
    Set-LockScreenWallpaper -LockScreenImageUrl $LockScreenImageUrl
}
