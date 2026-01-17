import { NavigationContainer } from '@react-navigation/native'
import AuthNavigator from './auth_navigator'
import AppNavigator from './app_navigator'
import { useEffect, useState } from 'react'
import { getToken } from '../storage/auth_storage'

export default function Routes() {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null)

  useEffect(() => {
    async function loadSession() {
      const token = await getToken()
      setIsAuthenticated(!!token)
    }

    loadSession()
  }, [])

  if (isAuthenticated === null) {
    return null
  }

  return (
    <NavigationContainer>
      {isAuthenticated ? <AppNavigator /> : <AuthNavigator />}
    </NavigationContainer>
  )
}
