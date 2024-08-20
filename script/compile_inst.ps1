param(
  [string]$p1
)
#Debug Mode
#Set-PSDebug -Trace 2
 
##############################################################################################################################
#SECTION 1: Set the directory paths.  indicates for windows, which is necessary when calling B4CPars.exe from a bash script#
##############################################################################################################################
 
#region
  #WRITE-ERROR "ERROR LINE MESSAGE" 2>&1
  #argument for workspace coming from vscode task.json
  $repo_root=$p1
 
  #Blaise Project FILE (customize)
  $bpf="$repo_root\e-inst\inst.bpf"
 
  #Blaise Datamodel Properties FILE (customize)
  $bdp="$repo_root\e-inst\inst.bdp"
 
  #Blaise Mode library FILE (customize)
  $bml="$repo_root\config\ncvs.bml"
 
  #inst.bla FILE (customize)
  $inst_file="$repo_root\e-inst\inst.bla"
 
  #e-inst path
  $einst="$repo_root\e-inst"
 
  #procedures path
  $procedures="$repo_root\procedures"
 
  #Types path
  $types="$repo_root\Types"
 
  #Externals path
  $externals="$repo_root\externals"
 
  #externals prep path
  $externalsprep="$repo_root\externals prep"
 
  #Include path
  $includes="$repo_root\includes"
 
  #e-inst *.man files
  $einst_man_files="$repo_root\e-inst\*.man"
 
  #externals prep *.bla and *.man files
  $externals_prep_bla="$repo_root\externals prep\*.bla"
  $externals_prep_man="$repo_root\externals prep\*.man"
 
  #error flag
$error_message=""
 
 
#endregion
 
##############################################################################################################################
#SECTION 2: Create temporary /T files for B4CPars.exe to read                                                                                                #
##############################################################################################################################
 
#region
 
  #inst.bla txt file
  $compile_inst="$repo_root\script\compile_inst.txt"
 
    #e-inst/*.man txt file
  $compile_man="$repo_root\script\compile_man.txt"
 
    #function to create compile_inst.txt
  $runspace_create_instfile=
  {
        param (
            [string]$compile_inst,  # Path to the file where content will be written
            [string]$types,
            [string]$einst,
            [string]$externalsprep,
            [string]$externals,
            [string]$includes,
            [string]$procedures,
            [string]$bml,
            [string]$bdp,
            [string]$inst_file
        )
 
    function Create-InstFile {
        param (
              [string]$compile_inst,  # Path to the file where content will be written
              [string]$types,
              [string]$einst,
              [string]$externalsprep,
              [string]$externals,
              [string]$includes,
              [string]$procedures,
              [string]$bml,
              [string]$bdp,
              [string]$inst_file
        )
 
        # Create or overwrite the file with the first line of content
        Set-Content -Path $compile_inst -Value "/H$types;$einst;$externalsprep;$externals"
 
        # Append additional lines to the file
        Add-Content -Path $compile_inst -Value "/S$einst;$includes;$procedures;$types"
        Add-Content -Path $compile_inst -Value "/M$bml"
        Add-Content -Path $compile_inst -Value "/P$bdp"
        Add-Content -Path $compile_inst -Value "$inst_file"
      }
 
        Create-InstFile -compile_inst $compile_inst -types $types -einst $einst -externalsprep $externalsprep -externals $externals -includes $includes -procedures $procedures -bml $bml -bdp $bdp -inst_file $inst_file
  }
    #function to create compile_man.txt  
    $runspace_create_einstmanfile=
      {
      param (
              [string]$compile_man,  # Path to the file where content will be written
              [string]$types,
              [string]$einst,
              [string]$externalsprep,
              [string]$externals,
              [string]$includes,
              [string]$procedures,
              [string]$bml,
              [string]$bdp,
              [string]$einst_man_files
          )
          function Create-EInstManFile {
                param (
              [string]$compile_man,  # Path to the file where content will be written
              [string]$types,
              [string]$einst,
              [string]$externalsprep,
              [string]$externals,
              [string]$includes,
              [string]$procedures,
              [string]$bml,
              [string]$bdp,
              [string]$einst_man_files
      )
 
      # Create or overwrite the file with the first line of content
      Set-Content -Path $compile_man -Value "/H$types;$einst;$externalsprep;$externals"
 
      # Append additional lines to the file
      Add-Content -Path $compile_man -Value "/S$einst;$includes;$procedures;$types"
      Add-Content -Path $compile_man -Value "/M$bml"
      Add-Content -Path $compile_man -Value "/P$bdp"
      Add-Content -Path $compile_man -Value "$einst_man_files"
  }
 
          Create-EInstManFile -compile_man $compile_man -types $types -einst $einst -externalsprep $externalsprep -externals $externals -includes $includes -procedures $procedures -bml $bml -bdp $bdp -einst_man_files $einst_man_files
    }
 
    write-host "Compiling scripts..." -ForegroundColor Yellow
    # Create and start runspaces
    $runspaces = @()
 
    #Create compile_inst.txt 
    $runspace1 = [powershell]::Create().AddScript($runspace_create_instfile).AddArgument($compile_inst).AddArgument($types).AddArgument($einst).AddArgument($externalsprep).AddArgument($externals).AddArgument($includes).AddArgument($procedures).AddArgument($bml).AddArgument($bdp).AddArgument($inst_file)
    #Create compile_einstman.txt 
    $runspace2 = [powershell]::Create().AddScript($runspace_create_einstmanfile).AddArgument($compile_man).AddArgument($types).AddArgument($einst).AddArgument($externalsprep).AddArgument($externals).AddArgument($includes).AddArgument($procedures).AddArgument($bml).AddArgument($bdp).AddArgument($einst_man_files)
    $runspaces += [PSCustomObject]@{ Runspace = $runspace1; AsyncResult = $runspace1.BeginInvoke() }
    $runspaces += [PSCustomObject]@{ Runspace = $runspace2; AsyncResult = $runspace2.BeginInvoke() }
 
    # Ensure all runspaces have completed
    foreach ($runspace in $runspaces) {
        $runspace.Runspace.EndInvoke($runspace.AsyncResult)
        $runspace.Runspace.Dispose()
    }
 
#endregion
 
#############################################################################################################################
#SECTION 3: Call B4CPARS.EXE                                                                                                 #
##############################################################################################################################
#region
 
 
$runspace3_compile_inst={
  param(
    $compile_inst
  )
 
  function Compile-Inst {
      param(
        $compile_inst
      )
    $exeLocation = "C:\Users\galla339\Desktop\PortableBlaise4.8\Blaise486Build1960\Bin\b4cpars.exe"
      $compile_inst = "/T$compile_inst"
 
      return $output = & $exeLocation $compile_inst 
 
      } 
    return $output = Compile-Inst -compile_inst $compile_inst
 
 
}
 
$runspace4_compile_bla_prep={
    param(
      $externals_prep_bla
    )
 #compile externals prep/*.bla, b4cpars here does not use /T as it's short 
  function Compile-Bla-Prep {
    param (
          $externals_prep_bla
      )
 
        $exeLocation = "C:\Users\galla339\Desktop\PortableBlaise4.8\Blaise486Build1960\Bin\b4cpars.exe"
 
 
     return $output = & $exeLocation $externals_prep_bla
 
    }
  return $output =  Compile-Bla-Prep -externals_prep_bla $externals_prep_bla
 
}
 
$runspace5_compile_instman={
  param(
    $compile_man
  )
 
  function Compile-Inst-Man {
    param(
      $compile_man
    )
      $exeLocation = "C:\Users\galla339\Desktop\PortableBlaise4.8\Blaise486Build1960\Bin\b4cpars.exe"
      $compile_man = "/T$compile_man"
 
       $output = & $exeLocation $compile_man 
 
 
    return $output
 
    }
  return $output = Compile-Inst-Man -compile_man $compile_man
}
 
$runspace6_compile_man_prep={
  param(
    $externalsprep,
    $externals_prep_man
  )
 function Compile-Man-Prep {
    param (
         $externalsprep,
         $externals_prep_man
      )
 
                $exeLocation = "C:\Users\galla339\Desktop\PortableBlaise4.8\Blaise486Build1960\Bin\b4cpars.exe"
      $externalsprep = "/H$externalsprep"
 
      return $output =  & $exeLocation $externalsprep $externals_prep_man  
  }
  return $output = Compile-Man-Prep -externalsprep $externalsprep -externals_prep_man $externals_prep_man
}  
 
#region
    #calling compilation functions with parallelization for script speed
    $runspace3 = [powershell]::Create().AddScript($runspace3_compile_inst).AddArgument($compile_inst)
    $runspace4 = [powershell]::Create().AddScript($runspace4_compile_bla_prep).AddArgument($externals_prep_bla)
    $runspace5 = [powershell]::Create().AddScript($runspace5_compile_instman).AddArgument($compile_man)
    $runspace6 =[powershell]::Create().AddScript($runspace6_compile_man_prep).AddArgument($externalsprep).AddArgument($externals_prep_man)
 
    $runspaces += [PSCustomObject]@{ Runspace = $runspace3; AsyncResult = $runspace3.BeginInvoke() }
    $runspaces += [PSCustomObject]@{ Runspace = $runspace4; AsyncResult = $runspace4.BeginInvoke() }
    $runspaces += [PSCustomObject]@{ Runspace = $runspace5; AsyncResult = $runspace5.BeginInvoke() }
    $runspaces += [PSCustomObject]@{ Runspace = $runspace6; AsyncResult = $runspace6.BeginInvoke() }
 
    # Ensure all runspaces have completed
foreach ($runspace in $runspaces) {
      $output = $runspace.Runspace.EndInvoke($runspace.AsyncResult)
    try{
 
          if ($output -match "Error"){
            write-host $output -ForegroundColor Red
            Exit 1
            } 
    }catch{
 
    }
 
        $runspace.Runspace.Dispose()
}
 
 
#endregion
 
 
# Clean up files after all runspaces have finished
Remove-Item -Path $compile_man -ErrorAction SilentlyContinue
Remove-Item -Path $compile_inst -ErrorAction SilentlyContinue
 
#endregion
 
Write-Host "Compilation Success" -ForegroundColor Green
Exit 0