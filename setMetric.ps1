$logFile = 'template.log'

function setMetric(){
    Get-NetIPAddress|Format-Table >$logFile

    $ifIndexLan = select-string -Path $logFile -Pattern '^\d{1,4}.+192\.168\.42\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '\d{1,4}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }
    
    $ifIndexWifi = select-string -Path $logFile -Pattern '^\d{1,4}.+192\.168\.43\.\d{1,3}.+$' -AllMatches -Encoding default `
    | ForEach-Object { $_.Matches.Groups[0].Value } `
    | select-string -Pattern '\d{1,4}' `
    | ForEach-Object { $_.Matches.Groups[0].Value }

    Remove-Item $logFile

    if(![string]::IsNullOrEmpty($ifIndexLan)){
        Write-Host -NoNewline InterfaceIndex が $ifIndexLan の接続のメトリックを最大値に設定します…
        Write-Host 
        Set-NetIPInterface -InterfaceIndex $ifIndexLan -InterfaceMetric 9999
    }else{
        if(![string]::IsNullOrEmpty($ifIndexWifi)){
            Write-Host -NoNewline InterfaceIndex が $ifIndexWifi の接続のメトリックを最大値に設定します…
            Write-Host 
            Set-NetIPInterface -InterfaceIndex $ifIndexWifi -InterfaceMetric 9999
        }else{
            Write-Host テザリング回線を検知できませんでした。テザリングに接続されているかをご確認ください。
        }
    }
}

Write-Host ==================================================
setMetric
Write-Host ==================================================
pause