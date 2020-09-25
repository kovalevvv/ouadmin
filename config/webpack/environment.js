const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    Popper: ['popper.js', 'default']
  })
)

environment.loaders.append('imports', {
  test: /datatables\.net.*/,
  use: [
    {
      loader: 'imports-loader',
      options: {
        imports: {
          moduleName: 'jquery',
          name: '$',
        },
        additionalCode: 'var define = false;',
      },
    }
  ]
})

module.exports = environment
