const HtmlWebpackPlugin = require('html-webpack-plugin')
const path = require('path')
const isProduction = process.env.NODE_ENV === 'production'

const stylesHandler = 'style-loader'

const config  = {
  entry: './src/webpack/app.js',
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, 'public'),
    clean: true,
  },
  plugins: [
  ],
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/i,
        loader: 'babel-loader',
      },
      {
        test: /\.css$/i,
        use: [stylesHandler, 'css-loader', 'postcss-loader'],
      },
      {
        test: /\.(eot|svg|ttf|woff|woff2|png|jpg|gif)$/i,
        type: 'asset',
      },
    ],
  },
}

module.exports = () => {
  if (isProduction) {
    config.mode = 'production'
  } else {
    config.mode = 'development'
  }
  return config
}