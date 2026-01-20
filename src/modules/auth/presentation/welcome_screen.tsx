import { useEffect } from 'react'
import {
  View,
  Text,
  StyleSheet,
  Image,
  ActivityIndicator,
  SafeAreaView,
  ImageBackground,
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
    <View style={styles.wrapper}>
      <ImageBackground
        source={require('../../../../assets/background.png')}
        style={styles.backgroundImage}
        resizeMode="cover"
        imageStyle={{ opacity: 0.05 }}
      >
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
      </ImageBackground>
    </View>
  )
}

const styles = StyleSheet.create({
  wrapper: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },

  backgroundImage: {
    flex: 1,
    width: '100%',
    height: '100%',
  },

  safe: {
    flex: 1,
    backgroundColor: 'transparent',
  },

  container: {
    flex: 1,
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 64,
    paddingHorizontal: 24,
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