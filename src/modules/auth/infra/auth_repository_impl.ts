import { AuthRepository } from '../domain/repositories/auth_repository'
import { User } from '../domain/entities/user'
import { AuthApi } from './auth_api'

export class AuthRepositoryImpl implements AuthRepository {
  private api = new AuthApi()

  async login(email: string, password: string): Promise<User> {
    const data = await this.api.login(email, password)

    return {
      id: data.user.id,
      name: data.user.name,
      email: data.user.email,
      token: data.token,
    }
  }
}
