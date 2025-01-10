import { greetUser, createUser, sum, isEven, getNodeEnv } from './app'

describe('greetUser', () => {
  it('should greet the user with name and age', () => {
    const user = { name: 'John', age: 30 }
    const result = greetUser(user)
    expect(result).toBe('Hello, John. You are 30 years old.')
  })

  it('should greet the user with name and unknown age', () => {
    const user = { name: 'Jane' }
    const result = greetUser(user)
    expect(result).toBe('Hello, Jane. You are unknown years old.')
  })
})

describe('createUser', () => {
  it('should create a user with the given name and age', () => {
    const name = 'John Doe'
    const age = 30
    const consoleSpy = jest.spyOn(console, 'log')
    const user = createUser(name, age)
    expect(user).toEqual({ name, age })
    expect(consoleSpy).toHaveBeenCalledWith('Creating user with name: ', name)
    consoleSpy.mockRestore()
  })

  it('should create a user with the given name and no age', () => {
    const name = 'Jane Doe'
    const consoleSpy = jest.spyOn(console, 'log')
    const user = createUser(name)
    expect(user).toEqual({ name })
    expect(consoleSpy).toHaveBeenCalledWith('Creating user with name: ', name)
    consoleSpy.mockRestore()
  })
})

describe('sum', () => {
  it('should return the sum of two numbers', () => {
    expect(sum(2, 3)).toBe(5)
    expect(sum(-1, 1)).toBe(0)
  })
})

describe('isEven', () => {
  it('should return true for even numbers', () => {
    expect(isEven(4)).toBe(true)
    expect(isEven(0)).toBe(true)
  })

  it('should return false for odd numbers', () => {
    expect(isEven(3)).toBe(false)
    expect(isEven(-1)).toBe(false)
  })
})

describe('getNodeEnv', () => {
  it('should return the current NODE_ENV', () => {
    process.env.NODE_ENV = 'test'
    expect(getNodeEnv()).toBe('test')
  })

  it('should return undefined if NODE_ENV is not set', () => {
    delete process.env.NODE_ENV
    expect(getNodeEnv()).toBeUndefined()
  })
})
