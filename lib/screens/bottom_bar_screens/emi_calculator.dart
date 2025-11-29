import 'dart:math';

import 'package:flutter/material.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final TextEditingController _propertyValueController = TextEditingController(text: '1,500,000');
  final TextEditingController _loanAmountController = TextEditingController(text: '1,500,000');
  
  String _propertyType = 'Residential';
  String _theProperty = '1';
  double _loanTerm = 10.0; // Default value is 10 months
  
  double _grossLoan = 650000.0;
  double _netLoan = 41850.0;
  double _interestRate = 2.25;
  double _emiAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateEMI();
    
    // Add listeners to controllers to recalculate when text changes
    _propertyValueController.addListener(_onInputChanged);
    _loanAmountController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    _calculateEMI();
  }

  void _calculateEMI() {
    // Parse input values
    double propertyValue = _parseCurrency(_propertyValueController.text);
    double loanAmount = _parseCurrency(_loanAmountController.text);
    double loanTermMonths = _loanTerm;

    // Validate inputs
    if (propertyValue <= 0 || loanAmount <= 0 || loanTermMonths <= 0) {
      return;
    }

    // Calculate interest rate based on property type and loan term
    _calculateInterestRate();

    // Convert annual interest rate to monthly and percentage to decimal
    double monthlyInterestRate = _interestRate / 12 / 100;

    // Calculate EMI using the formula: 
    // EMI = [P x R x (1+R)^N] / [(1+R)^N - 1]
    // Where P = Principal, R = Monthly Interest Rate, N = Loan Term in Months
    if (monthlyInterestRate > 0) {
      double emi = (loanAmount * 
                   monthlyInterestRate * 
                   _pow(1 + monthlyInterestRate, loanTermMonths)) / 
                  (_pow(1 + monthlyInterestRate, loanTermMonths) - 1);
      
      // Calculate total payment (Gross Loan)
      double totalPayment = emi * loanTermMonths;
      
      // Calculate net loan (principal amount)
      double netLoan = loanAmount;

      setState(() {
        _emiAmount = emi;
        _grossLoan = totalPayment;
        _netLoan = netLoan;
      });
    } else {
      // If interest rate is 0, EMI is simply loan amount divided by months
      double emi = loanAmount / loanTermMonths;
      setState(() {
        _emiAmount = emi;
        _grossLoan = loanAmount;
        _netLoan = loanAmount;
      });
    }
  }

  void _calculateInterestRate() {
    // Different interest rates based on property type and loan term
    switch (_propertyType) {
      case 'Residential':
        if (_loanTerm <= 12) {
          _interestRate = 2.25;
        } else if (_loanTerm <= 24) {
          _interestRate = 2.75;
        } else if (_loanTerm <= 36) {
          _interestRate = 3.25;
        } else if (_loanTerm <= 48) {
          _interestRate = 3.75;
        } else {
          _interestRate = 4.25;
        }
        break;
      case 'Commercial':
        if (_loanTerm <= 12) {
          _interestRate = 3.25;
        } else if (_loanTerm <= 24) {
          _interestRate = 3.75;
        } else if (_loanTerm <= 36) {
          _interestRate = 4.25;
        } else if (_loanTerm <= 48) {
          _interestRate = 4.75;
        } else {
          _interestRate = 5.25;
        }
        break;
      case 'Industrial':
        if (_loanTerm <= 12) {
          _interestRate = 4.25;
        } else if (_loanTerm <= 24) {
          _interestRate = 4.75;
        } else if (_loanTerm <= 36) {
          _interestRate = 5.25;
        } else if (_loanTerm <= 48) {
          _interestRate = 5.75;
        } else {
          _interestRate = 6.25;
        }
        break;
      default:
        _interestRate = 2.25;
    }
  }

  double _pow(double x, double y) {
    return pow(x, y).toDouble();
  }

  double _parseCurrency(String value) {
    try {
      // Remove currency symbols and commas, then parse
      String cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleanedValue.isEmpty ? '0' : cleanedValue);
    } catch (e) {
      return 0.0;
    }
  }


  String _formatCurrencyWithDecimal(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(\.\d+)?$)'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Loan Calculator',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              const Text(
                'Find out how much you or your clients can borrow today with our Loan Calculators.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: "Enter a few relevant details about your property and get a free instant quote with indicative terms estimating how much it may cost."',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              // Loan Calculator Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loan Calculator',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Property Type
                      _buildDropdownField(
                        label: 'Property Type',
                        value: _propertyType,
                        onChanged: (String? value) {
                          setState(() {
                            _propertyType = value!;
                            _calculateEMI();
                          });
                        },
                        items: ['Residential', 'Commercial', 'Industrial'],
                      ),
                      const SizedBox(height: 16),

                      // The Property
                      _buildDropdownField(
                        label: 'The Property',
                        value: _theProperty,
                        onChanged: (String? value) {
                          setState(() {
                            _theProperty = value!;
                          });
                        },
                        items: ['1', '2', '3', '4', '5'],
                      ),
                      const SizedBox(height: 16),

                      // Property Value
                      _buildCurrencyTextField(
                        controller: _propertyValueController,
                        label: 'Property Value',
                        onChanged: (String value) {
                          _calculateEMI();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Loan Amount Required
                      _buildCurrencyTextField(
                        controller: _loanAmountController,
                        label: 'Loan Amount Required',
                        onChanged: (String value) {
                          _calculateEMI();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Loan Term - Simple display with slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loan Term',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Display box showing selected value
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_loanTerm.toInt()} Months',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Simple Slider
                          Slider(
                            value: _loanTerm,
                            min: 1.0,
                            max: 60.0,
                            divisions: 59, // 1 to 60 months
                            onChanged: (double value) {
                              setState(() {
                                _loanTerm = value;
                                _calculateEMI();
                              });
                            },
                            activeColor: const Color(0xFFD79A2F), // Gold color
                            inactiveColor: Colors.grey[300],
                          ),
                          
                          // Month indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '1 Month',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '60 Months',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Loan Estimate Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Loan Estimate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Gross Loan (Total Payment)
                        _buildEstimateRow(
                          label: 'Total Payment',
                          value: _formatCurrencyWithDecimal(_grossLoan),
                        ),
                        const SizedBox(height: 12),

                        // Net Loan (Principal Amount)
                        _buildEstimateRow(
                          label: 'Loan Amount',
                          value: _formatCurrencyWithDecimal(_netLoan),
                        ),
                        const SizedBox(height: 12),

                        // Interest Rate
                        _buildEstimateRow(
                          label: 'Interest Rate',
                          value: '${_interestRate.toStringAsFixed(2)}% ($_propertyType)',
                        ),
                        const SizedBox(height: 12),

                        // Monthly EMI
                        _buildEstimateRow(
                          label: 'Monthly EMI',
                          value: _formatCurrencyWithDecimal(_emiAmount),
                        ),
                        const SizedBox(height: 12),

                        // Total Interest
                        _buildEstimateRow(
                          label: 'Total Interest',
                          value: _formatCurrencyWithDecimal(_grossLoan - _netLoan),
                        ),

                        const SizedBox(height: 20),

                        // Disclaimer
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: const Text(
                            'This is an estimate only and is used to give you a basic understanding of our terms. To get a precise quote, contact us now.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Talk To Expert Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle expert consultation
                              _showExpertDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD79A2F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Talk To An Expert',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required Function(String?) onChanged,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              underline: const SizedBox(),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyTextField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD79A2F)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEstimateRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showExpertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Talk To An Expert"),
          content: const Text(
            "Our loan experts are available to provide you with personalized advice and accurate calculations based on your specific situation.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add your contact logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD79A2F),
                foregroundColor: Colors.white,
              ),
              child: const Text("Contact Now"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _propertyValueController.removeListener(_onInputChanged);
    _loanAmountController.removeListener(_onInputChanged);
    _propertyValueController.dispose();
    _loanAmountController.dispose();
    super.dispose();
  }
}