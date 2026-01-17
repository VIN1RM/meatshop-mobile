import { TextInput, StyleSheet, TextInputProps } from 'react-native'
import { colors } from '../theme/colors'

type InputProps = TextInputProps

export default function Input(props: InputProps) {
  return (
    <TextInput
      {...props}
      style={[styles.input, props.style]}
      placeholderTextColor={colors.gray}
    />
  )
}

const styles = StyleSheet.create({
  input: {
    width: '100%',
    borderWidth: 1,
    borderColor: '#DADADA',
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 14,
    marginTop: 12,
    fontSize: 16,
    color: colors.text,
    backgroundColor: '#FAFAFA',
  },
})
