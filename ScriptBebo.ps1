######
#
# But du script : CrÃ©er automatiquement les comptes et les ressources nÃ©cessaires Ã  la formation.
#
######

#--- PARTIE GENERALE :

####
# [O-U] Création d'une unitée d'organisation
#
# (Description) Organisation de l'annuaire GSB : DC=GSB,DC=LOC,OU=stages,OU=<nom de la formation>.
# Une OU du nom de la formation est créée pour accueillir les comptes.
#
###
function new_ou {
param([string]$nom)
New-ADOrganizationalUnit -Name $nom -Path "DC=GSB,DC=LOC,OU=stages,OU=$nom"
Write-Host " La formation $nom a été ajouté ou est déja présente."
}
# Source : https://technet.microsoft.com/fr-fr/library/dd378831%28v=ws.10%29.aspx
#
####


####
# [PERM+SHARE] Permissions NTFS/Partage
#
# (Description) x1 Répertoire de partage est créé pour permettre l'échange entre les différents stagiaires
#
###
function new_partage {
param([string]$nom)
New-Item -Path C:\data\stages\$nom\commum -ItemType Directory
New-SmbShare -Name commum -Path E:\commum -FullAccess Stagiaires -Description "Partage pour stagiaire" -encryptdata $true
Write-Host "--- [OK] --- Le partage $nom a été ajouté."
}
# Source : http://informatique-windows.blogspot.fr/2015/04/creation-partage-powershell.html
#
####


#--- PARTIE CONCERNANT LES USERS :

####
#
# [USERS] Création des utilisateurs
#
# (Description) Chaque utilisateurs doit disposer d'un identifiant et d'un mot de passe, d'un répertoire personnel.
#
###
function new_users {
param([string]$parametres)
$nom=$parametres[0]
$nomComplet=$parametres[1]
$description=$parametres[2]

$compte=[ADSI]"WinNT://./$nom"
if (!$compte.path){
	$utilisateur=$local.create("user",$nom)
	$utilisateur.InvokeSet("FullName",$nomComplet) 
	$utilisateur.InvokeSet("Description",$description)
	$utilisateur.CommitChanges() 
	Write "--- [OK] --- L'utilisateur $nom a été ajouté."
	}
else{
	Write-Host "--- [ERREUR] --- L'utilisateur $nom existe déjà ."
	}
}
# SOURCE : TP cours fichier ajoutCompteFIchierCorrection.ps1 (SISR5 BTS SIO 2013-2015)
#
####

####
# [REP] Création des répertoires perso
#
# (Description)
#
###
function new-folder {
    param([string[]]$params)
    $nom=$params[0]
    $prenom=$params[1]
    $nom_formation=$params[2]
    $folderpath="C:\data\$nom_formation\$prenom.$nom"
    $shares=[WMICLASS]'WIN32_Share'
    $sharename="$prenom.$nom"
}
#
####

#
# Proposer une politique de nommage des comptes et une politique de mot de passe pour les stagiaires de GSB.
#
