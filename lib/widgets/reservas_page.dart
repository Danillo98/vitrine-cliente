import 'package:flutter/material.dart';

class ReservasPage extends StatefulWidget {
  final List<Map<String, dynamic>> reservas;

  const ReservasPage({Key? key, required this.reservas}) : super(key: key);

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Suas reservas te aguardam...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Seus Produtos Reservados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: widget.reservas.isEmpty
                  ? Center(
                      child: Text('Nenhum produto reservado.'),
                    )
                  : ListView.builder(
                      itemCount: widget.reservas.length,
                      itemBuilder: (context, index) {
                        final reserva = widget.reservas[index];
                        return ListTile(
                          title: Text(reserva['nomeitem'] ?? ''),
                          subtitle: Text('Preço: ${reserva['preco'] ?? ''}'),
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
