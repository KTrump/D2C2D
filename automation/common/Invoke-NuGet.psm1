function Invoke-NuGet { param ($assembly, $projectpath, $repo, $command)

    $nugetLocation = $repo + "\Automation\tools"

    #$source = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    #$Filename = [System.IO.Path]::GetFileName($source)
    #$nuget = "$nugetLocation\$Filename"
    $nuget = "$nugetLocation\nuget.exe"

    #$wc = New-Object System.Net.WebClient
    #$wc.DownloadFile($source, $dest)

    if ($command -eq "restoreProjectJson")
    {
        $projJson = $projectpath + "\" + $assembly + "\" + "project.json"
        $nugetparams = "restore", $projJson, "-SolutionDirectory", $projectpath
        Write-Output "Call NuGet restoreProjectJson '$nugetparams'"
        & $nuget $nugetparams
    }

    if ($command -eq "restore")
    {
       $packagesConfig = $projectpath + "\" + $assembly + ".sln"
        $repositoryPath = $repo + "\nugets"
        $nugetparams = "update", $packagesConfig, "-RepositoryPath", $repositoryPath, "-Verbose"
        Write-Output "Call NuGet Update '$nugetparams'"
        & $nuget $nugetparams 

        $proj = $projectpath + "\"  + $assembly + ".sln"
        $nugetparams = "restore", $proj, "-SolutionDirectory", $projectpath
        Write-Output "Call NuGet Restore '$nugetparams'"
        & $nuget $nugetparams

     }
    
    if ($command -eq "pack")
    {
        
        $proj = $projectpath + "\" + $assembly + "\" + $assembly + ".csproj"
        $nugetparams = "spec", "-f", $proj  
        Write-Output "Call NuGet Spec '$nugetparams'"
        & $nuget $nugetparams

        $nugetparams = "pack", $proj  
        Write-Output "Call NuGet Pack '$nugetparams'"
        & $nuget $nugetparams
    } 
}

Export-ModuleMember -Function Invoke-NuGet