# Base URL
$BASE_URL = "http://10.0.2.2:3000/api"

Write-Host "Testing API Routes..." -ForegroundColor Cyan

# 1. Register a new user
Write-Host "`n1. Testing user registration..." -ForegroundColor Green
$registerBody = @{
    username = "testuser"
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

$registerResponse = Invoke-RestMethod -Uri "${BASE_URL}/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $registerBody `
    -ErrorAction SilentlyContinue

Write-Host ($registerResponse | ConvertTo-Json)

# 2. Login with the created user
Write-Host "`n2. Testing user login..." -ForegroundColor Green
$loginBody = @{
    username = "testuser"
    password = "password123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "${BASE_URL}/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $loginBody `
    -ErrorAction SilentlyContinue

Write-Host ($loginResponse | ConvertTo-Json)

if ($null -eq $loginResponse.token) {
    Write-Host "No token received. Login might have failed." -ForegroundColor Red
    exit 1
}

# 3. Test protected route (profiles)
Write-Host "`n3. Testing protected route (profiles)..." -ForegroundColor Green
$headers = @{
    "Authorization" = "Bearer $($loginResponse.token)"
    "Content-Type" = "application/json"
}

$profilesResponse = Invoke-RestMethod -Uri "${BASE_URL}/profiles" `
    -Method Get `
    -Headers $headers `
    -ErrorAction SilentlyContinue

Write-Host ($profilesResponse | ConvertTo-Json)

Write-Host "`nTests completed!" -ForegroundColor Green
