import 'package:flutter/material.dart';
import 'package:projeto_2_cards/models/app_bloc.dart';
import 'package:projeto_2_cards/models/card.dart';
import 'package:projeto_2_cards/pages/login_page.dart';
import 'package:projeto_2_cards/routes/routes.dart';
import 'package:projeto_2_cards/services/cards_service.dart';

class CardsPage extends StatefulWidget {
  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  List<Cartao> cards;
  Future<List<Cartao>> getCards;
  CardsService cardsService = CardsService();

  @override
  void initState() {
    super.initState();
    getCards = cardsService.buscarTodosCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                padding: EdgeInsets.only(left: 15.0, top: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Color.fromRGBO(43, 56, 91, .4),
                      child: Icon(
                        Icons.perm_identity,
                        size: 60,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    Text(
                      AppBloc.user.email,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      AppBloc.user.name,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(43, 56, 91, 1),
                ),
              ),
              ListTile(
                title: Text('Sair'),
                onTap: () {
                  AppBloc.user = null;
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Cards'),
          backgroundColor: Color.fromRGBO(43, 56, 91, 1),
          actions: [
            GestureDetector(
              child: Icon(Icons.add),
              onTap: () async {
                var cardCreated = await Navigator.of(context)
                    .pushNamed(Routes.CREATE_CARD_PAGE);

                if (cardCreated != null) {
                  setState(() {
                    cards.add(cardCreated);
                  });
                }
              },
            ),
            SizedBox(
              width: 15.0,
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: FutureBuilder(
            future: getCards,
            builder: (context, AsyncSnapshot<List<Cartao>> snapshot) {
              if (!snapshot.hasData) {
                print('nao tem data');
                return Center(
                  child: Text('Não há cartões salvos'),
                );
              } else if (snapshot.hasError) {
                print('tem erro');
                return Center(
                  child: Text(snapshot.error),
                );
              }
              cards = snapshot.data;
              cards.forEach((element) {
                print(element);
              });
              return ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  var card = cards[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).accentColor,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(60),
                                color: Theme.of(context).accentColor,
                              ),
                              child: Text(
                                card.id.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                card.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20,
                          color: Colors.grey,
                          thickness: 2,
                        ),
                        Text(
                          card.content,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.justify,
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.start,
                          children: [
                            FlatButton(
                              child: Text(
                                'Editar',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: () async {
                                var cardUpdated =
                                    await Navigator.of(context).pushNamed(
                                  Routes.CREATE_CARD_PAGE,
                                  arguments: card,
                                );

                                if (cardUpdated != null) {
                                  setState(() {
                                    card = cardUpdated;
                                  });
                                }
                              },
                              splashColor: Theme.of(context).accentColor,
                            ),
                            RaisedButton(
                              child: Text(
                                'Deletar',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: () async {
                                var deleted = await cardsService.delete(card);
                                if (deleted) {
                                  setState(() {
                                    cards.remove(card);
                                  });
                                }
                              },
                              splashColor: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ));
  }
}
