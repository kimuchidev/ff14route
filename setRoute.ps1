$gameIp = '124.150.157.0'
$logFile = 'template.log'
$gateWayMask = '255.255.255.0'

function deleteRouteSetting(){
    Write-Host �����ݒ���폜���܂��c
    route delete $gameIp
}

function addRouteSetting(){
    route print >$logFile

    $gateWayIp = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.42\.\d{1,3}.+192\.168\.42\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.42\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    $gateWayIpWifi = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.43\.\d{1,3}.+192\.168\.43\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.43\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    Remove-Item $logFile

    if(![string]::IsNullOrEmpty($gateWayIp)){
        Write-Host -NoNewline $gameIp �ւ̐ڑ��� $gateWayIp ���o�R����悤�ɐݒ肵�܂��c
        Write-Host 
        route -p add $gameIp MASK $gateWayMask $gateWayIp
    }else{
        if(![string]::IsNullOrEmpty($gateWayIpWifi)){
            Write-Host -NoNewline $gameIp �ւ̐ڑ��� $gateWayIpWifi ���o�R����悤�ɐݒ肵�܂��c
            Write-Host 
            route -p add $gameIp MASK $gateWayMask $gateWayIpWifi
        }else{
            Write-Host �e�U�����O��������m�ł��܂���ł����B�e�U�����O�ɐڑ�����Ă��邩�����m�F���������B
        }
    }
}

Write-Host ==================================================
deleteRouteSetting
Write-Host ==================================================
addRouteSetting
Write-Host ==================================================
pause