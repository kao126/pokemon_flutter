import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './const/pokeapi.dart';
import './models/favorite.dart';
import './models/pokemon.dart';
import './poke_list_item.dart';

class PokeList extends StatefulWidget {
  const PokeList({Key? key}) : super(key: key);
  @override
  _PokeListState createState() => _PokeListState();
}

class _PokeListState extends State<PokeList> {
  static const int pageSize = 30;
  bool isFavoriteMode = true;
  int _currentPage = 1;

  // 表示個数
  int itemCount(List<Favorite> favs, int page) {
    int ret = page * pageSize;
    if (isFavoriteMode && ret > favs.length) {
      ret = favs.length;
    }
    if (ret > pokeMaxId) {
      ret = pokeMaxId;
    }
    return ret;
  }

  int itemId(List<Favorite> favs, int index) {
    int ret = index + 1; // 通常モード
    if (isFavoriteMode && index < favs.length) {
      ret = favs[index].pokeId;
    }
    return ret;
  }

  bool isLastPage(List<Favorite> favs, int page) {
    if (isFavoriteMode) {
      if (_currentPage * pageSize < favs.length) {
        return false;
      }
      return true;
    } else {
      if (_currentPage * pageSize < pokeMaxId) {
        return false;
      }
      return true;
    }
  }

  void changeMode(bool isFavoriteMode) {
    setState(() => isFavoriteMode = !isFavoriteMode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesNotifier>(
        builder: (context, favs, child) => Column(children: [
              Container(
                height: 24,
                alignment: Alignment.topRight,
                child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    onPressed: () async {
                      var ret = await showModalBottomSheet<bool>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return ViewModeBottomSheet(
                            favMode: isFavoriteMode,
                          );
                        },
                      );
                      if (ret != null && ret) {
                        changeMode(isFavoriteMode);
                      }
                    }),
              ),
              Expanded(child:
                  Consumer<PokemonsNotifier>(builder: (context, pokes, child) {
                if (itemCount(favs.favs, _currentPage) == 0) {
                  return const Text('no data');
                } else {
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    itemCount:
                        itemCount(favs.favs, _currentPage) + 1, // pokeMaxId,
                    itemBuilder: (context, index) {
                      if (index == itemCount(favs.favs, _currentPage)) {
                        return OutlinedButton(
                          onPressed: isLastPage(favs.favs, _currentPage)
                              ? null
                              : () => {
                                    setState(
                                        () => setState(() => _currentPage++))
                                  },
                          child: const Text('more'),
                        );
                      } else {
                        return PokeListItem(
                          poke: pokes.byId(itemId(favs.favs, index)),
                        );
                      }
                    },
                  );
                }
              }))
            ]));
  }
}

class ViewModeBottomSheet extends StatelessWidget {
  const ViewModeBottomSheet({
    Key? key,
    required this.favMode,
  }) : super(key: key);
  final bool favMode;

  String mainText(bool fav) {
    if (fav) {
      return 'お気に入りのポケモンが表示されています';
    } else {
      return 'すべてのポケモンが表示されています';
    }
  }

  String menuTitle(bool fav) {
    if (fav) {
      return '「すべて」表示に切り替え';
    } else {
      return '「お気に入り」表示に切り替え';
    }
  }

  String menuSubtitle(bool fav) {
    if (fav) {
      return 'すべてのポケモンが表示されます';
    } else {
      return 'お気に入りに登録したポケモンのみが表示されます';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 5,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                mainText(favMode),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(
                menuTitle(favMode),
              ),
              subtitle: Text(
                menuSubtitle(favMode),
              ),
              onTap: () {
                Navigator.pop(context, true);
              },
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              child: const Text('キャンセル'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}
