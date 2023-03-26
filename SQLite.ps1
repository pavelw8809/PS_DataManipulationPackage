[Reflection.Assembly]::LoadFile("C:\sqlite3net\System.Data.SQLite.dll")

Function Get-SQLiteDataFromTable {
    param(
        [string]$DBFile,
        [string]$Table,
        [string]$Props = "*",
        [string]$Cond1 = "",
        [string]$Cond2 = "",
        [string]$Limit = 0
    )

    $strBuilder = "select $($Props) from $($Table)"

    if ($Cond1) {
        $strBuilder += " where $($Cond1)"
    }
    if ($Cond2) {
        $strBuilder += " and $($Cond2)"
    } 
    if ($Limit -gt 0) {
        $strBuilder += " limit $($Limit)"
    }
    $strBuilder

    if (Test-Path -Path $DBFile) {
        try {
            $dbcon = [string]::Format("data source=$DBFile")
            $dbobj = New-Object System.Data.SQLite.SQLiteConnection
            $dbobj.ConnectionString = $dbcon
            $dbobj.Open()

            $dbcmd = $dbobj.CreateCommand()
            $dbcmd.CommandText = $strBuilder
            $dbcmd.CommandType = [System.Data.CommandType]::Text
            $dbread = $dbcmd.ExecuteReader()

            $psobjlist = @()

            while ($dbread.HasRows) {
                if ($dbread.Read()) {
                    $psobj = [PSCustomObject]@{}
                    for ($dbr = 0; $dbr -lt $dbread.FieldCount; $dbr++) {
                        $dbcol = $dbread.GetName($dbr)
                        $dbcol
                        $dbread[$dbcol]
                        $psobj | Add-Member -MemberType NoteProperty -Name $dbcol -Value $dbread[$dbcol]
                    }
                    #$psobj
                    $psobjlist += $psobj
                }
            }
            $dbobj.Close()
            return $psobjlist
        } catch {
            Write-Host "SQL Select Error: $_"
        }
    } else {
        Write-Host "DB File: $($DBFile) does not exist"
    }

}

Function New-SQLiteDB {
    param(
        [string]$DBFile
    )

    try {
        if (!(Test-Path -Path $DBFile)) {
            [System.Data.SQLite.SQLiteConnection]::CreateFile($DBFile)
        }
    } catch {
        Write-Host $_
    }
}

Function New-SQLiteTable {
    param(
        [string]$DBFile,
        [string]$Table,
        $Data
    )

    New-SQLiteDB -DBFile $DBFile

    $strBuilder = "create table if not exists $($Table) ("

    for ($i = 0; $i -lt $Data.Length; $i++) {
        $strBuilder += "$($Data[$i][0]) $($Data[$i][1])"
        if ($i -lt $Data.Length-1) {
            $strBuilder += ", "
        }
    }

    $strBuilder += ")"

    try {
        $dbcon = [string]::Format("data source=$DBFile")
        $dbobj = New-Object System.Data.SQLite.SQLiteConnection
        $dbobj.ConnectionString = $dbcon
        $dbobj.Open()

        $dbcmd = $dbobj.CreateCommand()
        $dbcmd.CommandText = $strBuilder
        $dbcmd.CommandType = [System.Data.CommandType]::Text
        $dbcmd.ExecuteNonQuery()
    } catch {
        Write-Host "SQL Create Table: $_"
    }
}

Function New-SQLiteItem {
    param(
        [string]$DBFile,
        [string]$Table,
        $AddData,
        $TableData = $null
    )

    if ($TableData) {
        New-SQLiteTable -DBFile $DBFile -Table $Table -Data $TableData
    }
    
    $strBuilder = "INSERT INTO $($Table) ("

    $DataProps = (Get-Member -InputObject $AddData -MemberType NoteProperty).Name
    For ($i = 0; $i -lt $DataProps.Length; $i++) {
        $strBuilder += $DataProps[$i]  
        if ($i -lt $DataProps.Length-1) {
            $strBuilder += ", "
        }
    }

    $strBuilder += ") VALUES ("

    For ($i = 0; $i -lt $DataProps.Length; $i++) {
        $curProp = $DataProps[$i]
        $strBuilder += "'$($AddData.$curProp)'"
        if ($i -lt $DataProps.Length-1) {
            $strBuilder += ", "
        }
    }

    $strBuilder += ")"

    Write-Host $strBuilder

    try {
        $dbcon = [string]::Format("data source=$DBFile")
        $dbobj = New-Object System.Data.SQLite.SQLiteConnection
        $dbobj.ConnectionString = $dbcon
        $dbobj.Open()

        $dbcmd = $dbobj.CreateCommand()
        $dbcmd.CommandText = $strBuilder
        $dbcmd.CommandType = [System.Data.CommandType]::Text
        $dbcmd.ExecuteNonQuery()
        $dbobj.Close()
    } catch {
        Write-Host "SQL Create Table: $_"
    }
} 

Function Update-SQLiteItem {
    param(
        [string]$DBFile,
        [string]$Table,
        $TableData,
        [string]$Condition
    )
    #$TableProps = (Get-Member -InputObject $Data -MemberType NoteProperty).Name
    if (!($WhereValue -match "^\d+$")) {
        $WhereValue = "'$($WhereValue)'"
    }

    $strBuilder = "UPDATE $($Table) SET "
    $DataProps = (Get-Member -InputObject $TableData -MemberType NoteProperty).Name
    For ($i = 0; $i -lt $DataProps.Length; $i++) {
        $curProp = $DataProps[$i]
        if ($TableData.$curProp -match "^\d+$") {
            $strBuilder += "$($curProp) = $($TableData.$curProp)"  
        } else {
            $strBuilder += "$($curProp) = '$($TableData.$curProp)'" 
        }
         
        if ($i -lt $DataProps.Length-1) {
            $strBuilder += ", "
        }
    }
    $strBuilder += " WHERE $($Condition)"
    Write-Host $strBuilder
    
    if (Test-Path -Path $DBFile) {
        try {
            $dbcon = [string]::Format("data source=$DBFile")
            $dbobj = New-Object System.Data.SQLite.SQLiteConnection
            $dbobj.ConnectionString = $dbcon
            $dbobj.Open()

            $dbcmd = $dbobj.CreateCommand()
            $dbcmd.CommandText = $strBuilder
            $dbcmd.CommandType = [System.Data.CommandType]::Text
            $dbcmd.ExecuteNonQuery()
            $dbobj.Close()
        } catch {
            Write-Host "SQL Create Table: $_"
        }
    } else {
        Write-Host "DB File: $($DBFile) does not exist"
    }
    
}
