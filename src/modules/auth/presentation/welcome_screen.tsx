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
        imageStyle={{ opacity: 0.03 }}
      >
        <SafeAreaView style={styles.safe}>
          <View style={styles.container}>
            {/* Textos no topo */}
            <View style={styles.textWrapper}>
              <Text style={styles.title}>
                SEJA <Text style={styles.highlight}>BEM VINDO!</Text>
              </Text>
              <Text style={styles.subtitle}>Sentimos sua falta.</Text>
            </View>

            {/* Loading no centro */}
            <View style={styles.loadingWrapper}>
              <ActivityIndicator size="large" color={colors.primary} />
            </View>

            {/* Logo na parte inferior */}
            <View style={styles.logoWrapper}>
              <Image
                source={require('../../../../assets/logo_completa.png')}
                style={styles.logo}
                resizeMode="contain"
              />
            </View>
          </View>
        </SafeAreaView>
      </ImageBackground>
    </View>
  )
}

const styles = StyleSheet.create({
  wrapper: {
    flex: 1,
    backgroundColor: '#F5F5F5',
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
    paddingTop: 80,
    paddingBottom: 60,
    paddingHorizontal: 24,
  },

  textWrapper: {
    alignItems: 'center',
  },

  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#4A4A4A',
    textAlign: 'center',
  },

  highlight: {
    color: '#C8342B',
  },

  subtitle: {
    marginTop: 12,
    fontSize: 20,
    color: '#666',
    fontWeight: '400',
  },

  loadingWrapper: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },

  logoWrapper: {
    alignItems: 'center',
    justifyContent: 'flex-end',
  },

  logo: {
    width: 280,
    height: 280,
  },
})