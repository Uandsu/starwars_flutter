class Favorite {
  final int id;
  final String name;

  Favorite({
    required this.id,
    required this.name,
  });

  // Converta um favorito em um mapa. As entradas tem que corresponder aos nomes dos
  // colunas no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
