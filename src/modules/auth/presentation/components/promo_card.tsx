import { View, Text, Image, StyleSheet } from 'react-native'

export function PromoCard({ item }: any) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: item.image }} style={styles.image} />
      <Text style={styles.name}>{item.name} /kg</Text>
      <Text style={styles.price}>{item.price}</Text>
    </View>
  )
}

const styles = StyleSheet.create({
  card: {
    width: 180,
    marginRight: 16,
  },
  image: {
    width: '100%',
    height: 120,
    borderRadius: 16,
  },
  name: {
    marginTop: 6,
    color: '#333',
  },
  price: {
    color: '#C62828',
    fontWeight: '700',
  },
})
