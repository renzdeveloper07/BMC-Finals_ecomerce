import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

const Color foodHubOrange = Color(0xFFFF5722);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FoodHubApp());
}

class FoodHubApp extends StatelessWidget {
  const FoodHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: foodHubOrange),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
      ),
      home: const WelcomePage(),
    );
  }
}

// WELCOME SCREEN

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fastfood, size: 100, color: foodHubOrange),
                const SizedBox(height: 20),
                const Text(
                  'FoodHub',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your Favorite Food Marketplace',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foodHubOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Get Started', style: TextStyle(fontSize: 17)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HOME SCREEN - GUEST BROWSING

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: foodHubOrange,
        foregroundColor: Colors.white,
        title: const Text('FoodHub', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shopping cart coming soon!')),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Food Lover! 👋',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'What would you like to eat today?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchText = value.toLowerCase().trim());
              },
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Popular Foods',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('isAvailable', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Unable to load foods. Please check Firestore Rules.');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data?.docs ?? [];
                final filteredProducts = products.where((doc) {
                  final name = (doc.data()['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchText);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No food products yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final data = filteredProducts[index].data();
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFE0D2),
                          child: Icon(Icons.fastfood, color: foodHubOrange),
                        ),
                        title: Text(
                          data['name']?.toString() ?? 'Food Item',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('₱${data['price'] ?? 0}'),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8DF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.storefront, size: 40, color: foodHubOrange),
                  const SizedBox(height: 10),
                  const Text(
                    'Own a Food Business?',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text('Sell your delicious food on FoodHub!'),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SellerRegisterPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: foodHubOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Become a Seller'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SELLER REGISTRATION

class SellerRegisterPage extends StatefulWidget {
  const SellerRegisterPage({super.key});

  @override
  State<SellerRegisterPage> createState() => _SellerRegisterPageState();
}

class _SellerRegisterPageState extends State<SellerRegisterPage> {
  final nameController = TextEditingController();
  final storeController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerSeller() async {
    if (nameController.text.trim().isEmpty ||
        storeController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete all fields. Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final user = credential.user!;

      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final sellerRef = FirebaseFirestore.instance.collection('sellers').doc(user.uid);

      batch.set(userRef, {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': 'seller',
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.set(sellerRef, {
        'sellerId': user.uid,
        'ownerName': nameController.text.trim(),
        'storeName': storeController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Registration Successful!'),
          content: const Text(
            'Your seller account has been created. Your account is currently pending admin approval.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerDashboardPage()),
                );
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.message ?? 'Registration failed.';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'Please use a stronger password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firestore error: ${e.message}. The Auth account may already have been created. Check Firebase Authentication before trying again.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget buildField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool password = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: password,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    storeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Registration'),
        backgroundColor: foodHubOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Your Store',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Register your food business with FoodHub.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            buildField('Owner Name', Icons.person, nameController),
            buildField('Store Name', Icons.store, storeController),
            buildField('Phone Number', Icons.phone, phoneController,
                keyboard: TextInputType.phone),
            buildField('Email Address', Icons.email, emailController,
                keyboard: TextInputType.emailAddress),
            buildField('Password', Icons.lock, passwordController, password: true),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : registerSeller,
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodHubOrange,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register Store', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SELLER DASHBOARD - ACCESS IS LIMITED TO APPROVED SELLERS

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('sellers').doc(user.uid).snapshots(),
      builder: (context, sellerSnapshot) {
        if (sellerSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to check seller status. Check Firestore Rules.')),
          );
        }
        if (sellerSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!sellerSnapshot.hasData || !sellerSnapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Seller account not found.')));
        }

        final sellerData = sellerSnapshot.data!.data()!;
        final status = sellerData['status']?.toString() ?? 'pending';
        final storeName = sellerData['storeName']?.toString() ?? 'My Store';
        final isApproved = status == 'approved';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Seller Dashboard'),
            backgroundColor: foodHubOrange,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomePage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          floatingActionButton: isApproved
              ? FloatingActionButton.extended(
                  backgroundColor: foodHubOrange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Food'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductPage()),
                    );
                  },
                )
              : null,
          body: !isApproved
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          status == 'pending' ? Icons.hourglass_top : Icons.block,
                          size: 85,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          status == 'pending' ? 'Waiting for Approval' : 'Seller Not Approved',
                          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          status == 'pending'
                              ? 'Your store "$storeName" is waiting for admin approval. You can add products once approved.'
                              : 'Your seller account is not approved. Please contact the administrator.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        Chip(
                          label: Text(status.toUpperCase()),
                          backgroundColor: const Color(0xFFFFE0B2),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $storeName!',
                            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Chip(
                            avatar: Icon(Icons.verified, color: Colors.green),
                            label: Text('APPROVED SELLER'),
                            backgroundColor: Color(0xFFE0F2F1),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'My Food Products',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .where('sellerId', isEqualTo: user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(child: Text('Unable to load products.'));
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final products = snapshot.data?.docs ?? [];
                          if (products.isEmpty) {
                            return const Center(
                              child: Text(
                                'No products yet. Tap Add Food to start selling.',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final doc = products[index];
                              final data = doc.data();
                              final name = data['name']?.toString() ?? 'Food Item';
                              final price = data['price'] ?? 0;
                              final available = data['isAvailable'] == true;

                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFFFE0D2),
                                    child: Icon(Icons.fastfood, color: foodHubOrange),
                                  ),
                                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('₱$price • ${available ? "Available" : "Unavailable"}'),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      try {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddProductPage(
                                                productId: doc.id,
                                                oldName: name,
                                                oldPrice: price.toString(),
                                              ),
                                            ),
                                          );
                                        } else if (value == 'toggle') {
                                          await doc.reference.update({
                                            'isAvailable': !available,
                                          });
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (dialogContext) => AlertDialog(
                                              title: const Text('Delete Product?'),
                                              content: const Text('Are you sure you want to delete this food?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(dialogContext, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(dialogContext, true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await doc.reference.delete();
                                          }
                                        }
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit Product')),
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: Text(available ? 'Set Unavailable' : 'Set Available'),
                                      ),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete Product')),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// ADD AND EDIT PRODUCT

class AddProductPage extends StatefulWidget {
  final String? productId;
  final String? oldName;
  final String? oldPrice;

  const AddProductPage({
    super.key,
    this.productId,
    this.oldName,
    this.oldPrice,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.oldName ?? '';
    priceController.text = widget.oldPrice ?? '';
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid food name and price.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final productRef = FirebaseFirestore.instance.collection('products');

      if (widget.productId == null) {
        final sellerDoc = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(user.uid)
            .get();
        final sellerData = sellerDoc.data();

        if (!sellerDoc.exists || sellerData?['status'] != 'approved') {
          throw Exception('Your seller account is not approved.');
        }

        await productRef.add({
          'name': name,
          'price': price,
          'isAvailable': true,
          'sellerId': user.uid,
          'storeName': sellerData?['storeName'] ?? 'FoodHub Store',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await productRef.doc(widget.productId).update({
          'name': name,
          'price': price,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.productId == null
                ? 'Food product added successfully!'
                : 'Product updated successfully!',
          ),
        ),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Food Product' : 'Edit Food Product'),
        backgroundColor: foodHubOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.fastfood, size: 90, color: foodHubOrange),
            const SizedBox(height: 25),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                prefixIcon: Icon(Icons.restaurant),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.payments),
                prefixText: '₱ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodHubOrange,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.productId == null ? 'Save Product' : 'Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ADMIN LOGIN

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginAdmin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      final adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!adminDoc.exists || adminDoc.data()?['role'] != 'admin') {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access denied. Admin account only.')),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Login failed.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: foodHubOrange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.admin_panel_settings, size: 90, color: foodHubOrange),
              const SizedBox(height: 20),
              const Text(
                'FoodHub Admin',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Admin Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: foodHubOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login as Admin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ADMIN DASHBOARD - APPROVE OR REJECT SELLERS

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<void> updateSellerStatus(
    BuildContext context,
    String sellerId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('sellers').doc(sellerId).update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'approved' ? 'Seller approved successfully!' : 'Seller rejected.'),
        ),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message}')),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: foodHubOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('sellers')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load seller applications. Check Firestore Rules.',
                textAlign: TextAlign.center,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sellers = snapshot.data?.docs ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Admin!',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Manage FoodHub seller applications.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      color: const Color(0xFFFFE8DF),
                      child: ListTile(
                        leading: const Icon(Icons.store, size: 35, color: foodHubOrange),
                        title: const Text(
                          'Pending Applications',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${sellers.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: foodHubOrange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Seller Applications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: sellers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 70, color: Colors.green),
                            SizedBox(height: 12),
                            Text('No pending applications.', style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sellers.length,
                        itemBuilder: (context, index) {
                          final doc = sellers[index];
                          final data = doc.data();

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Color(0xFFFFE0D2),
                                        child: Icon(Icons.storefront, color: foodHubOrange),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          data['storeName']?.toString() ?? 'Unnamed Store',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Owner: ${data['ownerName'] ?? 'N/A'}'),
                                  Text('Email: ${data['email'] ?? 'N/A'}'),
                                  Text('Phone: ${data['phone'] ?? 'N/A'}'),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => updateSellerStatus(
                                            context,
                                            doc.id,
                                            'approved',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Approve'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => updateSellerStatus(
                                            context,
                                            doc.id,
                                            'rejected',
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
    );
  }
}
