$Admin = "Promo2022.d2p1g5@diiage.org"
$Password = Read-Host "Mot de passe" -AsSecureString

#Identifiants avec concaténation Nom d'user + Password
$SecPass = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Admin, $SecPass)

#Connexion
try{
    Connect-AzAccount -Credential $Credentials
}catch{
    write-host "$_.Exception.Message"
}

$resourceGroupName = Read-Host -Prompt "Saisissez le nom du groupe de ressource à créer"
$location = Read-Host -Prompt "Entrer une localisation" #verifier localisation ou try catch

New-AzResourceGroup -Name $resourceGroupName -Location $location

#Ouverture d'un explorateur de fichier pour selectionner un fichier JSON
try {
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Please Select File"
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.filter = "JSON (*.json)| *.json"
    $OpenFileDialog.ShowDialog() | Out-Null
    $Global:SelectedFile = $OpenFileDialog.FileName
    write-host $OpenFileDialog.FileName
    $Template = $OpenFileDialog.FileName
}
Catch {

    write-host "$_.Exception.Message"
        
    }

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $Template
