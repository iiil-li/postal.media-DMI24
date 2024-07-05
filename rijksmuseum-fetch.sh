#!/bin/bash

# Base URL of the API
base_url="https://www.rijksmuseum.nl/api/nl/collection?key="[INSERT API KEY]"&mgonly=True&ps=100&q='briefkaart+van'"

# Directory to save the JSON files
output_dir="output"
mkdir -p "$output_dir"

# Function to fetch a page and save it
fetch_page() {
    page_number=$1
    url="${base_url}&p=${page_number}"
    output_file="${output_dir}/page_${page_number}.json"

    # Use curl to fetch the page and save the output
    curl -s "$url" -o "$output_file"
    echo "Saved ${output_file}"
}

# Number of pages to fetch (you can change this to the desired number of pages)
num_pages=24

# Loop through the desired number of pages
for ((i=0; i<num_pages; i++)); do
    fetch_page $i
done
