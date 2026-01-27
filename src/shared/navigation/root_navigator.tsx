import { createNativeStackNavigator } from '@react-navigation/native-stack'
import LoginScreen from '../../modules/auth/presentation/login_screen'
import AppNavigator from './app_navigator'

const Stack = createNativeStackNavigator()

export default function RootNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        animation: 'fade'
      }}
      initialRouteName="Login"
    >
      {/* Auth Screens */}
      <Stack.Screen name="Login" component={LoginScreen} />

      {/* Main App */}
      <Stack.Screen name="App" component={AppNavigator} />
    </Stack.Navigator>
  )
}