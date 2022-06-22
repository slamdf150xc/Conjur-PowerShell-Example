# Define the PVWA base URI
$pvwaBaseURI = "https://pvwa.cybr.com"
$conjurBaseURI = "https://conjur.cybr.com"

# Define vars for Conjur and Vault
$conjurAccount = "quick-start"
$conjurLogin = "Randy@BotApp"

# This should be a variable that gets populated by logging into the Conjur API to pull the API Key for the Conjur User
$conjurAPIKey = "2gzw3w054w0ha1zf83rddfczdv1nm4kwb22m8mqf167vgw124dafwq"

# Define the secret we want to pull from Conjur
$conjurSecret = "BotApp/secretVar"

# Define the user that will log into the Vault API
$vaultUser = "Test_API"

# Define the inital headers for Conjur
$conjurHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$conjurHeaders.Add("Content-Type", "application/x-www-form-urlencoded")
$conjurHeaders.Add("Accept-Encoding", "base64")

# Define the inital headers for the Vault
$vaultHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

# Call Conjur, request an auth token
$authToken = Invoke-RestMethod -Uri "$conjurBaseURI/authn/$conjurAccount/$conjurLogin/authenticate" -Method POST -Headers $conjurHeaders -Body $conjurAPIKey

# Add auth token to headers
$conjurHeaders.Add("Authorization", "Token token=`"$authToken`"")

# Call Conjur to pull secret to be used to log into the Vault API
$response = Invoke-RestMethod -Uri "$conjurBaseURI/secrets/$conjurAccount/variable/$conjurSecret" -Method GET -Headers $conjurHeaders

# Build the data body to log into the Vault API
$data = @{
    username=$vaultUser
    password=$response
} | ConvertTo-Json

# Execute Vault Login
$ret = Invoke-RestMethod -Uri "$pvwaBaseURI/PasswordVault/API/Auth/CyberArk/Logon" -Method POST -Body $data -ContentType 'application/json'

# Set Vault auth header for API calls
$vaultHeaders.Add("Authorization", $ret.Replace("`"",""))

# Execute Vault log off using the auth token
Invoke-RestMethod -Uri "$pvwaBaseURI/PasswordVault/API/Auth/Logoff" -Method POST -Headers $vaultHeaders -ContentType 'application/json'