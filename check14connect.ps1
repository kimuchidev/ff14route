$gameIp = '124.150.157.0'
$logFile = 'template.log'
$gateWayMask = '255.255.255.0'
    
function check14Connect(){
    Write-Host FF14の接続を確認します…
    netstat -ano|findstr "124.150.157" >$logFile
    $connected = select-string -Path $logFile -Pattern '^.*192\.168\.42\.\d{1,3}.+124\.150\.157\.\d{1,3}.+ESTABLISHED.+$' -AllMatches -Encoding default
    Remove-Item $logFile

    if([string]::IsNullOrEmpty($connected)){
        Write-Host "NG：FF14はテザリングに接続されていません。"
        Write-Host "   再度ログインしなおして確認してください。"
        Write-Host "   再ログインでも解消されない場合は一度有線ケーブルを抜いて見てください。"

        Write-Host "10秒後に再度接続確認を実施します。(Ctrl+C で処理を中止できます)"
        Start-Sleep -s 10
        Write-Host ==================================================
        check14Connect
    }else{
        Write-Host "OK：FF14はテザリングに接続されています。"
    }
}

function checkRouteSetting(){
    Write-Host ルーター設定を確認します…
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
        Write-Host "NG：ルーター設定が正常に動作していません。"
        checkIfSetRoute
    }else{
        if($routedIp -eq $gateWayIp){
            Write-Host "OK：ルーター設定は正常です。"
        }else{
            Write-Host "NG：ルーター設定IPとテザリングGatewayが一致しません。"
            Write-Host "   - routedIp:"$routedIp
            Write-Host "   - gateWayIp:"$gateWayIp
            checkIfSetRoute
        }
    }
}

function checkIfSetRoute(){
    $doSetRoute = (Read-Host ルーター設定を実行しますか？（※管理者権限が必要です）（Y/N）)
    if($doSetRoute -eq 'Y'){
        Write-Host "ルーター設定を実行します。管理者権限を許可してください。"
        setRoute
        checkRouteSetting
    }else{
        Write-Host "では確認処理を中止します。"
        Pause
        exit
    }
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

Write-Host ==================================================
checkRouteSetting
Write-Host ==================================================
check14Connect
Write-Host ==================================================

Pause