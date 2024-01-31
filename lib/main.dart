import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/Categories.dart';
import 'package:inventory/firebase_options.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory and Sales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<GDPData> _chartData;
  late TooltipBehavior _tooltipBehavior;

  late List<Product> _products;

  @override
  void initState() {
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);

    _products = getProductData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const CategoriesScreen(),
              ));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 25),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 500,
                child: SfCircularChart(
                  title: ChartTitle(
                      text: 'Sales & Inventory',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  legend: const Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap),
                  tooltipBehavior: _tooltipBehavior,
                  series: <CircularSeries>[
                    RadialBarSeries<GDPData, String>(
                        dataSource: _chartData,
                        xValueMapper: (GDPData data, _) => data.continent,
                        yValueMapper: (GDPData data, _) => data.gdp,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        enableTooltip: true,
                        maximumValue: 1000)
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _products.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(product.image.toString())),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        product.price.toString(),
                      ),
                      trailing: Text(
                        '\$ ${product.quantity.toString()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<GDPData> getChartData() {
    final List<GDPData> chartData = [
      GDPData('Shampoo', 432),
      GDPData('Soup', 453),
      GDPData('Grocery', 743),
      GDPData('Plastice', 633),
      GDPData('Pizza', 745),
      GDPData('Food', 759),
    ];
    return chartData;
  }

  List<Product> getProductData() {
    final List<Product> products = [
      Product('Shampoo', 10, 2, 'assets/1522664.avif'),
      Product('Soup', 15, 1, 'assets/pngimg.com - soup_PNG39.png'),
      Product('Grocery', 20, 3, 'assets/54018-9-grocery-free-hq-image.png'),
      Product('Pizza', 8, 5, 'assets/pizza-transparent-background-png.webp'),
      Product('Food', 14, 2, 'assets/1873233.png'),
    ];
    return products;
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);
  final String continent;
  final int gdp;
}

class Product {
  Product(this.name, this.quantity, this.price, this.image);
  final String name;
  final int quantity;
  final int price;
  final String image;
}
