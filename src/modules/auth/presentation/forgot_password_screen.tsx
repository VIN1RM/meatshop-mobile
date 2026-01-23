import { useState } from 'react'
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
} from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useNavigation } from '@react-navigation/native'
import Button from '../../../shared/components/button'
import Input from '../../../shared/components/input'
import { colors } from '../../../shared/theme/colors'

export default function ForgotPasswordScreen() {
    const navigation = useNavigation<any>()
    const [email, setEmail] = useState('')
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState('')

    async function handleSubmit() {
        setError('')
        setLoading(true)

        try {
            // await api.forgotPassword(email)

            await new Promise(resolve => setTimeout(resolve, 1500))

            console.log('Código enviado para:', email)
            
            // Navega para a tela de verificação de código
            navigation.navigate('VerifyCode', { email })
        } catch (err) {
            setError('Erro ao enviar código. Tente novamente.')
        } finally {
            setLoading(false)
        }
    }

    function handleBackToLogin() {
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
                            onPress={handleBackToLogin}
                        >
                            <Ionicons name="arrow-back" size={28} color="#4A4A4A" />
                        </TouchableOpacity>

                        <View style={styles.header}>
                            <Text style={styles.opsText}>OPS!</Text>
                            <Text style={styles.title}>Parece que você{'\n'}esqueceu a sua senha.</Text>
                        </View>

                        <View style={styles.formContainer}>
                            <Text style={styles.label}>Digite seu e-mail</Text>

                            <Input
                                value={email}
                                onChangeText={setEmail}
                                keyboardType="email-address"
                                placeholder="seu@email.com"
                                autoCapitalize="none"
                            />

                            {error && <Text style={styles.error}>{error}</Text>}

                            <Button
                                title="Enviar código de verificação"
                                onPress={handleSubmit}
                                loading={loading}
                                style={styles.button}
                            />
                        </View>

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
        marginBottom: 40,
    },
    header: {
        alignItems: 'center',
        marginBottom: 60,
    },
    opsText: {
        fontSize: 48,
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
        marginBottom: 60,
    },
    label: {
        fontSize: 16,
        color: '#4A4A4A',
        marginBottom: 12,
    },
    error: {
        color: colors.error,
        marginTop: 10,
        fontSize: 14,
    },
    button: {
        marginTop: 24,
    },
    logoContainer: {
        flex: 1,
        justifyContent: 'flex-end',
        alignItems: 'center',
        paddingBottom: 40,
    },
    logo: {
        width: 200,
        height: 140,
    },
})