import { useState, useRef, useEffect } from 'react'
import {
    View,
    Text,
    StyleSheet,
    Image,
    SafeAreaView,
    KeyboardAvoidingView,
    ScrollView,
    Platform,
    TouchableOpacity,
    TextInput,
} from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useNavigation, useRoute } from '@react-navigation/native'
import Button from '../../../shared/components/button'
import { colors } from '../../../shared/theme/colors'

export default function VerifyCodeScreen() {
    const navigation = useNavigation<any>()
    const route = useRoute<any>()
    const email = route.params?.email || ''

    const [code, setCode] = useState(['', '', '', '', '', ''])
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState('')

    const inputRefs = useRef<(TextInput | null)[]>([])

    useEffect(() => {
        // Foca no primeiro input ao montar
        inputRefs.current[0]?.focus()
    }, [])

    function handleChangeText(text: string, index: number) {
        // Apenas números
        if (text && !/^\d+$/.test(text)) return

        const newCode = [...code]
        newCode[index] = text

        setCode(newCode)

        // Move para o próximo input se digitou algo
        if (text && index < 5) {
            inputRefs.current[index + 1]?.focus()
        }
    }

    function handleKeyPress(e: any, index: number) {
        // Se apertar backspace e o campo estiver vazio, volta para o anterior
        if (e.nativeEvent.key === 'Backspace' && !code[index] && index > 0) {
            inputRefs.current[index - 1]?.focus()
        }
    }

    async function handleSubmit() {
        const fullCode = code.join('')
        
        if (fullCode.length !== 6) {
            setError('Digite o código completo')
            return
        }

        setError('')
        setLoading(true)

        try {
            // await api.verifyCode(email, fullCode)

            await new Promise(resolve => setTimeout(resolve, 1500))

            console.log('Código verificado:', fullCode)
            
            // Navega para a tela de redefinir senha
            navigation.navigate('ResetPassword', { email, code: fullCode })
        } catch (err) {
            setError('Código inválido. Tente novamente.')
        } finally {
            setLoading(false)
        }
    }

    async function handleResendCode() {
        try {
            // await api.forgotPassword(email)
            
            await new Promise(resolve => setTimeout(resolve, 1000))
            
            console.log('Código reenviado para:', email)
            setCode(['', '', '', '', '', ''])
            inputRefs.current[0]?.focus()
        } catch (err) {
            setError('Erro ao reenviar código.')
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
                    <ScrollView
                        contentContainerStyle={styles.scrollContent}
                        keyboardShouldPersistTaps="handled"
                    >
                        <TouchableOpacity
                            style={styles.backButton}
                            onPress={handleBack}
                        >
                            <Ionicons name="arrow-back" size={28} color="#4A4A4A" />
                        </TouchableOpacity>

                        <View style={styles.header}>
                            <Text style={styles.title}>
                                Verifique seu e-mail e digite o{'\n'}código recebido
                            </Text>
                        </View>

                        <View style={styles.codeContainer}>
                            {code.map((digit, index) => (
                                <TextInput
                                    key={index}
                                    ref={ref => {
                                        inputRefs.current[index] = ref
                                    }}
                                    style={styles.codeInput}
                                    value={digit}
                                    onChangeText={text => handleChangeText(text, index)}
                                    onKeyPress={e => handleKeyPress(e, index)}
                                    keyboardType="number-pad"
                                    maxLength={1}
                                    selectTextOnFocus
                                />
                            ))}
                        </View>

                        {error && <Text style={styles.error}>{error}</Text>}

                        <Button
                            title="Redefinir senha"
                            onPress={handleSubmit}
                            loading={loading}
                            style={styles.button}
                        />

                        <TouchableOpacity 
                            style={styles.resendButton}
                            onPress={handleResendCode}
                        >
                            <Text style={styles.resendText}>Reenviar código</Text>
                        </TouchableOpacity>

                        <View style={styles.logoContainer}>
                            <Image
                                source={require('../../../../assets/logo_completa.png')}
                                style={styles.logo}
                                resizeMode="contain"
                            />
                        </View>
                    </ScrollView>
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
    scrollContent: {
        flexGrow: 1,
        padding: 24,
    },
    backButton: {
        alignSelf: 'flex-start',
        marginBottom: 60,
    },
    header: {
        alignItems: 'center',
        marginBottom: 80,
    },
    title: {
        fontSize: 24,
        fontWeight: '600',
        color: '#4A4A4A',
        textAlign: 'center',
        lineHeight: 32,
    },
    codeContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        gap: 12,
        marginBottom: 40,
    },
    codeInput: {
        width: 50,
        height: 60,
        backgroundColor: '#D3D3D3',
        borderRadius: 12,
        fontSize: 24,
        fontWeight: '600',
        color: '#4A4A4A',
        textAlign: 'center',
    },
    error: {
        color: colors.error,
        textAlign: 'center',
        marginBottom: 20,
        fontSize: 14,
    },
    button: {
        marginBottom: 24,
    },
    resendButton: {
        alignItems: 'center',
        paddingVertical: 12,
    },
    resendText: {
        fontSize: 16,
        color: '#4A4A4A',
        textDecorationLine: 'underline',
    },
    logoContainer: {
        flex: 1,
        justifyContent: 'flex-end',
        alignItems: 'center',
        paddingBottom: 40,
        marginTop: 60,
    },
    logo: {
        width: 200,
        height: 140,
    },
})