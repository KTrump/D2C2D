function Invoke-DataTransfer { param ($RepoPath, $dataPath, $connStr, $collectionName)

	$dt = $RepoPath + "\Automation\Tools\dt\dt-1.3\dt.exe"
	$dtparams = "/s:JsonFile", "/s.Files:F:\\Projects\\Git-D2C2D\\automation\\deploy\\data\\Registry\\provision-kirby-test-output.json", "/t:DocumentDBBulk", "/t.ConnectionString:$connStr", "/t.Collection:$collectionName", "/t.CollectionTier:S3"
    Write-Output $dtparams
	&$dt $dtparams
}
Export-ModuleMember -Function Invoke-DataTransfer
