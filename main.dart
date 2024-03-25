import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ContactMode {
  Add,
  Edit,
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactListPage(),
    );
  }
}

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [
    Contact(name: 'John Doe', phoneNumber: '1234567890'),
    Contact(name: 'Jane Smith', phoneNumber: '9876543210'),
  ];

  List<Contact> _filteredContacts = [];

  TextEditingController _searchController = TextEditingController();

  late TextEditingController _editNameController;
  late TextEditingController _editPhoneNumberController;
  late ContactMode _mode;
  late int _editIndex;

  @override
  void initState() {
    super.initState();
    _filteredContacts = _contacts;
    _editNameController = TextEditingController();
    _editPhoneNumberController = TextEditingController();
    _mode = ContactMode.Add;
    _editIndex = -1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _editNameController.dispose();
    _editPhoneNumberController.dispose();
    super.dispose();
  }

  void _addContact(String name, String phoneNumber) {
    if (name.isNotEmpty && phoneNumber.isNotEmpty) {
      if (!_isNumeric(name) && _isNumeric(phoneNumber)) {
        setState(() {
          _contacts.add(Contact(name: name, phoneNumber: phoneNumber));
          _filteredContacts = _contacts;
        });
        Navigator.pop(context);
      } else {
        _showErrorDialog('Name should not contain numbers\nPhone number must be numeric');
      }
    } else {
      _showErrorDialog('Name and phone number cannot be empty');
    }
  }

  void _deleteContact(Contact contact) {
    setState(() {
      _showConfirmationDialog(contact);
    });
  }

  void _confirmDeleteContact(Contact contact) {
    setState(() {
      _contacts.remove(contact);
      _filteredContacts = _contacts;
    });
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  void _filterContacts(String query) {
    List<Contact> filteredList = [];
    filteredList.addAll(_contacts.where((contact) {
      return contact.name.toLowerCase().contains(query.toLowerCase()) ||
          contact.phoneNumber.contains(query);
    }));
    setState(() {
      _filteredContacts = filteredList;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _editContact(Contact contact) {
    setState(() {
      _mode = ContactMode.Edit;
      _editIndex = _contacts.indexOf(contact);
      _editNameController.text = contact.name;
      _editPhoneNumberController.text = contact.phoneNumber;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactPage(
          onAddContact: _editExistingContact,
          mode: _mode,
          nameController: _editNameController,
          phoneNumberController: _editPhoneNumberController,
        ),
      ),
    );
  }

  void _editExistingContact(String name, String phoneNumber) {
    if (name.isNotEmpty && phoneNumber.isNotEmpty) {
      if (!_isNumeric(name) && _isNumeric(phoneNumber)) {
        setState(() {
          _contacts[_editIndex] = Contact(name: name, phoneNumber: phoneNumber);
          _filteredContacts = _contacts;
          _mode = ContactMode.Add;
        });
        Navigator.pop(context);
      } else {
        _showErrorDialog('Name should not contain numbers\nPhone number must be numeric');
      }
    } else {
      _showErrorDialog('Name and phone number cannot be empty');
    }
  }

  void _sortContacts() {
    setState(() {
      _filteredContacts.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _showConfirmationDialog(Contact contact) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this contact?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _confirmDeleteContact(contact);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              _sortContacts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                _filterContacts(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(_filteredContacts[index].name),
                    subtitle: Text(_filteredContacts[index].phoneNumber),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editContact(_filteredContacts[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteContact(_filteredContacts[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContactPage(
                onAddContact: _addContact,
                mode: ContactMode.Add,
                nameController: TextEditingController(),
                phoneNumberController: TextEditingController(),
              ),
            ),
          );
        },
        child:
Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AddContactPage extends StatefulWidget {
  final Function(String name, String phoneNumber) onAddContact;
  final ContactMode mode;
  final TextEditingController nameController;
  final TextEditingController phoneNumberController;

  AddContactPage({
    required this.onAddContact,
    required this.mode,
    required this.nameController,
    required this.phoneNumberController,
  });

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  void _clearInputs() {
    widget.nameController.clear();
    widget.phoneNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == ContactMode.Add ? 'Add Contact' : ' Edit Contact'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: widget.nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\d')),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: widget.phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _clearInputs();
                  },
                  child: Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onAddContact(
                      widget.nameController.text,
                      widget.phoneNumberController.text,
                    );
                  },
                  child: Text(widget.mode == ContactMode.Add ? 'Submit' : 'Update'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Contact {
  final String name;
  final String phoneNumber;

  Contact({required this.name, required this.phoneNumber});
}

class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  ContactDetailPage({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Detail'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${contact.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Phone Number: ${contact.phoneNumber}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
