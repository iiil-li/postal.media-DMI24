import fs from "fs";
import fetch from "node-fetch";

// Load JSON data from the files
const rawData1 = fs.readFileSync("./search_results.json", "utf8");
const rawData2 = fs.readFileSync("./search_results_2.json", "utf8");

const jsonData1 = JSON.parse(rawData1);
const jsonData2 = JSON.parse(rawData2);

// Combine the data from both JSON files if needed
const combinedData = [...jsonData1, ...jsonData2];

// API endpoint and token
const apiEndpoint = "http://api.postal.media/api/nypl-scrapes/";
const apiToken = "[INSERT API KEY]";

// Function to create the payload for Strapi
function makeStrapiPackage(data) {
  const formattedCollection = data
    .map((entry) => {
      const { id, title, image_id, high_res_link, title_full } = entry.item;
      if (!high_res_link) {
        return null;
      }
      const imageUrl = `https://iiif-prod.nypl.org/index.php?id=${image_id}&t=g`;
      const link = `https://digitalcollections.nypl.org/items/${id}`;
      const description = title_full;

      return {
        title,
        image: imageUrl,
        link,
        description,
      };
    })
    .filter((item) => item !== null); // Filter out null values
  return { data: formattedCollection };
}

// Function to post data to the API endpoint
async function postData(url, data) {
  console.log(`Posting data: ${JSON.stringify(data, null, 2)}`);

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiToken}`,
    },
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    const errorDetails = await response.text();
    console.error(
      `Failed to post data - Status: ${response.status} - ${response.statusText}`,
    );
    console.error(`Server response: ${errorDetails}`);
    throw new Error(`Failed to post data: ${response.statusText}`);
  }

  const result = await response.json();
  console.log(`Successfully posted data - Status: ${response.status}`);
  return result;
}

// Function to deliver the Strapi package
async function deliverStrapiPackage(url, packages) {
  for (const element of packages.data) {
    const strungEl = { data: element };
    console.log(`Prepared payload: ${JSON.stringify(strungEl, null, 2)}`);
    try {
      await postData(url, strungEl);
    } catch (error) {
      console.error(`Error posting data - `, error);
    }
  }
}

// Main function to execute the script
async function main() {
  const packages = makeStrapiPackage(combinedData);
  await deliverStrapiPackage(apiEndpoint, packages);
}

main()
  .then(() => {
    console.log("All data posted successfully.");
  })
  .catch((error) => {
    console.error("Error posting data: ", error);
  });
