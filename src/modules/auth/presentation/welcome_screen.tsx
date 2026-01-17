import { useEffect } from 'react'
import {
  View,
  Text,
  StyleSheet,
  Image,
  ActivityIndicator,
  SafeAreaView,
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { colors } from '../../../shared/theme/colors'

export default function WelcomeScreen() {
  const navigation = useNavigation<any>()

  useEffect(() => {
    const timer = setTimeout(() => {
      navigation.replace('App')
    }, 2500)

    return () => clearTimeout(timer)
  }, [])

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.container}>
        {/* Textos */}
        <View style={styles.textWrapper}>
          <Text style={styles.title}>
            SEJA <Text style={styles.highlight}>BEM VINDO!</Text>
          </Text>
          <Text style={styles.subtitle}>Sentimos sua falta.</Text>
        </View>

        {/* Loading */}
        <ActivityIndicator size="large" color={colors.primary} />

        {/* Logo */}
        <Image
          source={require('../../../../assets/logo_completa.png')}
          style={styles.logo}
          resizeMode="contain"
        />
      </View>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: '#F7F7F7', // MESMA cor do splash
  },

  container: {
    flex: 1,
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 64,
    paddingHorizontal: 24,
    backgroundColor: '#F7F7F7',
  },

  textWrapper: {
    alignItems: 'center',
    marginTop: 24,
  },

  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#333',
  },

  highlight: {
    color: colors.primary,
  },

  subtitle: {
    marginTop: 8,
    fontSize: 18,
    color: '#666',
  },

  logo: {
    width: 200,
    height: 200,
  },
})
