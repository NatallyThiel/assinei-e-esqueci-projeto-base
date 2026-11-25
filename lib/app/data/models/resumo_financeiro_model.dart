class ResumoFinanceiroModel {
  final double totalValoresAtivos;
  final int quantidadeAssinaturasAtivas;
  final Map<String, double> gastosPorCategoria;

  ResumoFinanceiroModel({
    required this.totalValoresAtivos,
    required this.quantidadeAssinaturasAtivas,
    required this.gastosPorCategoria,
  });

  factory ResumoFinanceiroModel.fromJson(Map<String, dynamic> json) {
    final total = (json['totalValoresAtivos'] as num?)?.toDouble() ?? 0.0;
    final qtd = (json['quantidadeAssinaturasAtivas'] as num?)?.toInt() ?? 0;

    final Map<String, double> categoriasMap = {};
    if (json['gastosPorCategoria'] is Map) {
      (json['gastosPorCategoria'] as Map<String, dynamic>).forEach((key, val) {
        categoriasMap[key] = (val as num?)?.toDouble() ?? 0.0;
      });
    }

    return ResumoFinanceiroModel(
      totalValoresAtivos: total,
      quantidadeAssinaturasAtivas: qtd,
      gastosPorCategoria: categoriasMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalValoresAtivos': totalValoresAtivos,
        'quantidadeAssinaturasAtivas': quantidadeAssinaturasAtivas,
        'gastosPorCategoria': gastosPorCategoria,
      };
}
