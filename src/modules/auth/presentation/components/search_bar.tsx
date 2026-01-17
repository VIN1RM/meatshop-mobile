import { View, TextInput, StyleSheet } from 'react-native'
import { Ionicons } from '@expo/vector-icons'

export function SearchBar() {
  return (
    <View style={styles.container}>
      <Ionicons name="search" size={20} color="#AAA" />
      <TextInput
        placeholder="Procure por produto ou estabelecimento"
        style={styles.input}
        placeholderTextColor="#AAA"
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#3A3A3A',
    borderRadius: 14,
    paddingHorizontal: 14,
    height: 48,
    marginTop: 16,
  },
  input: {
    marginLeft: 10,
    color: '#FFF',
    flex: 1,
  },
})
