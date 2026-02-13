import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Image,
  TextInput,
  TouchableOpacity,
  Dimensions,
} from "react-native";
import { useState, useRef, useEffect } from "react";
import { useNavigation } from "@react-navigation/native";

const { width, height } = Dimensions.get("window");

const promotions = [
  {
    id: 1,
    name: "Picanha",
    price: "R$58,99",
    unit: "/kg",
    image: require("./assets/picanha.png"),
  },
  {
    id: 2,
    name: "Peito de frango",
    price: "R$9,99",
    unit: "/kg",
    image: require("./assets/peito.png"),
  },
  {
    id: 3,
    name: "Lombo suíno",
    price: "R$17,99",
    unit: "/kg",
    image: require("./assets/lombo.png"),
  },
];

const butchers = [
  {
    id: 1,
    name: "Master Carnes",
    rating: 5,
    logo: require("./assets/mastercarnes.png"),
  },
  {
    id: 2,
    name: "Frigorífico Goiás",
    rating: 4.5,
    logo: require("./assets/frigoias.png"),
  },
  { id: 3, name: "Bom Beef", rating: 4, logo: require("./assets/bombeef.png") },
];

export default function HomeScreen() {
  const navigation = useNavigation();
  const [currentSlide, setCurrentSlide] = useState(0);
  const scrollViewRef = useRef<ScrollView>(null);

  const infinitePromotions = Array(100).fill(promotions).flat();

  useEffect(() => {
    const initialPosition = Math.floor(infinitePromotions.length / 2);
    setTimeout(() => {
      scrollViewRef.current?.scrollTo({
        x: initialPosition * (width * 0.3 + 12),
        animated: false,
      });
      setCurrentSlide(initialPosition);
    }, 100);

    const interval = setInterval(() => {
      setCurrentSlide((prev) => {
        const next = prev + 1;
        scrollViewRef.current?.scrollTo({
          x: next * (width * 0.3 + 12),
          animated: true,
        });
        return next;
      });
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  const handleScroll = (e: any) => {
    const scrollX = e.nativeEvent.contentOffset.x;
    const cardWidth = width * 0.3 + 12;
    const slide = Math.round(scrollX / cardWidth);
    setCurrentSlide(slide);
  };

  const renderStars = (rating: number) => {
    const stars = [];
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 !== 0;

    for (let i = 0; i < fullStars; i++) {
      stars.push(
        <Text key={i} style={styles.star}>
          ⭐
        </Text>,
      );
    }
    if (hasHalfStar) {
      stars.push(
        <Text key="half" style={styles.starHalf}>
          ⭐
        </Text>,
      );
    }
    while (stars.length < 5) {
      stars.push(
        <Text key={`empty-${stars.length}`} style={styles.starEmpty}>
          ⭐
        </Text>,
      );
    }
    return stars;
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Image
          source={require("./assets/logo.png")}
          style={styles.logoIcon}
          resizeMode="contain"
        />
      </View>

      {/* Main Content */}
      <View style={styles.mainContent}>
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
            <TouchableOpacity
              style={styles.categoryButton}
              onPress={() => navigation.navigate("BeefCuts" as never)}
            >
              <Image
                source={require("./assets/vaca.png")}
                style={styles.categoryImage}
                resizeMode="contain"
              />
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.categoryButton}
              onPress={() => navigation.navigate("PorkCuts" as never)}
            >
              <Image
                source={require("./assets/porco.png")}
                style={styles.categoryImage}
                resizeMode="contain"
              />
            </TouchableOpacity>
            <TouchableOpacity style={styles.categoryButton}>
              <Image
                source={require("./assets/frango.png")}
                style={styles.categoryImage}
                resizeMode="contain"
              />
            </TouchableOpacity>
            <TouchableOpacity style={styles.categoryButton}>
              <Image
                source={require("./assets/peixe.png")}
                style={styles.categoryImage}
                resizeMode="contain"
              />
            </TouchableOpacity>
          </View>
        </View>

        {/* Promoções */}
        <View style={styles.promoSection}>
          <Text style={styles.promotionTitle}>PROMOÇÕES</Text>
          <ScrollView
            ref={scrollViewRef}
            horizontal
            showsHorizontalScrollIndicator={false}
            onMomentumScrollEnd={handleScroll}
            contentContainerStyle={styles.promoScrollContent}
            decelerationRate="fast"
            snapToInterval={width * 0.3 + 12}
            snapToAlignment="start"
          >
            {infinitePromotions.map((promo, index) => (
              <View key={`promo-${index}`} style={styles.promoCard}>
                <Image source={promo.image} style={styles.promoImage} />
                <View style={styles.promoInfo}>
                  <Text style={styles.promoName}>
                    {promo.name}{" "}
                    <Text style={styles.promoUnit}>{promo.unit}</Text>
                  </Text>
                  <Text style={styles.promoPrice}>{promo.price}</Text>
                </View>
              </View>
            ))}
          </ScrollView>
        </View>

        {/* Açougues */}
        <View style={styles.butchersSection}>
          <View style={styles.butchersSectionHeader}>
            <Text style={styles.sectionTitle}>AÇOUGUES</Text>
          </View>
          <View style={styles.butchersContainer}>
            {butchers.map((butcher) => (
              <TouchableOpacity
                key={butcher.id}
                style={styles.butcherCard}
                onPress={() => navigation.navigate("Butchers" as never)}
              >
                <Image source={butcher.logo} style={styles.butcherLogo} />
                <Text style={styles.butcherName}>{butcher.name}</Text>
                <View style={styles.ratingContainer}>
                  {renderStars(butcher.rating)}
                </View>
              </TouchableOpacity>
            ))}
            {/* Ver mais button */}
            <TouchableOpacity
              style={styles.viewMoreButton}
              onPress={() => navigation.navigate("Butchers" as never)}
            >
              <Text style={styles.viewMoreText}>Ver mais</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#FFFFFF",
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "#3D3D3D",
    paddingHorizontal: 16,
    paddingVertical: 10,
    paddingTop: 45,
  },
  logoIcon: {
    width: 35,
    height: 35,
  },
  mainContent: {
    flex: 1,
    backgroundColor: "#F5F5F5",
  },
  searchContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#E8E8E8",
    marginHorizontal: 12,
    marginTop: 10,
    marginBottom: 6,
    paddingHorizontal: 10,
    paddingVertical: 8,
    borderRadius: 6,
  },
  searchIcon: {
    fontSize: 16,
    marginRight: 6,
  },
  searchInput: {
    flex: 1,
    fontSize: 13,
    color: "#333",
  },
  section: {
    marginTop: 8,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: "#4A4A4A",
    marginLeft: 12,
    marginBottom: 8,
    letterSpacing: 0.3,
  },
  promotionTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: "#C8342B",
    marginLeft: 12,
    marginBottom: 8,
    letterSpacing: 0.3,
  },
  categoriesContainer: {
    flexDirection: "row",
    justifyContent: "space-around",
    paddingHorizontal: 12,
    marginBottom: 4,
  },
  categoryButton: {
    width: width * 0.21,
    height: width * 0.21,
    maxWidth: 75,
    maxHeight: 75,
    backgroundColor: "#E0E0E0",
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
  },
  categoryImage: {
    width: "65%",
    height: "65%",
  },
  promoSection: {
    marginTop: 10,
  },
  promoScrollContent: {
    paddingHorizontal: 6,
  },
  promoCard: {
    width: width * 0.3,
    marginHorizontal: 6,
    backgroundColor: "#FFF",
    borderRadius: 10,
    overflow: "hidden",
    elevation: 2,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  promoImage: {
    width: "100%",
    height: width * 0.3,
    resizeMode: "cover",
  },
  promoInfo: {
    padding: 6,
    alignItems: "center",
    backgroundColor: "#FFF",
  },
  promoName: {
    fontSize: 11,
    fontWeight: "600",
    color: "#333",
    marginBottom: 2,
    textAlign: "center",
  },
  promoUnit: {
    fontSize: 9,
    fontWeight: "400",
    color: "#666",
  },
  promoPrice: {
    fontSize: 13,
    fontWeight: "700",
    color: "#C8342B",
  },
  butchersSection: {
    marginTop: 10,
    flex: 1,
  },
  butchersSectionHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingRight: 12,
  },
  butchersContainer: {
    paddingHorizontal: 12,
  },
  butcherCard: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#FFF",
    marginBottom: 6,
    padding: 8,
    borderRadius: 6,
    elevation: 1,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 1,
  },
  butcherLogo: {
    width: 38,
    height: 38,
    borderRadius: 19,
    marginRight: 10,
  },
  butcherName: {
    flex: 1,
    fontSize: 14,
    fontWeight: "600",
    color: "#333",
  },
  ratingContainer: {
    flexDirection: "row",
  },
  viewMoreButton: {
    alignSelf: "flex-end",
    marginTop: 8,
    paddingVertical: 8,
    paddingHorizontal: 16,
  },
  viewMoreText: {
    fontSize: 14,
    fontWeight: "600",
    color: "#C8342B",
  },
  star: {
    fontSize: 15,
    marginLeft: 1,
  },
  starHalf: {
    fontSize: 15,
    marginLeft: 1,
    opacity: 0.6,
  },
  starEmpty: {
    fontSize: 15,
    marginLeft: 1,
    opacity: 0.2,
  },
});
