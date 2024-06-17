Overview
This project provides scripts to create a Win32 application on Microsoft Intune, enabling Intune administrators to manage dynamic wallpapers across their organization. The package includes two PowerShell scripts: Install.ps1 for installing and setting up the dynamic wallpapers, and Detection.ps1 for verifying the installation status on the client machines.

Features
Dynamic Desktop and Lock Screen Images: Easily update and manage desktop and lock screen images across your organization.
Intune Integration: Designed to be deployed as a Win32 app through Microsoft Intune, providing a seamless management experience.
Customizable: Pass your desired images through the installation command to personalize the desktop and lock screen backgrounds.

Getting Started
Prerequisites
Microsoft Intune subscription
URLs for the desktop and lock screen images you wish to deploy

Installation
1. Prepare the Win32 app in Intune: Package the Install.ps1 and Detection.ps1 scripts along with any other required files into an Intune Win32 app package.

2. Configure the Install Command: Use the following command as the install command for your Win32 app in Intune:
%windir%\sysnative\windowspowershell\v1.0\powershell.exe -executionPolicy bypass -windowstyle hidden -file "./Install.ps1" -DesktopImageUrl "https://tuneMDM.com/desktopimage.png" -LockScreenImageUrl "https://tuneMDM.com/lockscreenimage.png"

Note: Replace https://tuneMDM.com/desktopimage.png and https://tuneMDM.com/lockscreenimage.png with the URLs of your desired desktop and lock screen images.

3. Detection Script: Use Detection.ps1 as the detection rule for the Win32 app to verify the installation status on the client devices.

Scripts Description
- Install.ps1: This script sets the specified images as the desktop and lock screen backgrounds. It takes two parameters:
    - DesktopImageUrl: URL of the image to be set as the desktop background.
    - LockScreenImageUrl: URL of the image to be set as the lock screen background.
- Detection.ps1: This script checks if the dynamic wallpapers have been applied successfully. It is used by Intune to confirm the app installation status.

Support
For issues, questions, or contributions, please open an issue on the project's GitHub repository.# DynamicWallpaper
