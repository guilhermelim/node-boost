import { readdirSync, statSync, renameSync } from 'node:fs'
import { dirname, join, basename } from 'node:path'
import chalk from 'chalk'
import ora from 'ora'
import { table } from 'table'

class FsLint {
  private action: 'list' | 'fix'
  private directory: string

  constructor(action: 'list' | 'fix', directory: string = '.') {
    this.action = action
    this.directory = directory
  }

  private lintPath(path: string): null | { action: 'list' | 'fix'; original: string; fixed: string } {
    const trimmedPath = join(dirname(path), basename(path).trimStart().trimEnd())
    if (path !== trimmedPath) {
      if (this.action === 'fix') {
        renameSync(path, trimmedPath)
        return { action: 'fix', original: path, fixed: trimmedPath }
      } else {
        return { action: 'list', original: path, fixed: trimmedPath }
      }
    }
    return null
  }

  private lintDirectory(dir: string): Array<{ action: 'list' | 'fix'; original: string; fixed: string }> {
    const items = readdirSync(dir)
    let issues: Array<{ action: 'list' | 'fix'; original: string; fixed: string }> = []

    items.forEach(item => {
      const fullPath = join(dir, item)
      const stats = statSync(fullPath)

      if (stats.isDirectory()) {
        issues = [...issues, ...this.lintDirectory(fullPath)]
      }

      const issue = this.lintPath(fullPath)
      if (issue) issues.push(issue)
    })

    return issues
  }

  public async run(): Promise<void> {
    const spinner = ora({
      text: 'Starting fs-lint...',
      color: 'cyan',
      spinner: 'dots',
    }).start()

    await this.delay(500)

    // Run linting to find the issues
    const issues = this.lintDirectory(this.directory)

    // Display the result
    spinner.stopAndPersist({
      symbol: '🚀',
      suffixText: 'Done!',
    })

    // Display an introduction message about what fs-lint does
    console.log(
      chalk.cyan(
        '\nfs-lint helps fix formatting issues in file paths by removing extra spaces from the beginning and end of file and directory names.\n',
      ),
    )

    // Check if there are any issues
    if (this.action === 'list') {
      const listSpinner = ora({
        text: '🔍 Looking for issues...',
        color: 'yellow',
        spinner: 'material',
      }).start()

      // Simulate a slight delay
      await this.delay(1500)

      if (issues.length === 0) {
        listSpinner.stopAndPersist({
          symbol: '✔',
          text: ' No issues found to fix.',
          suffixText: 'All good!',
        })
      } else {
        listSpinner.stopAndPersist({
          symbol: '✘ ',
          text: chalk.red(`${issues.length} issue(s) found:`),
        })

        const tableData = [['Original File/Folder', 'Fixed File/Folder']]
        issues.forEach(issue => {
          tableData.push([issue.original, issue.fixed])
        })

        const output = table(tableData)
        console.log(output)

        // Suggest to fix the issues
        console.log(chalk.yellow('\nTo fix the issues, run the command with the --fix parameter.'))
        process.exit(1)
      }
    } else if (this.action === 'fix') {
      // Display loading indicator to fix the issues
      const fixSpinner = ora({
        text: 'Fixing issues...',
        color: 'yellow',
        spinner: 'material',
      }).start()

      // Simulate a slight delay
      await this.delay(1500)

      if (issues.length === 0) {
        fixSpinner.stopAndPersist({
          symbol: '✔',
          text: ' No issues found to fix.',
          suffixText: 'All good!',
        })
      } else {
        console.log(chalk.green(`✔ ${issues.length} issue(s) fixed:`))

        const tableData = [['Original File', 'Fixed File']]
        issues.forEach(issue => {
          tableData.push([issue.original, issue.fixed])
        })

        const output = table(tableData)
        console.log(output)

        fixSpinner.stopAndPersist({
          symbol: '✔',
          text: ' Fixed successfully.',
          suffixText: 'All good!',
        })
      }
    }

    console.log(chalk.cyan('🔧 Processing complete.'))
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}

const run = (): void => {
  const action: 'list' | 'fix' = process.argv.includes('--fix') ? 'fix' : 'list'
  const directory = '.'

  const fsLint = new FsLint(action, directory)
  fsLint.run()
}

if (import.meta.url === `file://${process.argv[1]}`) {
  run()
}

export default FsLint
