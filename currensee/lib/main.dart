import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received notification: \${message.notification?.title}');
  });
  runApp(CurrenSeeApp());
}

class CurrenSeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CurrenSee',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
          headlineSmall: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(

          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> loginWithEmail() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

          title: Text('Currensee')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() => isPasswordVisible = !isPasswordVisible);
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
              SizedBox(height: 20),
              isLoading ? CircularProgressIndicator() : Column(
                children: [
                  ElevatedButton(
                    onPressed: loginWithEmail,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (context) => RegisterScreen())),
                    child: Text('Create an account'),
                  ),
                  Footer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> register() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CurrenSee')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() => isPasswordVisible = !isPasswordVisible);
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
              SizedBox(height: 20),
              isLoading ? CircularProgressIndicator() : ElevatedButton(
                onPressed: register,
                child: Text('Register'),
              ),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  final String userId;

  CurrencyConverterScreen({required this.userId});

  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  List<String> currencies = ['USD', 'EUR', 'GBP', 'NGN'];
  String? selectedBase = 'USD';
  String? selectedTarget = 'EUR';
  TextEditingController amountController = TextEditingController();
  String convertedAmount = '';

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  Future<void> loadCurrencies() async {
    final url = Uri.parse('http://localhost:5001/currencies/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currencies = List<String>.from(data['currencies']);
        });
      }
    } catch (error) {
      print('Error loading currencies: $error');
    }
  }

  Future<void> addCurrency(String currency) async {
    if (!currencies.contains(currency)) {
      final url = Uri.parse('http://localhost:5001/add-currency/${widget.userId}');
      try {
        final response = await http.post(url, body: jsonEncode({'currency': currency}), headers: {'Content-Type': 'application/json'});
        if (response.statusCode == 200) {
          loadCurrencies(); // Reload the updated currency list
          setState(() {
            selectedBase = currency;
            selectedTarget = currency;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$currency added successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add $currency.')),
          );
        }
      } catch (error) {
        print('Error adding currency: $error');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$currency is already in the list.')),
      );
    }
  }

  Future<void> convertCurrency() async {
    final url = Uri.parse(
        'http://localhost:5001/convert?base=$selectedBase&target=$selectedTarget&amount=${amountController.text}&user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          convertedAmount = '${data['convertedAmount']} ${data['target']}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversion failed')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newCurrency = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CurrencyListScreen(
                    onCurrencySelected: (currency) {
                      Navigator.pop(context, currency);
                    },
                  ),
                ),
              );
              if (newCurrency != null) {
                addCurrency(newCurrency);
              }
            },
          ),
        ],
      ),
      drawer:AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            DropdownButton<String>(
              value: selectedBase,
              items: currencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBase = newValue;
                });
              },
            ),
            DropdownButton<String>(
              value: selectedTarget,
              items: currencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedTarget = newValue;
                });
              },
            ),
            ElevatedButton(
              onPressed: convertCurrency,
              child: Text('Convert'),
            ),
            SizedBox(height: 20),
            Text(
              convertedAmount,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversionHistoryScreen extends StatefulWidget {
  final String userId;
  ConversionHistoryScreen({required this.userId});

  @override
  _ConversionHistoryScreenState createState() => _ConversionHistoryScreenState();
}

class _ConversionHistoryScreenState extends State<ConversionHistoryScreen> {
  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    final url = Uri.parse('http://localhost:5001/history/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          history = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conversion History')),
      drawer: AppDrawer(),
      body: history.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final conversion = history[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child:ListTile(
              title: Text('${conversion['base_currency']} → ${conversion['target_currency']}'),
              subtitle: Text(
                'Amount: ${conversion['amount']} → ${conversion['converted_amount']} at rate: ${conversion['rate']}',
              ),
              trailing: Text(
                '${DateTime.parse(conversion['conversion_date']).toLocal()}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CurrencyListScreen extends StatefulWidget {
  final Function(String) onCurrencySelected;

  CurrencyListScreen({required this.onCurrencySelected});

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  List currencies = [];
  List filteredCurrencies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
    searchController.addListener(() => filterCurrencies());
  }

  Future<void> fetchCurrencies() async {
    final url = Uri.parse('http://localhost:5001/currencies');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          currencies = jsonDecode(response.body);
          filteredCurrencies = currencies;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load currencies')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void filterCurrencies() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCurrencies = currencies.where((currency) {
        final name = currency['name'].toLowerCase();
        final code = currency['code'].toLowerCase();
        return name.contains(query) || code.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Currency')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Currency',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredCurrencies.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = filteredCurrencies[index];
                return ListTile(
                  leading: Image.network(
                    currency['flag'],
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.flag),
                  ),
                  title: Text('${currency['name']} (${currency['code']})'),
                  onTap: () {
                    widget.onCurrencySelected(currency['code']);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExchangeRateScreen extends StatefulWidget {
  final String? currencyCode;  // Optional currency code for single currency view
  final String? currencyName;  // Optional currency name

  ExchangeRateScreen({this.currencyCode, this.currencyName});

  @override
  _ExchangeRateScreenState createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  List rates = [];
  List filteredRates = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
    searchController.addListener(filterRates);
  }

  Future<void> fetchExchangeRates() async {
    final base = widget.currencyCode ?? 'USD';  // Default to USD if no currency is passed
    final url = Uri.parse('http://localhost:5001/exchange-rates/$base');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          rates = jsonDecode(response.body);
          filteredRates = rates;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exchange rates')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void filterRates() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredRates = rates.where((rate) {
        final currency = rate['name'].toLowerCase();
        final code = rate['code'].toLowerCase();
        return currency.contains(query) || code.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currencyName != null
            ? 'Exchange Rates for ${widget.currencyName}'
            : 'All Exchange Rates'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Currency',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredRates.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredRates.length,
              itemBuilder: (context, index) {
                final rate = filteredRates[index];
                return ListTile(
                  leading: Image.network(
                    rate['flag'],
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.flag),
                  ),
                  title: Text('${rate['name']} (${rate['code']})'),
                  subtitle: Text('Rate: ${rate['symbol']} ${rate['rate']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MarketNewsScreen extends StatefulWidget {
  @override
  _MarketNewsScreenState createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen> {
  List news = [];

  Future<void> fetchNews() async {
    final url = Uri.parse('http://localhost:5001/market-news');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          news = data['news'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load news')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Market News')),
      drawer: AppDrawer(),
      body: news.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: news.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: news[index]['urlToImage'] != null
                  ? Image.network(news[index]['urlToImage'], width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.article, size: 50),
              title: Text(news[index]['title']),
              subtitle: Text(news[index]['description'] ?? 'No description available'),
              onTap: () => launchUrl(news[index]['url']),
            ),
          );
        },
      ),
    );
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open news link')),
      );
    }
  }
}

class RateAlertsScreen extends StatefulWidget {
  @override
  _RateAlertsScreenState createState() => _RateAlertsScreenState();
}

class _RateAlertsScreenState extends State<RateAlertsScreen> {
  TextEditingController targetRateController = TextEditingController();
  String? selectedBase = 'USD';
  String? selectedTarget = 'EUR';
  List alerts = [];

  @override
  void initState() {
    super.initState();
    fetchRateAlerts();
  }

  // Fetch Rate Alerts
  Future<void> fetchRateAlerts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('http://localhost:5001/get-alerts/${user.uid}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          alerts = jsonDecode(response.body);
        });
      } else {
        print("Failed to load alerts");
      }
    } catch (error) {
      print("Error fetching alerts: $error");
    }
  }

  // Set Rate Alert
  Future<void> setRateAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to set alerts')),
      );
      return;
    }

    final url = Uri.parse('http://localhost:5001/set-alert');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': FirebaseAuth.instance.currentUser?.uid,  // Should be a string
          'base': selectedBase,
          'target': selectedTarget,
          'threshold': double.parse(targetRateController.text),
        }),

      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rate alert set successfully!')),
        );
        fetchRateAlerts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set rate alert')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  // Delete Rate Alert
  Future<void> deleteAlert(int alertId) async {
    final url = Uri.parse('http://localhost:5001/delete-alert/$alertId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alert deleted successfully!')),
        );
        fetchRateAlerts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete alert')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate Alerts')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdowns
            DropdownButton<String>(
              value: selectedBase,
              items: ['USD', 'EUR', 'GBP', 'NGN'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBase = newValue;
                });
              },
            ),
            DropdownButton<String>(
              value: selectedTarget,
              items: ['USD', 'EUR', 'GBP', 'NGN'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedTarget = newValue;
                });
              },
            ),
            // Target Rate Input
            TextField(
              controller: targetRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Target Rate'),
            ),
            SizedBox(height: 10),
            // Set Alert Button
            ElevatedButton(
              onPressed: setRateAlert,
              child: Text('Set Alert'),
            ),
            Divider(),
            // Alerts List
            Expanded(
              child: alerts.isEmpty
                  ? Center(child: Text('No Alerts Set'))
                  : ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return ListTile(
                    title: Text('${alert['base_currency']} to ${alert['target_currency']}'),
                    subtitle: Text('Threshold: ${alert['threshold']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteAlert(alert['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserPreferencesScreen extends StatefulWidget {
  @override
  _UserPreferencesScreenState createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  String selectedBaseCurrency = 'USD';
  String selectedTargetCurrency = 'EUR';

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }


  Future<void> fetchPreferences() async {
    const userId = '1'; // Replace with the actual user_id or fetch it after login

    final url = Uri.parse('http://localhost:5001/preferences/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Fetched preferences: $data");

        setState(() {
          selectedBaseCurrency = data['base_currency'] ?? 'USD';
          selectedTargetCurrency = data['target_currency'] ?? 'EUR';
        });
      } else {
        print('Failed to load preferences: ${response.body}');
      }
    } catch (error) {
      print('Error fetching preferences: $error');
    }
  }


  Future<void> savePreferences() async {
    final url = Uri.parse('http://localhost:5001/preferences');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': FirebaseAuth.instance.currentUser?.uid,
          'base_currency': selectedBaseCurrency,
          'target_currency': selectedTargetCurrency,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preferences updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preferences')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Preferences')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedBaseCurrency,
              items: ['USD', 'EUR', 'GBP', 'NGN'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBaseCurrency = newValue!;
                });
              },
            ),
            DropdownButton<String>(
              value: selectedTargetCurrency,
              items: ['USD', 'EUR', 'GBP', 'NGN'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedTargetCurrency = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePreferences,
              child: Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List faqs = [];
  TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    final response = await http.get(Uri.parse('http://localhost:5001/faqs'));
    if (response.statusCode == 200) {
      setState(() {
        faqs = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load FAQs')),
      );
    }
  }

  Future<void> submitFeedback() async {
    final response = await http.post(
      Uri.parse('http://localhost:5001/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': '1', 'message': feedbackController.text}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted!')),
      );
      feedbackController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support & Feedback')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FAQs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(faqs[index]['question']),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(faqs[index]['answer']),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text('Submit Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitFeedback,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();

  Future<void> submitFeedback() async {
    final url = Uri.parse('http://localhost:5001/feedback');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': '1', // Replace with the actual user ID
        'message': feedbackController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feedback submitted!')));
      feedbackController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit feedback')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Feedback')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitFeedback,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(FirebaseAuth.instance.currentUser?.displayName ?? 'User'),
            accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? 'Not Logged In'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('My Account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text('Currency Converter'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => CurrencyConverterScreen(userId: '1'))),
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('Currency List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CurrencyListScreen(
                    onCurrencySelected: (String code) {
                      print('Selected Currency: $code');
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Exchange Rates'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExchangeRateScreen(), // No currency passed, shows all rates
                ),
              );
            },
          ),

          ListTile(
              leading: Icon(Icons.history),
              title: Text('Conversion History'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConversionHistoryScreen(
                      userId: FirebaseAuth.instance.currentUser?.uid ?? '1',)),
              )
          ),
          ListTile(
            leading: Icon(Icons.article),
            title: Text('Market News'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MarketNewsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Rate Alerts'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RateAlertsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.support),
            title: Text('User Support'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SupportScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Preferences'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserPreferencesScreen())),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
          Footer(),
        ],
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? fcmToken;

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get and store FCM token
    String? token = await messaging.getToken();
    setState(() {
      fcmToken = token;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New Alert: ${message.notification?.title}')),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RateAlertsScreen()));
    });
  }

  @override
  void initState() {
    super.initState();
    setupFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CurrenSee Home')),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to CurrenSee!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (fcmToken != null)
              Text(
                'Notification Token: $fcmToken',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CurrencyConverterScreen(userId: '1'))),
              child: Text('Go to Currency Converter'),
            ),
          ],
        ),
      ),
    );
  }
}


// Utility function to show snackbars
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// Function to handle logout and reset state
Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
}

// Function to check login status and redirect
void checkLoginStatus(BuildContext context) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  });
}

// Function to fetch user profile
Future<Map<String, dynamic>> fetchUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  return {
    'name': user?.displayName ?? 'Guest',
    'email': user?.email ?? 'No Email',
  };
}
class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String name = 'Loading...';
  String email = 'Loading...';
  bool isPasswordVisible = false;
  String? profileImageUrl;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = await fetchUserProfile();
    setState(() {
      name = user['name'];
      email = user['email'];
      profileImageUrl = user['profileImageUrl'];
      emailController.text = email;
    });
  }

  Future<void> updateEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.updateEmail(emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update email: $e')));
    }
  }

  Future<void> updatePassword() async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Account')),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: updateEmail,
              child: Text('Update Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() => isPasswordVisible = !isPasswordVisible);
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: updatePassword,
              child: Text('Update Password'),
            ),
            SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => logout(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.redAccent,
            ),
            child: Text('Sign Out', style: TextStyle(fontSize: 18)),
          ),
        ),
          ],
        ),
      ),
    );
  }
}

final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.blueAccent,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
);

final InputDecoration textFieldDecoration = InputDecoration(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  filled: true,
  fillColor: Colors.grey[200],
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
);
void navigateWithAnimation(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}
// Firebase Auth Debugging
void checkFirebaseAuthStatus() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print("User is not logged in");
    } else {
      print("User is logged in: ${user.email}");
    }
  });
}

// API Debugging - Error Handling
Future<void> debugApiCall() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:5001/debug'));
    if (response.statusCode == 200) {
      print("API is working fine: ${response.body}");
    } else {
      print("API issue: ${response.statusCode}");
    }
  } catch (e) {
    print("Error calling API: $e");
  }
}
class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '© 2025 ABC Finance Limited',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
// Common Flutter Issues & Fixes
void commonFlutterFixes() {
  print("If UI changes are not reflecting:");
  print("- Run `flutter clean`");
  print("- Delete `pubspec.lock` and run `flutter pub get`");
  print("- Restart the emulator");
  print("- Ensure you have enabled Firebase Auth");
}
