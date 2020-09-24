Import-Module AzureAD


function CheckUser{

#Vérifie si l'utilisateur est déjà créer

param([string]$mail)

process{

Get-AzADUser -UserPrincipalName $mail

}
}

function CreateUser {

#Création d'un utilisateur AzAD


param([string]$nom,[string]$prenom,[String]$mdp)

process {

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile

$PasswordProfile.Password = $mdp

$mail = ($prenom + "." + $nom + "@rezorezo7.onmicrosoft.com").ToLower()
$displayName = $nom + $prenom
New-AzureADUser -DisplayName $displayName -PasswordProfile $PasswordProfile.Password -UserPrincipalName $mail -AccountEnabled $true -MailNickName $displayName


ADD-content -path $fichier -value ($mail + "`t" + $PasswordProfile.Password)


}
}

function DeleteUser{

#Suppression d'un utilisateur

param([string]$objectid)
process{
Get-AzureADUser -ObjectId $objectid | select UserPrincipalName,DisplayName
$choix = Read-Host "Voulez vous supprimer cet utilisateur ? O/N"
if (-not(($choix -ne "o") -or  ($choix -ne "O"))){
    Remove-AzureADUser -ObjectId $objectid
    Write-Host "`nUtilisateur supprimé.`n"
}
}
}


function ChangeUserPassword{

#Changement mdp utilisateur

param([string]$objectid)
process{
Get-AzureADUser -ObjectId $objectid | select UserPrincipalName,DisplayName
$choix = Read-Host "S'agit il de cet utilisateur ? O/N"
if (-not(($choix -ne "o") -or  ($choix -ne "O"))){
    $newpass = Read-Host "Saisissez le nouveau mot de passe" -AsSecureString
    Set-AzureADUserPassword -ObjectId $objectid -Password $newpass
    Write-Host "`nMot de passe mis à jour.`n"
}
}
}

$tenant = "32b7737e-995c-4199-a1b9-35e028b81f7d" #locataire azure rezorezo7
$subscription = "6c6f03b8-8d2b-46ed-a2ec-57c9117854c8"
#si pb de connexion affiche un message
function connectazad {
try{
    Connect-AzureAD -TenantId $tenant -ErrorAction Stop

}catch{
    cls
    write-host "Erreur lié à la connexion à Azure"
    pause
    connectazad
    }
}

#Emplacement utilisateurs à importer
$userList = ".\listeGroupe.csv"

#Emplacement du fichier utilisateurs crées login et mdp
$fichier = "C:\logs.txt"

#Créer le fichier si il n'existe pas
if ((Test-Path $fichier) -eq $False){

New-Item -Path $fichier -ItemType File

}



function menu(){

    cls
    Write-Host " -------------------- MENU --------------------`n"
    Write-Host " 1 : Lister les utilisateurs"
    Write-Host " 2 : Créer un utilisateur"
    Write-Host " 3 : Supprimer un utilisateur"
    Write-Host " 4 : Modifier un mot de passe"
    Write-Host " 5 : Création d'utilisateurs via fichier CSV"
    Write-Host " 6 : Rechercher un utilisateur"
    Write-Host " Q : Quitter`n"

}

connectazad
do
{
     Menu
     #Affichage du menu puis nous redirige sur l'action souhaitée
     $input = Read-Host "Votre selection"
     switch ($input)
     {
           '1' {

                #Liste tous les utilisauteurs de l'azure ad
                Get-AzureADUser | Select UserPrincipalName,DisplayName,ObjectID

           } '2' {

                #Création d'un seul utilisateur
                #Demande le nom et prénom puis mdp avec une confirmation
                   do{
                    cls
                    $nom = Read-Host "Nom"
                    $prenom = Read-Host "Prenom"

                    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
                    
                    do{
                        $mdp1 = Read-Host "Mot de passe" -AsSecureString
                        $mdp2 = Read-Host "Confirmation" -AsSecureString

                        $pass1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mdp1))
                        $pass2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mdp2))
                        if ($pass1 -ne $pass2) {Write-Host "Mots de passe non identique."}
                    } until ($pass1 -eq $pass2)

                    $mail = ($prenom + "." + $nom + "@rezorezo7.onmicrosoft.com").ToLower()

                    cls
                    Write-Host "Nom : $nom"
                    Write-Host "Prenom : $prenom"
                    Write-Host "Mail : $mail `n"
                    $choix = Read-Host "Les informations sont correctes ? O/N"

                   }
                    until (($choix -eq "o") -or ($choix -eq "O"))

                    #$mdp1 = ConvertTo-SecureString $mdp1 -AsPlainText -Force

                    $mail = ($prenom + "." + $nom + "@rezorezo7.onmicrosoft.com").ToLower()
                    $displayName = $nom + $prenom
                    try{
                    New-AzADUser -DisplayName $displayName -Password $mdp1 -UserPrincipalName $mail -MailNickName $displayName -ErrorAction Stop
                    ADD-content -path $fichier -value ($mail + "`t" + $PasswordProfile.Password)
                    }catch{
                    
                    write-host "$_.Exception.Message"
                    } 
           
           } '3' {
                cls
                $objectid = Read-Host "Saisissez l'object id de l'utilisateur à supprimer"
                DeleteUser $objectid
                
           }  '4' {
                cls
                $objectid = Read-Host "Saisissez l'object id de l'utilisateur"
                ChangeUserPassword $objectid

               } '5' {
                cls
                #Création des utilisateurs qui sont dans le fichier CSV

                $i = 0
                $userList = Read-Host "Emplacement absolu du fichier"
                $Users = Import-Csv -Path $userList -Delimiter ";"
                foreach ($User in $Users) 
                { 
                    $login = $User.prenom +"."+$User.nom

                    $mail = ($prenom + "." + $nom + "@rezorezo7.onmicrosoft.com").ToLower()

                    $randomPassword = [System.Web.Security.Membership]::GeneratePassword(8,1)
                    ADD-content -path $fichier -value ($mail + "`t" + $randomPassword)
                    #$PasswordProfile.Password = $randomPassword
                    
                    $randomPassword = ConvertTo-SecureString $randomPassword -AsPlainText -Force
                    
                    #CreateUser $nom $prenom $randomPassword
                    
                    $displayName = ($nom + $prenom) 
                    try{
                        New-AzADUser -DisplayName $displayName -Password $randomPassword -UserPrincipalName $mail -MailNickName $displayName -ErrorAction Stop
                        ADD-content -path $fichier -value ($mail + "`t" + $PasswordProfile.Password)
                    }catch{
                    
                        write-host "$_.Exception.Message"
                    
                    }
                    $i ++
                    }

                write-host "Execution terminée, $i utilisateur(s) créé(s)"
           }
           
           '6' {
                cls
                $search = Read-Host "Nom à rechercher"
                Get-AzureADUser -SearchString $search | Select UserPrincipalName,DisplayName,ObjectID
           }
           
           'q' {
                return
           }
     }
     pause
}
until (($input -eq "q") -or ($input -eq "Q"))




