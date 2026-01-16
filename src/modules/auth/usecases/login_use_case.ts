import { AuthRepository } from '../domain/repositories/AuthRepository'

export class LoginUseCase {
  constructor(private authRepository: AuthRepository) {}

  async execute(email: string, password: string) {
    if (!email || !password) {
      throw new Error('Invalid credentials')
    }

    return this.authRepository.login(email, password)
  }
}
