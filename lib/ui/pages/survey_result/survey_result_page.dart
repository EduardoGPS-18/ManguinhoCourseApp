import 'package:app_curso_manguinho/ui/components/components.dart';
import 'package:flutter/material.dart';

import '../pages.dart';

import '../../helpers/helpers.dart';

class SurveyResultPage extends StatelessWidget {
  final SurveyResultPresenter presenter;

  const SurveyResultPage({
    @required this.presenter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.strings.surveys),
        centerTitle: true,
      ),
      body: Builder(
        builder: (_) {
          presenter.isLoading.listen((isLoading) {
            if (isLoading == true) {
              showLoading(context);
            } else {
              hideLoading(context);
            }
          });

          presenter.loadData();

          return StreamBuilder<dynamic>(
            stream: presenter.surveysData,
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return ReloadScreen(
                  error: snapshot.error,
                  reload: presenter.loadData,
                );
              }
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: 4,
                  itemBuilder: (ctx, index) {
                    if (index == 0) {
                      return Container(
                        padding: EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
                        child: Text('Qual é seu framework web favorito?'),
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withAlpha(90),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(
                                'http://fordevs.herokuapp.com/static/img/logo-angular.png',
                                width: 40,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Text(
                                    'Angular',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              Text(
                                '100%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).highlightColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                        ),
                      ],
                    );
                  },
                );
              }
              return Center();
            },
          );
        },
      ),
    );
  }
}
