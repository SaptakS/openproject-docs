const path = require('path');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  resolve: {
    extensions: ['.ts', '.js', '.json']
  },
  entry: {
    site: ['./webpack/javascripts/index.ts', './webpack/stylesheets/index.scss']
  },
  module: {
    rules: [
      {
        "test": /\.tsx?$/,
        "exclude": /node_modules/,
        "use": {
          "loader": "ts-loader"
        }
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf|svg)$/,
        use: [{
          loader: 'file-loader', options: {
            esModule: false,
            outputPath: 'fonts',
            publicPath: './../fonts',
          }
        }],
      },
      {
        test: /\.(sa|sc|c)ss$/,
        exclude: /node_modules/,
        use: [{
          loader: MiniCssExtractPlugin.loader,
          options: {
            publicPath: __dirname + '/stylesheets/',
            sourceMap: true
          }
        },
          {
            loader: 'css-loader',
            options: {
              sourceMap: true
            }
          },
          {
            loader: 'postcss-loader',
            options: {
              sourceMap: true
            }
          },
          {
            loader: 'sass-loader',
            options: {
              sourceMap: true
            }
          },
        ],
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: 'stylesheets/[name].css',
      chunkFilename: '[id].css'
    })
  ],
  output: {
    filename: 'javascripts/[name].js',
    path: path.resolve(__dirname, '.tmp/dist')
  }
};