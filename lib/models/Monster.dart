import 'dart:math';

import 'package:rpg_game/models/Character.dart';
import 'package:rpg_game/models/unit.dart';

class Monster extends Unit {
  final int maxAttack; // 최대 공격력만 저장

  Monster(String name, int health, this.maxAttack, int playerDefense)
    : super(name, health, 0, 0); // 기본 공격력과 방어력은 0으로 처리

  int generateAttack(int playerDefense) {
    return Random().nextInt(maxAttack + 1);
  }

  void attackCharacter(Character character) {
    int generatedAttack = max(
      Random().nextInt(maxAttack + 1),
      character.defense,
    );
    int damage = generatedAttack - character.defense;
    if (damage < 0) damage = 0;

    character.health -= damage;
    if (character.health < 0) character.health = 0;

    print(
      '$name이(가) ${character.name}에게 $damage 데미지를 입혔습니다. '
      '(공격력: $generatedAttack)',
    );
  }

  @override
  void showStatus() {
    print('[몬스터] 이름: $name | 체력: $health | 공격력 범위: 0 ~ $maxAttack');
  }
}
