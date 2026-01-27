import { View, Text, StyleSheet, ScrollView, Image, TextInput, TouchableOpacity, FlatList } from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useNavigation } from '@react-navigation/native'

interface Chat {
  id: string
  name: string
  lastMessage: string
  time: string
  unreadCount?: number
  image: any
}

export default function ChatsScreen() {
  const navigation = useNavigation()

  const chats: Chat[] = [
    {
      id: '1',
      name: 'Master Carnes',
      lastMessage: 'Seu pedido está a caminho!',
      time: 'Há 1 minuto',
      image: require('./assets/logo.png')
    },
    {
      id: '2',
      name: 'Frigorífico Goiás',
      lastMessage: 'Obrigado pela preferência',
      time: 'Hoje às 20:15',
      unreadCount: 2,
      image: require('./assets/logo.png')
    },
    {
      id: '3',
      name: 'Mendes',
      lastMessage: 'Pedido entregue com sucesso',
      time: '06/12/2023',
      image: require('./assets/logo.png')
    },
    {
      id: '4',
      name: 'Master Carnes',
      lastMessage: 'Temos promoções especiais',
      time: '22/11/2023',
      image: require('./assets/logo.png')
    },
    {
      id: '5',
      name: 'Master Carnes',
      lastMessage: 'Avalie sua última compra',
      time: '08/11/2023',
      image: require('./assets/logo.png')
    },
  ]

  const renderChatItem = ({ item }: { item: Chat }) => (
    <TouchableOpacity 
      style={styles.chatItem}
      onPress={() => {
        // @ts-ignore
        navigation.navigate('ChatConversation', { establishmentName: item.name })
      }}
    >
      <View style={styles.avatarContainer}>
        <View style={styles.avatar}>
          <Ionicons name="business" size={32} color="#C8342B" />
        </View>
      </View>

      <View style={styles.chatContent}>
        <View style={styles.chatHeader}>
          <Text style={styles.chatName}>{item.name}</Text>
          <Text style={styles.chatTime}>{item.time}</Text>
        </View>
        <View style={styles.messageRow}>
          <Text style={styles.lastMessage} numberOfLines={1}>
            {item.lastMessage}
          </Text>
          {item.unreadCount && (
            <View style={styles.unreadBadge}>
              <Text style={styles.unreadCount}>{item.unreadCount}</Text>
            </View>
          )}
        </View>
      </View>
    </TouchableOpacity>
  )

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Ionicons name="arrow-back" size={28} color="#FFF" />
        </TouchableOpacity>
        
        <Image
          source={require('./assets/logo.png')}
          style={styles.logo}
          resizeMode="contain"
        />
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Ionicons name="search" size={20} color="#999" />
        <TextInput
          style={styles.searchInput}
          placeholder="Procure por produto ou estabelecimento"
          placeholderTextColor="#999"
        />
      </View>

      {/* Title */}
      <Text style={styles.pageTitle}>CHATS</Text>

      {/* Chats List */}
      <FlatList
        data={chats}
        renderItem={renderChatItem}
        keyExtractor={item => item.id}
        style={styles.chatsList}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.chatsContent}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  header: {
    backgroundColor: '#3D3D3D',
    paddingHorizontal: 16,
    paddingVertical: 12,
    paddingTop: 45,
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    marginRight: 16,
  },
  logo: {
    width: 180,
    height: 50,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E8E8E8',
    marginHorizontal: 16,
    marginTop: 12,
    marginBottom: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 6,
  },
  searchInput: {
    flex: 1,
    fontSize: 13,
    color: '#333',
    marginLeft: 8,
  },
  pageTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#C8342B',
    marginLeft: 16,
    marginTop: 16,
    marginBottom: 12,
    letterSpacing: 0.5,
  },
  chatsList: {
    flex: 1,
  },
  chatsContent: {
    paddingBottom: 20,
  },
  chatItem: {
    flexDirection: 'row',
    backgroundColor: '#FFF',
    marginHorizontal: 16,
    marginBottom: 2,
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E8E8E8',
  },
  avatarContainer: {
    marginRight: 12,
  },
  avatar: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#F5F5F5',
    alignItems: 'center',
    justifyContent: 'center',
  },
  chatContent: {
    flex: 1,
    justifyContent: 'center',
  },
  chatHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  chatName: {
    fontSize: 16,
    fontWeight: '700',
    color: '#333',
  },
  chatTime: {
    fontSize: 12,
    color: '#999',
  },
  messageRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  lastMessage: {
    fontSize: 14,
    color: '#666',
    flex: 1,
  },
  unreadBadge: {
    backgroundColor: '#C8342B',
    borderRadius: 10,
    minWidth: 20,
    height: 20,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 6,
    marginLeft: 8,
  },
  unreadCount: {
    fontSize: 12,
    color: '#FFF',
    fontWeight: '700',
  },
})