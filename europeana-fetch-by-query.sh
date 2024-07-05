#!/bin/bash

# Prompt for the query term
read -p "Enter query: " query

# Base URL and other parameters
base_url="https://api.europeana.eu/record/v2/search.json"
reusability="open"
media="true"
rows="100"
wskey="[INSERT API KEY]"

# Function to urlencode using jq
urlencode() {
    jq -s -R -r @uri <<<"$1"
}

# Encode the query
encoded_query=$(urlencode "$query")

# Create directory to store JSON files
output_dir="./${query}_results"
mkdir -p "$output_dir"

# Initialize variables
cursor="*"
page_number=1

# Loop to fetch and store each page of results
while [ "$cursor" != "null" ]; do
    # Fetch data from API using curl -o option to save directly to file
    target_url="${base_url}?query=${encoded_query}&reusability=${reusability}&cursor=${cursor}&media=${media}&rows=${rows}&wskey=${wskey}"
    echo "here's the url it will try: ${target_url}"
    curl -s -H "Accept: application/json" -X GET \
        ${target_url} \
        -o "${output_dir}/page_${page_number}.json"

    echo "Page ${page_number} saved to ${output_dir}/page_${page_number}.json"

    # Extract cursor for next page from the just saved JSON file
    unencoded_cursor=$(jq -r '.nextCursor' "${output_dir}/page_${page_number}.json")
    cursor=$(urlencode "$unencoded_cursor")
    echo "this is what i think the nextcursor is: ${cursor}"
    # Increment page number
    ((page_number++))
done

echo "All pages saved in directory: ${output_dir}"
