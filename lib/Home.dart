import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];

  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File('${diretorio.path}/dados.json');
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;

    //criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa['titulo'] = textoDigitado;
    tarefa['realizada'] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controllerTarefa.text = '';
    //
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    //converção para json
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }


  // try e catch = recomendado para coisas sensiveis, como ler e escrever arquivos
  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }



  //=== aplicativo ===

  @override
  Widget build(BuildContext context) {
    //_salvarArquivo();

    //print('itens: ' + DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Lista de Tarefas'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Adicionar Tarefa'),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(labelText: 'Digite sua tarefa'),
                    onChanged: (text) {},
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar')),
                    FlatButton(
                        onPressed: () {
                          _salvarTarefa();
                          Navigator.pop(context);
                        },
                        child: Text('Salvar')),
                  ],
                );
              });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                itemBuilder: criarItemLista,
          ))
        ],
      ),
    );
  }

  Widget criarItemLista(context, index){

    //final item = _listaTarefas[index]['titulo'];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        //DateTime.now().millisecondsSinceEpoch.toString = gera uma chave(Key) diferente. para recuperar um item diferente
        direction: DismissDirection.endToStart,
        onDismissed: (direcao){

          //recuperar ultimo excluido
          _ultimaTarefaRemovida = _listaTarefas[index];

          //remover item
          _listaTarefas.removeAt(index);
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                  label: 'Desfazer',
                  onPressed: (){
                    setState(() {
                      _listaTarefas.insert(index, _ultimaTarefaRemovida);
                    });
                    _salvarArquivo();
                  }),
              content: Text('tarefa removida'));
          Scaffold.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.delete, color: Colors.white,)
            ],
          ),
        ),
        child: CheckboxListTile(
          value: _listaTarefas[index]['realizada'],
          onChanged: (valorAlterado) {
            print('valor: ' + valorAlterado.toString());
            setState(() {
              _listaTarefas[index]['realizada'] = valorAlterado;
            });
            _salvarArquivo();
          },
          title: Text(_listaTarefas[index]['titulo']),
        ));
  }
}