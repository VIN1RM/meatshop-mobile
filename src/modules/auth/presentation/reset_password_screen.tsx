import { useState } from 'react'
import {
    View,
    Text,
    StyleSheet,
    SafeAreaView,
    KeyboardAvoidingView,
    Platform,
    TouchableOpacity,
} from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useNavigation, useRoute } from '@react-navigation/native'
import Button from '../../../shared/components/button'
import Input from '../../../shared/components/input'
import { colors } from '../../../shared/theme/colors'

export default function ResetPasswordScreen() {
    const navigation = useNavigation<any>()
    const route = useRoute<any>()
    const email = route.params?.email || ''
    const code = route.params?.code || ''

    const [password, setPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState('')
    const [showPassword, setShowPassword] = useState(false)
    const [showConfirmPassword, setShowConfirmPassword] = useState(false)

    // Estados para validação individual
    const [hasMinLength, setHasMinLength] = useState(false)
    const [hasUpperCase, setHasUpperCase] = useState(false)
    const [hasLowerCase, setHasLowerCase] = useState(false)
    const [hasNumber, setHasNumber] = useState(false)
    const [hasSpecialChar, setHasSpecialChar] = useState(false)

    function checkPasswordRequirements(password: string) {
        setHasMinLength(password.length >= 6)
        setHasUpperCase(/[A-Z]/.test(password))
        setHasLowerCase(/[a-z]/.test(password))
        setHasNumber(/[0-9]/.test(password))
        setHasSpecialChar(/[!@#$%^&*(),.?":{}|<>]/.test(password))
    }

    function handlePasswordChange(text: string) {
        setPassword(text)
        checkPasswordRequirements(text)
    }

    function validatePassword(password: string): string | null {
        if (password.length < 6) {
            return 'A senha deve ter no mínimo 6 caracteres'
        }

        if (!/[A-Z]/.test(password)) {
            return 'A senha deve conter pelo menos uma letra maiúscula'
        }

        if (!/[a-z]/.test(password)) {
            return 'A senha deve conter pelo menos uma letra minúscula'
        }

        if (!/[0-9]/.test(password)) {
            return 'A senha deve conter pelo menos um número'
        }

        if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
            return 'A senha deve conter pelo menos um caractere especial'
        }

        return null
    }

    async function handleSubmit() {
        setError('')

        const passwordError = validatePassword(password)
        if (passwordError) {
            setError(passwordError)
            return
        }

        if (password !== confirmPassword) {
            setError('As senhas não coincidem')
            return
        }

        setLoading(true)

        try {
            // await api.resetPassword(email, code, password)

            await new Promise(resolve => setTimeout(resolve, 1500))

            console.log('Senha redefinida com sucesso')
            
            // Volta para a tela de login
            navigation.navigate('Login')
        } catch (err) {
            setError('Erro ao redefinir senha. Tente novamente.')
        } finally {
            setLoading(false)
        }
    }

    function handleBack() {
        navigation.goBack()
    }

    return (
        <View style={styles.container}>
            <SafeAreaView style={styles.safe}>
                <KeyboardAvoidingView
                    style={{ flex: 1 }}
                    behavior={Platform.OS === 'ios' ? 'padding' : undefined}
                >
                    <View style={styles.content}>
                        <TouchableOpacity
                            style={styles.backButton}
                            onPress={handleBack}
                        >
                            <Ionicons name="arrow-back" size={28} color="#4A4A4A" />
                        </TouchableOpacity>

                        <View style={styles.header}>
                            <Text style={styles.titleRed}>Estamos quase lá!</Text>
                            <Text style={styles.title}>
                                Faltam poucos passos{'\n'}para redefinir sua senha.
                            </Text>
                        </View>

                        <View style={styles.formContainer}>
                            <Text style={styles.label}>Digite a nova senha</Text>
                            
                            <View style={styles.requirementsBox}>
                                <Text style={styles.requirementsTitle}>A senha deve conter:</Text>
                                <Text style={[styles.requirement, hasMinLength && styles.requirementValid]}>
                                    • No mínimo 6 caracteres
                                </Text>
                                <Text style={[styles.requirement, hasUpperCase && styles.requirementValid]}>
                                    • Pelo menos uma letra maiúscula (A-Z)
                                </Text>
                                <Text style={[styles.requirement, hasLowerCase && styles.requirementValid]}>
                                    • Pelo menos uma letra minúscula (a-z)
                                </Text>
                                <Text style={[styles.requirement, hasNumber && styles.requirementValid]}>
                                    • Pelo menos um número (0-9)
                                </Text>
                                <Text style={[styles.requirement, hasSpecialChar && styles.requirementValid]}>
                                    • Pelo menos um caractere especial (!@#$%...)
                                </Text>
                            </View>

                            <View style={styles.passwordContainer}>
                                <Input
                                    value={password}
                                    onChangeText={handlePasswordChange}
                                    secureTextEntry={!showPassword}
                                    placeholder="••••••••"
                                    autoCapitalize="none"
                                />
                                <TouchableOpacity
                                    style={styles.eyeButton}
                                    onPress={() => setShowPassword(!showPassword)}
                                >
                                    <Ionicons
                                        name={showPassword ? "eye-off" : "eye"}
                                        size={24}
                                        color="#4A4A4A"
                                    />
                                </TouchableOpacity>
                            </View>

                            <Text style={styles.label}>Confirme a nova senha</Text>

                            <View style={styles.passwordContainer}>
                                <Input
                                    value={confirmPassword}
                                    onChangeText={setConfirmPassword}
                                    secureTextEntry={!showConfirmPassword}
                                    placeholder="••••••••"
                                    autoCapitalize="none"
                                />
                                <TouchableOpacity
                                    style={styles.eyeButton}
                                    onPress={() => setShowConfirmPassword(!showConfirmPassword)}
                                >
                                    <Ionicons
                                        name={showConfirmPassword ? "eye-off" : "eye"}
                                        size={24}
                                        color="#4A4A4A"
                                    />
                                </TouchableOpacity>
                            </View>

                            {error && <Text style={styles.error}>{error}</Text>}

                            <Button
                                title="Retornar à página de login"
                                onPress={handleSubmit}
                                loading={loading}
                                style={styles.button}
                            />
                        </View>
                    </View>
                </KeyboardAvoidingView>
            </SafeAreaView>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#E8E8E8',
    },
    safe: {
        flex: 1,
    },
    content: {
        flex: 1,
        padding: 24,
    },
    backButton: {
        alignSelf: 'flex-start',
        marginBottom: 24,
    },
    header: {
        alignItems: 'center',
        marginBottom: 32,
    },
    titleRed: {
        fontSize: 32,
        fontWeight: 'bold',
        color: '#C94A3C',
        marginBottom: 16,
    },
    title: {
        fontSize: 24,
        fontWeight: '600',
        color: '#4A4A4A',
        textAlign: 'center',
        lineHeight: 32,
    },
    formContainer: {
        marginBottom: 40,
    },
    label: {
        fontSize: 16,
        color: '#4A4A4A',
        marginBottom: 12,
        marginTop: 16,
    },
    requirementsBox: {
        backgroundColor: '#F5F5F5',
        padding: 16,
        borderRadius: 8,
        marginBottom: 16,
        borderLeftWidth: 3,
        borderLeftColor: '#C94A3C',
    },
    requirementsTitle: {
        fontSize: 14,
        fontWeight: '600',
        color: '#4A4A4A',
        marginBottom: 8,
    },
    requirement: {
        fontSize: 13,
        color: '#666',
        marginBottom: 4,
        lineHeight: 18,
    },
    requirementValid: {
        color: '#22C55E',
        fontWeight: '600',
    },
    passwordContainer: {
        position: 'relative',
    },
    eyeButton: {
        position: 'absolute',
        right: 16,
        top: 16,
        padding: 4,
    },
    error: {
        color: colors.error,
        marginTop: 16,
        fontSize: 14,
    },
    button: {
        marginTop: 32,
    },
})