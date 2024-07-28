import 'package:example/repository.dart';
import 'package:example/router.dart';

void navigationLogic() {
  repo.listen(
    'navigationLogic',
    'logout',
    onData: (data) async {
      if (data == true) {
        await repo.clearAllData();
        router.pushReplacementNamed('login');
      }
    },
  );
}
