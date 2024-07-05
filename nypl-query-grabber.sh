#!/bin/bash

# Prompt for API key and query
api_key="[INSERT API KEY]"

read -p "Enter your search query: " query
read -p "Enter the field for your  query: " field

# Set other parameters
per_page=500
page=1

# Function to make the API request and save the response
fetch_results() {
    local page=$1
    local response=$(curl -s "https://api.repo.nypl.org/api/v2/items/search?field=notes&q=${query}&per_page=${per_page}&page=${page}" \
                      -H "Authorization: Token token=${api_key}")
    echo $response | jq '.' > "nypl_${query}_${page}.json"
    echo $response
}

# Fetch the first page of results
response=$(fetch_results $page)

# Check if there are more results
total_results=$(echo $response | jq '.nyplAPI.response.numResults' | tr -d '"')
num_pages=$(expr \( $total_results + $per_page - 1 \) / $per_page)

echo "Total results: $total_results"
echo "Total pages: $num_pages"

# Fetch and save remaining pages
while [ $page -lt $num_pages ]; do
    page=$(expr $page + 1)
    fetch_results $page
done

echo "All results have been saved."
