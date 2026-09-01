class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;

  static String fromFirestore(Object error) {
    final raw = error.toString().toLowerCase();

    if (raw.contains('permission-denied')) {
      return 'Sem permissão para realizar essa operação. Verifique sua conexão e tente novamente.';
    }
    if (raw.contains('not-found')) {
      return 'Registro não encontrado.';
    }
    if (raw.contains('already-exists')) {
      return 'Este registro já existe.';
    }
    if (raw.contains('unavailable')) {
      return 'Serviço indisponível no momento. Tente novamente em instantes.';
    }
    if (raw.contains('deadline-exceeded') || raw.contains('timeout')) {
      return 'Tempo de resposta esgotado. Verifique sua conexão.';
    }
    if (raw.contains('unauthenticated')) {
      return 'Sessão expirada. Faça login novamente.';
    }
    if (raw.contains('resource-exhausted')) {
      return 'Muitas requisições. Tente novamente em instantes.';
    }
    if (raw.contains('cancelled')) {
      return 'Operação cancelada. Tente novamente.';
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return 'Sem conexão com a internet.';
    }
    if (raw.contains('internal')) {
      return 'Erro interno do servidor. Tente novamente.';
    }

    return 'Erro inesperado. Tente novamente.';
  }
}
