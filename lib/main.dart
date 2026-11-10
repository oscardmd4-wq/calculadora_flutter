import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculadora(),
    );
  }
}

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String _pantalla = '0';
  String _expresionPantalla = ''; 
  double? _primerNumero;
  String? _operador;
  bool _nuevoNumero = true;

  String? _funcionActiva; 
  String _argumentoFuncion = '';
  bool _nuevoArgumento = true;

  void _presionarNumero(String digito) {
    setState(() {
      if (_funcionActiva != null) {
        if (_nuevoArgumento || _argumentoFuncion == '0') {
          _argumentoFuncion = digito;
          _nuevoArgumento = false;
        } else {
          _argumentoFuncion += digito;
        }
      } else {
        if (_nuevoNumero || _pantalla == '0') {
          _pantalla = digito;
          _nuevoNumero = false;
        } else {
          _pantalla += digito;
        }
      }
      _actualizarExpresion();
    });
  }

  void _presionarPunto() {
    setState(() {
      if (_funcionActiva != null) {
        if (_nuevoArgumento) {
          _argumentoFuncion = '0.';
          _nuevoArgumento = false;
        } else if (!_argumentoFuncion.contains('.')) {
          _argumentoFuncion += '.';
        }
      } else {
        if (_nuevoNumero) {
          _pantalla = '0.';
          _nuevoNumero = false;
        } else if (!_pantalla.contains('.')) {
          _pantalla += '.';
        }
      }
      _actualizarExpresion();
    });
  }

  void _presionarOperador(String op) {
    setState(() {
      if (_funcionActiva != null) {
        double? res = _resolverFuncionActiva();
        if (res == null) return;
        _primerNumero = res;
      } else {
        if (_operador != null && !_nuevoNumero) {
          _resolver(continuarOperacion: true);
        }
        _primerNumero = double.tryParse(_pantalla);
      }
      _operador = op;
      _nuevoNumero = true;
      _actualizarExpresion();
    });
  }

  void _actualizarExpresion() {
    if (_funcionActiva != null) {
      if (_funcionActiva == 'sqrt') {
        _expresionPantalla = '√($_argumentoFuncion)';
      } else if (_funcionActiva == 'ln' || _funcionActiva == 'log') {
        _expresionPantalla = '$_funcionActiva($_argumentoFuncion)';
      } else {
        _expresionPantalla = '$_funcionActiva($_argumentoFuncion°)';
      }
      return;
    }

    if (_primerNumero != null && _operador != null) {
      if (_nuevoNumero) {
        _expresionPantalla = '${_formatear(_primerNumero!)} $_operador';
      } else {
        _expresionPantalla = '${_formatear(_primerNumero!)} $_operador $_pantalla';
      }
    } else {
      _expresionPantalla = _pantalla;
    }
  }

  void _resolver({bool continuarOperacion = false}) {
    final double? a = _primerNumero;
    final double? b = double.tryParse(_pantalla);
    if (a == null || b == null || _operador == null) return;

    double resultado = 0;
    bool error = false;

    switch (_operador) {
      case '+':
        resultado = a + b;
        break;
      case '-':
        resultado = a - b;
        break;
      case '×':
        resultado = a * b;
        break;
      case '÷':
        error = (b == 0);
        if (!error) resultado = a / b;
        break;
      case '~/':
        error = (b == 0);
        if (!error) resultado = (a ~/ b).toDouble();
        break;
      case '%':
        error = (b == 0);
        if (!error) resultado = a % b;
        break;
      case 'x^y':
        resultado = pow(a, b).toDouble();
        break;
    }

    setState(() {
      if (error) {
        _pantalla = 'Error';
        _expresionPantalla = 'Error';
      } else {
        String resFormateado = _formatear(resultado);
        if (!continuarOperacion) {
          _expresionPantalla = '${_formatear(_primerNumero!)} $_operador $_pantalla = $resFormateado';
        } else {
          _expresionPantalla = resFormateado;
        }
        _pantalla = resFormateado;
      }
      if (!continuarOperacion) {
        _primerNumero = null;
        _operador = null;
      } else {
        _primerNumero = resultado;
      }
      _nuevoNumero = true;
    });
  }

  double? _resolverFuncionActiva() {
    if (_funcionActiva == null) return double.tryParse(_pantalla);

    final double? x = double.tryParse(_argumentoFuncion);
    if (x == null) return null;

    double resultado = 0;
    bool error = false;
    final double radianes = x * pi / 180;

    switch (_funcionActiva) {
      case 'sin':
        resultado = sin(radianes);
        break;
      case 'cos':
        resultado = cos(radianes);
        break;
      case 'tan':
        if (x % 180 == 90 || x % 180 == -90) {
          error = true;
        } else {
          resultado = tan(radianes);
        }
        break;
      case 'sqrt':
        error = (x < 0);
        if (!error) resultado = sqrt(x);
        break;
      case 'ln':
        error = (x <= 0);
        if (!error) resultado = log(x);
        break;
      case 'log':
        error = (x <= 0);
        if (!error) resultado = log(x) / ln10;
        break;
    }

    if (error) {
      setState(() {
        _pantalla = 'Error';
        _expresionPantalla = 'Error';
        _funcionActiva = null;
        _argumentoFuncion = '';
      });
      return null;
    }

    String resFormateado = _formatear(resultado);
    String exprCompleta = '';
    if (_funcionActiva == 'sqrt') {
      exprCompleta = '√($_argumentoFuncion) = $resFormateado';
    } else if (_funcionActiva == 'ln' || _funcionActiva == 'log') {
      exprCompleta = '$_funcionActiva($_argumentoFuncion) = $resFormateado';
    } else {
      exprCompleta = '$_funcionActiva($_argumentoFuncion°) = $resFormateado';
    }

    setState(() {
      _pantalla = resFormateado;
      _expresionPantalla = exprCompleta;
      _funcionActiva = null;
      _argumentoFuncion = '';
      _nuevoNumero = true;
    });

    return resultado;
  }

  void _presionarIgual() {
    setState(() {
      if (_funcionActiva != null) {
        _resolverFuncionActiva();
      } else {
        _resolver(continuarOperacion: false);
      }
    });
  }

  void _presionarFuncion(String funcion) {
    setState(() {
      _funcionActiva = funcion;
      _argumentoFuncion = '';
      _nuevoArgumento = true;
      _actualizarExpresion();
    });
  }

  void _borrarUno() {
    setState(() {
      if (_funcionActiva != null) {
        if (_argumentoFuncion.isNotEmpty) {
          _argumentoFuncion = _argumentoFuncion.substring(0, _argumentoFuncion.length - 1);
        }
      } else {
        if (_nuevoNumero || _pantalla == 'Error') return;
        if (_pantalla.length > 1) {
          _pantalla = _pantalla.substring(0, _pantalla.length - 1);
        } else {
          _pantalla = '0';
        }
      }
      _actualizarExpresion();
    });
  }

  void _limpiar() {
    setState(() {
      _pantalla = '0';
      _expresionPantalla = '0';
      _primerNumero = null;
      _operador = null;
      _funcionActiva = null;
      _argumentoFuncion = '';
      _nuevoNumero = true;
    });
  }

  String _formatear(double valor) {
    valor = double.parse(valor.toStringAsFixed(10));
    if (valor == valor.truncateToDouble()) {
      return valor.toInt().toString();
    }
    return valor.toString();
  }

  Widget _boton(String texto, VoidCallback alPresionar, Color colorFondo, Color colorTexto, {int flex = 1, double fontSize = 20, FontWeight fontWeight = FontWeight.normal}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox.expand(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorFondo,
              foregroundColor: colorTexto,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: alPresionar,
            child: Text(
              texto,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: colorTexto,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fila(List<Widget> botones) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: botones,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorFondoApp = Color(0xFF010101);
    const colorBotonGrisOscuro = Color(0xFF2E2E2E);
    const colorBotonGrisClaro = Color(0xFF505050);
    const colorNaranjaAcento = Color(0xFFFF9F0A);
    const colorTextoPrimario = Colors.white;

    return Scaffold(
      backgroundColor: colorFondoApp,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.bottomRight,
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _expresionPantalla.isEmpty ? ' ' : _expresionPantalla,
                          style: const TextStyle(color: Color(0xFF808080), fontSize: 24, fontWeight: FontWeight.w400),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _pantalla,
                          style: const TextStyle(color: colorTextoPrimario, fontSize: 48, fontWeight: FontWeight.w300),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _fila([
                      _boton('sin', () => _presionarFuncion('sin'), colorBotonGrisClaro, colorTextoPrimario),
                      _boton('cos', () => _presionarFuncion('cos'), colorBotonGrisClaro, colorTextoPrimario),
                      _boton('tan', () => _presionarFuncion('tan'), colorBotonGrisClaro, colorTextoPrimario),
                      _boton('C', _limpiar, colorNaranjaAcento, colorTextoPrimario, fontWeight: FontWeight.bold, fontSize: 20),
                    ]),
                    _fila([
                      _boton('ln', () => _presionarFuncion('ln'), colorBotonGrisClaro, colorTextoPrimario),
                      _boton('log', () => _presionarFuncion('log'), colorBotonGrisClaro, colorTextoPrimario),
                      _boton('√', () => _presionarFuncion('sqrt'), colorBotonGrisClaro, colorTextoPrimario, fontSize: 22),
                      _boton('~/', () => _presionarOperador('~/'), colorBotonGrisClaro, colorTextoPrimario, fontSize: 20),
                    ]),
                    _fila([
                      _boton('7', () => _presionarNumero('7'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('8', () => _presionarNumero('8'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('9', () => _presionarNumero('9'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('%', () => _presionarOperador('%'), colorNaranjaAcento, colorTextoPrimario, fontWeight: FontWeight.bold, fontSize: 20),
                    ]),
                    _fila([
                      _boton('4', () => _presionarNumero('4'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('5', () => _presionarNumero('5'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('6', () => _presionarNumero('6'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('÷', () => _presionarOperador('÷'), colorNaranjaAcento, colorTextoPrimario, fontSize: 26),
                    ]),
                    _fila([
                      _boton('1', () => _presionarNumero('1'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('2', () => _presionarNumero('2'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('3', () => _presionarNumero('3'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('-', () => _presionarOperador('-'), colorNaranjaAcento, colorTextoPrimario, fontSize: 26),
                    ]),
                    _fila([
                      _boton('0', () => _presionarNumero('0'), colorBotonGrisOscuro, colorTextoPrimario),
                      _boton('.', _presionarPunto, colorBotonGrisOscuro, colorTextoPrimario, fontSize: 24, fontWeight: FontWeight.bold),
                      _boton('⌫', _borrarUno, colorBotonGrisClaro, colorTextoPrimario, fontSize: 18),
                      _boton('+', () => _presionarOperador('+'), colorNaranjaAcento, colorTextoPrimario, fontSize: 26),
                    ]),
                    _fila([
                      _boton('x^y', () => _presionarOperador('x^y'), colorBotonGrisClaro, colorTextoPrimario, fontSize: 20),
                      _boton('=', _presionarIgual, colorNaranjaAcento, colorTextoPrimario, flex: 3, fontSize: 28),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}