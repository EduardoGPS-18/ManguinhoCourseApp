import 'package:mockito/mockito.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import 'package:app_curso_manguinho/domain/helpers/helpers.dart';
import 'package:app_curso_manguinho/domain/entities/entities.dart';

import 'package:app_curso_manguinho/data/usecases/usecases.dart';
import 'package:app_curso_manguinho/data/cache/cache.dart';

import '../../../mocks/mocks.dart';

class CacheStorageSpy extends Mock implements CacheStorage {}

void main() {
  group('loadBySurvey', () {
    CacheStorage cacheStorage;
    LocalLoadSurveyResult sut;
    String surveyId;

    Map data;

    PostExpectation mockFetchCall() => when(cacheStorage.fetch(any));
    void mockFetch(Map json) {
      data = json;
      mockFetchCall().thenAnswer((_) async => data);
    }

    void mockFetchError() => mockFetchCall().thenThrow(Exception());

    setUp(() {
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveyResult(cacheStorage: cacheStorage);
      surveyId = faker.guid.guid();
      mockFetch(FakeSurveyResultFactory.makeCacheJson());
    });

    test('Should call fetch cache storage with correct key', () async {
      await sut.loadBySurvey(surveyId: surveyId);

      verify(cacheStorage.fetch('survey_result/$surveyId')).called(1);
    });

    test('Should return survey result on success', () async {
      final surveyResult = await sut.loadBySurvey(surveyId: surveyId);

      final expectedSurveyResult = SurveyResultEntity(
        question: data['question'],
        surveyId: data['surveyId'],
        answers: [
          SurveyAnswerEntity(
            answer: data['answers'][0]['answer'],
            isCurrentAnswer: true,
            percent: 40,
            image: data['answers'][0]['image'],
          ),
          SurveyAnswerEntity(
            answer: data['answers'][1]['answer'],
            isCurrentAnswer: false,
            percent: 68,
          ),
        ],
      );
      expect(surveyResult, expectedSurveyResult);
    });

    test('Should throws unexpected error if cache is empty', () async {
      mockFetch({});

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws unexpected error if cache is null', () async {
      mockFetch(null);

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws unexpected error if cache is invalid', () async {
      mockFetch(FakeSurveyResultFactory.makeInvalidCacheJson());

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws unexpected error if cache is incomplete', () async {
      mockFetch(FakeSurveyResultFactory.makeIncompleteCacheJson());

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws unexpected error if cache throws', () async {
      mockFetchError();

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });
  });

  group('validate', () {
    CacheStorage cacheStorage;
    LocalLoadSurveyResult sut;
    String surveyId;

    Map data;

    PostExpectation mockFetchCall() => when(cacheStorage.fetch(any));
    void mockFetch(Map json) {
      data = json;
      mockFetchCall().thenAnswer((_) async => data);
    }

    void mockFetchError() => mockFetchCall().thenThrow(Exception());

    setUp(() {
      surveyId = faker.guid.guid();
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveyResult(cacheStorage: cacheStorage);
      mockFetch(FakeSurveyResultFactory.makeCacheJson());
    });

    test('Should call fetch cache storage with correct key', () async {
      await sut.validate(surveyId);

      verify(cacheStorage.fetch('survey_result/$surveyId')).called(1);
    });

    test('Should delete cache if it is invalid', () async {
      mockFetch(FakeSurveyResultFactory.makeInvalidCacheJson());
      await sut.validate(surveyId);

      verify(cacheStorage.delete('survey_result/$surveyId')).called(1);
    });

    test('Should delete cache when fetch throws', () async {
      mockFetchError();

      await sut.validate(surveyId);

      verify(cacheStorage.delete('survey_result/$surveyId')).called(1);
    });
  });

  group('save', () {
    CacheStorage cacheStorage;
    LocalLoadSurveyResult sut;
    SurveyResultEntity surveyResult;
    String surveyId;

    PostExpectation mockSaveCall() => when(
          cacheStorage.save(key: anyNamed('key'), value: anyNamed('value')),
        );
    void mockSaveError() => mockSaveCall().thenThrow(Exception());

    setUp(() {
      surveyResult = FakeSurveyResultFactory.makeEntity();
      surveyId = surveyResult.surveyId;
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveyResult(cacheStorage: cacheStorage);
    });

    test('Should call save cache storage with correct values', () async {
      final toSaveData = {
        'surveyId': surveyResult.surveyId,
        'question': surveyResult.question,
        'answers': [
          {
            'image': surveyResult.answers[0].image,
            'answer': surveyResult.answers[0].answer,
            'isCurrentAnswer': 'true',
            'percent': '40',
          },
          {
            'image': surveyResult.answers[1].image,
            'answer': surveyResult.answers[1].answer,
            'isCurrentAnswer': 'false',
            'percent': '68',
          },
        ],
      };

      await sut.save(surveyResult);

      verify(cacheStorage.save(key: 'survey_result/$surveyId', value: toSaveData)).called(1);
    });

    test('Should throw unexpected error if save throws', () async {
      mockSaveError();

      final future = sut.save(surveyResult);

      expect(future, throwsA(DomainError.unexpected));
    });
  });
}
