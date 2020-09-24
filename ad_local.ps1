Import-Module ActiveDirectory

Add-Type -AssemblyName System.Web


#Repertoire création utilisateurs
$OU = "OU=tests,DC=rezorezo7,DC=onmicrosoft,DC=com"

#Emplacement utilisateurs à importer
$userList = ".\listeGroupe.csv"

#Emplacement du fichier log
$fichier = "C:\Users\administrateur.API-REZOREZO7\Desktop\logs.txt"

#Créer le fichier si il n'existe pas
if ((Test-Path $fichier) -eq $False){

New-Item -Path $fichier -ItemType File

}


function CheckUser{

    #Vérifie si l'utilisateur est déjà créer

    param([string]$login)

    process{

        Get-ADUser -Filter 'SamAccountName -eq $login' -SearchBase $OU

    }
}

function CreateUser {

    #Création d'un utilisateur AD


    param([string]$nom,[string]$prenom)

    process {

        $login = $nom + "." + $prenom
        $mdp = ConvertTo-SecureString "Azerty@123" -AsPlainText -Force

        #Création mdp random et insertion dans le fichier
        $randomPassword = [System.Web.Security.Membership]::GeneratePassword(8,1)
        ADD-content -path $fichier -value ($login + "`t" + $randomPassword)

        try{
            New-ADUser -Name ($nom +" " + $prenom) -GivenName $prenom -SamAccountName $login -Path $OU -AccountPassword $mdp -Enabled $true -ErrorAction Stop
        }catch{
            Write-Host "L'utilisateur $login existe déjà."
        }
    }
}

function DeleteUser{

    #Suppression d'un utilisateur

    param([string]$login)
    process{
        Remove-ADUser $login -Confirm:$False
    }
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

do
{
     Menu
     #Affichage du menu puis nous redirige sur l'action souhaitée
     $input = Read-Host "Votre selection"
     switch ($input)
     {
           '1' {

                #Liste tous les utilisauteurs de l' ad
                Get-ADUser 

           } '2' {

                #Création d'un seul utilisateur
                #Demande le nom et prénom puis mdp avec une confirmation
                   do{
                    cls
                    $nom = Read-Host "Nom"
                    $prenom = Read-Host "Prenom"

                    
                    do{
                        $mdp1 = Read-Host "Mot de passe" -AsSecureString
                        $mdp2 = Read-Host "Confirmation" -AsSecureString

                        $pass1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mdp1))
                        $pass2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mdp2))
                        if ($pass1 -ne $pass2) {Write-Host "Mots de passe non identique."}
                    } until ($pass1 -eq $pass2)

                    cls
                    Write-Host "Nom : $nom"
                    Write-Host "Prenom : $prenom`n"
                    $choix = Read-Host "Les informations sont correctes ? O/N"

                   }
                    until (($choix -eq "o") -or ($choix -eq "O"))

                    #$mdp1 = ConvertTo-SecureString $mdp1 -AsPlainText -Force
                    try{
                    New-ADUser -ErrorAction Stop
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
                    $login = $User.prenom +"."+ $User.nom

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

