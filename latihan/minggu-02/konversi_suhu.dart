// Latihan 1: Konversi suhu Celsius ke Fahrenheit dan Kelvin
// Setiap konversi dibuat sebagai function terpisah.

/// Rumus: F = C x 9/5 + 32
double celsiusKeFahrenheit(double celsius) => celsius * 9 / 5 + 32;

/// Rumus: K = C + 273.15
double celsiusKeKelvin(double celsius) => celsius + 273.15;

void main() {
  final daftarCelsius = <double>[0, 25, 36.5, 100];

  for (final c in daftarCelsius) {
    final f = celsiusKeFahrenheit(c);
    final k = celsiusKeKelvin(c);
    print('${c.toStringAsFixed(1)} °C = '
        '${f.toStringAsFixed(1)} °F = '
        '${k.toStringAsFixed(2)} K');
  }
}