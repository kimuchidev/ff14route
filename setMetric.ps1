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
        Write-Host -NoNewline InterfaceIndex �� $ifIndexLan �̐ڑ��̃��g���b�N���ő�l�ɐݒ肵�܂��c
        Write-Host 
        Set-NetIPInterface -InterfaceIndex $ifIndexLan -InterfaceMetric 9999
    }else{
        if(![string]::IsNullOrEmpty($ifIndexWifi)){
            Write-Host -NoNewline InterfaceIndex �� $ifIndexWifi �̐ڑ��̃��g���b�N���ő�l�ɐݒ肵�܂��c
            Write-Host 
            Set-NetIPInterface -InterfaceIndex $ifIndexWifi -InterfaceMetric 9999
        }else{
            Write-Host �e�U�����O��������m�ł��܂���ł����B�e�U�����O�ɐڑ�����Ă��邩�����m�F���������B
        }
    }
}

Write-Host ==================================================
setMetric
Write-Host ==================================================
pause