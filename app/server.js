const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("FoodExpress API is running 🚀");
});

app.get("/health", (req, res) => {
  res.json({ status: "healthy", service: "FoodExpress API" });
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});