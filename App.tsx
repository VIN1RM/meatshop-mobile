import { NavigationContainer } from '@react-navigation/native'
import RootNavigator from './src/shared/navigation/root_navigator'

export default function App() {
  return (
    <NavigationContainer>
      <RootNavigator />
    </NavigationContainer>
  )
}
