import { createNativeStackNavigator } from '@react-navigation/native-stack'
import AuthNavigator from './auth_navigator'
import AppNavigator from './app_navigator'

export type RootStackParamList = {
  Auth: undefined
  App: undefined
}

const Stack = createNativeStackNavigator<RootStackParamList>()

export default function RootNavigator() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Auth" component={AuthNavigator} />
      <Stack.Screen name="App" component={AppNavigator} />
    </Stack.Navigator>
  )
}
