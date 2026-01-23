import { createNativeStackNavigator } from '@react-navigation/native-stack'
import LoginScreen from '../../modules/auth/presentation/login_screen'
import WelcomeScreen from '../../modules/auth/presentation/welcome_screen'
import ForgotPasswordScreen from '../../modules/auth/presentation/forgot_password_screen'
import VerifyCodeScreen from '../../modules/auth/presentation/verify_code_screen'
import ResetPasswordScreen from '../../modules/auth/presentation/reset_password_screen'

const Stack = createNativeStackNavigator()

export default function AuthNavigator() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
      <Stack.Screen name="VerifyCode" component={VerifyCodeScreen} />
      <Stack.Screen name="ResetPassword" component={ResetPasswordScreen} />
      <Stack.Screen name="Welcome" component={WelcomeScreen} />
    </Stack.Navigator>
  )
}