import { View, Text, StyleSheet } from 'react-native'
import { Ionicons } from '@expo/vector-icons'

export function CategoryItem({ icon }: { icon: string }) {
  return (
    <View style={styles.box}>
      <Ionicons name={icon as any} size={32} color="#555" />
    </View>
  )
}

const styles = StyleSheet.create({
  box: {
    width: 64,
    height: 64,
    backgroundColor: '#EAEAEA',
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
})
