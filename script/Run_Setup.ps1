#Debug Mode
#Set-PSDebug -Trace 2
 
############################################################
#SECTION 1: Global file locations                          #    
############################################################
#region
 
    #workspace directory comes from vscode task.json
    $vs_workspace_dir=$args[0]
 
    $input_folder="$vs_workspace_dir\testfiles\"
    $OutputFolder="$vs_workspace_dir\e-inst\"
    $setup_msu_location="$vs_workspace_dir\e-inst\setup.msu"
    $externals_location="$vs_workspace_dir\externals\"
    $manipula_exe_location="C:\Users\galla339\Desktop\PortableBlaise4.8\Blaise486Build1960\Bin\Manipula.exe" 
 
#endregion
############################################################
#SECTION 2: Create the temp .bcf file                      #         
############################################################
#region
 
    $temp_bcf_file="$vs_workspace_dir\script\setup_file.bcf"
 
    # Initialize the content of the file
    "[ManipulaCmd]" | Set-Content -Path $temp_bcf_file
 
    # Append additional lines to the file
    "Setup=$setup_msu_location" | Add-Content -Path $temp_bcf_file
    "WaitForKey=1" | Add-Content -Path $temp_bcf_file
    "MetaSearchPath=$externals_location" | Add-Content -Path $temp_bcf_file
    "InputFolder=$input_folder" | Add-Content -Path $temp_bcf_file
    "InputFile=$input_folder\AHS_SCIF_2025_TMO_BUILDS.inp" | Add-Content -Path $temp_bcf_file
    "OutputFolder=$OutputFolder" | Add-Content -Path $temp_bcf_file
 
#endregion
 
###########################################################
#SECTION 3: Call the manipula.exe program                 #
########################################################### 
 
 
#region
function RunSetup{
    param(
        [string]$manipula_exe_location=$manipula_exe_location,
        [string]$temp_bcf_file=$temp_bcf_file
    )
    Start-Process -FilePath $manipula_exe_location "@$temp_bcf_file" -NoNewWindow -Wait
 
}

    # Run the executable with the temp_bcf_file as an argument
    RunSetup
 
    #Remove the temporary BCF file
    Remove-Item -Path $temp_bcf_file -ErrorAction SilentlyContinue
 
    Exit 0
#endregion