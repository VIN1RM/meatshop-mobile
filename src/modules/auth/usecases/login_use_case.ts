import { AuthRepository } from '../domain/repositories/auth_repository'
import { User } from '../domain/entities/user'

export class LoginUseCase {
  constructor(private authRepository: AuthRepository) {}

  async execute(email: string, password: string): Promise<User> {
    if (!email || !password) {
      throw new Error('Invalid credentials')
    }

    return this.authRepository.login(email, password)
  }
}
