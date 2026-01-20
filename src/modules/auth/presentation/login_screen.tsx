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
  ImageBackground,
} from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useLogin } from './use_login'
import Button from '../../../shared/components/button'
import Input from '../../../shared/components/input'
import { colors } from '../../../shared/theme/colors'
import { useNavigation } from '@react-navigation/native'
import { cpfMask } from '../../../shared/utils/cpf_mask'

export default function LoginScreen() {
  const { login, loading, error } = useLogin()
  const navigation = useNavigation<any>()

  const [cpf, setCpf] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)

  function handleCpfChange(value: string) {
    setCpf(cpfMask(value))
  }

  async function handleLogin() {
    try {
      const cpfClean = cpf.replace(/\D/g, '')
      await login(cpfClean, password)
      navigation.replace('Welcome')
    } catch {}
  }

  function handleForgotPassword() {
    console.log('Navegar para recuperação de senha')
  }

  return (
    <View style={styles.container}>
      <ImageBackground
        source={require('../../../../assets/background.png')}
        style={styles.backgroundImage}
        resizeMode="cover"
        imageStyle={{ opacity: 0.05 }}
      >
        <SafeAreaView style={styles.safe}>
          <KeyboardAvoidingView
            style={{ flex: 1 }}
            behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          >
            <ScrollView
              contentContainerStyle={styles.scrollContent}
              keyboardShouldPersistTaps="handled"
            >
              <View style={styles.logoContainer}>
                <Image
                  source={require('../../../../assets/logo.png')}
                  style={styles.logo}
                  resizeMode="contain"
                />
              </View>

              <View style={styles.card}>
                <Text style={styles.label}>CPF</Text>

                <Input
                  value={cpf}
                  onChangeText={handleCpfChange}
                  keyboardType="numeric"
                  placeholder="000.000.000-00"
                  maxLength={14}
                />

                <Text style={[styles.label, { marginTop: 16 }]}>Senha</Text>

                <View style={styles.passwordWrapper}>
                  <Input
                    value={password}
                    onChangeText={setPassword}
                    secureTextEntry={!showPassword}
                    placeholder="••••••"
                    style={{ paddingRight: 44 }}
                  />

                  <TouchableOpacity
                    style={styles.eyeButton}
                    onPress={() => setShowPassword(prev => !prev)}
                  >
                    <Ionicons
                      name={showPassword ? 'eye-off-outline' : 'eye-outline'}
                      size={22}
                      color={colors.gray}
                    />
                  </TouchableOpacity>
                </View>

                <TouchableOpacity 
                  style={styles.forgotPassword}
                  onPress={handleForgotPassword}
                >
                  <Text style={styles.forgotPasswordText}>Esqueceu sua senha?</Text>
                </TouchableOpacity>

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
      </ImageBackground>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#4A4A4A',
  },
  backgroundImage: {
    flex: 1,
    width: '100%',
    height: '100%',
  },
  safe: { 
    flex: 1, 
    backgroundColor: 'transparent',
  },
  scrollContent: {
    flexGrow: 1,
    padding: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoContainer: {
    width: '100%',
    alignItems: 'center',
    marginBottom: 32,
  },
  logo: { 
    width: 180, 
    height: 180,
  },
  card: {
    width: '100%',
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 16,
    padding: 20,
  },
  label: { color: '#FFF', fontSize: 16, marginBottom: 6 },
  passwordWrapper: {
    position: 'relative',
  },
  eyeButton: {
    position: 'absolute',
    right: 15,
    top: 12,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  forgotPassword: {
    alignSelf: 'flex-start',
    marginTop: 12,
  },
  forgotPasswordText: {
    color: '#FFF',
    fontSize: 14,
    textDecorationLine: 'underline',
  },
  error: { color: colors.error, marginTop: 10 },
})