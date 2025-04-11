const webpack = require('webpack');

module.exports = function override(config) {
  // Add polyfills
  config.resolve.fallback = {
    ...config.resolve.fallback,
    "stream": require.resolve("stream-browserify"),
    "buffer": require.resolve("buffer"),
    "path": require.resolve("path-browserify"),
    "crypto": require.resolve("crypto-browserify"),
    "http": require.resolve("stream-http"),
    "https": require.resolve("https-browserify"),
    "fs": false,
    "timers": require.resolve("timers-browserify"),
    "zlib": require.resolve("browserify-zlib"),
    "util": require.resolve("util/"),
    "net": false,
    "tls": false,
    "assert": require.resolve("assert/"),
    "url": require.resolve("url/"),
    "os": require.resolve("os-browserify/browser"),
    "process": require.resolve("process/browser"),
  };

  // Add plugins
  config.plugins = [
    ...config.plugins,
    new webpack.ProvidePlugin({
      process: 'process/browser',
      Buffer: ['buffer', 'Buffer'],
    }),
  ];

  return config;
}; 