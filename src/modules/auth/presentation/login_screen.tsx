import { useState } from 'react'
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  SafeAreaView,
  KeyboardAvoidingView,
  ScrollView,
  Platform,
} from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useLogin } from './use_login'
import Button from '../../../shared/components/button'
import Input from '../../../shared/components/input'
import { colors } from '../../../shared/theme/colors'
import { useNavigation } from '@react-navigation/native'

export default function LoginScreen() {
  const { login, loading, error } = useLogin()
  const navigation = useNavigation<any>()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)

  async function handleLogin() {
    try {
      await login(email, password)
      navigation.replace('Welcome')
    } catch {}
  }

  return (
    <SafeAreaView style={styles.safe}>
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={styles.container}
          keyboardShouldPersistTaps="handled"
        >
          <Image
            source={require('../../../../assets/logo.png')}
            style={styles.logo}
            resizeMode="contain"
          />

          <Text style={styles.title}>LOGIN</Text>

          <View style={styles.card}>
            <Text style={styles.label}>Usuário</Text>
            <Input value={email} onChangeText={setEmail} />

            <Text style={[styles.label, { marginTop: 16 }]}>Senha</Text>

            <View style={styles.passwordWrapper}>
              <Input
                value={password}
                onChangeText={setPassword}
                secureTextEntry={!showPassword}
                style={{ paddingRight: 44 }}
              />

              <TouchableOpacity
                style={styles.eyeButton}
                onPress={() => setShowPassword(!showPassword)}
              >
                <Ionicons
                  name={showPassword ? 'eye-off-outline' : 'eye-outline'}
                  size={22}
                  color="#FFF"
                />
              </TouchableOpacity>
            </View>

            {error && <Text style={styles.error}>{error}</Text>}
          </View>

          <Button
            title="Entrar"
            onPress={handleLogin}
            loading={loading}
            style={{ marginTop: 28 }}
          />
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#4A4A4A' },
  container: {
    flexGrow: 1,
    padding: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logo: { width: 140, height: 140, marginBottom: 12 },
  title: { color: '#FFF', fontSize: 22, fontWeight: '700', marginBottom: 20 },
  card: {
    width: '100%',
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 16,
    padding: 20,
  },
  label: { color: '#FFF', fontSize: 16, marginBottom: 6 },
  passwordWrapper: { position: 'relative' },
  eyeButton: { position: 'absolute', right: 12, top: 18 },
  error: { color: colors.error, marginTop: 10 },
})
