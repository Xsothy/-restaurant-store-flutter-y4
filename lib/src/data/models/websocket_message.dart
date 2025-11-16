class OrderStatusMessage {
  final int? orderId;
  final String? eventType;
  final String? status;
  final String? title;
  final String? message;
  final DateTime? timestamp;

  OrderStatusMessage({
    this.orderId,
    this.eventType,
    this.status,
    this.title,
    this.message,
    this.timestamp,
  });

  factory OrderStatusMessage.fromJson(Map<String, dynamic> json) {
    return OrderStatusMessage(
      orderId: json['orderId'] as int?,
      eventType: json['eventType'] as String?,
      status: json['status'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'eventType': eventType,
      'status': status,
      'title': title,
      'message': message,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'OrderStatusMessage(orderId: $orderId, eventType: $eventType, status: $status, title: $title, message: $message, timestamp: $timestamp)';
  }
}

class WebSocketInfo {
  final String endpoint;
  final String protocol;
  final List<WebSocketTopic> topics;
  final Map<String, dynamic>? exampleCode;

  WebSocketInfo({
    required this.endpoint,
    required this.protocol,
    required this.topics,
    this.exampleCode,
  });

  factory WebSocketInfo.fromJson(Map<String, dynamic> json) {
    return WebSocketInfo(
      endpoint: json['endpoint'] as String,
      protocol: json['protocol'] as String,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => WebSocketTopic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      exampleCode: json['exampleCode'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'protocol': protocol,
      'topics': topics.map((e) => e.toJson()).toList(),
      'exampleCode': exampleCode,
    };
  }
}

class WebSocketTopic {
  final String topic;
  final String description;
  final String? subscribeEndpoint;
  final List<String>? messageTypes;

  WebSocketTopic({
    required this.topic,
    required this.description,
    this.subscribeEndpoint,
    this.messageTypes,
  });

  factory WebSocketTopic.fromJson(Map<String, dynamic> json) {
    return WebSocketTopic(
      topic: json['topic'] as String,
      description: json['description'] as String,
      subscribeEndpoint: json['subscribeEndpoint'] as String?,
      messageTypes: (json['messageTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'description': description,
      'subscribeEndpoint': subscribeEndpoint,
      'messageTypes': messageTypes,
    };
  }
}
