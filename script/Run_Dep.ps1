param(
    [string]$optionalArg, 
    [string]$Workspace
)
 
 
#debug mode
#Set-PSDebug -Trace 2
 
##########################################################################
#SECTION 1: DECLARE GLOBAL VARIABLES                                    ##
##########################################################################
#workspace comes from vscode task.json
$vs_workspace_dir = $Workspace
 
#bdbfile comes from vscode task.json user input
$bdbfile=$optionalArg
 
$temp_bcf_file="$vs_workspace_dir" + "\script\dep_file.bcf"
#$datafile="$vs_workspace_dir\e-inst\00000002.bdb"
$datamodel="$vs_workspace_dir" + "\e-inst\inst.bmi"
$bdm_location="$vs_workspace_dir" + "\e-inst\inst.bdm"
$work_folder="$vs_workspace_dir" + "\e-inst"
#$externals_location="$vs_workspace_dir\externals"
$meta_location="$vs_workspace_dir" + "\externals\;$vs_workspace_dir" + "config"
$menufile="$vs_workspace_dir" + "\config\menu.bmf"
$dep_exe_location="C:\Users\galla339\Desktop\PortableBlaise4.8\Blaise486Build1960\Bin\Dep.exe" 
#$mode_location="$vs_workspace_dir\config"
#$carisettingsfile="$vs_workspace_dir\e-inst\AHS.bci"
$work_folder = "$vs_workspace_dir" + "\e-inst\"
 
###########################################################################
#SECTION 2: CREATE TEMP BCF FILE                                          #  
###########################################################################
# Initialize the content of the file
"[DepCmd]" | Set-Content -Path $temp_bcf_file
 
# Append additional lines to the file
"MenuFile=$menufile" | Add-Content -Path $temp_bcf_file
"MetaSearchPath=$meta_location" | Add-Content -Path $temp_bcf_file
"ExternalSearchPath=$meta_location" | Add-Content -Path $temp_bcf_file
"DataFile=$bdbfile" | Add-Content -Path $temp_bcf_file
"Key=$bdbfile" | Add-Content -Path $temp_bcf_file
"DataModel=$datamodel" | Add-Content -Path $temp_bcf_file
"GetMode=0" | Add-Content -Path $temp_bcf_file
"ExitDep=0" | Add-Content -Path $temp_bcf_file
"WatchWindow=1" | Add-Content -Path $temp_bcf_file
"BrowseMode=1" | Add-Content -Path $temp_bcf_file 
"WorkFolder=$work_folder" | Add-Content -Path $temp_bcf_file 
########################################################################
#SECTION 3: RUN DEP EXE                                                #
########################################################################
function RunDep{
    param(
        [string]$dep_exe_location,
        [string]$temp_bcf_file
    )
 
    Start-Process -FilePath $dep_exe_location "@$temp_bcf_file" -NoNewWindow -Wait
 
}
 
try{
RunDep -dep_exe_location $dep_exe_location -temp_bcf_file $temp_bcf_file
 
}
catch{
    write-host $_ -ForegroundColor Red
    exit 1
}
# Remove the temporary BCF file
Remove-Item -Path $temp_bcf_file
 
Exit 0