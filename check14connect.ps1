$gameIp = '124.150.157.0'
$logFile = 'template.log'
$gateWayMask = '255.255.255.0'

$ip1 = '192','192','192'
$ip2 = '168','168','168'
$ip3 = '42' ,'43' ,'165'
$ip4 = '\d{1,3}','\d{1,3}','\d{1,3}'

$check14Connect = 0
$checkMetricSetting = 0
$checkRouteSetting = 0,0

function checkMetricSetting($count){
    if($checkMetricSetting -ne 0){
        return $checkMetricSetting
    }
    route print >$logFile

    $command = '^.*0\.0\.0\.0.+0\.0\.0\.0.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+\d{3,4}.*$'
    $metricSetted = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    Remove-Item $logFile

    if([string]::IsNullOrEmpty($metricSetted)){
        return 0
    }else{
        return $metricSetted
    }
}

function checkRouteSetting($count){
    route print >$logFile
    
    if($checkRouteSetting[0] -ne 0){
        return $checkRouteSetting
    }
    
    $ipPattern = $ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]
    $command = '^.*124\.150\.157\.0.+255\.255\.255\.0.+'+$ipPattern+'.+1.+$'

    $routedIp = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern $ipPattern `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    $command = '^.*0\.0\.0\.0.+0\.0\.0\.0.+'+$ipPattern+'.+'+$ipPattern+'.+$'
    $gateWayIp = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern $ipPattern `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    Remove-Item $logFile

    if(!([string]::IsNullOrEmpty($routedIp)) -And ($routedIp -eq $gateWayIp)){
        $checkRouteSetting[0] = $routedIp
        $checkRouteSetting[1] = $gateWayIp
    }
}

function check14Connect($count){
    if($check14Connect -ne 0){
        return $check14Connect
    }
    
    netstat -ano|findstr "124.150.157" >$logFile
    $command = '^.*'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+124\.150\.157\.\d{1,3}.+ESTABLISHED.+$'
    $connected = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default
    Remove-Item $logFile

    if([string]::IsNullOrEmpty($connected)){
        return 0
    }else{
        return 1
    }
}

function checkIfSetMetric(){
    $doSetMetric = (Read-Host ���g���b�N�ݒ�����s���܂����H�i���Ǘ��Ҍ������K�v�ł��j�iY/N�j)
    if($doSetMetric -eq 'Y'){
        Write-Host "���g���b�N�ݒ�����s���܂��B�Ǘ��Ҍ����������Ă��������B"
        setMetric
        checkMetricSettingAll $count
    }else{
        Write-Host "�ł͏����𒆎~���܂��B"
        Pause
        exit
    }
}

function checkIfSetRoute($count){
    $doSetRoute = (Read-Host ���[�^�[�ݒ�����s���܂����H�i���Ǘ��Ҍ������K�v�ł��j�iY/N�j)
    if($doSetRoute -eq 'Y'){
        Write-Host "���[�^�[�ݒ�����s���܂��B�Ǘ��Ҍ����������Ă��������B"
        setRoute $count
        checkRouteSettingAll $count
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

function getCount(){
    route print >$logFile

    $count = 0
    $command = '^.*0\.0\.0\.0.+0\.0\.0\.0.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+\d{3,4}.*$'
    $metricSetted = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    if(!([string]::IsNullOrEmpty($metricSetted))){
        Remove-Item $logFile
        return $count
    }

    $count = 1
    $command = '^.*0\.0\.0\.0.+0\.0\.0\.0.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+\d{3,4}.*$'
    $metricSetted = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    if(!([string]::IsNullOrEmpty($metricSetted))){
        Remove-Item $logFile
        return $count
    }

    $count = 2
    $command = '^.*0\.0\.0\.0.+0\.0\.0\.0.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+'+$ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]+'.+\d{3,4}.*$'
    $metricSetted = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    if(!([string]::IsNullOrEmpty($metricSetted))){
        Remove-Item $logFile
        return $count
    }

    Write-Host "ERROR�F�e�U�����O�ɐڑ�����Ă��邩�����m�F���������B"
    return -1
}

function checkMetricSettingAll($count){

    Write-Host "��DEBUG��" "count" $count

    $checkMetricSetting = 0
    Write-Host ���g���b�N�ݒ���m�F���܂��c
    $checkMetricSetting = checkMetricSetting $count
    if($checkMetricSetting -ne 0){
        Write-Host $checkMetricSetting
        Write-Host "OK�F���g���b�N�ݒ肪�͐���Ɏ��{����܂����B"
    }else{
        Write-Host "NG�F���g���b�N�ݒ肪�s���Ă��܂���B"
        checkIfSetMetric
    }
}
function checkRouteSettingAll($count){

    Write-Host "��DEBUG��" "count" $count

    $checkRouteSetting = 0,0
    Write-Host ���[�^�[�ݒ���m�F���܂��c
    checkRouteSetting $count
    if($checkRouteSetting[0] -eq 0){
        Write-Host "NG�F���[�^�[�ݒ肪����ɓ��삵�Ă��܂���B"
        checkIfSetRoute $count
    }else{
        if($checkRouteSetting[0] -eq $checkRouteSetting[1]){
            Write-Host "OK�F���[�^�[�ݒ�͐���ł��B"
        }else{
            Write-Host "NG�F���[�^�[�ݒ�IP�ƃe�U�����OGateway����v���܂���B"
            Write-Host "   - routedIp:"$checkRouteSetting[0]
            Write-Host "   - gateWayIp:"$checkRouteSetting[1]
            checkIfSetRoute $count
        }
    }
}
function check14ConnectAll($count){

    Write-Host "��DEBUG��" "count" $count

    $check14Connect = 0
    Write-Host FF14�̐ڑ����m�F���܂��c
    $check14Connect = check14Connect $count
    if($check14Connect -ne 0){
        Write-Host "OK�FFF14�̓e�U�����O�ɐڑ�����Ă��܂��B"
    }else{
        Write-Host "NG�FFF14�̓e�U�����O�ɐڑ�����Ă��܂���B"
        Write-Host "   �ēx���O�C�����Ȃ����Ċm�F���Ă��������B"
        Write-Host "   �ă��O�C���ł���������Ȃ��ꍇ�͈�x�L���P�[�u���𔲂��Č��Ă��������B"
    
        Write-Host "10�b��ɍēx�ڑ��m�F�����{���܂��B(Ctrl+C �ŏ����𒆎~�ł��܂�)"
        Start-Sleep -s 10
        Write-Host ==================================================
        check14ConnectAll $count
    }
}

$count = getCount
Write-Host ==================================================
checkMetricSettingAll $count
Write-Host ==================================================
checkRouteSettingAll $count
Write-Host ==================================================
check14ConnectAll $count
Write-Host ==================================================

Pause