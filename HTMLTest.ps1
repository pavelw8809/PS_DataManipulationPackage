Function Get-HTMLContent {
    param(
        [string]$Url
    )

    $req = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write($req.Content)

    return $html
}

Get-HTMLContent "https://pl.wikipedia.org/wiki/Ełk"

$req = Invoke-WebRequest -Uri "https://pl.wikipedia.org/wiki/Ełk" -UseBasicParsing

$html = New-Object -ComObject "HTMLFile"
$html.IHTMLDocument2_write($req.Content)

$lat = $html.getElementsByTagName('span') | Where-Object {($_.className -eq "latitude")} | select -ExpandProperty innerText
$long = $html.getElementsByTagName('span') | Where-Object {($_.className -eq "longitude")} | select -ExpandProperty innerText

$long.textContent

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

"rrr" -match "\d"