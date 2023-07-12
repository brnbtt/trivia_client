const express = require("express");
const app = express();
const path = require("path");

// Serve static files from the Flutter web app build directory
app.use(express.static(path.join(__dirname, "build/web")));

// Redirect all requests to the index.html file
app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "build/web/index.html"));
});

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
