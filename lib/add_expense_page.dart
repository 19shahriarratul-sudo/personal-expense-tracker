import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  bool loading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // Future<void> submitExpense() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => loading = true);
  //
  //   try {
  //     final user = supabase.auth.currentUser!.id;
  //     if (user == null) throw Exception('User not logged in');
  //
  //     // Insert expense WITHOUT .execute() (latest SDK)
  //     final response = await supabase.from('expenses').insert({
  //       'user_id': user,
  //       'title': titleController.text.trim(),
  //       'amount': double.parse(amountController.text.trim()),
  //       'category': selectedCategory,
  //       'expense_date': selectedDate.toIso8601String(),
  //     });
  //
  //     // Supabase returns List<Map<String, dynamic>> on success
  //     if (response == null || response.isEmpty) {
  //       throw Exception('Failed to add expense');
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Expense added successfully')),
  //     );
  //
  //     // Clear form
  //     titleController.clear();
  //     amountController.clear();
  //     setState(() => selectedCategory = 'Food');
  //     setState(() => selectedDate = DateTime.now());
  //
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  //
  //   setState(() => loading = false);
  // }
  Future<void> submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Latest SDK: .insert() returns List<Map<String,dynamic>>
      final inserted = await supabase.from('expenses').insert({
        'user_id': user.id,
        'title': titleController.text.trim(),
        'amount': double.parse(amountController.text.trim()),
        'category': selectedCategory,
        'expense_date': selectedDate.toIso8601String(),
      }).select(); // <- important, returns the inserted row

      if (inserted.isEmpty) {
        throw Exception('Insert failed');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully')),
      );

      // Clear form
      titleController.clear();
      amountController.clear();
      setState(() => selectedCategory = 'Food');
      setState(() => selectedDate = DateTime.now());

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => loading = false);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null) return 'Enter a number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Food', 'Travel', 'Shopping', 'Bills','Entertainment','Other']
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedCategory = val);
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submitExpense,
                  child: loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
