import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';
import '../poses/pose_data.dart';
import '../poses/pose_library.dart';

/// 所有后端接口集中在此文件，便于统一查看与维护。
class Api {
  static const String _posesPath = '/api/photo-assistant/poses';

  /// 拉取完整姿势数据包（含 styles + activeStyle + poses）。
  ///
  /// 优先请求后端接口；任何失败都回退到本地内置数据。
  static Future<PoseResult> fetchPoseData() async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$_posesPath');
      final client = HttpClient();
      client.connectionTimeout = AppConfig.apiTimeout;
      final response =
          await client.getUrl(uri).then((req) => req.close());
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        client.close();
        final root = jsonDecode(body) as Map<String, dynamic>;
        final data = (root['data'] is Map)
            ? root['data'] as Map<String, dynamic>
            : root;
        if (data['styles'] is Map && data['poses'] is List) {
          print('[Api] 使用服务端数据 activeStyle=${data['activeStyle']} '
              'poses=${(data['poses'] as List).length}');
          return PoseResult.fromJson(data, fromServer: true);
        }
        print('[Api] 接口返回结构不含 styles/poses，使用离线兜底');
      } else {
        client.close();
        print('[Api] 接口 HTTP ${response.statusCode}，使用离线兜底');
      }
    } catch (e) {
      print('[Api] 接口请求异常，使用离线兜底：$e');
    }
    return defaultPoseResult;
  }
}
