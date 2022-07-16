$logFile = 'template.log'

$ip1 = '192','192','192'
$ip2 = '168','168','168'
$ip3 = '42' ,'43' ,'165'
$ip4 = '\d{1,3}','\d{1,3}','\d{1,3}'

$setMetric = 0
function setMetric($count){
    if($setMetric -ne 0){
        return $setMetric
    }

    Get-NetIPAddress|Format-Table >$logFile
    
    $ipPattern = $ip1[$count]+'\.'+$ip2[$count]+'\.'+$ip3[$count]+'\.'+$ip4[$count]
    $command = '^\d{1,4}.+'+$ipPattern+'.+$'
    $ifIndex = select-string -Path $logFile -Pattern $command -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '\d{1,4}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    Remove-Item $logFile

    if(![string]::IsNullOrEmpty($ifIndex)){
        return $ifIndex
    }else{
        return 0
    }
}

function setMetricAll(){
    $setMetric = 0
    $setMetric = setMetric 0
    $setMetric = setMetric 1
    $setMetric = setMetric 2
    if($setMetric -ne 0){
        Write-Host -NoNewline InterfaceIndex が $setMetric の接続のメトリックを最大値に設定します…
        Write-Host 
        Set-NetIPInterface -InterfaceIndex $setMetric -InterfaceMetric 9999
    }else{
        Write-Host テザリング回線を検知できませんでした。テザリングに接続されているかをご確認ください。
    }
}

Write-Host ==================================================
setMetricAll
Write-Host ==================================================
pause