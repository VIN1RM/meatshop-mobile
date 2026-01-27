import { createNativeStackNavigator } from '@react-navigation/native-stack'
import AuthNavigator from './auth_navigator'
import AppNavigator from './app_navigator'

const Stack = createNativeStackNavigator()

export default function RootNavigator() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      {/* Auth flow */}
      <Stack.Screen name="Auth" component={AuthNavigator} />

      {/* App flow */}
      <Stack.Screen name="App" component={AppNavigator} />
    </Stack.Navigator>
  )
}
