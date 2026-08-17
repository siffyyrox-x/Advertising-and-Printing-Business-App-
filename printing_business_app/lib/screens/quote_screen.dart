import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/chatbot_data.dart';
import '../data/services_data.dart';
import '../models/quote_request.dart';
import '../models/service.dart';
import '../utils/launcher_helper.dart';

/// Opens the Request Quote screen. [service] pre-selects a service when the
/// user arrived from an "Ask Quote" button on the Services screen.
Future<void> openQuoteScreen(BuildContext context, {Service? service}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => QuoteScreen(preselectedService: service),
    ),
  );
}

/// The Request Quote form.
///
/// Milestone 2 note: the form is fully working and validated, but the request
/// is only kept in memory on the device. There is no server or database yet,
/// so the app never claims that the request was sent to the company.
class QuoteScreen extends StatefulWidget {
  final Service? preselectedService;

  const QuoteScreen({super.key, this.preselectedService});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  int? _selectedServiceId;
  String? _suggestionText;

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.preselectedService?.serviceId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _detailsController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 3) {
      return 'Name is too short';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    // Email is optional, so an empty field is accepted.
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final RegExp pattern = RegExp(r'^[\w.\-]+@[\w\-]+\.[\w.\-]+$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateDetails(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe what you need';
    }
    if (value.trim().length < 10) {
      return 'Please give a little more detail';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    // Quantity is optional.
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final int? quantity = int.tryParse(value.trim());
    if (quantity == null || quantity <= 0) {
      return 'Enter a whole number, for example 100';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// The "AI Suggest a Suitable Service" button.
  /// Reads the description and picks the closest matching service.
  void _suggestService() {
    // Hide the keyboard so the suggestion is visible.
    FocusScope.of(context).unfocus();

    final String description = _detailsController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _suggestionText =
            'Please describe what you need first, then tap the button again.';
      });
      return;
    }

    final Service? suggestion = ChatBot.suggestService(description);
    setState(() {
      if (suggestion == null) {
        _suggestionText =
            'No matching service was found from your description. '
            'Please choose a service from the list above.';
      } else {
        _selectedServiceId = suggestion.serviceId;
        _suggestionText =
            'Suggested service: ${suggestion.title}. ${suggestion.priceNote} '
            'You can still change the selection above.';
      }
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the highlighted fields.')),
      );
      return;
    }

    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service.')),
      );
      return;
    }

    final QuoteRequest quote = QuoteStore.add(
      serviceId: _selectedServiceId!,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      projectDetails: _detailsController.text.trim(),
      quantity: _quantityController.text.trim(),
    );

    _showSuccessDialog(quote);
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _detailsController.clear();
    _quantityController.clear();
    setState(() {
      _selectedServiceId = null;
      _suggestionText = null;
    });
  }

  /// Builds a readable summary the customer can send over WhatsApp or email.
  String _quoteSummary(QuoteRequest quote) {
    final Service? service = ServicesData.byId(quote.serviceId);
    final String serviceName = service == null ? 'Not selected' : service.title;

    final StringBuffer buffer = StringBuffer()
      ..writeln('Quote request')
      ..writeln('Name: ${quote.customerName}')
      ..writeln('Phone: ${quote.phone}');
    if (quote.email.isNotEmpty) {
      buffer.writeln('Email: ${quote.email}');
    }
    buffer.writeln('Service: $serviceName');
    if (quote.quantity.isNotEmpty) {
      buffer.writeln('Quantity: ${quote.quantity}');
    }
    buffer.writeln('Details: ${quote.projectDetails}');
    return buffer.toString();
  }

  void _showSuccessDialog(QuoteRequest quote) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: <Widget>[
              Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Expanded(child: Text('Request saved')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Thank you, ${quote.customerName}.'),
                const SizedBox(height: 8),
                Text('Reference number: #${quote.quoteId}'),
                const SizedBox(height: 12),
                const Text(
                  'This version of the app saves your request on this device '
                  'only. It has not been sent to the company yet. Please send '
                  'it over WhatsApp, or call us, so we can prepare your quote.',
                  style: AppTheme.muted,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _clearForm();
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                LauncherHelper.openWhatsApp(
                  context,
                  message: _quoteSummary(quote),
                );
                _clearForm();
              },
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Send on WhatsApp'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  /// One consistent look for every field on this form.
  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Quote')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: <Widget>[
              const Text(
                'Fill in the form and we will prepare a price for you.',
                style: AppTheme.muted,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('Full Name'),
                validator: _validateName,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: _decoration('Phone Number'),
                validator: _validatePhone,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _decoration('Email (optional)'),
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<int>(
                value: _selectedServiceId,
                isExpanded: true,
                decoration: _decoration('Select Service'),
                hint: const Text('Choose a service'),
                items: ServicesData.active.map((Service service) {
                  return DropdownMenuItem<int>(
                    value: service.serviceId,
                    child: Text(service.title, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (int? value) {
                  setState(() => _selectedServiceId = value);
                },
                validator: (int? value) =>
                    value == null ? 'Please select a service' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: _decoration('Quantity (optional)', hint: 'e.g. 100'),
                validator: _validateQuantity,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _detailsController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  'Describe what you need',
                  hint: 'Example: 100 business cards, blue colour, matte paper',
                ),
                validator: _validateDetails,
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _suggestService,
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: const Text('AI Suggest a Suitable Service'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              if (_suggestionText != null) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: AppTheme.radius,
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Text(
                    _suggestionText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    'Submit Quote Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _clearForm,
                child: const Text('Clear form'),
              ),
              const SizedBox(height: 8),
              const Text(
                'No login or payment is needed in this version.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
