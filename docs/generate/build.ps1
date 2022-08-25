$CurrentPath = Get-Location
function Exit-Script {
  Set-Location $CurrentPath
  Exit
}

function Test-CommandExists
{
  param ($command)
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = "stop"
  try {
    if (Get-Command $command) {
      RETURN $true
    }
  } catch {
    RETURN $false
  } finally {
    $ErrorActionPreference=$oldPreference
  }
}

function Get-BasePath {
  $CurrentDir = Get-Location
  if ($CurrentDir -notmatch '\\$') {
    $CurrentDir = Join-Path -Path $CurrentDir -ChildPath "\"
  }

  if ($CurrentDir -match 'generate\\$') {
    $CurrentDir = Join-Path -Path $CurrentDir "..\.."
    $CurrentDir = Resolve-Path -Path $CurrentDir
  }

  if ($CurrentDir -match 'docs\\$') {
    $CurrentDir = Join-Path -Path $CurrentDir ".."
    $CurrentDir = Resolve-Path -Path $CurrentDir
  }

  RETURN $CurrentDir 
}

$ItemAllUnits = '<li><a href="AllUnits.html">Units</a></li>'
$ItemAllIdentifiers = '<li><a href="AllIdentifiers.html">Identifiers</a></li>'
function Set-NavigationItemOrder {
  param ($file)
  
  $Content = Get-Content -Path $file

  $Content = $Content.Replace('<li><a href="quickstart.html">Quick start</a></li>', '')
  $Content = $Content.Replace($ItemAllUnits, '<li><a href="quickstart.html">Quick start</a></li>' + $ItemAllUnits)

  $Content = $Content.Replace('<li><a href="application.html">Application structure</a></li>', '')
  $Content = $Content.Replace($ItemAllUnits, '<li><a href="application.html">Application structure</a></li>' + $ItemAllUnits)

  $Content = $Content.Replace('<li><a href="command.html">Command structure</a></li>', '')
  $Content = $Content.Replace($ItemAllUnits, '<li><a href="command.html">Command structure</a></li>' + $ItemAllUnits)

  $Content = $Content.Replace('<li><a href="features.html">Features</a></li>', '')
  $Content = $Content.Replace($ItemAllUnits, '<li><a href="features.html">Features</a></li>' + $ItemAllUnits)

  $Content = $Content.Replace('<li><a href="testing.html">Testing</a></li>', '')
  $Content = $Content.Replace($ItemAllUnits, '<li><a href="testing.html">Testing</a></li>' + $ItemAllUnits)

  $Content = $Content.Replace('<li><a href="project.html">About the project</a></li>', '')
  $Content = $Content.Replace($ItemAllUnits, '<li><a href="project.html">About the project</a></li>' + $ItemAllUnits)

  $Content = $Content.Replace($ItemAllUnits, '<hr><li>Reference<ul style="margin-left: 10px;">' + $ItemAllUnits)
  $Content = $Content.Replace($ItemAllIdentifiers, $ItemAllIdentifiers + '</li></ul>')

  Set-Content -Path $file -Value $Content
}

if (Test-CommandExists "pasdoc") {
  Write-Host "Pasdoc found"
} else {
  Write-Host "Pasdoc was not found, is required to build the documentation. Please install it or make sure that it is in current path."
  Exit-Script  
}

$BasePath = Get-BasePath
$DocArgs = 
  "--format=html " + 
  "--css=" + $BasePath + "docs\generate\custom.css " +
  "--use-tipue-search " +
  "--output " + $BasePath + "docs " +
  "--introduction=" + $BasePath + "docs\generate\introduction.txt " +
  "--additional="  + $BasePath + "docs\generate\quickstart.txt " +
  "--additional="  + $BasePath + "docs\generate\application.txt " +
  "--additional="  + $BasePath + "docs\generate\command.txt " +
  "--additional="  + $BasePath + "docs\generate\features.txt " +
  "--additional="  + $BasePath + "docs\generate\testing.txt " +
  "--additional="  + $BasePath + "docs\generate\project.txt " +
  $BasePath + "src\*.pas "

Start-Process -FilePath "pasdoc" -ArgumentList $DocArgs -Wait -NoNewWindow

$DocPath = Join-Path -Path $BasePath -ChildPath "docs\*.html"

Get-ChildItem -Path $DocPath -Recurse | ForEach-Object {
  Set-NavigationItemOrder -file $_
}