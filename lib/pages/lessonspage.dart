import 'package:flutter/material.dart';
import 'package:flutter_proj/pages/workspaces/StudMenu.dart';
import '../database/database_helper.dart';
import '../database/models/lesson.dart';
import 'workspaces/add_lesson_helper.dart';

///
/// TODO: TWO TABS: LESSONS AND GROUPS
/// LESSONS:
/// TODO: ПАРСИТЬ С КАЛЕНДАРЯ ВСЕ ПРОШЕДШИЕ ПАРЫ
/// ПАРА ИМЕЕТ ТИП (СОГЛАСОВАТЬ): ЛАБА, ПРАКТИКА, ЛЕКЦИЯ, СЕМИНАР
/// ПАРА ИМЕЕТ СОСТОЯНИЕ: ПРОШЛА, ИДЁТ, ЗАПЛАНИРОВАНО
/// ОБЪЕКТ ПАРЫ: ГРУППА, НАЗВАНИЕ, ТИП, СОСТОЯНИЕ
///

String _ddGroupp = "";
String _ddCourse = "";
DateTime selectedDate = DateTime.now();
int _ddDate = selectedDate.millisecondsSinceEpoch;
String _ddStartTime = "";
String _ddType = "";
String _lesson = "";
List<String> defaults = ["ПИ", "1", "10:00", "Лекция"];

bool trigger = true;

class LessonsPage extends StatelessWidget {
  const LessonsPage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(
                    text: 'Занятия',
                  ),
                  Tab(
                    text: 'Студенты',
                  ),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LessonsTab(),
            StudGroupsPage(),
          ],
        ),
      ),
    );
  }
}

class LessonsTab extends StatefulWidget {
  const LessonsTab({Key? key}) : super(key: key);

  @override
  _LessonsTabState createState() => _LessonsTabState();
}

class _LessonsTabState extends State<LessonsTab>
  with AutomaticKeepAliveClientMixin<LessonsTab> {

  int? selectedId;

  TextEditingController _controllerName = TextEditingController();
  List<String> time = [
    "8:20",
    "10:00",
    "11:45",
    "14:00",
    "15:45",
    "17:20",
    "18:55",
  ];
  String? selectedTime = "10:00";

  List<String> type = [
    "Лекция",
    "Практика",
    "Лабораторная",
    "Зачёт",
  ];
  String? selectedType = 'Лекция';

  List<String> groups = ["ПИ", "ИВТ", "БИ"];
  String? selectedGroup = "ПИ";

  List<String> courses = ["1", "2", "3", "4"];
  String? selectedCourse = '1';


  _changeName() {
    setState(() => _lesson = _controllerName.text);
  }

  @override
  void initState() {
    super.initState();
    _controllerName.text = _lesson;
    _controllerName.addListener(_changeName);
  }

  @override
  void dispose() {
    try {
      _controllerName.dispose();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Lesson>>(
            future: DatabaseHelper.instance.getLessons(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Lesson>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('Loading...'));
              }
              return snapshot.data!.isEmpty
                  ? Center(child: Text('Пусто'))
                  : ListView(
                children: snapshot.data!.map((lesson) {
                  return Center(
                    child: Card(
                      child: ListTile(
                        title: Text(lesson.name),
                        onTap: () {
                          setState(() {
                            // TODO: ITEM MENU
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            DatabaseHelper.instance.removeLesson(lesson.id!);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'AddLessons',
        onPressed: () {
          showDialogue();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void getDropDownValues() {
    setState(() {
      _ddStartTime = selectedTime!;
      _ddGroupp = selectedGroup!;
      _ddCourse = selectedCourse!;
      _ddType = selectedType!;
    });
  }

  void resetDropDownValues() {
    setState(() {
      Navigator.of(context).pop();
      _controllerName.clear();
      selectedGroup = defaults[0];
      selectedCourse = defaults[1];
      selectedTime = defaults[2];
      selectedType = defaults[3];
    });
  }

  void showDialogue(){
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none, children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                  ),
                ),
              ),
              Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Новое занятие"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _controllerName,
                        decoration: InputDecoration(
                            errorStyle:
                            const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                            hintText: 'Название пары',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0))),
                      ),

                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0))),
                        value: selectedGroup,
                        items: groups
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                            .toList(),
                        onChanged: (item) => setState(() {
                          selectedGroup = item;
                        }),
                      ),

                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            errorStyle:
                            const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0))),
                        value: selectedCourse,
                        items: courses
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                            .toList(),
                        onChanged: (item) => setState(() {
                          selectedCourse = item;
                        }),
                      ),

                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            errorStyle:
                            const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0))),
                        value: selectedTime,
                        items: time
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                            .toList(),
                        onChanged: (item) => setState(() {
                          selectedTime = item;
                        }),
                      ),

                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            errorStyle:
                            const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0))),
                        value: selectedType,
                        items: type
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                            .toList(),
                        onChanged: (item) => setState(() {
                          selectedType = item;
                        }),
                      ),

                    ),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                            child: DatePicker(),
                            height: 40
                        )

                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size(width, 50),
                        ),
                        child: Text("Submit"),
                        onPressed: () {
                          setState(() {
                            getDropDownValues();
                            if (_controllerName.text.trim() != "" &&
                                _ddGroupp != "" &&
                                _ddCourse != "" &&
                                _ddStartTime != "" &&
                                _ddType != "") {
                              Lesson lesson = Lesson(
                                name: _controllerName.text.trim(),
                                groupp: _ddGroupp,
                                course: int.parse(_ddCourse),
                                date: _ddDate,
                                starttime: _ddStartTime,
                                type: _ddType,
                                state: 0,
                              );
                              DatabaseHelper.instance.insertLesson(lesson);
                              ///
                              /// TODO: ADD TO CALENDAR DATABASE
                              ///
                              ///
                              resetDropDownValues();


                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class StudGroupsPage extends StatefulWidget {
  const StudGroupsPage({Key? key}) : super(key: key);

  @override
  _StudGroupsPageState createState() => _StudGroupsPageState();
}

class _StudGroupsPageState extends State<StudGroupsPage>
    with AutomaticKeepAliveClientMixin<StudGroupsPage> {
  // TODO: dynamic get all groups from db
  var groups = DatabaseHelper.instance.getGroups().toString();
/*      <String>[
        "ПИб-1 курс",
        "ПИб-2 курс",
        "ПИб-3 курс",
        "ПИб-4 курс",
        "ИВТ-1 курс",
        "ИВТ-2 курс",
        "ИВТ-3 курс",
        "ИВТ-4 курс"
      ];*/

  @override
  Widget build(BuildContext context) {
    // TODO: разобраться со структурой всей этой хуйни
    // TODO: сделать красивый ListTile, OnTap => парсим студентов (пока конст) и отображаем на экране
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return WillPopScope(
                onWillPop: null,
                child: ListTile(
                    title: Text('${groups[index]}'),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return GetStudents();
                          },
                        ),
                      );
                    }),
              );
            },
          ),
        ),
      ),
      //TODO: DO ONE BUTTON FOR ONE PAGE UNIQ
      floatingActionButton: new FloatingActionButton(
        heroTag: 'AddGroup',
        onPressed: () {
          // TODO: ADD WINDOW TO ADD GROUPS
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class GetStudents extends StatefulWidget {
  const GetStudents();
  @override
  _GetStudentsState createState() => _GetStudentsState();
}

class _GetStudentsState extends State<GetStudents>
    with AutomaticKeepAliveClientMixin<GetStudents> {
  // TODO: dynamic get group id and get all students from DB
  // TODO: Add Button
  get students => <String>[
        "Петров",
        "Сидоров",
        "Ермолин",
        "Сидоров",
        "Ермолин",
        "Сидоров",
        "Ермолин",
        "Сидоров",
        "Ермолин",
        "Сидоров",
        "Ермолин"
      ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudNotes'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              return WillPopScope(
                onWillPop: null,
                child: ListTile(
                    title: Text('${students[index]}'),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return StudentMenu();
                          },
                        ),
                      );
                    }),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'AddStudent',
        onPressed: () {
          // TODO: ADD WINDOW TO ADD STUDENTS
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
