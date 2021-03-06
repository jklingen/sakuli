# script for modify the user variables for starting Firefox correctly
# call the script via cmd `powershell -executionPolicy bypass -file "modfiy_firefox_variables.ps1" set`
# if no arguments are assigned, the script will delete SAKULI_HOME from the PATH

###### parsing arguments

param([string]$parSet = $null)
#set or not set

set-strictmode -version Latest

###### functions & parameters:
$keyFF = "MOZ_DISABLE_OOP_PLUGINS"
$keyFF2 = "MOZ_DISABLE_AUTO_SAFE_MODE"
$keyFF3 = "MOZ_DISABLE_SAFE_MODE_KEY"

function setUserVarToOne([string]$updateKey){
    [string] $newValue = 1
    echo "SET user environment variable '$updateKey': $newValue"
    Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name $updateKey -Value $newValue
}

function unsetUserVar([string]$keyValue) {
    $present = Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name "$keyValue" -ErrorAction SilentlyContinue
	if ($present){
		echo "CLEAR user environment vairable '$keyValue'"
    	Remove-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name "$keyValue"
	} else {
		echo "'$keyValue' is not set as environment variable, so nothing to do!"
	}
}

function setForegroundLockTimeout($newValue){
    $regPath = "HKEY_CURRENT_USER\Control Panel\Desktop"
	$regKey =  "ForegroundLockTimeout"
 	echo "SET '$regPath' key '$regKey' to '$newValue'" 
    Set-ItemProperty -Path "Registry::$regPath" -Name $regKey -Value $newValue
}

function setFontSmoothingType($newValue){
    $regPath = "HKEY_CURRENT_USER\Control Panel\Desktop"
	$regKey =  "FontSmoothingType"
 	echo "SET '$regPath' key '$regKey' to '$newValue'" 
    Set-ItemProperty -Path "Registry::$regPath" -Name $regKey -Value $newValue
}

function setMinAnimate($newValue){
    $regPath = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
	$regKey =  "MinAnimate"
 	echo "SET '$regPath' key '$regKey' to '$newValue'" 
    Set-ItemProperty -Path "Registry::$regPath" -Name $regKey -Value $newValue
}

function setVisualFXSettings($newValue){
	$regPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
	$regKey =  "VisualFXSetting"
 	echo "SET '$regPath' key '$regKey' to '$newValue'" 
    Set-ItemProperty -Path "Registry::$regPath" -Name $regKey -Value $newValue
}

function setWindowsErrorReportingDisabeld($newValue){
	$regPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\Windows Error Reporting"
	$regKey =  "Disabled"
 	echo "SET '$regPath' key '$regKey' to '$newValue'" 
    Set-ItemProperty -Path "Registry::$regPath" -Name $regKey -Value $newValue
}

function notifyWindowsEnvironmentChange(){
	echo "Notify Windows about Environment Change!"

Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class NativeMethods
    {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr SendMessageTimeout(
            IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
            uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
    }
"@

$HWND_BROADCAST = [IntPtr] 0xffff
$WM_SETTINGCHANGE = 0x1a
$SMTO_ABORTIFHUNG = 0x2
$result = [UIntPtr]::Zero

[void] ([Nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, 'Environment', $SMTO_ABORTIFHUNG, 5000, [ref] $result))
}

###### excecution logic
	
if ($parSet.Equals("set")) {
	setUserVarToOne($keyFF)
	setUserVarToOne($keyFF2)
	setUserVarToOne($keyFF3)
	setForegroundLockTimeout(0x0)
	setFontSmoothingType(0x0)
	setMinAnimate("0")
	setVisualFXSettings(0x2)
	setWindowsErrorReportingDisabeld(0x1)
} else {
	#will called durint uninstallation
    unsetUserVar($keyFF)
    unsetUserVar($keyFF2)
    unsetUserVar($keyFF3)
	setForegroundLockTimeout(0x30d40)
	setFontSmoothingType(0x2)
	setMinAnimate("1")
	setVisualFXSettings(0x0)
	setWindowsErrorReportingDisabeld(0x0)
}
notifyWindowsEnvironmentChange
echo "Environment update FINISHED!"
exit