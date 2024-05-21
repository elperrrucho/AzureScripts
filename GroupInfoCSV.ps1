#==========================================================================
# Technical: CSV, Azure
#
# Generate CSV file with the group inormation :
# - Group name 
# - Group Owner
# - Group Members
# - all emails 
#
# AUTEUR: Edgar A. Garcia 
# DATE  : May 21st 2024
#
#==========================================================================


# Import required module
Import-Module AzureAD

# Function to fetch members' emails of a group
function Get-AzureADGroupMembers {
    param ($GroupId)
    $members = Get-AzureADGroupMember -ObjectId $GroupId -All $true | Where-Object { $_.ObjectType -eq 'User' }
    $memberEmails = $members | ForEach-Object { $_.Mail }
    return ($memberEmails -join ', ')
}

# Function to fetch owners' emails of a group
function Get-AzureADGroupOwners {
    param ($GroupId)
    $owners = Get-AzureADGroupOwner -ObjectId $GroupId
    $ownerEmails = $owners | ForEach-Object { $_.Mail }
    return ($ownerEmails -join ', ')
}

# Connect to Azure AD with administrative privileges
Connect-AzureAD

# Fetch all groups
$groups = Get-AzureADGroup -All $true

# Collecting group info
$groupInfo = @()
foreach ($group in $groups) {
    $members = Get-AzureADGroupMembers -GroupId $group.ObjectId
    $owners = Get-AzureADGroupOwners -GroupId $group.ObjectId

    $groupInfo += [PSCustomObject]@{
        GroupName = $group.DisplayName
        Email = $group.Mail
        OwnerEmails = $owners
        MemberEmails = $members
    }
}

# Define the file path for the CSV output
$filePath = Join-Path -Path $env:USERPROFILE -ChildPath 'Documents\azure_groups.csv'

# Export collected group information to CSV
$groupInfo | Export-Csv -Path $filePath -NoTypeInformation
