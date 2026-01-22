import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

void main() {
	group('MemoryUsageTargetLevel', () {
		test('supports expected values', () {
			expect(MemoryUsageTargetLevel.NORMAL.toValue(), 0);
			expect(MemoryUsageTargetLevel.LOW.toValue(), 1);
		});
	});

	group('WebResourceRequestSourceKind', () {
		test('supports expected flags', () {
			expect(WebResourceRequestSourceKind.NONE.toValue(), 0x0);
			expect(WebResourceRequestSourceKind.DOCUMENT.toValue(), 0x1);
			expect(WebResourceRequestSourceKind.SHARED_WORKER.toValue(), 0x2);
			expect(WebResourceRequestSourceKind.SERVICE_WORKER.toValue(), 0x4);
			expect(WebResourceRequestSourceKind.ALL.toValue(), 0xFFFFFFFF);
		});
	});


	group('SaveAs UI types', () {
		test('SaveAsUIShowingResponse fromMap parses enums', () {
			final response = SaveAsUIShowingResponse.fromMap({
				'cancel': false,
				'suppressDefaultDialog': true,
				'saveAsFilePath': 'C:\\tmp\\page.mhtml',
				'allowReplace': true,
				'kind': SaveAsKind.SINGLE_FILE.toNativeValue(),
			});

			expect(response?.cancel, false);
			expect(response?.suppressDefaultDialog, true);
			expect(response?.saveAsFilePath, 'C:\\tmp\\page.mhtml');
			expect(response?.allowReplace, true);
			expect(response?.kind, SaveAsKind.SINGLE_FILE);
		});
	});

	group('NotificationReceivedRequest', () {
		test('fromMap parses nested notification', () {
			final request = NotificationReceivedRequest.fromMap({
				'senderOrigin': 'https://example.com/',
				'notification': {
					'title': 'Hello',
					'body': 'World',
					'direction': NotificationDirection.LEFT_TO_RIGHT.toNativeValue(),
					'iconUri': 'https://example.com/icon.png',
					'isSilent': true,
				},
			});

			expect(request?.senderOrigin?.toString(), 'https://example.com/');
			expect(request?.notification.title, 'Hello');
			expect(request?.notification.body, 'World');
			expect(request?.notification.direction, NotificationDirection.LEFT_TO_RIGHT);
			expect(
				request?.notification.iconUri?.toString(),
				'https://example.com/icon.png',
			);
			expect(request?.notification.isSilent, true);
		});
	});

	group('SaveFileSecurityCheckStartingRequest', () {
		test('toMap and fromMap round-trip', () {
			final request = SaveFileSecurityCheckStartingRequest(
				documentOriginUri: WebUri('https://example.com/'),
				fileExtension: '.exe',
				filePath: 'C:\\tmp\\test.exe',
				cancelSave: true,
				suppressDefaultPolicy: true,
			);

			final map = request.toMap();
			final parsed = SaveFileSecurityCheckStartingRequest.fromMap(map);

			expect(parsed?.documentOriginUri?.toString(), 'https://example.com/');
			expect(parsed?.fileExtension, '.exe');
			expect(parsed?.filePath, 'C:\\tmp\\test.exe');
			expect(parsed?.cancelSave, true);
			expect(parsed?.suppressDefaultPolicy, true);
		});
	});

	group('ScreenCaptureStartingResponse', () {
		test('fromMap parses values', () {
			final response = ScreenCaptureStartingResponse.fromMap({
				'cancel': true,
				'handled': true,
			});

			expect(response?.cancel, true);
			expect(response?.handled, true);
		});
	});
}
