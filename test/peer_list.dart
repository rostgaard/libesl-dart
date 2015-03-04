// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl.test;

void parsePeerBuffer() {
  ESL.PeerList list = new ESL.PeerList.fromMultilineBuffer(testData);

  bool isValidPeer(ESL.Peer peer) {
    if (peer.callgroup == null) {
      throw new ArgumentError('peer.callgroup == null!');
    }
    if (peer.ID.isEmpty) {
      throw new ArgumentError('peer.ID.isEmpty!');
    }
    if (peer.context == null) {
      throw new ArgumentError('peer.context == null!');
    }

    if (peer.domain.isEmpty) {
      throw new ArgumentError('peer.domain.isEmpty!');
    }

    return true;
  }


  return expect(list.every(isValidPeer), isTrue);
}


const String testData =
    '''userid|context|domain|group|contact|callgroup|effective_caller_id_name|effective_caller_id_number
1000|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1000|1000
1001|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1001|1001
1002|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1002|1002
1003|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1003|1003
1004|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1004|1004
1005|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1005|1005
1006|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1006|1006
1007|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1007|1007
1008|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1008|1008
1009|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1009|1009
1010|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1010|1010
1011|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1011|1011
1012|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1012|1012
1013|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1013|1013
1014|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1014|1014
1015|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1015|1015
1016|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1016|1016
1017|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1017|1017
1018|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1018|1018
1019|default|192.168.1.178|default|error/user_not_registered|techsupport|Extension 1019|1019
brian|default|192.168.1.178|default|error/user_not_registered||Brian West|1000
default||192.168.1.178|default|error/user_not_registered|||
example.com||192.168.1.178|default|error/user_not_registered|||
SEP001120AABBCC||192.168.1.178|default|error/user_not_registered|||
1100|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1100|1100
1101|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1101|1101
1102|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1102|1102
1103|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1103|1103
1104|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1104|1104
1105|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1105|1105
1106|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1106|1106
1107|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1107|1107
1108|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1108|1108
1109|default|192.168.1.178|default|error/user_not_registered|test_receptionst|Test Receptionst Extension 1109|1109
1200|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1200|1200
1201|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1201|1201
1202|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1202|1202
1203|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1203|1203
1204|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1204|1204
1205|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1205|1205
1206|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1206|1206
1207|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1207|1207
1208|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1208|1208
1209|public|192.168.1.178|default|error/user_not_registered|test_customer|Test Customer Extension 1209|1209''';
