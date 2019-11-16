import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:spruce/widgets/helpers/screensize.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/product.dart';
import '../../scoped-models/main.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  Screen size;
  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: TitleDefault(product.title),
          ),
          Flexible(
            child: SizedBox(
              width: 8.0,
            ),
          ),
          Flexible(
            child: PriceTag(product.price.toString()),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.info),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  model.selectProduct(product.id);
                  Navigator.pushNamed<bool>(context, '/product/' + product.id)
                      .then((_) => model.selectProduct(null));
                },
              ),
              IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Colors.red,
                onPressed: () {
                  model.selectProduct(product.id);
                  model.toggleProductFavoriteStatus();
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 4.0,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      borderOnForeground: true,
      child: Container(
        height: size.getWidthPx(360),
        width: size.getWidthPx(330),
        child: Column(
          children: <Widget>[
            ClipRRect(
              // tag: product.id,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0)),
              child: FadeInImage(
                image: NetworkImage(product.image),
                height: 220,
                width: 370,
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/food.jpg'),
              ),
            ),
            _buildTitlePriceRow(),
            SizedBox(
              height: 10.0,
            ),
            AddressTag(product.location.address),
            _buildActionButtons(context)
          ],
        ),
      ),
    );
  }
}
