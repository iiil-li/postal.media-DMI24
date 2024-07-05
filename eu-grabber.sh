#!/bin/bash

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found, please install jq to use this script."
    exit 1
fi

# Function to URL encode a string
urlencode() {
    local data
    data=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))")
    echo "$data"
}

# Base URL without cursor parameter
base_url="https://api.europeana.eu/record/v2/search.json?query=postmark+envelope&cursor=CURSOR_PLACEHOLDER&media=true&rows=100&wskey=[INSERT API KEY]"

# Initialize the file counter
counter=1

# Initialize the cursor with an empty value
cursor="*"

# Infinite loop to continuously fetch data until no cursor is returned
while true; do
  # URL encode the cursor value
  encoded_cursor=$(urlencode "$cursor")

  # Replace CURSOR_PLACEHOLDER in the URL with the encoded cursor value
  url=${base_url/CURSOR_PLACEHOLDER/$encoded_cursor}

  # Construct the output filename
  filename="eur-brev-$counter.json"

  # Perform the curl request
  echo "Fetching data with cursor: $cursor"
  curl -H "Accept: application/json" -X GET "$url" -o "$filename"

  # Check if the curl request was successful
  if [ $? -eq 0 ]; then
    echo "Data saved to $filename"

    # Extract the next cursor value from the JSON response
    next_cursor=$(jq -r '.nextCursor' < "$filename")

    # Check if next_cursor is null or empty, then exit the loop
    if [ -z "$next_cursor" ] || [ "$next_cursor" == "null" ]; then
      echo "No more data to fetch. Exiting the script."
      break
    fi

    # Update the cursor value for the next iteration
    cursor="$next_cursor"

  else
    echo "Failed to fetch data. Please check the API response and try again."
    break
  fi

  # Increment the file counter
  counter=$((counter + 1))
done
