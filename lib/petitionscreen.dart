import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiretrace/theme/app_colors.dart';

class PetitionScreen extends StatefulWidget {
  const PetitionScreen({super.key});
  @override
  State<PetitionScreen> createState() => _PetitionScreenState();
}

class _PetitionScreenState extends State<PetitionScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _waterwayController = TextEditingController();
  bool _copied = false;
  bool _generated = false;

  String get _petitionText {
    final city =
        _cityController.text.isEmpty ? '[your city]' : _cityController.text;
    final road =
        _roadController.text.isEmpty ? '[road name]' : _roadController.text;
    final waterway = _waterwayController.text.isEmpty
        ? '[local waterway]'
        : _waterwayController.text;

    return '''To: Local City Council & Environmental Affairs Office

Subject: Tire Microplastic Runoff Entering $waterway in $city

Dear Council Members,

I am writing to raise urgent concern about tire wear microplastics entering $waterway via stormwater runoff on $road and nearby routes in $city.

Tire wear particles are the largest source of microplastic pollution in urban waterways, yet receive far less regulatory attention than other pollutants. These particles carry toxic chemicals including zinc, PAHs, and especially 6PPD-quinone, a compound linked to mass coho salmon mortality in the Pacific Northwest and documented in waterways across the US.

I respectfully request the council:
1. Commission a stormwater runoff audit for roads draining into $waterway
2. Install bioretention filters or vegetated swales at high-risk drain outfalls on $road
3. Consider lower-shedding road surfaces on the highest-impact corridors
4. Support regional policy requiring tire particle impact assessments for new road projects

Our waterways depend on action now, not after the damage is done.

Sincerely,
A concerned resident of $city''';
  }

  void _generate() {
    setState(() => _generated = true);
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: _petitionText));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _roadController.dispose();
    _waterwayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(
        backgroundColor: appBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: appTextSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Petition generator',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: appTextPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: appBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explainer
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appBorder, width: 1),
              ),
              child: Text(
                'Fill in the details below to generate a letter addressed to your local officials about tire microplastic runoff in your area.',
                style: TextStyle(
                    fontSize: 12, color: appTextSecondary, height: 1.6),
              ),
            ),

            const _FieldLabel('Your city'),
            const SizedBox(height: 6),
            _Field(
                controller: _cityController,
                hint: 'e.g. San Jose, Boston...',
                onChanged: (_) => setState(() => _generated = false)),
            const SizedBox(height: 14),

            const _FieldLabel('Most polluting road'),
            const SizedBox(height: 6),
            _Field(
                controller: _roadController,
                hint: 'e.g. El Camino Real...',
                onChanged: (_) => setState(() => _generated = false)),
            const SizedBox(height: 14),

            const _FieldLabel('Affected waterway'),
            const SizedBox(height: 6),
            _Field(
                controller: _waterwayController,
                hint: 'e.g. Guadalupe River...',
                onChanged: (_) => setState(() => _generated = false)),
            const SizedBox(height: 24),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: appBlueLight,
                  foregroundColor: appBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: appBlue.withOpacity(0.3), width: 1),
                  ),
                ),
                onPressed: _generate,
                child: const Text('Generate petition',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),

            // Generated petition
            if (_generated) ...[
              const SizedBox(height: 20),
              const _FieldLabel('Your petition'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _petitionText,
                      style: TextStyle(
                          fontSize: 12, color: appTextSecondary, height: 1.8),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _copied ? appGreenLight : appBg,
                          foregroundColor: _copied ? appGreen : appBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: _copied
                                    ? appGreen.withOpacity(0.3)
                                    : appBorder,
                                width: 1),
                          ),
                        ),
                        onPressed: _copy,
                        icon:
                            Icon(_copied ? Icons.check : Icons.copy, size: 15),
                        label: Text(_copied ? 'Copied!' : 'Copy to clipboard'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            color: appTextSecondary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: appTextPrimary),
        cursorColor: appBlue,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: appTextSecondary, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
