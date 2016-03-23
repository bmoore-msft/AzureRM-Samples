Configuration Main
{

param ( 
	$nodeName,
	$artifactsLocation,
	$artifactsLocationSasToken,
	$fileToInstall, # should be of the format projectname/file.ext
	$folderToInstall
)

Import-DscResource –ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
	File CreateFolder
	  {
		DestinationPath = "c:\WindowsAzure\$folderToInstall"
		Ensure = "Present"
		Type = "Directory"
	  }
	Script InstallFileFromStaging
     {	
		TestScript = {
            Test-Path "C:\WindowsAzure\$using:folderToInstall\$using:fileToInstall"
        }
        SetScript = {
            $source = $using:artifactsLocation + "\$using:folderToInstall\$using:fileToInstall" + $using:artifactsLocationSasToken
			$dest = "C:\WindowsAzure\$using:folderToInstall\$using:fileToInstall"
            Invoke-WebRequest $source -OutFile $dest
        }
        GetScript = { @{Result = "InstallFileFromStaging"} }
		DependsOn = "[File]CreateFolder"
     }
  }
}