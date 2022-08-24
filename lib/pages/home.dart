import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:starwars_flutter/class/favorites.dart';
import 'package:starwars_flutter/func/data.dart';
import 'package:starwars_flutter/func/swapi.dart';
import 'package:starwars_flutter/design/decoration.dart';
import 'package:starwars_flutter/design/styletext.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Color red = Color.fromARGB(255, 196, 0, 0);
  Color gray = Color.fromARGB(255, 117, 117, 117);

  bool chooseAvatar = false;

  List<String> myFavorite = []; // Favoritos escolhidos

  List<String> charactersList = []; // Personagens Api
  List<String> moviesList = []; // Filmes Api

//Tab
  late TabController _tabController;
  int selectedMenuGlobal = 0; //Tabela Selecionada
  //Filmes 0, Personagens 1, Favoritos 2, Site 3
  bool showSite = false;

// Init
  @override
  void initState() {
    //GET LOCAL DATA FROM SQLFLITE
    getSQLData();

    //TAB CONTROL
    tabControl();

    //Personagens
    for (int i = 1; i < 84; i++) {
      getAPIcharacters(i);
    }
    //Filmes
    for (int i = 1; i < 7; i++) {
      getAPImovies(i);
    }

    super.initState();
  }

  tabControl() {
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      selectedMenuGlobal = _tabController.index;
      setState(() {});
    });
  }

  getAPImovies(int i) {
    SWAPI _api = SWAPI();
    _api.getRawDataFromURL('https://swapi.dev/api/films/$i').then((result) {
      if (result.statusCode == 200) {
        final name = jsonDecode(result.body)['title']; //Resposta Positiva
        final episodeID =
            jsonDecode(result.body)['episode_id']; //Resposta Positiva
        moviesList.add('Episode $episodeID: $name');
        setState(() {});
      }
    });
  }

  getAPIcharacters(int i) {
    SWAPI _api = SWAPI();
    _api.getRawDataFromURL('https://swapi.dev/api/people/$i').then((result) {
      if (result.statusCode == 200) {
        String name =
            jsonDecode(result.body)['name'].toString(); //Resposta Positiva
        name = name.replaceAll('Ã©', 'é');
        charactersList.add(name);
        setState(() {});
      }
    });
  }

  getSQLData() async {
    List<Favorite> favsList = await Sql().funcFavorites(); //Favoritos Sql
    for (var favoriteObject in favsList) {
      myFavorite.add(favoriteObject.name); //Salvo na lista de favoritos
    }
  }

// d
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

// B
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/images/painel.jpg', // Background do darth vader
              height: _height,
              fit: BoxFit.fill),
          Column(
            children: [
              const SizedBox(height: 30),
              appBarWidget(),
              const SizedBox(height: 8),
              showSite
                  ? Expanded(child: listWidget(selectedMenu: 3)) // site
                  : Expanded(
                      child: Column(
                      children: [
                        tabBarWidget(), //Layout Tabs
                        Expanded(child: listSelectedWidget()), //lista nomes
                      ],
                    )),
            ],
          ),
          chooseAvatar ? chooseAvatarWidget() : Container(),
        ],
      ),
    );
  }

// widgets
  Widget appBarWidget() {
    return Row(
      children: [
        // site
        GestureDetector(
          onTap: () async {
            showSite = !showSite;
            setState(() {});
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: showSite ? red : Colors.black26,
              border: Border.all(
                width: 2,
                color: red,
              ),
            ),
            child: const Text(
              'Site Oficial',
              style: TextoBranco.text2,
            ),
          ),
        ),

        // Star Wars
        Expanded(child: Image.asset('assets/images/sw.png', height: 40)),

        // Fluttermoji
        GestureDetector(
          onTap: () {
            chooseAvatar = true;
            setState(() {});
          },
          child: CircleAvatar(
            backgroundColor: gray,
            radius: 33,
            child: FluttermojiCircleAvatar(
              backgroundColor: Color.fromARGB(255, 192, 192, 192),
              radius: 30,
            ),
          ),
        )
      ],
    );
  }

  //  Tabs
  Widget tabBarWidget() {
    return Container(
      color: gray.withOpacity(0.2),
      child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: selectedMenuGlobal <= 2 ? gray : Colors.transparent,
          ),
          tabs: const [
            Tab(text: 'Filmes'),
            Tab(text: 'Personagens'),
            Tab(text: 'Favoritos'),
          ]),
    );
  }

  Widget listSelectedWidget() {
    // Tabs
    return TabBarView(controller: _tabController, children: [
      listWidget(selectedMenu: 0),
      listWidget(selectedMenu: 1),
      listWidget(selectedMenu: 2),
    ]);
  }

  Widget listWidget({required int selectedMenu}) {
    List list = [];
    if (selectedMenu == 0) {
      list = List.from(moviesList);
      list.sort();
    } else if (selectedMenu == 1) {
      list = List.from(charactersList);
      list.sort();
    } else if (selectedMenu == 2) {
      list = List.from(myFavorite);
      list.sort();
    }

    if (selectedMenu <= 2) {
      return ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            if (selectedMenu == 0) {
              return moviesRow(name: list[index]);
            } else if (selectedMenu == 1) {
              return charactersRow(name: list[index]);
            } else {
              return favoritesRow(name: list[index]);
            }
          });
    } else {
      return InAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse('https://www.starwars.com/community')),
      );
    }
  }

  Widget moviesRow({required String name}) {
    bool isFavorite = myFavorite.contains(name);
    return GestureDetector(
      onTap: () {
        showSearchSnackbar(name); //pesquisa no google imagens
      },
      child: Container(
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: customBoxDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(name,
                  textAlign: TextAlign.center, style: TextoBranco.text2),
            ),
            GestureDetector(
              onTap: () async {
                if (myFavorite.contains(name)) {
                  Favorite fav =
                      Favorite(id: myFavorite.indexOf(name), name: name);
                  Sql().deleteFavorite(fav.id);
                  myFavorite.remove(name);
                } else {
                  myFavorite.add(name);
                  Favorite fav =
                      Favorite(id: myFavorite.indexOf(name), name: name);
                  Sql().insertFavorite(fav);
                }
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.star_rounded,
                    size: 40, color: isFavorite ? Colors.red : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget charactersRow({required String name}) {
    bool isFavorite = myFavorite.contains(name);
    return GestureDetector(
      onTap: () {
        showSearchSnackbar(name);
      }, // google
      child: Container(
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: customBoxDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(name,
                  textAlign: TextAlign.center, style: TextoBranco.text1),
            ),
            GestureDetector(
              onTap: () {
                if (myFavorite.contains(name)) {
                  Favorite fav =
                      Favorite(id: myFavorite.indexOf(name), name: name);
                  Sql().deleteFavorite(fav.id);
                  myFavorite.remove(name);
                } else {
                  myFavorite.add(name);
                  Favorite fav =
                      Favorite(id: myFavorite.indexOf(name), name: name);
                  Sql().insertFavorite(fav);
                }
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.star_rounded,
                    size: 40, color: isFavorite ? Colors.red : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget favoritesRow({required String name}) {
    bool isMovieFavorite = moviesList.contains(name);

    return GestureDetector(
      onTap: () {
        showSearchSnackbar(name); //pesquisa no google imagens
      },
      child: Container(
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(
            width: 4.0,
            color: isMovieFavorite ? Colors.red : Colors.green,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(name,
                  textAlign: TextAlign.center, style: TextoBranco.text2),
            ),
          ],
        ),
      ),
    );
  }

  Widget chooseAvatarWidget() {
    return GestureDetector(
      onTap: () async {
        chooseAvatar = false;

        setState(() {});
      },
      child: Container(
        color: Color.fromARGB(255, 173, 173, 173),
        child: Column(
          children: [
            const Spacer(),
            FluttermojiCircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 100,
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: FluttermojiCustomizer(
                outerTitleText: 'Customizar:',
              ),
            ),
          ],
        ),
      ),
    );
  }

// snackbar
  showSearchSnackbar(String name) {
    final snackBar = snackBarUrl(name);

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  SnackBar snackBarUrl(String name) {
    return SnackBar(
        duration: const Duration(minutes: 5),
        action: SnackBarAction(
          label: 'Fechar',
          onPressed: () {},
        ),
        content: SizedBox(
          height: 631,
          child: InAppWebView(
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'https://www.google.com/search?q=$name&bih=649&biw=1366&hl=pt-BR&source=hp&ei=CeUEY4mBLq2H5OUPn_Co4Aw&iflsig=AJiK0e8AAAAAYwTzGU2gmXkYbYo8WTZv7wE8iP6GG0Wi&ved=0ahUKEwjJqeD-lt35AhWtA7kGHR84CswQ4dUDCAc&uact=5&oq=%24name&gs_lcp=Cgdnd3Mtd2l6EAMyBAgAEBMyBAgAEBMyBAgAEBMyBAgAEBMyBAgAEBMyBAgAEBMyBAgAEBMyBAgAEBMyBAgAEBMyBAgAEBM6CAgAEIAEELEDOgUIABCABDoLCAAQgAQQsQMQgwE6BQguEIAEOgcILhDUAhATUMgKWJASYMMVaAFwAHgAgAF-iAHRBJIBAzEuNJgBAKABAbABAA&sclient=gws-wiz')),
          ),
        ));
  }
}
