import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      initialRoute: Home.id,
      routes: {
        Home.id: (context) => Home(),
        Registration.id: (context) => Registration(),
        Chat.id: (context) => Chat(),
        Login.id: (context) => Login(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  static const String logo = 'assets/images/logo.png';
  static const String id = 'MyHomePage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  width: 200,
                  child: Image.asset(logo),
                ),
              ),
              Text(
                'Ziber',
                style: TextStyle(fontSize: 40),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          CustomButton(
            text: 'Log In',
            callback: () {
              Navigator.of(context).pushNamed(Login.id);
            },
          ),
          CustomButton(
            text: 'Register',
            callback: () {
              Navigator.of(context).pushNamed(Registration.id);
            },
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  CustomButton({this.callback, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Material(
          color: Colors.blueGrey,
          elevation: 6.0,
          borderRadius: BorderRadius.circular(30.0),
          child: MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.blueGrey)),
            minWidth: 200.0,
            height: 45.0,
            onPressed: callback,
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

class Registration extends StatefulWidget {
  static const String id = 'Registration';

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String email;
  String password;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset(MyHomePage.logo),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintText: 'Enter Your Email...',
                border: const OutlineInputBorder()),
            onChanged: (value) {
              email = value;
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            obscureText: true,
            autocorrect: false,
            decoration: InputDecoration(
                hintText: 'Enter Your Password...',
                border: const OutlineInputBorder()),
            onChanged: (value) {
              password = value;
            },
          ),
          SizedBox(
            height: 50,
          ),
          CustomButton(
            text: 'Register',
            callback: () async {
              await registerUser();
            },
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final FirebaseUser user = result.user;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Chat(user: user)));
  }
}

class Login extends StatefulWidget {
  static const String id = 'Login';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email;
  String password;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset(MyHomePage.logo),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: 'Enter Your Email...',
                  border: const OutlineInputBorder()),
              onChanged: (value) {
                email = value;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                  hintText: 'Enter Your Password...',
                  border: const OutlineInputBorder()),
              onChanged: (value) {
                password = value;
              },
            ),
            SizedBox(
              height: 50,
            ),
            CustomButton(
              text: 'Log In',
              callback: () async {
                await loginUser();
              },
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  void loginUser() async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          user: user,
        ),
      ),
    );
  }
}

class Chat extends StatefulWidget {
  static const String id = 'Chat';
  final FirebaseUser user;

  Chat({@required this.user});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final String collection = 'message';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      await _firestore
          .collection(collection)
          .add({'text': messageController.text, 'from': widget.user.email});
      messageController.clear();
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(microseconds: 200), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'logo',
          child: Container(
            height: 40,
            child: Image.asset(MyHomePage.logo),
          ),
        ),
        title: Text('Zimber Chat'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection(collection).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  List<Widget> messages = docs.map((doc) => Message(
                        from: doc.data['from'],
                        text: doc.data['text'],
                        me: widget.user.email == doc.data['from'],
                      )).toList();
                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages
                    ],
                  );
                },
              ),
            ),
            Container(
                child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autocorrect: false,
                    onSubmitted: (_) => callback(),
                    controller: messageController,
                    decoration: InputDecoration(
                        hintText: 'Enter a message here...',
                        border: const OutlineInputBorder()),
                  ),
                ),
                SendButton('Send', callback),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  SendButton(this.text, this.callback);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.orange,
      child: Text(text),
      onPressed: callback,
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final bool me;

  Message({this.from, this.text, this.me});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(from),
          Material(
            color: me ? Colors.teal : Colors.orange,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(text),
            ),
          )
        ],
      ),
    );
  }
}
