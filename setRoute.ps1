$gameIp = '124.150.157.0'
$logFile = 'template.log'
$gateWayMask = '255.255.255.0'

$ip1 = '192','192','192'
$ip2 = '168','168','168'
$ip3 = '42' ,'43' ,'165'
$ip4 = '\d{1,3}','\d{1,3}','\d{1,3}'

$count = $Args[0]

function deleteRouteSetting(){
    Write-Host 既存設定を削除します…
    route delete $gameIp
}

$addRouteSetting = 0
function addRouteSetting($count){
    if($addRouteSetting -ne 0){
        return $addRouteSetting
    }

    route print >$logFile

    $ipPattern = $ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]
    $command = '^.*0\.0\.0\.0.+0\.0\.0\.0.+'+$ipPattern+'.+'+$ipPattern+'.+$'
    $gateWayIp = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern $ipPattern `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    Remove-Item $logFile

    if(![string]::IsNullOrEmpty($gateWayIp)){
        Write-Host -NoNewline $gameIp への接続は $gateWayIp を経由するように設定します…
        Write-Host 
        route -p add $gameIp MASK $gateWayMask $gateWayIp
        return $gateWayIp
    }else{
        return 0
    }
}

function addRouteSettingAll(){
    $addRouteSetting = 0
    $addRouteSetting = addRouteSetting 0
    $addRouteSetting = addRouteSetting 1
    $addRouteSetting = addRouteSetting 2
    if($addRouteSetting -ne 0){
        # 処理なし
    }else{
        Write-Host テザリング回線を検知できませんでした。テザリングに接続されているかをご確認ください。
    }

}

Write-Host ==================================================
deleteRouteSetting
Write-Host ==================================================
addRouteSettingAll
Write-Host ==================================================
pause