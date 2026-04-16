class ButcherProduct {
  final String nome;
  final String preco;
  final String unidade;
  final String imageAsset;
  final String descricao;

  const ButcherProduct({
    required this.nome,
    required this.preco,
    required this.unidade,
    this.imageAsset = '',
    this.descricao = '',
  });
}
