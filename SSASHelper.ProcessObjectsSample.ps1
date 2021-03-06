# Clear the screen
cls

# On error stop the script
$ErrorActionPreference = "Stop"

# Get the current folder of the running script
$currentPath = (Split-Path $MyInvocation.MyCommand.Definition -Parent)

# Import helper modules
Import-Module "$currentPath\Modules\SSASHelper" -Force

# Connection strings (on prem & Azure)
# ex: "Data Source=.\sql2016tb;Initial Catalog=Adventure Works Internet Sales;"
$connStr = (Get-Content "$currentPath\SSASTestConnStr.txt" | Out-String)
		  
$conn = Get-SSASConnection -connectionString $connStr -open

$ssasDatabase = "AW Internet Sales Tabular Model"

# Process only most recent facts
2009..2015|%{
	
	$year = $_

	if ($year -eq 2014) {
		$ssasTable = "Internet Sales"
		$partition = "Internet Sales $year"
		Invoke-SSASProcessCommand -connectionString $connStr -database $ssasDatabase -table $ssasTable -partition $partition -Verbose
	}
	
}

# Get all tables from AS database
$cmdText  = 'select [Name] from $SYSTEM.tmschema_tables'
$result = Invoke-SSASCommand -connectionString $connStr -commandtext $cmdText -commandType "query"

foreach ($item in $result) {

	$tableName = $item.Values 

	# Process all the dimension tables (smaller tables)
	# If is not named like the fact tables: process
	if( !($tableName.Contains("Internet Sales")) ){
		Invoke-SSASProcessCommand -connectionString $connStr -database $ssasDatabase -table $tableName -Verbose
	}
}




	

	
