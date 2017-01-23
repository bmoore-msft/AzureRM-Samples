Configuration Main
{

Param ($nodeName,
    $artifactsLocation,
    $artifactsLocationSasToken,
    $webDeployPackageFileName, # should be of the format projectname/file.ext
    $webDeployPackageFolder
 )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature WebManagementConsole
    {
      Name = "Web-Mgmt-Console"
      Ensure = "Present"
    }
    WindowsFeature WebManagementService
    {
      Name = "Web-Mgmt-Service"
      Ensure = "Present"
    }
    WindowsFeature ASPNet45
    {
      Name = "Web-Asp-Net45"
      Ensure = "Present"
    }
    WindowsFeature HTTPRedirection
    {
      Name = "Web-Http-Redirect"
      Ensure = "Present"
    }
    WindowsFeature CustomLogging
    {
      Name = "Web-Custom-Logging"
      Ensure = "Present"
    }
    WindowsFeature LogginTools
    {
      Name = "Web-Log-Libraries"
      Ensure = "Present"
    }
    WindowsFeature RequestMonitor
    {
      Name = "Web-Request-Monitor"
      Ensure = "Present"
    }
    WindowsFeature Tracing
    {
      Name = "Web-Http-Tracing"
      Ensure = "Present"
    }
    WindowsFeature BasicAuthentication
    {
      Name = "Web-Basic-Auth"
      Ensure = "Present"
    }
    WindowsFeature WindowsAuthentication
    {
      Name = "Web-Windows-Auth"
      Ensure = "Present"
    }
    WindowsFeature ApplicationInitialization
    {
      Name = "Web-AppInit"
      Ensure = "Present"
    }
    Package InstallWebDeploy
    {
        Ensure = "Present"  
        Path  = "http://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
        Name = "Microsoft Web Deploy 3.6"
        ProductId = "{ED4CC1E5-043E-4157-8452-B5E533FE2BA1}"
        Arguments = "ADDLOCAL=ALL"
        DependsOn = "[WindowsFeature]WebServerRole"
    }
    Service StartWebDeploy
    {                    
        Name = "WMSVC"
        StartupType = "Automatic"
        State = "Running"
        DependsOn = "[Package]InstallWebDeploy"
    }
    File CreateFolder
      {
        DestinationPath = "c:\WindowsAzure\$webDeployPackageFolder"
        Ensure = "Present"
        Type = "Directory"
      }
    Script InstallFileFromStaging
     {    
        TestScript = {
            #This is not ideal since this means we won't overwrite an existing package (never updated)
            Test-Path "C:\WindowsAzure\$using:webDeployPackageFolder\$using:webDeployPackageFileName"
        }
        SetScript = {
            $source = $using:artifactsLocation + "\$using:webDeployPackageFolder\$using:webDeployPackageFileName" + $using:artifactsLocationSasToken
            $dest = "C:\WindowsAzure\$using:webDeployPackageFolder\$using:webDeployPackageFileName"
            Invoke-WebRequest $source -OutFile $dest
        }
        GetScript = { @{Result = "InstallFileFromStaging"} }
        DependsOn = "[File]CreateFolder"
     }
     Script DeployPackage
     {
         TestScript = {
            #look for a file on the website created by this config, we could look for many
            $defaulthtm = (Get-WebSite -Name "Default Web Site").physicalPath.Replace("%SystemDrive%", $env:SystemDrive) + "\default.htm"
            Test-Path $defaulthtm
         }
         SetScript = {
            #find msdeploy.exe in the location where this script installed it
            $deploycmd = "$env:ProgramFiles\IIS\Microsoft Web Deploy V3\msdeploy.exe"
            $packageLocation = Resolve-Path -Path "C:\WindowsAzure\$using:webDeployPackageFolder\$using:webDeployPackageFileName"
            & $deploycmd "-verb:sync", "-source:package=$packageLocation", "-dest:auto",  "-setParam:name=""IIS Web Application Name"",value=""Default Web Site"""
         }
         GetScript = { @{Result = "DeployPackage"} }
         DependsOn = "[Script]InstallFileFromStaging"
     }
  }
}
