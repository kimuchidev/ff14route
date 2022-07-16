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
    $doSetMetric = (Read-Host メトリック設定を実行しますか？（※管理者権限が必要です）（Y/N）)
    if($doSetMetric -eq 'Y'){
        Write-Host "メトリック設定を実行します。管理者権限を許可してください。"
        setMetric
        checkMetricSettingAll $count
    }else{
        Write-Host "では処理を中止します。"
        Pause
        exit
    }
}

function checkIfSetRoute($count){
    $doSetRoute = (Read-Host ルーター設定を実行しますか？（※管理者権限が必要です）（Y/N）)
    if($doSetRoute -eq 'Y'){
        Write-Host "ルーター設定を実行します。管理者権限を許可してください。"
        setRoute $count
        checkRouteSettingAll $count
    }else{
        Write-Host "では処理を中止します。"
        Pause
        exit
    }
}

function setMetric(){
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
        $setMetricPsPath = Convert-Path setMetric.ps1
        Start-Process powershell.exe "-File $setMetricPsPath" -Verb RunAs
    }else{
        Write-Host "現在のユーザーには管理者権限がないため、メトリック設定が行えません。"
    }

    Write-Host "メトリック設定を待ちます…。（10秒後にメトリック設定を再確認します。）"
    Start-Sleep -s 10
}

function setRoute(){
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
        $setRoutePsPath = Convert-Path setRoute.ps1
        Start-Process powershell.exe "-File $setRoutePsPath" -Verb RunAs
    }else{
        Write-Host "現在のユーザーには管理者権限がないため、route設定が行えません。"
    }

    Write-Host "route設定を待ちます…。（10秒後にルーター設定を再確認します。）"
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

    Write-Host "ERROR：テザリングに接続されているかをご確認ください。"
    return -1
}

function checkMetricSettingAll($count){

    Write-Host "★DEBUG★" "count" $count

    $checkMetricSetting = 0
    Write-Host メトリック設定を確認します…
    $checkMetricSetting = checkMetricSetting $count
    if($checkMetricSetting -ne 0){
        Write-Host $checkMetricSetting
        Write-Host "OK：メトリック設定がは正常に実施されました。"
    }else{
        Write-Host "NG：メトリック設定が行われていません。"
        checkIfSetMetric
    }
}
function checkRouteSettingAll($count){

    Write-Host "★DEBUG★" "count" $count

    $checkRouteSetting = 0,0
    Write-Host ルーター設定を確認します…
    checkRouteSetting $count
    if($checkRouteSetting[0] -eq 0){
        Write-Host "NG：ルーター設定が正常に動作していません。"
        checkIfSetRoute $count
    }else{
        if($checkRouteSetting[0] -eq $checkRouteSetting[1]){
            Write-Host "OK：ルーター設定は正常です。"
        }else{
            Write-Host "NG：ルーター設定IPとテザリングGatewayが一致しません。"
            Write-Host "   - routedIp:"$checkRouteSetting[0]
            Write-Host "   - gateWayIp:"$checkRouteSetting[1]
            checkIfSetRoute $count
        }
    }
}
function check14ConnectAll($count){

    Write-Host "★DEBUG★" "count" $count

    $check14Connect = 0
    Write-Host FF14の接続を確認します…
    $check14Connect = check14Connect $count
    if($check14Connect -ne 0){
        Write-Host "OK：FF14はテザリングに接続されています。"
    }else{
        Write-Host "NG：FF14はテザリングに接続されていません。"
        Write-Host "   再度ログインしなおして確認してください。"
        Write-Host "   再ログインでも解消されない場合は一度有線ケーブルを抜いて見てください。"
    
        Write-Host "10秒後に再度接続確認を実施します。(Ctrl+C で処理を中止できます)"
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