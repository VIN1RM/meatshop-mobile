import api from '../../../shared/api/api'

export class AuthApi {
  async login(email: string, password: string) {
    const response = await api.post('/auth/login', {
      email,
      password,
    })

    return response.data
  }
}
