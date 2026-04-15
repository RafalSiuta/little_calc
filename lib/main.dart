import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'model/calculator_logic.dart';
import 'utils/styles/colors.dart';
import 'widgets/buttons/numbtn.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CalculatorLogic(),
        ),
      ],
      child: MaterialApp(
        title: 'little_calc',
        debugShowCheckedModeBanner: false,
        color: Colors.transparent,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const SystemWindow(),
      ),
    );
  }
}

class SystemWindow extends StatelessWidget {
  const SystemWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: ColoredBox(
        color: AppColors.systemWindow,
        child: Column(
          children: [
            WindowTitleBar(),
            Expanded(child: CalculatorView()),
          ],
        ),
      ),
    );
  }
}

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({Key? key}) : super(key: key);

  static const double height = 44;
  static const MethodChannel _windowChannel =
      MethodChannel('little_calc/window');

  Future<void> _invokeWindowAction(String action) async {
    try {
      await _windowChannel.invokeMethod<void>(action);
    } on MissingPluginException {
      // Allows the UI to render outside the Windows runner.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (_) => _invokeWindowAction('drag'),
                onDoubleTap: () => _invokeWindowAction('toggleMaximize'),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'little_calc',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Exo',
                      fontSize: 10,
                      fontWeight: FontWeight.w200,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _WindowActionButton(
              semanticLabel: 'Minimize',
              onPressed: () => _invokeWindowAction('minimize'),
              child: const _MinimizeIcon(),
            ),
            const SizedBox(width: 16),
            _WindowActionButton(
              semanticLabel: 'Maximize',
              onPressed: () => _invokeWindowAction('toggleMaximize'),
              child: const _MaximizeIcon(),
            ),
            const SizedBox(width: 16),
            _WindowActionButton(
              semanticLabel: 'Close',
              onPressed: () => _invokeWindowAction('close'),
              child: const _CloseIcon(),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key}) : super(key: key);

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  static const List<List<String>> _rows = [
    ['C', '+ -', '%', '/'],
    ['7', '8', '9', '*'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['.', '0', '='],
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorLogic>(
      builder: (context, data, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: AppColors.background,
          child: Column(
            children: [
              Expanded(
                child: _Display(data: data),
              ),
              _OptionsBar(onBackspace: data.delete),
              _Keyboard(
                rows: _rows,
                onPressed: (value) => data.multifunction(_logicValue(value)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _logicValue(String value) {
    if (value == '+ -') {
      return '+/-';
    }
    return value;
  }
}

class _Display extends StatelessWidget {
  const _Display({Key? key, required this.data}) : super(key: key);

  final CalculatorLogic data;

  @override
  Widget build(BuildContext context) {
    final equation = _equationText();

    return Padding(
      padding: const EdgeInsets.only(top: 44, right: 2, bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (equation.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Text(
                  equation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontFamily: 'Exo',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  data.display,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontFamily: 'Exo',
                    fontSize: 48,
                    fontWeight: FontWeight.w200,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _equationText() {
    if (data.operator.isEmpty) {
      return '';
    }
    final leftSide = data.oldText.isNotEmpty ? data.oldText : data.display;
    return '$leftSide ${data.operator}';
  }
}

class _OptionsBar extends StatelessWidget {
  const _OptionsBar({Key? key, required this.onBackspace}) : super(key: key);

  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.unselected,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: const [
                SizedBox(width: 22),
                _OptionIcon(icon: Icons.history),
                SizedBox(width: 22),
                _OptionIcon(icon: Icons.attach_money),
                SizedBox(width: 22),
                _OptionIcon(icon: Icons.straighten),
                SizedBox(width: 22),
                _OptionIcon(icon: Icons.calculate_outlined),
              ],
            ),
          ),
          IconButton(
            splashColor: AppColors.borderDark,
            highlightColor: AppColors.borderDark,
            hoverColor: AppColors.borderDark,
            onPressed: onBackspace,
            icon: const Icon(
              Icons.backspace_outlined,
              color: AppColors.unselected,
              size: 24,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _OptionIcon extends StatelessWidget {
  const _OptionIcon({Key? key, required this.icon}) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: AppColors.unselected,
      size: 24,
    );
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({
    Key? key,
    required this.rows,
    required this.onPressed,
  }) : super(key: key);

  final List<List<String>> rows;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final value in row)
                NumBtn(
                  label: value,
                  flex: value == '=' ? 2 : 1,
                  onPressed: () => onPressed(value),
                ),
            ],
          ),
      ],
    );
  }
}

class _WindowActionButton extends StatelessWidget {
  const _WindowActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            hoverColor: Colors.white.withOpacity(0.08),
            splashColor: Colors.white.withOpacity(0.12),
            highlightColor: Colors.white.withOpacity(0.08),
            onTap: onPressed,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _MinimizeIcon extends StatelessWidget {
  const _MinimizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 2,
      color: AppColors.background,
    );
  }
}

class _MaximizeIcon extends StatelessWidget {
  const _MaximizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.background,
          width: 2,
        ),
      ),
    );
  }
}

class _CloseIcon extends StatelessWidget {
  const _CloseIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14, 14),
      painter: _CloseIconPainter(),
    );
  }
}

class _CloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
