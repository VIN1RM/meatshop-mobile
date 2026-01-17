import { View, Text, StyleSheet, ScrollView, Image, TextInput, TouchableOpacity, Dimensions } from 'react-native'
import { useState, useRef, useEffect } from 'react'

const { width } = Dimensions.get('window')

const promotions = [
  {
    id: 1,
    name: 'Picanha',
    price: 'R$58,99',
    unit: '/kg',
    image: require('./assets/picanha.png')
  },
  {
    id: 2,
    name: 'Peito de frango',
    price: 'R$9,99',
    unit: '/kg',
    image: require('./assets/peito.png')
  },
  {
    id: 3,
    name: 'Lombo suíno',
    price: 'R$17,99',
    unit: '/kg',
    image: require('./assets/lombo.png')
  }
]

const butchers = [
  { id: 1, name: 'Master Carnes', rating: 5, logo: require('./assets/logo.png') },
  { id: 2, name: 'Frigorífico Goiás', rating: 4.5, logo: require('./assets/logo.png') },
  { id: 3, name: 'Bom Beef', rating: 4, logo: require('./assets/logo.png') }
]

export default function HomeScreen() {
  const [currentSlide, setCurrentSlide] = useState(0)
  const scrollViewRef = useRef<ScrollView>(null)

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide((prev) => {
        const next = (prev + 1) % promotions.length
        scrollViewRef.current?.scrollTo({
          x: next * (width - 48),
          animated: true
        })
        return next
      })
    }, 3000)

    return () => clearInterval(interval)
  }, [])

  const renderStars = (rating: number) => {
    const stars = []
    const fullStars = Math.floor(rating)
    const hasHalfStar = rating % 1 !== 0

    for (let i = 0; i < fullStars; i++) {
      stars.push(<Text key={i} style={styles.star}>⭐</Text>)
    }
    if (hasHalfStar) {
      stars.push(<Text key="half" style={styles.starHalf}>⭐</Text>)
    }
    while (stars.length < 5) {
      stars.push(<Text key={`empty-${stars.length}`} style={styles.starEmpty}>⭐</Text>)
    }
    return stars
  }

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Image
          source={require('./assets/logo-preta.png')}
          style={styles.logoIcon}
          resizeMode="contain"
        />
        <TouchableOpacity style={styles.helpButton}>
          <Text style={styles.helpIcon}>?</Text>
        </TouchableOpacity>
      </View>

      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Search Bar */}
        <View style={styles.searchContainer}>
          <Text style={styles.searchIcon}>🔍</Text>
          <TextInput
            style={styles.searchInput}
            placeholder="Procure por produto ou estabelecimento"
            placeholderTextColor="#999"
          />
        </View>

        {/* Categorias - CORTES */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>CORTES</Text>
          <View style={styles.categoriesContainer}>
            <TouchableOpacity style={styles.categoryButton}>
              <Text style={styles.categoryIcon}>🐄</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.categoryButton}>
              <Text style={styles.categoryIcon}>🐷</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.categoryButton}>
              <Text style={styles.categoryIcon}>🐔</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.categoryButton}>
              <Text style={styles.categoryIcon}>🐟</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Promoções */}
        <View style={styles.section}>
          <Text style={styles.promotionTitle}>PROMOÇÕES</Text>
          <ScrollView
            ref={scrollViewRef}
            horizontal
            pagingEnabled
            showsHorizontalScrollIndicator={false}
            onMomentumScrollEnd={(e) => {
              const slide = Math.round(e.nativeEvent.contentOffset.x / (width - 48))
              setCurrentSlide(slide)
            }}
          >
            {promotions.map((promo) => (
              <View key={promo.id} style={styles.promoCard}>
                <Image source={promo.image} style={styles.promoImage} />
                <View style={styles.promoInfo}>
                  <Text style={styles.promoName}>{promo.name} <Text style={styles.promoUnit}>{promo.unit}</Text></Text>
                  <Text style={styles.promoPrice}>{promo.price}</Text>
                </View>
              </View>
            ))}
          </ScrollView>

          {/* Pagination Dots */}
          <View style={styles.pagination}>
            {promotions.map((_, index) => (
              <View
                key={index}
                style={[
                  styles.paginationDot,
                  currentSlide === index && styles.paginationDotActive
                ]}
              />
            ))}
          </View>
        </View>

        {/* Açougues */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>AÇOUGUES</Text>
          {butchers.map((butcher) => (
            <TouchableOpacity key={butcher.id} style={styles.butcherCard}>
              <Image source={butcher.logo} style={styles.butcherLogo} />
              <Text style={styles.butcherName}>{butcher.name}</Text>
              <View style={styles.ratingContainer}>
                {renderStars(butcher.rating)}
              </View>
            </TouchableOpacity>
          ))}
          <TouchableOpacity>
            <Text style={styles.seeMore}>Ver mais...</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Bottom Navigation */}
      <View style={styles.bottomNav}>
        <TouchableOpacity style={styles.navItem}>
          <Text style={styles.navIcon}>🏠</Text>
          <Text style={styles.navTextActive}>Início</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navItem}>
          <Text style={styles.navIcon}>🛒</Text>
          <Text style={styles.navText}>Carrinho</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navItem}>
          <Text style={styles.navIcon}>📋</Text>
          <Text style={styles.navText}>Pedidos</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navItem}>
          <Text style={styles.navIcon}>👤</Text>
          <Text style={styles.navText}>Minha conta</Text>
        </TouchableOpacity>
      </View>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#3D3D3D',
    paddingHorizontal: 20,
    paddingVertical: 16,
    paddingTop: 50,
  },
  logoIcon: {
    width: 50,
    height: 50,
  },
  logoText: {
    flex: 1,
    fontSize: 28,
    fontWeight: '700',
    color: '#FFF',
    marginLeft: -10,
  },
  helpButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    borderWidth: 2,
    borderColor: '#FFF',
    alignItems: 'center',
    justifyContent: 'center',
  },
  helpIcon: {
    fontSize: 20,
    color: '#FFF',
    fontWeight: '700',
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E8E8E8',
    marginHorizontal: 24,
    marginTop: 20,
    marginBottom: 10,
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderRadius: 8,
  },
  searchIcon: {
    fontSize: 20,
    marginRight: 10,
  },
  searchInput: {
    flex: 1,
    fontSize: 15,
    color: '#333',
  },
  section: {
    marginTop: 24,
  },
  sectionTitle: {
    fontSize: 26,
    fontWeight: '700',
    color: '#4A4A4A',
    marginLeft: 24,
    marginBottom: 16,
    letterSpacing: 1,
  },
  promotionTitle: {
    fontSize: 26,
    fontWeight: '700',
    color: '#C8342B',
    marginLeft: 24,
    marginBottom: 16,
    letterSpacing: 1,
  },
  categoriesContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingHorizontal: 24,
  },
  categoryButton: {
    width: 80,
    height: 80,
    backgroundColor: '#E0E0E0',
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  categoryIcon: {
    fontSize: 42,
  },
  promoCard: {
    width: width - 48,
    marginHorizontal: 24,
    backgroundColor: '#FFF',
    borderRadius: 12,
    overflow: 'hidden',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  promoImage: {
    width: '100%',
    height: 200,
    resizeMode: 'cover',
  },
  promoInfo: {
    padding: 16,
    alignItems: 'center',
  },
  promoName: {
    fontSize: 20,
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  promoUnit: {
    fontSize: 16,
    fontWeight: '400',
    color: '#666',
  },
  promoPrice: {
    fontSize: 24,
    fontWeight: '700',
    color: '#C8342B',
  },
  pagination: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 12,
  },
  paginationDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#CCC',
    marginHorizontal: 4,
  },
  paginationDotActive: {
    backgroundColor: '#C8342B',
    width: 24,
  },
  butcherCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF',
    marginHorizontal: 24,
    marginBottom: 12,
    padding: 16,
    borderRadius: 8,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  butcherLogo: {
    width: 50,
    height: 50,
    borderRadius: 25,
    marginRight: 16,
  },
  butcherName: {
    flex: 1,
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },
  ratingContainer: {
    flexDirection: 'row',
  },
  star: {
    fontSize: 20,
    marginLeft: 2,
  },
  starHalf: {
    fontSize: 20,
    marginLeft: 2,
    opacity: 0.6,
  },
  starEmpty: {
    fontSize: 20,
    marginLeft: 2,
    opacity: 0.2,
  },
  seeMore: {
    fontSize: 16,
    color: '#C8342B',
    textAlign: 'right',
    marginRight: 24,
    marginTop: 8,
    fontWeight: '600',
  },
  bottomNav: {
    flexDirection: 'row',
    backgroundColor: '#3D3D3D',
    paddingVertical: 12,
    paddingBottom: 24,
    borderTopWidth: 1,
    borderTopColor: '#555',
  },
  navItem: {
    flex: 1,
    alignItems: 'center',
  },
  navIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  navText: {
    fontSize: 12,
    color: '#AAA',
  },
  navTextActive: {
    fontSize: 12,
    color: '#FFF',
    fontWeight: '600',
  },
})