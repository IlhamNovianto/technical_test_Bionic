import 'package:integration_test/integration_test.dart';

import 'test/auth_test.dart';
import 'test/chat_test.dart';
import 'test/full_flow_test.dart';
import 'test/news_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  authTests();
  newsTests();
  chatTests();
  fullFlowTests();
}
