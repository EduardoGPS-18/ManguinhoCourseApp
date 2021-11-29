import 'package:mockito/mockito.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import 'package:app_curso_manguinho/domain/helpers/helpers.dart';
import 'package:app_curso_manguinho/data/usecases/usecases.dart';
import 'package:app_curso_manguinho/domain/entities/entities.dart';

import 'package:app_curso_manguinho/data/http/http.dart';

import '../../../mocks/mocks.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  HttpClient httpClient;
  String url;
  RemoteLoadSurveyResult sut;
  Map<String, dynamic> surveyResult;

  PostExpectation mockHttpRequestCall() => when(httpClient.request(
        url: anyNamed('url'),
        method: anyNamed('method'),
      ));
  void mockHttpResponseData(Map<String, dynamic> data) {
    surveyResult = data;
    mockHttpRequestCall().thenAnswer((_) async => data);
  }

  void mockHttpResponseError(HttpError httpError) => mockHttpRequestCall().thenThrow(httpError);

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();

    sut = RemoteLoadSurveyResult(
      httpClient: httpClient,
      url: url,
    );
    mockHttpResponseData(FakeSurveyResultFactory.makeApiJson());
  });

  test('Should call httpClient with correct values', () async {
    await sut.loadBySurvey();

    verify(httpClient.request(url: url, method: 'get')).called(1);
  });

  test('Should return surveys on 200', () async {
    final result = await sut.loadBySurvey();

    final expectedReturn = SurveyResultEntity(
      surveyId: surveyResult['surveyId'],
      question: surveyResult['question'],
      answers: [
        SurveyAnswerEntity(
          answer: surveyResult['answers'][0]['answer'],
          isCurrentAnswer: surveyResult['answers'][0]['isCurrentAccountAnswer'],
          percent: surveyResult['answers'][0]['percent'],
          image: surveyResult['answers'][0]['image'],
        ),
        SurveyAnswerEntity(
          answer: surveyResult['answers'][1]['answer'],
          isCurrentAnswer: surveyResult['answers'][1]['isCurrentAccountAnswer'],
          percent: surveyResult['answers'][1]['percent'],
        ),
      ],
    );

    expect(result, expectedReturn);
  });

  test('Should throw unexpected error if http client returns 200 with invalid data', () async {
    mockHttpResponseData(FakeSurveyResultFactory.makeInvalidApiJson());

    final future = sut.loadBySurvey();

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw unexpected error if http client returns 404', () async {
    mockHttpResponseError(HttpError.notFound);

    final future = sut.loadBySurvey();

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw unexpected error if http client returns 500', () async {
    mockHttpResponseError(HttpError.serverError);

    final future = sut.loadBySurvey();

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw unexpected error if http client returns 403', () async {
    mockHttpResponseError(HttpError.forbidden);

    final future = sut.loadBySurvey();

    expect(future, throwsA(DomainError.accessDenied));
  });
}
