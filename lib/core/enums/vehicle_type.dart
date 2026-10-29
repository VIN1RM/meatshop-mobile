enum VehicleType {
  motorcycle('MOTORCYCLE', 'Moto'),
  car('CAR', 'Carro'),
  bike('BIKE', 'Bicicleta');

  const VehicleType(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static VehicleType? tryParse(Object? value) =>
      switch (value?.toString().trim().toUpperCase()) {
        'MOTORCYCLE' || 'MOTO' => motorcycle,
        'CAR' || 'CARRO' => car,
        'BIKE' || 'BICICLETA' => bike,
        _ => null,
      };
}
