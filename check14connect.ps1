$gameIp = '124.150.157.0'
$logFile = 'template.log'
$gateWayMask = '255.255.255.0'
    
function check14Connect(){
    Write-Host FF14�̐ڑ����m�F���܂��c
    netstat -ano|findstr "124.150.157" >$logFile
    $connected = select-string -Path $logFile -Pattern '^.*192\.168\.4[2,3]\.\d{1,3}.+124\.150\.157\.\d{1,3}.+ESTABLISHED.+$' -AllMatches -Encoding default
    Remove-Item $logFile

    if([string]::IsNullOrEmpty($connected)){
        Write-Host "NG�FFF14�̓e�U�����O�ɐڑ�����Ă��܂���B"
        Write-Host "   �ēx���O�C�����Ȃ����Ċm�F���Ă��������B"
        Write-Host "   �ă��O�C���ł���������Ȃ��ꍇ�͈�x�L���P�[�u���𔲂��Č��Ă��������B"

        Write-Host "10�b��ɍēx�ڑ��m�F�����{���܂��B(Ctrl+C �ŏ����𒆎~�ł��܂�)"
        Start-Sleep -s 10
        Write-Host ==================================================
        check14Connect
    }else{
        Write-Host "OK�FFF14�̓e�U�����O�ɐڑ�����Ă��܂��B"
    }
}

function checkMetricSetting(){
    Write-Host ���g���b�N�ݒ���m�F���܂��c
    route print >$logFile
    $metricSettedLan = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.42\.\d{1,3}.+192\.168\.42\.\d{1,3}.+9999.*$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    $metricSettedWifi = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.43\.\d{1,3}.+192\.168\.43\.\d{1,3}.+9999.*$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    Remove-Item $logFile

    if([string]::IsNullOrEmpty($metricSettedLan) -And [string]::IsNullOrEmpty($metricSettedWifi)){
        Write-Host "NG�F���g���b�N�ݒ肪�s���Ă��܂���B"
        checkIfSetMetric
    }else{
        Write-Host $metricSettedLan $metricSettedWifi
        Write-Host "OK�F���g���b�N�ݒ肪�͐���Ɏ��{����܂����B"
    }
}

function checkRouteSetting(){
    Write-Host ���[�^�[�ݒ���m�F���܂��c
    route print >$logFile
    $routedIp = select-string -Path $logFile -Pattern '^.*124\.150\.157\.0.+255\.255\.255\.0.+192\.168\.42\.\d{1,3}.+1.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.42\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    $routedIpWifi = select-string -Path $logFile -Pattern '^.*124\.150\.157\.0.+255\.255\.255\.0.+192\.168\.43\.\d{1,3}.+1.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.43\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    $gateWayIp = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.42\.\d{1,3}.+192\.168\.42\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.42\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    $gateWayIpWifi = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.43\.\d{1,3}.+192\.168\.43\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.43\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    Remove-Item $logFile


    if([string]::IsNullOrEmpty($routedIp) -And [string]::IsNullOrEmpty($routedIpWifi)){
        Write-Host "NG�F���[�^�[�ݒ肪����ɓ��삵�Ă��܂���B"
        checkIfSetRoute
    }else{
        if([string]::IsNullOrEmpty($routedIpWifi)){
            if(($routedIp -eq $gateWayIp)){
                Write-Host "OK�F���[�^�[�ݒ�͐���ł��B"
            }else{
                Write-Host "NG�F���[�^�[�ݒ�IP�ƃe�U�����OGateway����v���܂���B"
                Write-Host "   - routedIp:"$routedIp $routedIpWifi 
                Write-Host "   - gateWayIp:"$gateWayIp $gateWayIpWifi 
                checkIfSetRoute
            }
        }else{
            if(($routedIpWifi -eq $gateWayIpWifi)){
                Write-Host "OK�F���[�^�[�ݒ�͐���ł��B"
            }else{
                Write-Host "NG�F���[�^�[�ݒ�IP�ƃe�U�����OGateway����v���܂���B"
                Write-Host "   - routedIp:"$routedIp $routedIpWifi 
                Write-Host "   - gateWayIp:"$gateWayIp $gateWayIpWifi 
                checkIfSetRoute
            }
        }
    }
}

function checkIfSetMetric(){
    $doSetMetric = (Read-Host ���g���b�N�ݒ�����s���܂����H�i���Ǘ��Ҍ������K�v�ł��j�iY/N�j)
    if($doSetMetric -eq 'Y'){
        Write-Host "���g���b�N�ݒ�����s���܂��B�Ǘ��Ҍ����������Ă��������B"
        setMetric
        checkMetricSetting
    }else{
        Write-Host "�ł͏����𒆎~���܂��B"
        Pause
        exit
    }
}

function checkIfSetRoute(){
    $doSetRoute = (Read-Host ���[�^�[�ݒ�����s���܂����H�i���Ǘ��Ҍ������K�v�ł��j�iY/N�j)
    if($doSetRoute -eq 'Y'){
        Write-Host "���[�^�[�ݒ�����s���܂��B�Ǘ��Ҍ����������Ă��������B"
        setRoute
        checkRouteSetting
    }else{
        Write-Host "�ł͏����𒆎~���܂��B"
        Pause
        exit
    }
}

function setMetric(){
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
        $setMetricPsPath = Convert-Path setMetric.ps1
        Start-Process powershell.exe "-File $setMetricPsPath" -Verb RunAs
    }else{
        Write-Host "���݂̃��[�U�[�ɂ͊Ǘ��Ҍ������Ȃ����߁A���g���b�N�ݒ肪�s���܂���B"
    }

    Write-Host "���g���b�N�ݒ��҂��܂��c�B�i10�b��Ƀ��g���b�N�ݒ���Ċm�F���܂��B�j"
    Start-Sleep -s 10
}

function setRoute(){
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
        $setRoutePsPath = Convert-Path setRoute.ps1
        Start-Process powershell.exe "-File $setRoutePsPath" -Verb RunAs
    }else{
        Write-Host "���݂̃��[�U�[�ɂ͊Ǘ��Ҍ������Ȃ����߁Aroute�ݒ肪�s���܂���B"
    }

    Write-Host "route�ݒ��҂��܂��c�B�i10�b��Ƀ��[�^�[�ݒ���Ċm�F���܂��B�j"
    Start-Sleep -s 10
}

Write-Host ==================================================
checkMetricSetting
Write-Host ==================================================
checkRouteSetting
Write-Host ==================================================
check14Connect
Write-Host ==================================================

Pause