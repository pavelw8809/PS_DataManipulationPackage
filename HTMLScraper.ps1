Function Get-HTMLContent {
    param(
        [string]$Url
    )

    $req = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write($req.Content)

    return $html
}

Function Read-TagByClassName {
    param(
        [string]$html,
        [string]$attr,
        [string]$classname
    )

    $html.getElementByTagName($attr) | Where-Object {($_.className -eq $classname)} | select -ExpandProperty innerText
}

Function Read-TagValue {
    param(
        $html,
        [string]$attr,
        [string]$option = "classname", # classname, text, regex,
        [string]$value
    )

    $resp

    switch($option) {
        "classname" {
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
    }
    return $resp
}

Function Get-ParentTag {
    param(
        $html,
        [string]$attr
    )
}

#$htmlc = Get-HTMLContent "https://pl.wikipedia.org/wiki/Ełk"

#Read-TagValue $htmlc "span" "classname" "latitude"
#Read-TagValue $htmlc "p" "text" "(+48)"

$htmlc = Get-HTMLContent "https://conadrogach.pl/droga-wojewodzka/106/przebieg-drogi/"
$htmlc = Read

<#
$htmlc.getElementsByTagName('span') | Where-Object {($_.className -eq "latitude")} | select -ExpandProperty innerText
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