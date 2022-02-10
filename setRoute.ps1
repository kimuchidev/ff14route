$gameIp = '124.150.157.0'
$logFile = 'template.log'
$gateWayMask = '255.255.255.0'

function deleteRouteSetting(){
    Write-Host 既存設定を削除します…
    route delete $gameIp
}

function addRouteSetting(){
    route print >$logFile
    $gateWayIp = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.43\.\d{1,3}.+192\.168\.43\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.43\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    Remove-Item $logFile

    Write-Host -NoNewline $gameIp への接続は $gateWayIp を経由するように設定します…
    Write-Host 
    route -p add $gameIp MASK $gateWayMask $gateWayIp
}

Write-Host ==================================================
deleteRouteSetting
Write-Host ==================================================
addRouteSetting
Write-Host ==================================================
pause