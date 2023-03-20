[Reflection.Assembly]::LoadFile("C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies\Microsoft.mshtml.dll")

Function Get-HTMLContent {
    param(
        [string]$Url
    )

    $req = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $html = New-Object -ComObject "HTMLFile"

    $req.Content

    try {
    # This works in PowerShell with Office installed
        $html.IHTMLDocument2_write($req.Content)
    }
    catch {
        # This works when Office is not installed    
        $src = [System.Text.Encoding]::Unicode.GetBytes($req.Content)
        $html.write($src)
    }
    #$html.IHTMLDocument2_write($req.Content)
    return $html
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
    $html.getElementsByTagName("p");
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
            Write-Host $value
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
    $resp | ConvertTo-Json
    return $resp
}

Function Get-StringFromTag {
    param(
        $HTMLTag
    )

    $ToString = $HTMLTag -join ","
    $GetString = ($ToString -split ",")[-1]
    Write-Host "Last item: $GetString"

    return $GetString
}

$objlist = @()
#for ($i = 100, $i -lt 1000, $i++) {
    $htmlc = (Invoke-WebRequest -Uri "https://conadrogach.pl/droga-wojewodzka/106/przebieg-drogi/" -UseBasicParsing).Content
    $ia = $htmlc.IndexOf('<div class="cnd-road-info-box">')
    $htmls = $htmlc.Substring($ia, $htmlc.Length - $ia)
    $src = [System.Text.Encoding]::Unicode.GetBytes($htmls)
    $htmld = New-Object -ComObject "HTMLFile"
    $htmld.IHTMLDocument2_write($htmls)
    #$htmld
    $roadinfo = Get-HTMLTag $htmld.body "div" "classname" "cnd-road-info-box"
    $roaditems = Get-HTMLTag $roadinfo "div" "classname" "road-item"
    
    $i = 0
    foreach ($item in $roaditems) {
        $obj
        $citya = Read-TagValue $item "a" "title" " - mapa samochodowa"
        $citya -join ","
        #$obj.road("106")
        $cityw = Read-TagValue $item "a" "title" "Drogi w województwie"
        $cityw
        #$obj.region($cityw)
        $cityr = Read-TagValue $item "a" "title" " - informacje, przebieg, mapy, zdjęcia"
        #$cityr
        $obj = [PSCustomObject]@{
            road = "106"
            no = $i
            city = Get-StringFromTag($citya)
            region = Get-StringFromTag($cityw)
        } 
        #$obj -join ","
        $obj
        <#
        $rn = 0
        foreach ($r in $cityr) {
            $propname = "r$($rn)"
            #$r
            $obj | Add-Member -MemberType NoteProperty -Name $propname -Value $r
            $rn++
        }
        #>
        $objlist += $obj
        $i++
    }
    $objlist | Export-Csv -Path "F:\_PROG\_POWERSHELL\PS_HTMLScrapper\test3.csv" -Encoding UTF8

#}
#$html = Get-HTMLContent "https://pl.wikipedia.org/wiki/Ełk"



#$html = Get-HTMLContent "https://conadrogach.pl/droga-wojewodzka/102/przebieg-drogi/"
#$html | Out-File -FilePath "F:/_PROG/_POWERSHELL/Gminy/test.txt"

#Read-TagValue $html.body "span" "classname" "latitude"
#$infobox = Get-HTMLTag $html.body "table" "classname" "infobox"
#Read-TagValue $infobox "a" "title" "Powiat"
#Read-TagValue $infobox "a" "title" "Powiat"
#Get-HTMLTag $html "div" "classname" "cnd-road-info-box"
#Read-TagValue $htmlccld "p" "text" "(+48)"

#$htmlc = Get-HTMLContent "https://conadrogach.pl/droga-wojewodzka/102/przebieg-drogi/"
#$req = Invoke-WebRequest -Uri "https://conadrogach.pl/droga-wojewodzka/102/przebieg-drogi/" -UseBasicParsing
#$html = New-Object -ComObject "HTMLFile"
#$req.Links | where 

#$req.Content

# This works in PowerShell with Office installed
#$html.IHTMLDocument2_write($req.Content)

#$html.getElementsByTagName("div")
#$htmlc.childNodes
#$htmld = Get-HTMLTag $htmlc "div" "classname" "cnd-road-info-box"
#$htmld
#$htmlc.getElementsByTagName('div') | Where-Object {($_.className -eq "cnd-road-info-box")}
#$htmlc.getElementsByName('cnd-road-info-box')


#$htmlc.getElementsByTagName('span') | Where-Object {($_.className -eq "latitude")} | select -ExpandProperty innerText
<#
$html.getElementsByTagName('p') | Where-Object {($_.innerText -like "*(+48)*")} | select -ExpandProperty innerText
$tr2.getElementsByTagName('p') | Where-Object {($_.innerText -match "\d")} | select -ExpandProperty innerText

#Read-TagByClassName
$html.getElementsByTagName('p') | Where-Object {($_.innerText -like "*(+48)*")} | select -ExpandProperty innerText
$html.getElementsByTagName('p') | Where-Object {($_.innerText -like "*m n.p.m. ")} | select -ExpandProperty innerText

#Get-ParrentTag
$tr = ($html.getElementsByTagName('a') | Where-Object {($_.innerText -like "*Strefa numeracyjna*")}).ParentElement
#$tr
$th = ($tr).ParentElement

$tr2 = ($html.getElementsByTagName('th') | Where-Object {($_.innerText -like "*Data założenia*")}).ParentElement
#$th2 = ($tr2).ParentElement
#$tr2.getElementsByTagName('p') | Where-Object {($_.innerText -match "\d")} | select -ExpandProperty innerText

#Read-ParrentTag

# Read-TagByLength
$th.getElementsByTagName('p') | Where-Object {($_.innerText.Length -lt 10)} | select -ExpandProperty innerText
$tr2.getElementsByTagName('p') | Where-Object {($_.innerText -match "\d")} | select -ExpandProperty innerText
#$html.getElementsByTagName('tr') | Where-Object {($_.childElement.innerText -like "Strefa numeracyjna")}
#>