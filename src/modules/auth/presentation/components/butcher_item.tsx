import { View, Text, StyleSheet } from 'react-native'
import { Ionicons } from '@expo/vector-icons'

export function ButcherItem({ item }: any) {
  return (
    <View style={styles.row}>
      <Text style={styles.name}>{item.name}</Text>
      <View style={styles.stars}>
        {Array.from({ length: 5 }).map((_, i) => (
          <Ionicons
            key={i}
            name="star"
            size={16}
            color={i < item.rating ? '#FFD700' : '#DDD'}
          />
        ))}
      </View>
    </View>
  )
}

const styles = StyleSheet.create({
  row: {
    backgroundColor: '#EFEFEF',
    padding: 14,
    borderRadius: 14,
    marginBottom: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  name: {
    fontWeight: '600',
  },
  stars: {
    flexDirection: 'row',
  },
})
