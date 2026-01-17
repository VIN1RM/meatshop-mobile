import { useState } from 'react'
import { saveToken } from '../../../shared/storage/auth_storage'

type MockUser = {
  id: string
  name: string
  email: string
  token: string
}

// 🔥 flag de controle (quando backend estiver pronto, muda pra false)
const USE_MOCK_LOGIN = true

export function useLogin() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const login = async (email: string, password: string) => {
    try {
      setLoading(true)
      setError(null)

      if (USE_MOCK_LOGIN) {
        // ⏳ simula delay de API
        await new Promise(resolve => setTimeout(resolve, 1200))

        const mockUser: MockUser = {
          id: 'mock-user-1',
          name: 'Vinícius',
          email: email || 'mock@meatshop.com',
          token: 'mock-token-123456',
        }

        await saveToken(mockUser.token)
        return mockUser
      }

      // 🔒 login real (fica aqui para depois)
      // const useCase = new LoginUseCase(new AuthRepositoryImpl())
      // const user = await useCase.execute(email, password)
      // await saveToken(user.token)
      // return user

    } catch (err: any) {
      setError('Invalid credentials')
      throw err
    } finally {
      setLoading(false)
    }
  }

  return { login, loading, error }
}
