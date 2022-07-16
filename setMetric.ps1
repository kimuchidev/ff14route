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
        Write-Host -NoNewline InterfaceIndex �� $setMetric �̐ڑ��̃��g���b�N���ő�l�ɐݒ肵�܂��c
        Write-Host 
        Set-NetIPInterface -InterfaceIndex $setMetric -InterfaceMetric 9999
    }else{
        Write-Host �e�U�����O��������m�ł��܂���ł����B�e�U�����O�ɐڑ�����Ă��邩�����m�F���������B
    }
}

Write-Host ==================================================
setMetricAll
Write-Host ==================================================
pause