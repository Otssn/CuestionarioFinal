import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cuestionario_final/helpers/api_helper.dart';
import 'package:cuestionario_final/models/form.dart';
import 'package:cuestionario_final/models/responses.dart';
import 'package:cuestionario_final/models/token.dart';
import 'package:cuestionario_final/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HomeScreen extends StatefulWidget {
  final Token token;
  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _form = false;
  int cont = 0;

  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  TextEditingController _emailController = TextEditingController();

  String _TheBest = '';
  String _TheBestError = '';
  bool _TheBestShowError = false;
  TextEditingController _TheBestController = TextEditingController();

  String _TheWorst = '';
  String _TheWorstError = '';
  bool _TheWorstShowError = false;
  TextEditingController _TheWorstController = TextEditingController();

  String _Remarks = '';
  String _RemarksError = '';
  bool _RemarksShowError = false;
  TextEditingController _RemarksController = TextEditingController();

  int _qualification = 1;

  void initState() {
    super.initState();
    _getForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cuestionario"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _logOut();
              },
              icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              _showEmail(),
              _showqualification(),
              _showTheBest(),
              _showTheWorst(),
              _showRemarks(),
              _form ? _showEdit() : _showSave(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showqualification() {
    return Center(
      child: RatingBar.builder(
        initialRating: _qualification + 0.0,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          _qualification = rating.round();
        },
      ),
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _emailController,
        decoration: InputDecoration(
          hintText: 'Ingresa un email de dominio ITM',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          suffixIcon: Icon(Icons.mail),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showTheBest() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _TheBestController,
        decoration: InputDecoration(
          hintText: 'Ingresa lo mejor del curso',
          labelText: 'Lo mejor',
          errorText: _TheBestShowError ? _TheBestError : null,
          suffixIcon: Icon(Icons.emoji_emotions),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          _TheBest = value;
        },
      ),
    );
  }

  Widget _showTheWorst() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _TheWorstController,
        decoration: InputDecoration(
          hintText: 'Ingresa lo peor del curso',
          labelText: 'Lo peor',
          errorText: _TheWorstShowError ? _TheWorstError : null,
          suffixIcon: Icon(Icons.mood_bad),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          _TheWorst = value;
        },
      ),
    );
  }

  Widget _showRemarks() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _RemarksController,
        decoration: InputDecoration(
          hintText: 'Ingresa comentarios para hacer mejor el curso',
          labelText: 'Comentarios',
          errorText: _RemarksShowError ? _RemarksError : null,
          suffixIcon: Icon(Icons.keyboard),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          _Remarks = value;
        },
      ),
    );
  }

  void _getForm() async {
    Responses response = await ApiHelper.getForm(widget.token);
    Forms forms = response.result;
    if (forms.email.isEmpty) {
      print("!");
      await showAlertDialog(
        context: context,
        title: 'Nuevo cuestionario',
        message: 'No hay encuestas realizadas anteriormente',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar')
        ],
      );
      setState(() {
        _form = false;
      });
    } else {
      print(forms.email);

      _form = true;
      _email = forms.email;
      _emailController.text = _email;
      _TheBest = forms.theBest;
      _TheBestController.text = _TheBest;
      _TheWorst = forms.theWorst;
      _TheWorstController.text = _TheWorst;
      _Remarks = forms.remarks;
      _RemarksController.text = _Remarks;
      _qualification = forms.qualification;
      setState(() {});
      ;
    }
  }

  Widget _showEdit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
            child: Text('Actualizar encuesta'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                return Colors.lightBlue;
                ;
              }),
            ),
            onPressed: () => _validate() ? _save() : Container()),
      ],
    );
  }

  Widget _showSave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
            child: Text('Guardar encuesta'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                return Colors.lightBlue;
              }),
            ),
            onPressed: () => _validate() ? _save() : Container()),
      ],
    );
  }

  bool _validate() {
    bool isValidate = true;

    if (_email.isEmpty) {
      isValidate = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un correo valido';
    } else {
      _emailShowError = false;
    }
    if (!_validateEmail(_email)) {
      _emailShowError = true;
      _emailError = 'Debes ingresar un correo del ITM';
    } else {
      _emailShowError = false;
    }
    if (_TheBest.isEmpty) {
      isValidate = false;
      _TheBestShowError = true;
      _TheBestError = 'Debes ingresar un comentario valido';
    } else {
      _TheBestShowError = false;
    }
    if (_TheWorst.isEmpty) {
      isValidate = false;
      _TheWorstShowError = true;
      _TheWorstError = 'Debes ingresar un comentario valido';
    } else {
      _TheWorstShowError = false;
    }
    if (_Remarks.isEmpty) {
      isValidate = false;
      _RemarksShowError = true;
      _RemarksError = 'Debes ingresar un comentario valido';
    } else {
      _RemarksShowError = false;
    }

    setState(() {});

    return isValidate;
  }

  _save() async {
    Map<String, dynamic> request = {
      'email': _email,
      'qualification': _qualification,
      'theBest': _TheBest,
      'theWorst': _TheWorst,
      'remarks': _Remarks,
    };

    Responses responses =
        await ApiHelper.post('/api/Finals', request, widget.token);

    if (!responses.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: responses.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar')
        ],
      );
      return;
    }
    await showAlertDialog(
      context: context,
      title: 'Exito',
      message: 'Se ha guardado con exito',
      actions: <AlertDialogAction>[
        AlertDialogAction(key: null, label: 'Aceptar')
      ],
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(
                token: widget.token,
              )),
    );
  }

  bool _validateEmail(String email) {
    var domain = email.split('@');
    var dom = domain.length;
    print(dom);
    if (dom != 2) {
      return false;
    } else if (domain[1] == "correo.itm.edu.co") {
      return true;
    }
    return false;
  }

  void _logOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
