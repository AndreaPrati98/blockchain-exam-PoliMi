import 'package:dart_web3/dart_web3.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/view_model_smart_contracts/admin_nft_contract_vm.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as devtools;

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  String ethAddress = "Missing address";
  String balanceOf = "";

  void _updateEthAddress(String newString) {
    setState(() {
      ethAddress = newString.isEmpty ? "Missing address" : newString;
    });
  }

  void _updateBalanceOf(String newString) {
    setState(() {
      balanceOf = newString;
    });
  }

  @override
  Widget build(BuildContext context) {
    var contractLink = Provider.of<AdminNFTcontractVM>(context);

    return Center(
      child: contractLink.isLoading
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(19.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Here the name of the contract we are trying to execute the methods',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${contractLink.deployedName}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text("and the address we are connected as:"),
                  FutureBuilder(
                    future: contractLink.address,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(
                          '${snapshot.data}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  const Text("and the address owner of the contract is:"),
                  FutureBuilder(
                    future: contractLink.owner,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(
                          '${snapshot.data}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: TextField(
                      maxLines: null,
                      controller: myController,
                      onChanged: (inputString) =>
                          _updateEthAddress(inputString),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter an Etherium address in Hex',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      String res;
                      try {
                        res = await contractLink.getBalanceOf(
                          EthereumAddress.fromHex(ethAddress),
                        );
                      } catch (e) {
                        devtools.log(
                          "An exception occureed\n${e.toString()}",
                          name: runtimeType.toString(),
                        );
                        res = "";
                      }
                      _updateBalanceOf(res);
                    },
                    icon: const Icon(Icons.account_balance_sharp),
                    label: const Text("Balance of BossNFT"),
                  ),
                  balanceOf.isEmpty
                      ? const Text("")
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "The Balance of this address is: $balanceOf"),
                        ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      devtools.log("Button 'safeMint' pressed");
                      var res = await contractLink
                          .safeMint(EthereumAddress.fromHex(ethAddress));

                      if (!context.mounted) {
                        devtools.log(
                          "Context not mounted",
                          name: runtimeType.toString(),
                        );
                        return;
                      }
                      devtools.log("here");
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Result of the safe mint"),
                            content: Text(res.toString()),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.attach_money_rounded),
                    label:
                        Text("Mint a ${contractLink.deployedName} token"),
                  ),
                ],
              ),
            ),
    );
  }
}