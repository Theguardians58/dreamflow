import 'package:flutter/material.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/models/address.dart';
import 'package:aura_bloom/services/cart_service.dart';
import 'package:aura_bloom/services/order_service.dart';
import 'package:aura_bloom/services/user_service.dart';
import 'package:aura_bloom/screens/main_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final user = await UserService().getCurrentUser();
    if (mounted) {
      setState(() {
        _addresses = user?.addresses ?? [];
        _selectedAddress = _addresses.isNotEmpty ? _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first) : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select a delivery address'), backgroundColor: AuraColors.error),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final user = await UserService().getCurrentUser();
    final cartItems = await CartService().getCartItems();
    final total = await CartService().getCartTotal();

    await OrderService().createOrder(
      userId: user!.id,
      items: cartItems,
      totalAmount: total,
      shippingAddress: _selectedAddress!,
    );

    await CartService().clearCart();
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AuraColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.check_circle, size: 50, color: AuraColors.success),
            ),
            const SizedBox(height: 24),
            Text('Order Placed!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Your order has been successfully placed', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AuraColors.dustyRose, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _StepIndicator(number: 1, label: 'Address', isActive: _currentStep == 0, isCompleted: _currentStep > 0),
                Expanded(child: Container(height: 2, color: _currentStep > 0 ? AuraColors.dustyRose : AuraColors.lightGrey)),
                _StepIndicator(number: 2, label: 'Payment', isActive: _currentStep == 1, isCompleted: _currentStep > 1),
                Expanded(child: Container(height: 2, color: _currentStep > 1 ? AuraColors.dustyRose : AuraColors.lightGrey)),
                _StepIndicator(number: 3, label: 'Review', isActive: _currentStep == 2, isCompleted: false),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildAddressStep(),
                _buildPaymentStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(foregroundColor: AuraColors.dustyRose, side: BorderSide(color: AuraColors.dustyRose), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () {
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          _placeOrder();
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AuraColors.dustyRose, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isProcessing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_currentStep < 2 ? 'Continue' : 'Place Order', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return _addresses.isEmpty ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: AuraColors.mediumGrey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No addresses found', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AuraColors.mediumGrey)),
          const SizedBox(height: 8),
          Text('Please add a delivery address', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
        ],
      ),
    ) : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedAddress = address),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _selectedAddress?.id == address.id ? AuraColors.dustyRose : AuraColors.lightGrey, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.fullName, style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    if (_selectedAddress?.id == address.id)
                      Icon(Icons.check_circle, color: AuraColors.dustyRose),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${address.addressLine1}, ${address.addressLine2}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
                Text('${address.city}, ${address.state} - ${address.pincode}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
                const SizedBox(height: 4),
                Text(address.phoneNumber, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AuraColors.mediumGrey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Payment Method', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _PaymentOption(icon: Icons.account_balance_wallet, title: 'Cash on Delivery', subtitle: 'Pay when you receive', isSelected: true),
          _PaymentOption(icon: Icons.credit_card, title: 'Card Payment', subtitle: 'Credit or Debit card', isSelected: false),
          _PaymentOption(icon: Icons.account_balance, title: 'UPI', subtitle: 'Google Pay, PhonePe, etc.', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          FutureBuilder(
            future: Future.wait([CartService().getCartItems(), CartService().getCartTotal()]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final items = snapshot.data![0];
              final total = snapshot.data![1];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: Text('${item.product.name} x${item.quantity}', style: Theme.of(context).textTheme.bodyMedium)),
                        Text('₹${item.totalPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                  )),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: Theme.of(context).textTheme.titleLarge),
                      Text('₹${total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AuraColors.dustyRose)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({required this.number, required this.label, required this.isActive, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: isCompleted || isActive ? AuraColors.dustyRose : AuraColors.lightGrey, shape: BoxShape.circle),
          child: Center(child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 20) : Text('$number', style: TextStyle(color: isActive ? Colors.white : AuraColors.mediumGrey, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isActive ? AuraColors.dustyRose : AuraColors.mediumGrey)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;

  const _PaymentOption({required this.icon, required this.title, required this.subtitle, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AuraColors.dustyRose : AuraColors.lightGrey, width: 2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AuraColors.dustyRose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AuraColors.dustyRose),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AuraColors.mediumGrey)),
              ],
            ),
          ),
          if (isSelected) Icon(Icons.check_circle, color: AuraColors.dustyRose),
        ],
      ),
    );
  }
}
