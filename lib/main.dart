import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Declare local variables
  double _loanAmount = 0.0;
  double _netIncome = 0.0;
  double _interestRate = 0.0;
  int _loanPeriod = 1;
  bool _hashGuarantor = false;
  int _carType = 1; // 1= new, 2 = used
  double _repaymentAmount = 0.0;
  String _repaymentOutput = '';
  final _years = [1,2,3,4,5,6,7,8,9];

  //controller
  final loanAmountCtrl = TextEditingController();
  final netIncomeCtrl = TextEditingController();
  final interestRateCtrl = TextEditingController();

  //set focus
  final _myFocusNode = FocusNode();

  //Format output with the currency symbol of malaysia
  final myCurrency = intl.NumberFormat('#,#00.00','ms_MY');

  //form controller
  final _formKey = GlobalKey<FormState>();

  void myAlertDialog(){
    AlertDialog eligibilityAlertDialog = AlertDialog(
      title: const Text('Eligibility'),
      content: const Text('You are not eligible for this loan.'
          'Get a guarantor to proceed.'),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text('OK'))
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context){
        return eligibilityAlertDialog;
      });
  }

  void _calculateRepayment(){
    _loanAmount = double.parse(loanAmountCtrl.text);
    _netIncome = double.parse(netIncomeCtrl.text);
    _interestRate = double.parse(interestRateCtrl.text);

    var interest = _loanAmount * _loanPeriod * (_interestRate/100);
    _repaymentAmount = (_loanAmount + interest) / (_loanPeriod*12);

    bool eligibility = _netIncome * 0.3 > _repaymentAmount;

    if(eligibility || _hashGuarantor){
      setState(() {
        _repaymentOutput = 'Repayment Amount : '
            '${myCurrency.currencySymbol} '
            '${myCurrency.format(_repaymentAmount)} '
            '\n '
            'Eligibility : ${eligibility? 'Eligible' : 'Not Eligible'}';
      });
    }else{
      myAlertDialog();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Car Loan calculator'),
      ),
      body: Form(
        key: _formKey,
        child: Center(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Loan Amount'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: loanAmountCtrl,
                  focusNode: _myFocusNode,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter loan amount';
                    }return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Net Income'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: netIncomeCtrl,
                  focusNode: _myFocusNode,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter net income';
                    }return null;
                  },
                ),
                DropdownButtonFormField(
                  initialValue: _loanPeriod,
                  items: _years.map((int item){
                    return DropdownMenuItem(
                      value: item,
                      child: Text('$item year(s)'),
                    );
                  }).toList(),
                  onChanged: (int? item){
                    setState(() {
                      _loanPeriod = item!;
                    });
                  }),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Interest Rate'
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  controller: interestRateCtrl,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter net income';
                    }
                    return null;
                  },
                ),
          ],
        ),
      )),
    );
  }
}

