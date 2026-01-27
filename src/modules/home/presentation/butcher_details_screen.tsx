import { View, Text, StyleSheet, ScrollView, Image, TextInput, TouchableOpacity, Dimensions } from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { useNavigation, useRoute } from '@react-navigation/native'

const { width } = Dimensions.get('window')

interface Product {
  id: number
  name: string
  price: string
  image: any
}

const products: Product[] = [
  {
    id: 1,
    name: 'Corte Peixe',
    price: 'R$75,00',
    image: require('./assets/peixecarne.jpg')
  },
  {
    id: 2,
    name: 'Lombo suíno',
    price: 'R$17,99',
    image: require('./assets/lombo.png')
  },
  {
    id: 3,
    name: 'Costela bovina',
    price: 'R$31,49',
    image: require('./assets/picanha.png')
  },
  {
    id: 4,
    name: 'Coxa de frango',
    price: 'R$9,99',
    image: require('./assets/peito.png')
  }
]

export default function ButcherDetailsScreen() {
  const navigation = useNavigation()
  const route = useRoute()
  const { butcherName, butcherRating, butcherLogo } = route.params as { 
    butcherName: string
    butcherRating: number
    butcherLogo: any
  }

  const renderStars = (rating: number) => {
    const stars = []
    const fullStars = Math.floor(rating)
    const hasHalfStar = rating % 1 !== 0

    for (let i = 0; i < fullStars; i++) {
      stars.push(
        <Ionicons key={i} name="star" size={32} color="#FFD700" />
      )
    }
    if (hasHalfStar) {
      stars.push(
        <Ionicons key="half" name="star-half" size={32} color="#FFD700" />
      )
    }
    while (stars.length < 5) {
      stars.push(
        <Ionicons key={`empty-${stars.length}`} name="star-outline" size={32} color="#E0E0E0" />
      )
    }
    return stars
  }

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

        <View style={styles.headerCenter}>
          <Image
            source={require('./assets/logo.png')}
            style={styles.logo}
            resizeMode="contain"
          />
        </View>
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Ionicons name="search" size={20} color="#FFF" />
        <TextInput
          style={styles.searchInput}
          placeholder="Procure por produto ou corte"
          placeholderTextColor="#CCC"
        />
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Banner Image */}
        <View style={styles.bannerContainer}>
          <Image
            source={require('./assets/mastercarnes.png')}
            style={styles.bannerImage}
            resizeMode="cover"
          />
        </View>

        {/* Butcher Info Card */}
        <View style={styles.infoCard}>
          <View style={styles.logoContainer}>
            <Image
              source={butcherLogo}
              style={styles.butcherLogo}
              resizeMode="contain"
            />
          </View>

          <Text style={styles.butcherName}>{butcherName}</Text>
          <Text style={styles.slogan}>Aqui você é o cheff!!</Text>

          <View style={styles.ratingContainer}>
            {renderStars(butcherRating)}
          </View>

          <View style={styles.priceLevel}>
            <Text style={styles.priceLevelActive}>$$$</Text>
          </View>

          <View style={styles.addressContainer}>
            <Ionicons name="location" size={16} color="#666" />
            <Text style={styles.addressText}>
              Avenida Universitária, 1522 - Vila Santa Isabel, Anápolis - GO
            </Text>
          </View>
        </View>

        {/* Promotions Section */}
        <View style={styles.promotionsSection}>
          <Text style={styles.sectionTitle}>Promoções</Text>

          <View style={styles.productsGrid}>
            {products.map((product) => (
              <TouchableOpacity key={product.id} style={styles.productCard}>
                <Image source={product.image} style={styles.productImage} />
                <View style={styles.productInfo}>
                  <Text style={styles.productName}>{product.name}</Text>
                  <Text style={styles.productPrice}>
                    {product.price}<Text style={styles.productUnit}>/kg</Text>
                  </Text>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </ScrollView>
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
    width: 40,
  },
  headerCenter: {
    flex: 1,
    alignItems: 'center',
    marginRight: 40,
  },
  logo: {
    width: 180,
    height: 40,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#4A4A4A',
    marginHorizontal: 16,
    marginTop: 12,
    marginBottom: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 6,
    gap: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 14,
    color: '#FFF',
  },
  content: {
    flex: 1,
  },
  bannerContainer: {
    width: '100%',
    height: 200,
    backgroundColor: '#E0E0E0',
  },
  bannerImage: {
    width: '100%',
    height: '100%',
  },
  infoCard: {
    backgroundColor: '#FFF',
    marginHorizontal: 16,
    marginTop: -60,
    borderRadius: 12,
    padding: 20,
    alignItems: 'center',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  logoContainer: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#FFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: -70,
    borderWidth: 4,
    borderColor: '#FFF',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  butcherLogo: {
    width: 100,
    height: 100,
    borderRadius: 50,
  },
  butcherName: {
    fontSize: 24,
    fontWeight: '700',
    color: '#333',
    marginTop: 12,
    textAlign: 'center',
  },
  slogan: {
    fontSize: 16,
    color: '#666',
    marginTop: 4,
    marginBottom: 12,
    textAlign: 'center',
  },
  ratingContainer: {
    flexDirection: 'row',
    gap: 4,
    marginBottom: 8,
  },
  priceLevel: {
    marginBottom: 12,
  },
  priceLevelActive: {
    fontSize: 24,
    fontWeight: '700',
    color: '#666',
    letterSpacing: 2,
  },
  addressContainer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 6,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    width: '100%',
  },
  addressText: {
    flex: 1,
    fontSize: 13,
    color: '#666',
    lineHeight: 18,
  },
  promotionsSection: {
    marginTop: 20,
    paddingHorizontal: 16,
    paddingBottom: 20,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#C8342B',
    marginBottom: 16,
    letterSpacing: 0.5,
  },
  productsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: 12,
  },
  productCard: {
    width: (width - 44) / 2,
    backgroundColor: '#FFF',
    borderRadius: 12,
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  productImage: {
    width: '100%',
    height: 140,
    resizeMode: 'cover',
  },
  productInfo: {
    padding: 12,
  },
  productName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 6,
  },
  productPrice: {
    fontSize: 18,
    fontWeight: '700',
    color: '#C8342B',
  },
  productUnit: {
    fontSize: 12,
    fontWeight: '400',
    color: '#666',
  },
})