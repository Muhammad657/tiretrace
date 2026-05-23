import 'package:flutter/material.dart';
import 'package:tiretrace/fakeData.dart';
import 'package:tiretrace/theme/app_colors.dart';

class TireGuideScreen extends StatefulWidget {
  const TireGuideScreen({super.key});

  @override
  State<TireGuideScreen> createState() => _TireGuideScreenState();
}

class _TireGuideScreenState extends State<TireGuideScreen> {
  String _selectedVehicleType = 'Passenger Car';
  String _selectedDrivingStyle = 'Mixed';
  String _selectedBudget = 'All';
  bool _showEnvironmentalImpact = true;
  bool _showPriceComparison = true;

  final List<String> _vehicleTypes = [
    'Passenger Car',
    'SUV/Crossover',
    'EV',
    'Light Truck'
  ];
  final List<String> _drivingStyles = [
    'City',
    'Highway',
    'Mixed',
    'Aggressive'
  ];
  final List<String> _budgets = [
    'All',
    'Budget (<\$150)',
    'Mid (\$150-250)',
    'Premium (\$250+)'
  ];

  List<TireRecommendation> get _filteredTires {
    var filtered = List<TireRecommendation>.from(tireRecommendations);

    // Filter by vehicle type
    if (_selectedVehicleType == 'EV') {
      filtered = filtered
          .where((t) => t.brand == 'Michelin' || t.brand == 'Pirelli')
          .toList();
    } else if (_selectedVehicleType == 'SUV/Crossover') {
      filtered = filtered
          .where((t) =>
              t.model.contains('SUV') || t.model.contains('CrossContact'))
          .toList();
    }

    // Filter by budget
    if (_budgets != 'All') {
      filtered = filtered.where((t) {
        if (_budgets == 'Budget (<\$150)')
          return t.priceRange.contains('80') || t.priceRange.contains('110');
        if (_budgets == 'Mid (\$150-250)')
          return t.priceRange.contains('160') || t.priceRange.contains('190');
        if (_budgets == 'Premium (\$250+)')
          return t.priceRange.contains('230') || t.priceRange.contains('280');
        return true;
      }).toList();
    }

    // Sort by shed rating (Very Low first, then Low)
    filtered.sort((a, b) {
      final ratingOrder = {'Very Low': 0, 'Low': 1};
      return ratingOrder[a.shedRating]!.compareTo(ratingOrder[b.shedRating]!);
    });

    return filtered;
  }

  double get _averageAnnualShed {
    if (_filteredTires.isEmpty) return 0;
    // Rough calculation: average shed in kg per year based on 15,000 km driven
    const baseShedPerKm = 0.1; // grams per km average
    final avgRating = _filteredTires
            .map((t) => t.shedRating == 'Very Low' ? 0.6 : 1.0)
            .reduce((a, b) => a + b) /
        _filteredTires.length;
    return (baseShedPerKm * 15000 * avgRating) / 1000;
  }

  double get _savingsPercentage {
    if (_filteredTires.isEmpty) return 0;
    final veryLowCount =
        _filteredTires.where((t) => t.shedRating == 'Very Low').length;
    return (veryLowCount / _filteredTires.length) * 100;
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
        title: const Text('Tire Guide',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: appTextPrimary,
                letterSpacing: -0.3)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                size: 20, color: appTextSecondary),
            onPressed: _showSettingsDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: appBorder),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Impact summary badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: appBlueLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: appBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_outlined, color: appBlue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Switching to low-shedding tires can reduce your microplastic pollution by up to 40%',
                    style: const TextStyle(
                        fontSize: 12, color: appTextPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filters section
          _buildFilterSection(),
          const SizedBox(height: 20),

          // Environmental impact calculator
          if (_showEnvironmentalImpact && _filteredTires.isNotEmpty) ...[
            _buildImpactCalculator(),
            const SizedBox(height: 20),
          ],

          // Recommended tires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Label('Recommended for you'),
              Text(
                '${_filteredTires.length} options',
                style: const TextStyle(fontSize: 11, color: appTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_filteredTires.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.tire_repair_outlined,
                      size: 48, color: appTextSecondary.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'No tires match your filters',
                    style: TextStyle(fontSize: 14, color: appTextSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedBudget = 'All';
                        _selectedVehicleType = 'Passenger Car';
                      });
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            )
          else
            ..._filteredTires.map((t) => _TireCard(
                  tire: t,
                  showPriceComparison: _showPriceComparison,
                )),

          const SizedBox(height: 24),
          const _Label('What to look for'),
          const SizedBox(height: 10),
          ..._buildCriteriaList(),

          const SizedBox(height: 20),
          _BuildFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter tires',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: appTextPrimary),
          ),
          const SizedBox(height: 12),

          // Vehicle type dropdown
          _buildFilterDropdown(
            label: 'Vehicle type',
            value: _selectedVehicleType,
            items: _vehicleTypes,
            icon: Icons.directions_car_outlined,
            onChanged: (value) => setState(() => _selectedVehicleType = value!),
          ),
          const SizedBox(height: 12),

          // Driving style
          _buildFilterDropdown(
            label: 'Driving style',
            value: _selectedDrivingStyle,
            items: _drivingStyles,
            icon: Icons.speed_outlined,
            onChanged: (value) =>
                setState(() => _selectedDrivingStyle = value!),
          ),
          const SizedBox(height: 12),

          // Budget
          _buildFilterDropdown(
            label: 'Price range',
            value: _selectedBudget,
            items: _budgets,
            icon: Icons.attach_money_outlined,
            onChanged: (value) => setState(() => _selectedBudget = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: appTextSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              labelStyle:
                  const TextStyle(fontSize: 12, color: appTextSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: appBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: appBorder),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(fontSize: 13, color: appTextPrimary),
            dropdownColor: appSurface,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactCalculator() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appGreenLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: appGreen, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Your potential impact',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ImpactStat(
                value: '${_averageAnnualShed.toStringAsFixed(1)} kg',
                label: 'microplastics/year',
                color: appGreen,
              ),
              Container(width: 1, height: 30, color: appBorder),
              _ImpactStat(
                value: '${_savingsPercentage.toStringAsFixed(0)}%',
                label: 'lower than average',
                color: appGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCriteriaList() {
    final criteria = [
      {
        'icon': Icons.science_outlined,
        'text': 'Silica compound rubber — sheds 60% less than carbon black',
        'detail':
            'Modern silica compounds reduce friction and wear significantly.'
      },
      {
        'icon': Icons.speed_outlined,
        'text': 'EU rolling resistance label B or above',
        'detail': 'Better rolling resistance = less energy loss = longer life.'
      },
      {
        'icon': Icons.repeat_outlined,
        'text': 'UTQG treadwear 500+ rating',
        'detail':
            'Higher treadwear rating means tires last longer, shedding less per km.'
      },
      {
        'icon': Icons.water_drop_outlined,
        'text': 'Low PAH and heavy metal content',
        'detail': 'Some eco-certified tires use safer additives.'
      },
    ];

    return criteria
        .map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                backgroundColor: appSurface,
                collapsedBackgroundColor: appSurface,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: appBorder),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: appBorder),
                ),
                title: Row(
                  children: [
                    Icon(c['icon'] as IconData, size: 16, color: appBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c['text'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: appTextSecondary),
                      ),
                    ),
                  ],
                ),
                children: [
                  Text(
                    c['detail'] as String,
                    style: const TextStyle(
                        fontSize: 11, color: appTextSecondary, height: 1.4),
                  ),
                ],
              ),
            ))
        .toList();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: appSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Display settings',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: appTextPrimary),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show environmental impact',
                    style: TextStyle(fontSize: 14, color: appTextPrimary)),
                value: _showEnvironmentalImpact,
                onChanged: (v) => setState(() => _showEnvironmentalImpact = v),
                activeColor: appBlue,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show price comparison',
                    style: TextStyle(fontSize: 14, color: appTextPrimary)),
                value: _showPriceComparison,
                onChanged: (v) => setState(() => _showPriceComparison = v),
                activeColor: appBlue,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: appBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 10,
            color: appTextSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600));
  }
}

class _TireCard extends StatelessWidget {
  final TireRecommendation tire;
  final bool showPriceComparison;

  const _TireCard({required this.tire, required this.showPriceComparison});

  Color get ratingColor => tire.shedRating == 'Very Low' ? appGreen : appBlue;

  String get _savingsBadge {
    if (tire.shedRating == 'Very Low') return '−40% microplastics';
    if (tire.shedRating == 'Low') return '−20% microplastics';
    return 'Standard';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    tire.brand[0],
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ratingColor),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tire.brand} ${tire.model}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: appTextPrimary,
                            letterSpacing: -0.2)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ratingColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tire.shedRating,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: ratingColor)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_outline,
                            size: 12, color: appTextSecondary),
                        const SizedBox(width: 3),
                        Text('4.5',
                            style: TextStyle(
                                fontSize: 11, color: appTextSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (showPriceComparison)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(tire.priceRange,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: appTextPrimary)),
                    Text('/ tire',
                        style:
                            TextStyle(fontSize: 10, color: appTextSecondary)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appGreenLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_outlined, size: 12, color: appGreen),
                const SizedBox(width: 4),
                Text(
                  _savingsBadge,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ImpactStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: appTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _BuildFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: appBorder, height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 12, color: appTextSecondary.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(
              'Data based on lab tests and manufacturer specs | Updated quarterly',
              style: TextStyle(
                  fontSize: 10, color: appTextSecondary.withOpacity(0.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            // Share or report incorrect data
          },
          icon:
              Icon(Icons.feedback_outlined, size: 14, color: appTextSecondary),
          label: const Text('Help improve this data',
              style: TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(foregroundColor: appTextSecondary),
        ),
      ],
    );
  }
}
