import globals from 'globals'
import pluginJs from '@eslint/js'
import tseslint from 'typescript-eslint'
import eslintConfigPrettier from 'eslint-config-prettier'
import gitignore from 'eslint-config-flat-gitignore'

const rulesConfig = {
  rules: {
    '@typescript-eslint/no-empty-object-type': ['error', { allowInterfaces: 'always', allowObjectTypes: 'never' }],
  },
}

/** @type {import('eslint').Linter.Config[]} */
export default [
  gitignore(),
  { files: ['**/*.{js,mjs,cjs,ts}'] },
  { languageOptions: { globals: globals.node } },
  pluginJs.configs.recommended,
  ...tseslint.configs.recommended,
  rulesConfig,
  eslintConfigPrettier,
]
