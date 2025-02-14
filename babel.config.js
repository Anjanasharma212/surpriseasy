module.exports = function (api) {
  const validEnv = ['development', 'test', 'production'];
  const currentEnv = api.env();
  const isDevelopmentEnv = api.env('development');
  const isProductionEnv = api.env('production');
  const isTestEnv = api.env('test');

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      'Please specify a valid NODE_ENV or BABEL_ENV. Valid values are "development", "test", and "production". Received: ' +
        JSON.stringify(currentEnv) +
        '.'
    );
  }

  return {
    presets: [
      [
        '@babel/preset-env',
        {
          targets: isTestEnv ? { node: 'current' } : undefined,
          forceAllTransforms: !isTestEnv,
          useBuiltIns: !isTestEnv ? 'entry' : undefined,
          corejs: !isTestEnv ? 3 : undefined,
          modules: isTestEnv ? 'commonjs' : false,
          exclude: !isTestEnv ? ['transform-typeof-symbol'] : undefined,
        },
      ],
      [
        '@babel/preset-react',
        {
          development: isDevelopmentEnv || isTestEnv,
          useBuiltIns: true,
        },
      ],
    ].filter(Boolean),
    plugins: [
      'babel-plugin-macros',
      '@babel/plugin-syntax-dynamic-import',
      isTestEnv && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',
      [
        '@babel/plugin-proposal-class-properties',
        { loose: true },
      ],
      [
        '@babel/plugin-proposal-object-rest-spread',
        { useBuiltIns: true },
      ],
      [
        '@babel/plugin-proposal-private-methods',
        { loose: true },
      ],
      [
        '@babel/plugin-proposal-private-property-in-object',
        { loose: true },
      ],
      [
        '@babel/plugin-transform-runtime',
        {
          helpers: false,
          regenerator: true,
          corejs: false,
        },
      ],
      isProductionEnv && [
        'babel-plugin-transform-react-remove-prop-types',
        { removeImport: true },
      ],
    ].filter(Boolean),
  };
};