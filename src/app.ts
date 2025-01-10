interface User {
  name: string
  age?: number
}

export function greetUser(user: User): string {
  return `Hello, ${user.name}. You are ${user.age ?? 'unknown'} years old.`
}

export function createUser(name: string, age?: number): User {
  console.log('Creating user with name: ', name)
  return { name, age }
}

export function sum(a: number, b: number): number {
  return a + b
}

export function isEven(num: number): boolean {
  return num % 2 === 0
}

export function getNodeEnv(): string | undefined {
  return process.env.NODE_ENV
}

// Example usage
const user = createUser('John Doe', 30)
console.log(greetUser(user))
console.log('Sum of 2 and 3 is: ', sum(2, 3))
console.log('Is 4 even? ', isEven(4))
console.log('Current NODE_ENV: ', getNodeEnv())
