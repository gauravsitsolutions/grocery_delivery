import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/main.dart';
import 'package:samrudhi_delivery_agent_app/view_model/auth_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/delivery_summary_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/duty_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/notifications_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_list_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/profile_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Samrudhi Delivery Agent',
      packageName: 'com.samrudhi.delivery',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('App smoke test - renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => OrderListViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
          ChangeNotifierProvider(create: (_) => DeliverySummaryViewModel()),
          ChangeNotifierProvider(create: (_) => DutyViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.text('Samruddha Kirana'), findsOneWidget);
  });
}
