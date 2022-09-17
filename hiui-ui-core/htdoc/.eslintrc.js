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
	parser: 'vue-eslint-parser',
	parserOptions: {
		ecmaVersion: 'latest',
		parser: '@typescript-eslint/parser',
		sourceType: 'module'
	},
	plugins: ['vue'],
	rules: {
		'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
		'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
		'vue/no-multiple-template-root': 'off',
		'no-unused-vars': 'off',
		'vue/multi-word-component-names': 'off',
		'array-bracket-spacing': 'off',
		'brace-style': 'error',
		'comma-dangle': 'error',
		'comma-spacing': 'error',
		quotes: ['error', 'single'],
		'keyword-spacing': 'error',
		'no-trailing-spaces': 'error',
		'no-unneeded-ternary': 'error',
		'space-infix-ops': ['error', {int32Hint: false}],
		'arrow-spacing': 'error',
		'no-var': 'error',
		'no-duplicate-imports': 'error',
		'space-before-blocks': 'error',
		'no-multi-spaces': 'error',
		eqeqeq: 'error'
	}
};
