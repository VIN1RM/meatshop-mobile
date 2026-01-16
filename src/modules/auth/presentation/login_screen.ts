import { View, Text } from 'react-native'
import { useState } from 'react'
import { useLogin } from './useLogin'
import Button from '../../../shared/components/Button'
import Input from '../../../shared/components/Input'

export default function LoginScreen() {
  const { login, loading, error } = useLogin()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  return (
    <View>
      <Text>Login</Text>

      <Input placeholder="Email" onChangeText={setEmail} />
      <Input placeholder="Password" secureTextEntry onChangeText={setPassword} />

      {error && <Text>{error}</Text>}

      <Button
        title={loading ? 'Loading...' : 'Login'}
        onPress={() => login(email, password)}
      />
    </View>
  )
}
