#!/bin/bash

# Base URL
BASE_URL="http://10.0.2.2:3000/api"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Testing API Routes..."

# 1. Register a new user
echo -e "\n${GREEN}1. Testing user registration...${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
}')
echo $REGISTER_RESPONSE

# 2. Login with the created user
echo -e "\n${GREEN}2. Testing user login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
}')
echo $LOGIN_RESPONSE

# Extract token from login response
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}No token received. Login might have failed.${NC}"
  exit 1
fi

# 3. Test protected route (profiles)
echo -e "\n${GREEN}3. Testing protected route (profiles)...${NC}"
curl -s -X GET "${BASE_URL}/profiles" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json"

echo -e "\n\n${GREEN}Tests completed!${NC}"
