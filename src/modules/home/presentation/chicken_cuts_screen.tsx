import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Image,
  TextInput,
  TouchableOpacity,
} from "react-native";
import { useNavigation } from "@react-navigation/native";

const chickenCuts = [
  {
    id: 1,
    name: "Asinha",
    price: "R$19,94",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
  {
    id: 2,
    name: "Coração",
    price: "R$38,59",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
  {
    id: 3,
    name: "Coxa",
    price: "R$15,98",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
  {
    id: 4,
    name: "Filé de peito",
    price: "R$17,49",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
  {
    id: 5,
    name: "Linguiça Toscana",
    price: "R$17,99",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
  {
    id: 6,
    name: "Moela",
    price: "R$18,99",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
  {
    id: 7,
    name: "Pé",
    price: "R$9,49",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
  {
    id: 8,
    name: "Sobrecoxa",
    price: "R$18,99",
    unit: "/KG",
    image: require("./assets/frango.png"),
  },
];

export default function ChickenCutsScreen() {
  const navigation = useNavigation();

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>

        <Image
          source={require("./assets/logo.png")}
          style={styles.logoIcon}
          resizeMode="contain"
        />
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Text style={styles.searchIcon}>🔍</Text>
        <TextInput
          style={styles.searchInput}
          placeholder="Procure por produto ou corte"
          placeholderTextColor="#999"
        />
      </View>

      {/* Title */}
      <View style={styles.titleContainer}>
        <Text style={styles.title}>CORTES DE FRANGO</Text>
      </View>

      {/* Chicken Cuts List */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {chickenCuts.map((cut) => (
          <TouchableOpacity key={cut.id} style={styles.cutCard}>
            <Image source={cut.image} style={styles.cutImage} />
            <View style={styles.cutInfo}>
              <Text style={styles.cutName}>{cut.name}</Text>
              <Text style={styles.cutPrice}>
                {cut.price}
                <Text style={styles.cutUnit}>{cut.unit}</Text>
              </Text>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Bottom Navigation */}
      <View style={styles.bottomNav}>
        <TouchableOpacity style={styles.navButton}>
          <Text style={styles.navIcon}>🏠</Text>
          <Text style={styles.navLabel}>Início</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navButton}>
          <Text style={styles.navIcon}>🛒</Text>
          <Text style={styles.navLabel}>Carrinho</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navButton}>
          <Text style={styles.navIcon}>📋</Text>
          <Text style={styles.navLabel}>Pedidos</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navButton}>
          <Text style={styles.navIcon}>👤</Text>
          <Text style={styles.navLabel}>Minha conta</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5F5F5",
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#3D3D3D",
    paddingHorizontal: 16,
    paddingVertical: 10,
    paddingTop: 45,
    position: "relative",
  },
  backButton: {
    position: "absolute",
    left: 16,
    top: 45,
    padding: 5,
    zIndex: 10,
  },
  backArrow: {
    fontSize: 28,
    color: "#FFFFFF",
    fontWeight: "300",
  },
  logoIcon: {
    width: 120,
    height: 35,
  },
  searchContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#E8E8E8",
    marginHorizontal: 16,
    marginTop: 12,
    marginBottom: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 6,
  },
  searchIcon: {
    fontSize: 16,
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 14,
    color: "#333",
  },
  titleContainer: {
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  title: {
    fontSize: 20,
    fontWeight: "700",
    color: "#C8342B",
    letterSpacing: 0.5,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 16,
    paddingBottom: 20,
  },
  cutCard: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#FFFFFF",
    marginBottom: 8,
    padding: 12,
    borderRadius: 8,
    elevation: 1,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
  },
  cutImage: {
    width: 70,
    height: 70,
    borderRadius: 8,
    marginRight: 14,
  },
  cutInfo: {
    flex: 1,
    justifyContent: "center",
  },
  cutName: {
    fontSize: 16,
    fontWeight: "600",
    color: "#333",
    marginBottom: 4,
  },
  cutPrice: {
    fontSize: 18,
    fontWeight: "700",
    color: "#333",
  },
  cutUnit: {
    fontSize: 13,
    fontWeight: "400",
    color: "#666",
  },
  bottomNav: {
    flexDirection: "row",
    backgroundColor: "#3D3D3D",
    borderTopColor: "#555",
    borderTopWidth: 1,
    paddingBottom: 12,
    paddingTop: 10,
    height: 70,
  },
  navButton: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  navIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  navLabel: {
    fontSize: 10,
    fontWeight: "600",
    color: "#AAA",
  },
});
