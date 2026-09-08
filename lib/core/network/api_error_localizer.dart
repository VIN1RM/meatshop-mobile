/// Centraliza as mensagens da API que podem ser exibidas pela interface.
/// O backend pode responder em inglês; o aplicativo traduz pelo código estável.
abstract final class ApiErrorLocalizer {
  static const Map<String, String> _messages = {
    'PROFILE_INCOMPLETE': 'Complete seu cadastro para continuar.',
    'EMAIL_ALREADY_EXISTS': 'Este e-mail já está cadastrado.',
    'CPF_ALREADY_EXISTS': 'Este CPF já está cadastrado.',
    'PHONE_ALREADY_EXISTS': 'Este telefone já está cadastrado.',
    'CNPJ_ALREADY_EXISTS': 'Este CNPJ já está cadastrado.',
    'FIREBASE_EMAIL_NOT_VERIFIED': 'Confirme seu e-mail antes de entrar.',
    'INVALID_FIREBASE_TOKEN': 'Sua sessão é inválida. Entre novamente.',
    'FIREBASE_TOKEN_REQUIRED': 'Sua sessão expirou. Entre novamente.',
    'INVALID_APP_CHECK_TOKEN': 'Não foi possível validar este dispositivo.',
    'APP_CHECK_REQUIRED': 'Não foi possível validar este dispositivo.',
    'FIREBASE_IDENTITY_ALREADY_LINKED':
        'Esta conta já está vinculada a outro usuário.',
    'FIREBASE_IDENTITY_CONFLICT':
        'Existe outra forma de acesso vinculada a este e-mail.',
    'ACCOUNT_LINK_REQUIRED': 'Confirme sua senha para vincular esta conta.',
    'ACCOUNT_LINK_INVALID_PASSWORD': 'A senha informada está incorreta.',
    'ACCOUNT_DISABLED': 'Esta conta está desativada.',
    'ACCOUNT_LOCKED': 'Esta conta está temporariamente bloqueada.',
    'ADDRESS_IN_USE': 'Este endereço está sendo usado em um pedido.',
    'EMPTY_CART': 'Seu carrinho está vazio.',
    'PRODUCT_UNAVAILABLE': 'Um dos produtos não está mais disponível.',
    'PRODUCT_NOT_AVAILABLE': 'Este produto não está disponível.',
    'INSUFFICIENT_STOCK': 'Não há estoque suficiente para este produto.',
    'INVALID_IDEMPOTENCY_KEY':
        'Não foi possível confirmar a operação. Tente novamente.',
    'DELIVERY_CODE_LOCKED':
        'O código de entrega foi bloqueado temporariamente.',
    'DELIVERY_CODE_EXPIRED': 'O código de entrega expirou.',
    'INVALID_DELIVERY_CODE': 'O código de entrega é inválido.',
    'COUPON_NOT_FOUND': 'Cupom não encontrado.',
    'COUPON_ALREADY_EXISTS': 'Este cupom já existe.',
    'COUPON_MINIMUM_NOT_REACHED':
        'O valor mínimo para usar este cupom não foi atingido.',
    'COUPON_NOT_APPLICABLE': 'Este cupom não se aplica ao pedido.',
    'COUPON_USAGE_LIMIT_REACHED': 'O limite de uso deste cupom foi atingido.',
    'COUPON_UNIT_REQUIRED': 'Selecione a unidade para usar este cupom.',
    'COUPON_UNIT_NOT_IN_CART':
        'Este cupom não é válido para os itens do carrinho.',
    'COUPON_UNIT_NOT_FOUND': 'A unidade vinculada ao cupom não foi encontrada.',
    'COUPON_SCOPE_IMMUTABLE':
        'O tipo de aplicação do cupom não pode ser alterado.',
    'COUPON_SCOPE_FORBIDDEN': 'Você não pode usar este tipo de cupom.',
    'COUPON_PLATFORM_FORBIDDEN':
        'Este cupom não está disponível no aplicativo.',
    'INVALID_CEP': 'Informe um CEP válido.',
    'CEP_NOT_FOUND': 'CEP não encontrado.',
    'CEP_PROVIDER_UNAVAILABLE':
        'A consulta de CEP está indisponível no momento.',
    'CEP_PROVIDER_ERROR': 'Não foi possível consultar o CEP.',
    'CEP_WITHOUT_COORDINATES':
        'Não foi possível localizar as coordenadas deste CEP.',
    'AUDIT_LOG_NOT_FOUND': 'Registro de auditoria não encontrado.',
    'RESOURCE_ALREADY_EXISTS': 'Este registro já existe.',
    'RATE_LIMIT_EXCEEDED':
        'Muitas tentativas. Aguarde um momento e tente novamente.',
    'INTERNAL_ERROR': 'Ocorreu um erro interno. Tente novamente mais tarde.',
  };

  static String translate({String? code, required int statusCode}) {
    final translated = code == null ? null : _messages[code.toUpperCase()];
    if (translated != null) return translated;

    return switch (statusCode) {
      400 || 422 => 'Verifique os dados informados e tente novamente.',
      401 => 'Sua sessão expirou. Entre novamente.',
      403 => 'Você não tem permissão para realizar esta ação.',
      404 => 'O conteúdo solicitado não foi encontrado.',
      409 => 'Não foi possível concluir devido a um conflito de dados.',
      429 => 'Muitas tentativas. Aguarde um momento e tente novamente.',
      >= 500 => 'O serviço está indisponível. Tente novamente mais tarde.',
      _ => 'Não foi possível concluir a operação. Tente novamente.',
    };
  }
}
