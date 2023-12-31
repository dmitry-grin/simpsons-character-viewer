import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simpsons_character_viewer/app/data/network/result.dart';
import 'package:simpsons_character_viewer/modules/character_viewer/data/characters_data_source.dart';
import 'package:simpsons_character_viewer/modules/character_viewer/domain/entities/character.dart';
import 'package:simpsons_character_viewer/modules/character_viewer/domain/search/character_searchable.dart';

import 'characters_list_state.dart';

class CharactersListCubit extends Cubit<CharactersListState> {
  CharactersListCubit({
    required CharactersDataSource charactersDataSource,
    required CharacterSearchable characterSearchable,
  })  : _charactersDataSource = charactersDataSource,
        _characterSearchable = characterSearchable,
        super(const CharactersListState.loading());

  final CharactersDataSource _charactersDataSource;
  final CharacterSearchable _characterSearchable;

  void fetchCharacters() async {
    emit(const CharactersListState.loading());

    final result = await _charactersDataSource.fetchCharacters();

    switch (result) {
      case Success(value: final charactersDto):
        final characters = charactersDto.map((e) => Character.from(e)).toList();
        emit(CharactersListState.loaded(allCharacters: characters));
      case Failure(exception: _):
        emit(const CharactersListState.error());
    }
  }

  void search({required String term}) {
    if (state is Loaded) {
      final currentState = state as Loaded;

      final filteredCharacters = currentState.allCharacters.where(
        (character) {
          return _characterSearchable.search(character, term);
        },
      ).toList();

      emit(
        CharactersListState.loaded(
          allCharacters: currentState.allCharacters,
          filteredCharacters: filteredCharacters,
          searchTerm: term,
        ),
      );
    }
  }

  void cancelSearch() {
    if (state is Loaded) {
      final currentState = state as Loaded;

      emit(
        CharactersListState.loaded(
          allCharacters: currentState.allCharacters,
        ),
      );
    }
  }
}
