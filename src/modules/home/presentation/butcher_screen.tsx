import { View, Text, StyleSheet, ScrollView, Image, TextInput, TouchableOpacity, Modal, Dimensions } from 'react-native'
import { useState } from 'react'
import { Ionicons } from '@expo/vector-icons'
import { useNavigation } from '@react-navigation/native'

const { width } = Dimensions.get('window')

type SortType = 'rating-desc' | 'rating-asc' | 'name-asc' | 'name-desc' | 'price-asc' | 'price-desc'

interface Butcher {
    id: number
    name: string
    rating: number
    priceLevel: number // 1 = $, 2 = $$, 3 = $$$
    logo: any
}

const butchersData: Butcher[] = [
    {
        id: 1,
        name: 'Master Carnes',
        rating: 5.0,
        priceLevel: 2,
        logo: require('./assets/mastercarnes.png')
    },
    {
        id: 2,
        name: 'Frigorífico Goiás',
        rating: 4.5,
        priceLevel: 3,
        logo: require('./assets/frigoias.png')
    },
    {
        id: 3,
        name: 'Bom Beef',
        rating: 4.0,
        priceLevel: 3,
        logo: require('./assets/bombeef.png')
    },
    {
        id: 4,
        name: 'Bifão Carnes',
        rating: 4.0,
        priceLevel: 3,
        logo: require('./assets/bifao.png')
    },
    {
        id: 5,
        name: 'Mendes',
        rating: 4.0,
        priceLevel: 2,
        logo: require('./assets/mendes.png')
    },
    {
        id: 6,
        name: 'Disk Suíno',
        rating: 3.5,
        priceLevel: 2,
        logo: require('./assets/disksuino.png')
    },
    {
        id: 7,
        name: 'Rio Branco',
        rating: 3.5,
        priceLevel: 2,
        logo: require('./assets/riobranco.png')
    },
    {
        id: 8,
        name: 'Casa de Carne Marcos',
        rating: 3.0,
        priceLevel: 1,
        logo: require('./assets/casamarcos.png')
    },
    {
        id: 9,
        name: 'Filé de Ouro',
        rating: 3.0,
        priceLevel: 1,
        logo: require('./assets/fileouro.png')
    },
    {
        id: 10,
        name: 'Peixaria do Ronaldão',
        rating: 2.0,
        priceLevel: 1,
        logo: require('./assets/peixaria.png')
    }
]

export default function ButcherScreen() {
    const navigation = useNavigation()
    const [sortType, setSortType] = useState<SortType>('rating-desc')
    const [showSortModal, setShowSortModal] = useState(false)
    const [searchQuery, setSearchQuery] = useState('')

    const getSortedButchers = () => {
        let filtered = butchersData.filter(butcher =>
            butcher.name.toLowerCase().includes(searchQuery.toLowerCase())
        )

        switch (sortType) {
            case 'rating-desc':
                return filtered.sort((a, b) => b.rating - a.rating)
            case 'rating-asc':
                return filtered.sort((a, b) => a.rating - b.rating)
            case 'name-asc':
                return filtered.sort((a, b) => a.name.localeCompare(b.name))
            case 'name-desc':
                return filtered.sort((a, b) => b.name.localeCompare(a.name))
            case 'price-desc':
                return filtered.sort((a, b) => b.priceLevel - a.priceLevel)
            case 'price-asc':
                return filtered.sort((a, b) => a.priceLevel - b.priceLevel)
            default:
                return filtered
        }
    }

    const sortedButchers = getSortedButchers()

    const getSortLabel = () => {
        switch (sortType) {
            case 'rating-desc':
                return 'Maior avaliação'
            case 'rating-asc':
                return 'Menor avaliação'
            case 'name-asc':
                return 'A → Z'
            case 'name-desc':
                return 'Z → A'
            case 'price-desc':
                return 'Maior preço'
            case 'price-asc':
                return 'Menor preço'
            default:
                return 'Ordenar'
        }
    }

    const renderStars = (rating: number) => {
        const stars = []
        const fullStars = Math.floor(rating)
        const hasHalfStar = rating % 1 !== 0

        for (let i = 0; i < fullStars; i++) {
            stars.push(
                <Ionicons key={i} name="star" size={20} color="#FFD700" />
            )
        }
        if (hasHalfStar) {
            stars.push(
                <Ionicons key="half" name="star-half" size={20} color="#FFD700" />
            )
        }
        while (stars.length < 5) {
            stars.push(
                <Ionicons key={`empty-${stars.length}`} name="star-outline" size={20} color="#E0E0E0" />
            )
        }
        return stars
    }

    const renderPriceLevel = (level: number) => {
        return '$'.repeat(level) + '$'.repeat(3 - level).split('').map((_, i) => (
            <Text key={i} style={styles.priceLevelEmpty}>$</Text>
        ))
    }

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <View style={styles.headerContent}>
                    <TouchableOpacity
                        style={styles.backButton}
                        onPress={() => navigation.goBack()}
                    >
                        <Ionicons name="arrow-back" size={28} color="#FFF" />
                    </TouchableOpacity>
                    <Image
                        source={require('./assets/logo.png')}
                        style={styles.logoIcon}
                        resizeMode="contain"
                    />
                    <TouchableOpacity style={styles.searchHeaderContainer}>
                        <Ionicons name="search" size={18} color="#FFF" />
                        <TextInput
                            style={styles.searchHeaderInput}
                            placeholder="Procure por produto ou estabelecimento"
                            placeholderTextColor="#CCCCCC"
                            value={searchQuery}
                            onChangeText={setSearchQuery}
                        />
                    </TouchableOpacity>
                </View>
            </View>

            {/* Main Content */}
            <View style={styles.mainContent}>
                {/* Açougues Title with Filter */}
                <View style={styles.titleContainer}>
                    <Text style={styles.sectionTitle}>AÇOUGUES</Text>
                    <TouchableOpacity
                        style={styles.filterButton}
                        onPress={() => setShowSortModal(true)}
                    >
                        <View style={styles.filterIcon}>
                            <View style={styles.filterLine} />
                            <View style={[styles.filterLine, styles.filterLineShort]} />
                            <View style={styles.filterLine} />
                        </View>
                    </TouchableOpacity>
                </View>

                {/* Active Filter Indicator */}
                <View style={styles.activeFilterContainer}>
                    <Text style={styles.activeFilterText}>
                        Ordenado por: <Text style={styles.activeFilterBold}>{getSortLabel()}</Text>
                    </Text>
                </View>

                {/* Butchers List */}
                <ScrollView
                    style={styles.butchersScrollView}
                    showsVerticalScrollIndicator={false}
                    contentContainerStyle={styles.scrollContent}
                >
                    <View style={styles.butchersContainer}>
                        {sortedButchers.length === 0 ? (
                            <View style={styles.emptyState}>
                                <Ionicons name="search-outline" size={48} color="#CCC" />
                                <Text style={styles.emptyStateText}>Nenhum açougue encontrado</Text>
                            </View>
                        ) : (
                            sortedButchers.map((butcher) => (
                                <TouchableOpacity 
                                    key={butcher.id} 
                                    style={styles.butcherCard}
                                    onPress={() => {
                                        // @ts-ignore
                                        navigation.navigate('ButcherDetails', {
                                            butcherName: butcher.name,
                                            butcherRating: butcher.rating,
                                            butcherLogo: butcher.logo
                                        })
                                    }}
                                >
                                    <Image source={butcher.logo} style={styles.butcherLogo} />
                                    <View style={styles.butcherInfo}>
                                        <Text style={styles.butcherName}>{butcher.name}</Text>
                                        <View style={styles.butcherMeta}>
                                            <View style={styles.priceContainer}>
                                                <Text style={styles.priceLevel}>
                                                    {'$'.repeat(butcher.priceLevel)}
                                                </Text>
                                                <Text style={styles.priceLevelEmpty}>
                                                    {'$'.repeat(3 - butcher.priceLevel)}
                                                </Text>
                                            </View>
                                            <View style={styles.ratingContainer}>
                                                <Text style={styles.ratingNumber}>{butcher.rating.toFixed(1)}</Text>
                                                <Ionicons name="star" size={16} color="#FFD700" />
                                            </View>
                                        </View>
                                    </View>
                                    <View style={styles.starsContainer}>
                                        {renderStars(butcher.rating)}
                                    </View>
                                </TouchableOpacity>
                            ))
                        )}
                    </View>
                </ScrollView>
            </View>

            {/* Sort Modal */}
            <Modal
                visible={showSortModal}
                transparent={true}
                animationType="fade"
                onRequestClose={() => setShowSortModal(false)}
            >
                <TouchableOpacity
                    style={styles.modalOverlay}
                    activeOpacity={1}
                    onPress={() => setShowSortModal(false)}
                >
                    <View style={styles.modalContent}>
                        <View style={styles.modalHeader}>
                            <Text style={styles.modalTitle}>Ordenar por</Text>
                            <TouchableOpacity onPress={() => setShowSortModal(false)}>
                                <Ionicons name="close" size={28} color="#333" />
                            </TouchableOpacity>
                        </View>

                        <TouchableOpacity
                            style={[styles.sortOption, sortType === 'rating-desc' && styles.sortOptionActive]}
                            onPress={() => {
                                setSortType('rating-desc')
                                setShowSortModal(false)
                            }}
                        >
                            <Ionicons name="star" size={22} color={sortType === 'rating-desc' ? '#C8342B' : '#666'} />
                            <Text style={[styles.sortOptionText, sortType === 'rating-desc' && styles.sortOptionTextActive]}>
                                Maior avaliação
                            </Text>
                        </TouchableOpacity>

                        <TouchableOpacity
                            style={[styles.sortOption, sortType === 'rating-asc' && styles.sortOptionActive]}
                            onPress={() => {
                                setSortType('rating-asc')
                                setShowSortModal(false)
                            }}
                        >
                            <Ionicons name="star-outline" size={22} color={sortType === 'rating-asc' ? '#C8342B' : '#666'} />
                            <Text style={[styles.sortOptionText, sortType === 'rating-asc' && styles.sortOptionTextActive]}>
                                Menor avaliação
                            </Text>
                        </TouchableOpacity>

                        <TouchableOpacity
                            style={[styles.sortOption, sortType === 'name-asc' && styles.sortOptionActive]}
                            onPress={() => {
                                setSortType('name-asc')
                                setShowSortModal(false)
                            }}
                        >
                            <Ionicons name="text" size={22} color={sortType === 'name-asc' ? '#C8342B' : '#666'} />
                            <Text style={[styles.sortOptionText, sortType === 'name-asc' && styles.sortOptionTextActive]}>
                                Nome (A → Z)
                            </Text>
                        </TouchableOpacity>

                        <TouchableOpacity
                            style={[styles.sortOption, sortType === 'name-desc' && styles.sortOptionActive]}
                            onPress={() => {
                                setSortType('name-desc')
                                setShowSortModal(false)
                            }}
                        >
                            <Ionicons name="text" size={22} color={sortType === 'name-desc' ? '#C8342B' : '#666'} />
                            <Text style={[styles.sortOptionText, sortType === 'name-desc' && styles.sortOptionTextActive]}>
                                Nome (Z → A)
                            </Text>
                        </TouchableOpacity>

                        <TouchableOpacity
                            style={[styles.sortOption, sortType === 'price-desc' && styles.sortOptionActive]}
                            onPress={() => {
                                setSortType('price-desc')
                                setShowSortModal(false)
                            }}
                        >
                            <Ionicons name="cash" size={22} color={sortType === 'price-desc' ? '#C8342B' : '#666'} />
                            <Text style={[styles.sortOptionText, sortType === 'price-desc' && styles.sortOptionTextActive]}>
                                Maior preço
                            </Text>
                        </TouchableOpacity>

                        <TouchableOpacity
                            style={[styles.sortOption, sortType === 'price-asc' && styles.sortOptionActive]}
                            onPress={() => {
                                setSortType('price-asc')
                                setShowSortModal(false)
                            }}
                        >
                            <Ionicons name="cash-outline" size={22} color={sortType === 'price-asc' ? '#C8342B' : '#666'} />
                            <Text style={[styles.sortOptionText, sortType === 'price-asc' && styles.sortOptionTextActive]}>
                                Menor preço
                            </Text>
                        </TouchableOpacity>
                    </View>
                </TouchableOpacity>
            </Modal>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#FFFFFF',
    },
    header: {
        backgroundColor: '#3D3D3D',
        paddingTop: 45,
        paddingBottom: 12,
    },
    headerContent: {
        paddingHorizontal: 16,
    },
    backButton: {
        marginBottom: 12,
        width: 40,
    },
    logoIcon: {
        width: 140,
        height: 40,
        marginBottom: 12,
    },
    searchHeaderContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#4A4A4A',
        paddingHorizontal: 12,
        paddingVertical: 10,
        borderRadius: 6,
        gap: 8,
    },
    searchHeaderInput: {
        flex: 1,
        fontSize: 14,
        color: '#FFF',
    },
    mainContent: {
        flex: 1,
        backgroundColor: '#F5F5F5',
    },
    titleContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingVertical: 16,
        backgroundColor: '#FFF',
    },
    sectionTitle: {
        fontSize: 22,
        fontWeight: '700',
        color: '#C8342B',
        letterSpacing: 0.5,
    },
    filterButton: {
        padding: 8,
    },
    filterIcon: {
        width: 32,
        height: 32,
        backgroundColor: '#4A4A4A',
        borderRadius: 6,
        alignItems: 'center',
        justifyContent: 'center',
        gap: 3,
    },
    filterLine: {
        width: 18,
        height: 2.5,
        backgroundColor: '#FFF',
        borderRadius: 2,
    },
    filterLineShort: {
        width: 12,
    },
    activeFilterContainer: {
        paddingHorizontal: 16,
        paddingVertical: 10,
        backgroundColor: '#FFF',
        borderBottomWidth: 1,
        borderBottomColor: '#E0E0E0',
    },
    activeFilterText: {
        fontSize: 13,
        color: '#666',
    },
    activeFilterBold: {
        fontWeight: '700',
        color: '#C8342B',
    },
    butchersScrollView: {
        flex: 1,
    },
    scrollContent: {
        paddingBottom: 20,
    },
    butchersContainer: {
        paddingHorizontal: 16,
        paddingTop: 12,
    },
    butcherCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#FFF',
        marginBottom: 10,
        padding: 14,
        borderRadius: 8,
        elevation: 2,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.08,
        shadowRadius: 3,
    },
    butcherLogo: {
        width: 52,
        height: 52,
        borderRadius: 26,
        marginRight: 12,
    },
    butcherInfo: {
        flex: 1,
    },
    butcherName: {
        fontSize: 16,
        fontWeight: '600',
        color: '#333',
        marginBottom: 6,
    },
    butcherMeta: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 12,
    },
    priceContainer: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    priceLevel: {
        fontSize: 16,
        fontWeight: '700',
        color: '#666',
        letterSpacing: 1,
    },
    priceLevelEmpty: {
        fontSize: 16,
        fontWeight: '700',
        color: '#E0E0E0',
        letterSpacing: 1,
    },
    ratingContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 4,
    },
    ratingNumber: {
        fontSize: 15,
        fontWeight: '700',
        color: '#333',
    },
    starsContainer: {
        flexDirection: 'row',
        gap: 2,
    },
    emptyState: {
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 60,
    },
    emptyStateText: {
        fontSize: 16,
        color: '#999',
        marginTop: 12,
    },
    // Modal styles
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        justifyContent: 'flex-end',
    },
    modalContent: {
        backgroundColor: '#FFF',
        borderTopLeftRadius: 20,
        borderTopRightRadius: 20,
        paddingBottom: 30,
        maxHeight: '70%',
    },
    modalHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 20,
        paddingVertical: 20,
        borderBottomWidth: 1,
        borderBottomColor: '#E0E0E0',
    },
    modalTitle: {
        fontSize: 20,
        fontWeight: '700',
        color: '#333',
    },
    sortOption: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 20,
        paddingVertical: 16,
        gap: 12,
        borderBottomWidth: 1,
        borderBottomColor: '#F0F0F0',
    },
    sortOptionActive: {
        backgroundColor: '#FFF5F5',
    },
    sortOptionText: {
        fontSize: 16,
        color: '#333',
    },
    sortOptionTextActive: {
        fontWeight: '600',
        color: '#C8342B',
    },
})