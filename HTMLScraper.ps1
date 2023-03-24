[Reflection.Assembly]::LoadFile("C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies\Microsoft.mshtml.dll")

Function Get-HTMLContent {
    param(
        [string]$data
    )
    

    if ($data -notmatch "[<]") {
        $data = (Invoke-WebRequest -Uri $Url -UseBasicParsing).Content
    }

    try {
        $encData = [System.Text.Encoding]::Unicode.GetBytes($data)
        $html = New-Object -ComObject "HTMLFile"
        $html.IHTMLDocument2_write($data) 
    } catch {
        Write-Host "Error: $_"
    }

    return $html
}

Function ConvertTo-HTMLObject {
    param(
        $data
    )

    $src = [System.Text.Encoding]::Unicode.GetBytes($data)
    $htmld = New-Object -ComObject "HTMLFile"
    $htmld.IHTMLDocument2_write($htmls)
}

Function Get-HTMLTag {
    param(
        $html,
        [string]$attr,
        [string]$option = "classname",
        [string]$value
    )

    #$html
    $content = $html.getElementsByTagName($attr) | Where-Object {($_.$option -eq $value)}
    return $content;
}
<#
Function Read-TagByClassName {
    param(
        $html,
        [string]$attr,
        [string]$classname
    )

    $html.getElementByTagName($attr) | Where-Object {($_.className -eq $classname)} | select -ExpandProperty innerText
}
#>
Function Read-TagValue {
    param(
        $html,
        [string]$attr,
        [string]$option = "", # classname, text, regex,
        [string]$value
    )

    $resp

    switch($option) {
        "class" {
            $resp = $html.getElementsByTagName($attr) | Where-Object {($_.className -eq $value)} | select -ExpandProperty innerText
            ; break
        }
        "text" {
            $resp = $html.getElementsByTagName($attr) | Where-Object {($_.innerText -like "*$value*")} | select -ExpandProperty innerText
            ; break
        }
        "regex" {
            $resp = $html.getElementsByTagName($attr) | Where-Object {($_.innerText -match "$value")} | select -ExpandProperty innerText
            ; break
        }
        "title" {
            $resp = $html.getElementsByTagName($attr) | Where-Object {($_.IHTMLElement_title -like "*$value*")} | select -ExpandProperty innerText
        }
        default {
            $resp = $html.getElementsByTagName($attr)# | select -ExpandProperty innerText
        }
    }
    #$resp | ConvertTo-Json
    return $resp
}

Function Get-StringFromTag {
    param(
        $HTMLTag
    )

    $ToString = $HTMLTag -join ","
    $GetString = ($ToString -split ",")[-1]
    #Write-Host "Last item: $GetString"

    return $GetString 
}