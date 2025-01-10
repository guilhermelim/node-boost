# Guia Completo de Scripts Especiais do NPM

Os scripts especiais do `npm` oferecem uma poderosa forma de automatizar processos e integrar fluxos de trabalho diretamente com o ciclo de vida do seu projeto. Este guia apresenta uma lista completa e organizada desses scripts, explicando sua ordem de execução e como você pode utilizá-los de maneira eficiente no seu `package.json`.

---

## O que são Scripts Especiais?

Os scripts especiais do NPM são comandos pré-definidos que são executados automaticamente em pontos específicos do ciclo de vida do projeto. Eles podem ser usados para tarefas como configurar dependências, rodar testes, publicar pacotes e muito mais.

Cada script especial tem um momento específico em que é acionado, permitindo que você personalize e controle cada etapa do desenvolvimento.

---

## Lista de Scripts Especiais em Ordem de Execução

Abaixo, está uma tabela com todos os scripts especiais organizados pela ordem em que são executados:

| **Script**       | **Ordem de Execução** | **Descrição**                                                                                            |
| ---------------- | --------------------- | -------------------------------------------------------------------------------------------------------- |
| `preinstall`     | 1                     | Executado **antes do processo de instalação** (antes do `npm install`).                                  |
| `install`        | 2                     | Executado durante o processo de instalação (executa quando o pacote é instalado).                        |
| `postinstall`    | 3                     | Executado **após o processo de instalação** (depois do `npm install`).                                   |
| `prepack`        | 4                     | Executado **antes de empacotar o projeto** (antes do `npm pack` ou `npm publish`).                       |
| `prepare`        | 5                     | Executado após o `install` e antes do `prepublishOnly`. É comum para configurar o projeto (e.g., Husky). |
| `prepublishOnly` | 6                     | Executado **antes de publicar um pacote** no registro, mas **não executa no `npm install`**.             |
| `prepublish`     | 7                     | Executado **antes de empacotar o projeto ou publicá-lo** (deprecated, mas ainda suportado).              |
| `postpublish`    | 8                     | Executado **após publicar um pacote** no registro.                                                       |
| `preuninstall`   | 9                     | Executado **antes de desinstalar** um pacote (antes do `npm uninstall`).                                 |
| `uninstall`      | 10                    | Executado durante o processo de desinstalação do pacote.                                                 |
| `postuninstall`  | 11                    | Executado **após desinstalar** um pacote.                                                                |
| `pretest`        | 12                    | Executado **antes do script `test`**.                                                                    |
| `test`           | 13                    | Executa os testes definidos no projeto (ou nenhum, se não configurado).                                  |
| `posttest`       | 14                    | Executado **após o script `test`**.                                                                      |
| `prestart`       | 15                    | Executado **antes do script `start`**.                                                                   |
| `start`          | 16                    | Usado para iniciar o aplicativo (ou `node server.js` se não configurado).                                |
| `poststart`      | 17                    | Executado **após o script `start`**.                                                                     |
| `prerelease`     | 18                    | Executado **antes de rodar `npm version` para criar uma nova versão**.                                   |
| `release`        | 19                    | Não padrão, mas frequentemente usado para criar uma nova versão do projeto manualmente.                  |
| `postrelease`    | 20                    | Executado **após o script `release`** (caso seja configurado manualmente).                               |

---

## Como Personalizar os Scripts no `package.json`

Você pode adicionar os scripts no seu arquivo `package.json` sob a chave `scripts`. Aqui está um exemplo de como configurar alguns scripts especiais:

```json
{
    "scripts": {
        "preinstall": "echo 'Executando antes da instalação'",
        "install": "node scripts/setup.js",
        "postinstall": "echo 'Instalação concluída'",
        "test": "jest",
        "pretest": "echo 'Preparando para testes'",
        "posttest": "echo 'Testes concluídos'",
        "start": "node server.js",
        "prestart": "echo 'Preparando para iniciar o servidor'",
        "poststart": "echo 'Servidor iniciado com sucesso'"
    }
}
```

---

## Dicas Práticas

1. **Use scripts com prefixos `pre` e `post`:** Eles permitem automatizar etapas antes e depois de um script principal.
   Qualquer script com nome xyz pode ter scripts prefixados `prexyz` e `postxyz`, que serão executados antes e depois, respectivamente. Exemplo: Para o script build, você pode ter `prebuild` e `postbuild`.

2. **Automatize tarefas repetitivas:** Configure scripts como `prepare` para instalar dependências adicionais ou configurar hooks do Git (como Husky).
3. **Integre com CI/CD:** Scripts como `prepublishOnly` garantem que seu pacote seja publicado corretamente.

---

## Conclusão

Os scripts especiais do NPM oferecem uma forma poderosa de otimizar e automatizar o ciclo de vida do seu projeto. Usar esses scripts corretamente pode melhorar a qualidade, organização e fluxo de trabalho, tornando seu desenvolvimento mais produtivo.

Explore as possibilidades e implemente os scripts que fazem sentido para o seu projeto! 🚀
