const fs = require("fs");
const cheerio = require("cheerio");

// Load the HTML file
const html = fs.readFileSync("./search_results.html", "utf8");

// Parse the HTML with Cheerio
const $ = cheerio.load(html);

// Extract titles, record links, and image IDs
const results = [];
$("#results-list li").each((index, element) => {
  const titleElement = $(element).find("a").attr("title");
  const title = titleElement ? titleElement.trim() : null;
  const recordLink = $(element).find("a").attr("href");
  const imageUrl = $(element).find("img").attr("src");
  const imageId = imageUrl ? imageUrl.match(/\/(\d+)\//)?.[1] : null;

  results.push({
    title,
    recordLink,
    imageId,
  });
});

// Create the JSON structure
const jsonOutput = {
  results,
};

// Write the JSON to a file
fs.writeFileSync(
  "nypl_search_results.json",
  JSON.stringify(jsonOutput, null, 2),
  "utf8",
);

console.log("JSON file has been created successfully.");
