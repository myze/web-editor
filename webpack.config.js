module.exports = {
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee-loader" }
    ]
  },
  resolve: {
    extensions: ["", ".coffee", ".js"]
  }
}