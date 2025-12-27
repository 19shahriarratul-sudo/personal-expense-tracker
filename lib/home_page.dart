// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'login_page.dart';
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   Future<void> logout(BuildContext context) async {
//     await Supabase.instance.client.auth.signOut();
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => logout(context),
//           ),
//         ],
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {},
//       //   child: const Icon(Icons.add),
//       // ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddExpensePage()),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//
//       body: Center(
//         child: Text(
//           'Welcome to Expense Tracker',
//           style: Theme.of(context).textTheme.headlineMedium,
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'add_expense_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    if (user == null) {
      // Just in case user is null, redirect to login
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          ).then((_) {
            setState(() {}); // Refresh when coming back from AddExpensePage
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchExpenses(user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final expenses = snapshot.data ?? [];

            // Calculate total expense
            double total = 0;
            for (var e in expenses) {
              total += (e['amount'] as num).toDouble();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Expense Card
                Card(
                  color: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expense',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Your Expenses',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Expenses List
                Expanded(
                  child: expenses.isEmpty
                      ? const Center(child: Text('No expenses yet'))
                      : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(expense['title']),
                          subtitle: Text(
                              '${expense['category']} • ${expense['expense_date'].toString().split('T')[0]}'),
                          trailing: Text(
                            '৳ ${expense['amount'].toString()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Fetch expenses from Supabase
  Future<List<Map<String, dynamic>>> fetchExpenses(String userId) async {
    final response = await supabase
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('expense_date', ascending: false);

    // Returns a List<Map<String,dynamic>>
    return List<Map<String, dynamic>>.from(response as List);
  }
}
