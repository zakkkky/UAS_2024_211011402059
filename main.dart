import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Crypto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      home: CryptoHomePage(),
    );
  }
}

class CryptoHomePage extends StatefulWidget {
  @override
  _CryptoHomePageState createState() => _CryptoHomePageState();
}

class _CryptoHomePageState extends State<CryptoHomePage> {
  late Future<List<Crypto>> futureCrypto;

  @override
  void initState() {
    super.initState();
    futureCrypto = fetchCrypto();
  }

  Future<List<Crypto>> fetchCrypto() async {
    final response =
        await http.get(Uri.parse('https://api.coinlore.net/api/tickers/'));

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)['data'];
      return json.map((data) => Crypto.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat data crypto');
    }
  }

  String getIconUrl(String symbol) {
    return 'https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/${symbol.toLowerCase()}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Cryptobase', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Crypto>>(
        future: futureCrypto,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data crypto'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Crypto crypto = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.network(
                        getIconUrl(crypto.symbol),
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                    title: Text(
                      crypto.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      crypto.symbol.toUpperCase(),
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${crypto.priceUsd.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${crypto.changePercent24Hr.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: crypto.changePercent24Hr >= 0
                                ? Color.fromARGB(255, 112, 5, 147)
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
