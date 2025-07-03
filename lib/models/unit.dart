abstract class Unit {
  //플레이어와 몬스터의 공통 속성을 정의햄
  String name;
  int health;
  int attack;
  int defense;

  Unit(this.name, this.health, this.attack, this.defense);

  void showStatus();
}
