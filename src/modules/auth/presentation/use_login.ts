import { useState } from 'react'
import { LoginUseCase } from '../usecases/LoginUseCase'
import { AuthRepositoryImpl } from '../infra/AuthRepositoryImpl'
import { saveToken } from '../../../shared/storage/auth.storage'

export function useLogin() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const login = async (email: string, password: string) => {
    try {
      setLoading(true)
      setError(null)

      const useCase = new LoginUseCase(new AuthRepositoryImpl())
      const user = await useCase.execute(email, password)

      await saveToken(user.token)

      return user
    } catch (err: any) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }

  return { login, loading, error }
}
