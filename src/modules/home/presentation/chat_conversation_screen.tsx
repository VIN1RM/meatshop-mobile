import { View, Text, StyleSheet, TextInput, TouchableOpacity, FlatList, KeyboardAvoidingView, Platform } from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useNavigation, useRoute } from '@react-navigation/native'
import { useState } from 'react'

interface Message {
  id: string
  text: string
  isFromUser: boolean
  timestamp: string
}

export default function ChatConversationScreen() {
  const navigation = useNavigation()
  const route = useRoute()
  const { establishmentName } = route.params as { establishmentName: string }

  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: 'Olá! Bem-vindo ao Frigorífico Goiás. Como podemos ajudá-lo hoje?',
      isFromUser: false,
      timestamp: '10:30'
    },
    {
      id: '2',
      text: 'Olá! Gostaria de saber sobre promoções de picanha.',
      isFromUser: true,
      timestamp: '10:32'
    },
    {
      id: '3',
      text: 'Temos uma promoção especial de picanha! Picanha bovina premium por R$ 39,90/kg. Válida até domingo.',
      isFromUser: false,
      timestamp: '10:33'
    },
    {
      id: '4',
      text: 'Perfeito! Vou fazer um pedido.',
      isFromUser: true,
      timestamp: '10:35'
    },
  ])

  const [messageText, setMessageText] = useState('')

  const sendMessage = () => {
    if (messageText.trim()) {
      const newMessage: Message = {
        id: Date.now().toString(),
        text: messageText,
        isFromUser: true,
        timestamp: new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
      }
      setMessages([...messages, newMessage])
      setMessageText('')
    }
  }

  const renderMessage = ({ item }: { item: Message }) => (
    <View style={[
      styles.messageContainer,
      item.isFromUser ? styles.userMessageContainer : styles.establishmentMessageContainer
    ]}>
      <View style={[
        styles.messageBubble,
        item.isFromUser ? styles.userMessage : styles.establishmentMessage
      ]}>
        <Text style={[
          styles.messageText,
          item.isFromUser ? styles.userMessageText : styles.establishmentMessageText
        ]}>
          {item.text}
        </Text>
      </View>
    </View>
  )

  return (
    <KeyboardAvoidingView 
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 0}
    >
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Ionicons name="arrow-back" size={28} color="#FFF" />
        </TouchableOpacity>
        
        <View style={styles.headerCenter}>
          <Text style={styles.headerTitle}>Mealshop</Text>
        </View>

        <View style={styles.headerRight}>
          <View style={styles.logoIcon}>
            <Ionicons name="nutrition" size={24} color="#FFF" />
          </View>
        </View>
      </View>

      {/* Establishment Info */}
      <View style={styles.establishmentInfo}>
        <View style={styles.establishmentAvatar}>
          <Ionicons name="business" size={40} color="#C8342B" />
        </View>
        <Text style={styles.establishmentName}>{establishmentName}</Text>
      </View>

      {/* Messages List */}
      <FlatList
        data={messages}
        renderItem={renderMessage}
        keyExtractor={item => item.id}
        style={styles.messagesList}
        contentContainerStyle={styles.messagesContent}
        showsVerticalScrollIndicator={false}
      />

      {/* Finalizar atendimento button */}
      <TouchableOpacity style={styles.finishButton}>
        <Text style={styles.finishButtonText}>Finalizar atendimento</Text>
      </TouchableOpacity>

      {/* Input Area */}
      <View style={styles.inputContainer}>
        <TouchableOpacity style={styles.attachButton}>
          <Ionicons name="attach" size={28} color="#C8342B" />
        </TouchableOpacity>

        <TextInput
          style={styles.input}
          placeholder="Digite sua mensagem..."
          placeholderTextColor="#999"
          value={messageText}
          onChangeText={setMessageText}
          multiline
        />

        <TouchableOpacity 
          style={styles.sendButton}
          onPress={sendMessage}
        >
          <Ionicons name="send" size={24} color="#C8342B" />
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
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
    justifyContent: 'space-between',
  },
  backButton: {
    width: 40,
  },
  headerCenter: {
    flex: 1,
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FFF',
    letterSpacing: 0.5,
  },
  headerRight: {
    width: 40,
    alignItems: 'flex-end',
  },
  logoIcon: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  establishmentInfo: {
    backgroundColor: '#E8E8E8',
    paddingVertical: 16,
    alignItems: 'center',
  },
  establishmentAvatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#FFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 8,
    borderWidth: 2,
    borderColor: '#C8342B',
  },
  establishmentName: {
    fontSize: 20,
    fontWeight: '700',
    color: '#333',
  },
  messagesList: {
    flex: 1,
  },
  messagesContent: {
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  messageContainer: {
    marginBottom: 12,
  },
  userMessageContainer: {
    alignItems: 'flex-end',
  },
  establishmentMessageContainer: {
    alignItems: 'flex-start',
  },
  messageBubble: {
    maxWidth: '75%',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderRadius: 20,
  },
  userMessage: {
    backgroundColor: '#C8342B',
    borderBottomRightRadius: 4,
  },
  establishmentMessage: {
    backgroundColor: '#E8E8E8',
    borderBottomLeftRadius: 4,
  },
  messageText: {
    fontSize: 15,
    lineHeight: 20,
  },
  userMessageText: {
    color: '#FFF',
  },
  establishmentMessageText: {
    color: '#333',
  },
  finishButton: {
    backgroundColor: '#E8E8E8',
    paddingVertical: 12,
    paddingHorizontal: 20,
    marginHorizontal: 16,
    marginBottom: 8,
    borderRadius: 8,
    alignItems: 'flex-end',
  },
  finishButtonText: {
    fontSize: 14,
    color: '#666',
    textDecorationLine: 'underline',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E8E8E8',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderTopWidth: 1,
    borderTopColor: '#DDD',
  },
  attachButton: {
    padding: 8,
  },
  input: {
    flex: 1,
    backgroundColor: '#FFF',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 10,
    fontSize: 15,
    color: '#333',
    maxHeight: 100,
    marginHorizontal: 8,
  },
  sendButton: {
    padding: 8,
  },
})