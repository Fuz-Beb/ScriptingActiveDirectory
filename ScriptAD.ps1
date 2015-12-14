######
#
# But du script : Créer automatiquement les comptes et les ressources nécessaires à la formation.
#
######

####
# [O-U] Création d'une unitée d'organisation
#
# (Description) Organisation de l'annuaire GSB : DC=GSB,DC=LOC,OU=stages,OU=<nom de la formation>.
# Une OU du nom de la formation est créée pour accueillir les comptes.
#
###
function Create_OU {
param([string]$nom)
    if(([adsi]::Exists("LDAP://OU=stage,DC=remy,DC=loc"))) {
   
        Write-Host "L'unité d'organisation stage existe déjà"
    }
    else {
        NEW-ADOrganizationalUnit "stage"
    }
    
    
    
    ### Création de l'OU "bts" ###
    
    if(([adsi]::Exists("LDAP://OU=bts,OU=stage,DC=remy,DC=loc"))) {
   
        Write-Host "L'unité d'organisation bts existe déjà"
    }
    else {
        NEW-ADOrganizationalUnit "bts" -path "OU=stage,DC=remy,DC=loc"
    }
}

Create_OU
#
####

####
#
# [USERS] Création des utilisateurs
#
# (Description) Chaque utilisateurs doit disposer d'un identifiant et d'un mot de passe, d'un répertoire personnel.
#
###
function Create_Users {
    
    ### Chemin vers le fichier contenant les comptes"
    $fichier="C:\content.txt"


    ### Parcours du fichier ###
    if (Test-Path $fichier){
        $colLIgnes=Get-Content $fichier
    
        foreach($ligne in $colLignes){
            $tabCompte=$ligne.Split("/")
            $var2=""+$tabCompte[1]+"";
            
            
            ### Test d'existence du compte et création du compte
            $checkUser = Get-ADUser -LDAPFilter "(sAMAccountName=$var2)"
                       
            if (!$checkUser) {
                New-ADUser -Name $tabCompte[0] -Path "OU=bts,OU=stage,DC=remy,DC=loc" -SamAccountName $tabCompte[1] -AccountPassword(ConvertTo-SecureString "P@sswordP@ssword" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enable $true;
            }
            else {
                Write-Host "Le nom d'utilisateur" $tabCompte[1] "existe déjà";
            }

            
            #################  CREATION DU REPERTOIRE PERSONNEL DES UTILISATEURS AVEC PERMISSIONS  #################
####
#

### Test d'existence et création du dossier personnel des utilisateurs ainsi que ses permissions ###

	if (-not (Test-Path $homeDirectory)) {


	        ### Le dossier n'existe pas donc ### Création du dossier personnel Ex:"E:\share\nomDuUser" ### Ajout d'acl sur le dossier (ajout des permissions du users sur son dossier personnel
		New-Item -ItemType directory  -Path $homeDirectory;
		$acl = Get-Acl -Path $homeDirectory;
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($tabCompte[1], "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule);
                Set-Acl -path $homeDirectory -AclObject $acl;
	}

        else {
        	Write-Host "Le dossier de"$tabCompte[0] "existe déjà"
        }
#
####
	            
            #################  CREATION DU REPERTOIRE COMMUN AVEC PERMISSIONS  #################
            
####
# [PERM+SHARE] Permissions NTFS/Partage
#
# (Description) x1 Répertoire de partage est créé pour permettre l'échange entre les différents stagiaires
#
###

	### Affectation du chemin du dossier commun ###
        $directoryAll = "E:\DATA\stages\bts\commun"

            
        ### Création du répertoire avec ses permissions ###
	if (-not (Test-Path $directoryAll)) {

        	New-Item -ItemType directory  -Path $directoryAll;
                $acl = Get-Acl -Path $directoryAll;
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Tout le monde", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule);
                Set-Acl -path $directoryAll -AclObject $acl;
        }
	else {
		Write-Host "Le dossier commun existe déjà"
        }

#
####  
          
            #################  AJOUT DES LECTEURS RESEAUX SUR LES COMPTES DES UTILISATEURS  #################
####
#
            
            ### Chemin réseau du répertoire de chaque users ###
            $PathNetworkUsers = "\\Remy-pc\DATA\stages\bts\"+$tabCompte[0]+"";
            
            ### Affectation du lecteur aux users ###
            SET-ADUSER -Identity $tabCompte[1] -HomeDirectory $PathNetworkUsers -HomeDrive 'Z:'
            
            
            ### Chemin réseau du répertoire partagé de chaque users ###
            $PathNetworkCommun = "\\Remy-pc\DATA\stages\bts\commun";
            
            ### Affectation du lecteur aux users ###
            SET-ADUSER -Identity $tabCompte[1] -HomeDirectory $PathNetworkCommun -HomeDrive 'Z:' 
#
####			
        }
    }
}

Create_Users
