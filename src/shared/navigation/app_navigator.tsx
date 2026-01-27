import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import { Ionicons } from '@expo/vector-icons'
import HomeScreen from '../../modules/home/presentation/home_screen'
import AccountScreen from '../../modules/home/presentation/account_screen'
import ButcherScreen from '../../modules/home/presentation/butcher_screen'
import ChatsScreen from '../../modules/home/presentation/chats_screen'
import ChatConversationScreen from '../../modules/home/presentation/chat_conversation_screen'
import { View, Text } from 'react-native'

const Tab = createBottomTabNavigator()
const Stack = createNativeStackNavigator()

function CartScreen() {
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#F5F5F5' }}>
      <Text style={{ fontSize: 18, color: '#4A4A4A' }}>Carrinho</Text>
    </View>
  )
}

function OrdersScreen() {
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#F5F5F5' }}>
      <Text style={{ fontSize: 18, color: '#4A4A4A' }}>Pedidos</Text>
    </View>
  )
}

function HomeStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="HomeMain" component={HomeScreen} />
      <Stack.Screen name="Butchers" component={ButcherScreen} />
    </Stack.Navigator>
  )
}

function AccountStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="AccountMain" component={AccountScreen} />
      <Stack.Screen name="Chats" component={ChatsScreen} />
      <Stack.Screen name="ChatConversation" component={ChatConversationScreen} />
    </Stack.Navigator>
  )
}

export default function AppNavigator() {
  return (
    <Tab.Navigator 
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: keyof typeof Ionicons.glyphMap = 'home'

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline'
          } else if (route.name === 'Cart') {
            iconName = focused ? 'cart' : 'cart-outline'
          } else if (route.name === 'Orders') {
            iconName = focused ? 'receipt' : 'receipt-outline'
          } else if (route.name === 'Account') {
            iconName = focused ? 'person' : 'person-outline'
          }

          return <Ionicons name={iconName} size={28} color={color} />
        },
        tabBarActiveTintColor: '#FFF',
        tabBarInactiveTintColor: '#AAA',
        tabBarStyle: {
          backgroundColor: '#3D3D3D',
          borderTopColor: '#555',
          borderTopWidth: 1,
          paddingBottom: 12,
          paddingTop: 10,
          height: 70,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '600',
          marginTop: 4,
        },
        tabBarIconStyle: {
          marginTop: 4,
        },
      })}
    >
      <Tab.Screen 
        name="Home" 
        component={HomeStack}
        options={{ tabBarLabel: 'Início' }}
      />
      <Tab.Screen 
        name="Cart" 
        component={CartScreen}
        options={{ tabBarLabel: 'Carrinho' }}
      />
      <Tab.Screen 
        name="Orders" 
        component={OrdersScreen}
        options={{ tabBarLabel: 'Pedidos' }}
      />
      <Tab.Screen 
        name="Account" 
        component={AccountStack}
        options={{ tabBarLabel: 'Minha conta' }}
      />
    </Tab.Navigator>
  )
}