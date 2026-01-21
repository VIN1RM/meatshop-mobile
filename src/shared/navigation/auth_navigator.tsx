import { createNativeStackNavigator } from '@react-navigation/native-stack'
import LoginScreen from '../../modules/auth/presentation/login_screen'
import WelcomeScreen from '../../modules/auth/presentation/welcome_screen'
import ForgotPasswordScreen from '../../modules/auth/presentation/forgot_password_screen'

const Stack = createNativeStackNavigator()

export default function AuthNavigator() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
      <Stack.Screen name="Welcome" component={WelcomeScreen} />
    </Stack.Navigator>
  )
}