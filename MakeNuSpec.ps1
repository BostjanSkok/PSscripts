param ([string]$ProjectName)

$scriptPath = Split-Path $MyInvocation.MyCommand.Path
Push-Location $scriptPath 

$nuSpecPath =$scriptPath +'\' +$ProjectName + '.nuspec'
$xml = New-Object XML
If (Test-Path $nuSpecPath ){

	$xml.Load($nuSpecPath )
	& hg log -r $xml.package.metadata.tags -r tip --template '{desc}\n' > 'changes.txt'
    $xml.package.metadata.tags= [string](&hg tip --template '{node}')
}Else{
	& hg log --template '{desc}\n' > 'changes.txt'
	& "..\.nuget\nuget.exe" spec 
	$xml.Load($nuSpecPath ) 


	$files = $xml.CreateElement("files")
	$file = $xml.CreateElement("file")


	$srcAtr = $xml.CreateAttribute("src")
	$srcAtr.Value = 'bin\$configuration$\$id$.pdb'
	$file.Attributes.Append($srcAtr)

	$targetAtr = $xml.CreateAttribute("target")
	$targetAtr.Value = 'lib\net40\'
	$file.Attributes.Append($targetAtr)


	$files.AppendChild($file)
	$xml.package.AppendChild($files)
	$xml.package.metadata.tags= [string](&hg tip --template '{node}')

}
$x = Get-Content 'changes.txt' | Out-String
$xml.package.metadata.releaseNotes = "$x"
$xml.Save($nuSpecPath)
Pop-Location


