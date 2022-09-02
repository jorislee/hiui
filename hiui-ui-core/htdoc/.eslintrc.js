module.exports = {
	globals: {
		process: true,
		__dirname: true
	},
	env: {
		browser: true,
		es2021: true
	},
	extends: ['eslint:recommended', 'plugin:vue/vue3-essential', 'plugin:prettier/recommended', './.eslintrc-auto-import.json'],
	parserOptions: {
		ecmaVersion: 'latest',
		sourceType: 'module'
	},
	plugins: ['vue'],
	rules: {
		'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
		'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
		'vue/no-multiple-template-root': 'off',
		'vue/multi-word-component-names': 'off',
		'no-unused-vars': 'off',
		'vue/no-unused-vars': 'off'
	}
};
