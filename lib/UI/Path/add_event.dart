import 'package:flutter_calendar/model/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/res/event_firestore_service.dart';

class AddEventPage extends StatefulWidget {

  final EventModel note;
const AddEventPage({Key key, this.note}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  TextEditingController _title;

  TextEditingController _description;
  DateTime _eventDate;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;

  @override

  void initState() {

    super.initState();

    _title = TextEditingController(

        text: widget.note != null ? widget.note.title : "");

    _description = TextEditingController(

        text: widget.note != null ? widget.note.description : "");

    _eventDate = DateTime.now();

    processing = false;

  }

  @override

  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(


        title: Text(widget.note != null ? "Edit Event" : "Add event"),


      ),


      key: _key,


      body: Form(


        key: _formKey,


        child: Container(


          alignment: Alignment.center,


          child: ListView(


            children: <Widget>[


              Padding(


                padding:


                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),


                child: TextFormField(


                  controller: _title,


                  validator: (value) =>


                  (value.isEmpty) ? "Please Enter title" : null,


                  style: style,


                  decoration: InputDecoration(


                      labelText: "Title",


                      filled: true,


                      fillColor: Colors.white,


                      border: OutlineInputBorder(


                          borderRadius: BorderRadius.circular(10))),


                ),


              ),


              Padding(


                padding:


                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),


                child: TextFormField(


                  controller: _description,


                  minLines: 3,


                  maxLines: 5,


                  validator: (value) =>


                  (value.isEmpty) ? "Please Enter description" : null,


                  style: style,


                  decoration: InputDecoration(


                      labelText: "description",


                      border: OutlineInputBorder(


                          borderRadius: BorderRadius.circular(10))),


                ),


              ),


              const SizedBox(height: 10.0),


              ListTile(


                title: Text("Date (YYYY-MM-DD)"),


                subtitle: Text(


                    "${_eventDate.year} - ${_eventDate.month} - ${_eventDate.day}"),


                onTap: () async {


                  DateTime picked = await showDatePicker(


                      context: context,


                      initialDate: _eventDate,


                      firstDate: DateTime(_eventDate.year - 5),


                      lastDate: DateTime(_eventDate.year + 5));


                  if (picked != null) {


                    setState(() {


                      _eventDate = picked;


                    });


                  }


                },


              ),


              SizedBox(height: 10.0),


              processing


                  ? Center(child: CircularProgressIndicator())


                  : Padding(


                padding: const EdgeInsets.symmetric(horizontal: 16.0),


                child: Material(


                  elevation: 5.0,


                  borderRadius: BorderRadius.circular(30.0),


                  color: Theme.of(context).primaryColor,


                  child: MaterialButton(


                    onPressed: () async {


                      if (_formKey.currentState.validate()) {


                        setState(() {


                          processing = true;


                        });


                        final data = {


                          "title": _title.text,


                          "description": _description.text,


                          "event_date": widget.note.eventDate


                        };


                        if (widget.note != null) {


                          await eventDBS.updateData(widget.note.id, data);


                        } else {


                          await eventDBS.create(data);


                        }


                        Navigator.pop(context);


                        setState(() {


                          processing = false;


                        });


                      }


                    },


                    child: Text(


                      "Save",


                      style: style.copyWith(


                          color: Colors.white,


                          fontWeight: FontWeight.bold),


                    ),


                  ),


                ),


              ),


            ],


          ),


        ),


      ),


    );


  }

  @override
  void dispose() {


    _title.dispose();


    _description.dispose();


    super.dispose();


  }


}

@override
Widget build(BuildContext context) {


  return Scaffold(


    appBar: AppBar(


      title: Text('Flutter Calendar'),


    ),


    body: StreamBuilder<List<EventModel>>(


        stream: eventDBS.streamList(),


        builder: (context, snapshot) {


          if (snapshot.hasData) {


            List<EventModel> allEvents = snapshot.data;


            if (allEvents.isNotEmpty) {


              _events = _groupEvents(allEvents);


            } else {


              _events = {};


              _selectedEvents = [];


            }


          }


          return SingleChildScrollView(


            child: Column(


              crossAxisAlignment: CrossAxisAlignment.start,


              children: <Widget>[


                TableCalendar(

                  events: _events,

                  initialCalendarFormat: CalendarFormat.week,

                  calendarStyle: CalendarStyle(

                      canEventMarkersOverflow: true,

                      todayColor: Colors.orange,

                      selectedColor: Theme.of(context).primaryColor,

                      todayStyle: TextStyle(

                          fontWeight: FontWeight.bold,

                          fontSize: 18.0,

                          color: Colors.white)),

                  headerStyle: HeaderStyle(

                    centerHeaderTitle: true,

                    formatButtonDecoration: BoxDecoration(

                      color: Colors.orange,

                      borderRadius: BorderRadius.circular(20.0),

                    ),

                    formatButtonTextStyle: TextStyle(color: Colors.white),

                    formatButtonShowsNext: false,

                  ),

                  startingDayOfWeek: StartingDayOfWeek.monday,

                  onDaySelected: (date, events) {

                    setState(() {

                      _selectedEvents = events;

                    });

                  },

                  builders: CalendarBuilders(

                    selectedDayBuilder: (context, date, events) => Container(

                        margin: const EdgeInsets.all(4.0),

                        alignment: Alignment.center,

                        decoration: BoxDecoration(

                            color: Theme.of(context).primaryColor,

                            borderRadius: BorderRadius.circular(10.0)),

                        child: Text(

                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  calendarController: _controller,
                ),
                ..._selectedEvents.map((event) => ListTile(
                  title: Text(event.title),
                  onTap: () {
                    Navigator.push(
                        context,

                        MaterialPageRoute(
                            builder: (_) => EventDetailsPage(
                              event: event,
                            )));
                  },
                )),
              ],
            ),
          );
        }),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => Navigator.pushNamed(context, 'add_event'),
    ),
  );
}
}
