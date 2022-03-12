$gameIp = '124.150.157.0'
$logFile = 'template.log'
$gateWayMask = '255.255.255.0'
    
function check14Connect(){
    Write-Host FF14�̐ڑ����m�F���܂��c
    netstat -ano|findstr "124.150.157" >$logFile
    $connected = select-string -Path $logFile -Pattern '^.*192\.168\.42\.\d{1,3}.+124\.150\.157\.\d{1,3}.+ESTABLISHED.+$' -AllMatches -Encoding default
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

function checkRouteSetting(){
    Write-Host ���[�^�[�ݒ���m�F���܂��c
    route print >$logFile
    $routedIp = select-string -Path $logFile -Pattern '^.*124\.150\.157\.0.+255\.255\.255\.0.+192\.168\.42\.\d{1,3}.+1.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.42\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    $gateWayIp = select-string -Path $logFile -Pattern '^.*0\.0\.0\.0.+0\.0\.0\.0.+192\.168\.42\.\d{1,3}.+192\.168\.42\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '192\.168\.42\.\d{1,3}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    Remove-Item $logFile


    if([string]::IsNullOrEmpty($routedIp)){
        Write-Host "NG�F���[�^�[�ݒ肪����ɓ��삵�Ă��܂���B"
        checkIfSetRoute
    }else{
        if($routedIp -eq $gateWayIp){
            Write-Host "OK�F���[�^�[�ݒ�͐���ł��B"
        }else{
            Write-Host "NG�F���[�^�[�ݒ�IP�ƃe�U�����OGateway����v���܂���B"
            Write-Host "   - routedIp:"$routedIp
            Write-Host "   - gateWayIp:"$gateWayIp
            checkIfSetRoute
        }
    }
}

function checkIfSetRoute(){
    $doSetRoute = (Read-Host ���[�^�[�ݒ�����s���܂����H�i���Ǘ��Ҍ������K�v�ł��j�iY/N�j)
    if($doSetRoute -eq 'Y'){
        Write-Host "���[�^�[�ݒ�����s���܂��B�Ǘ��Ҍ����������Ă��������B"
        setRoute
        checkRouteSetting
    }else{
        Write-Host "�ł͊m�F�����𒆎~���܂��B"
        Pause
        exit
    }
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
checkRouteSetting
Write-Host ==================================================
check14Connect
Write-Host ==================================================

Pause