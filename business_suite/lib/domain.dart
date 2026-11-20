import 'dart:convert';

const activities = <String, String>{
  'laundry': 'مغاسل الملابس', 'carwash': 'مغاسل السيارات',
  'barber': 'الحلاقة', 'beauty': 'التجميل',
  'cafe': 'المقاهي', 'home': 'أسر منتجة',
};
const services = <String, List<String>>{
  'laundry': ['غسيل وكي', 'كي', 'تنظيف جاف', 'مفارش', 'استلام الملابس'],
  'carwash': ['غسيل خارجي', 'غسيل شامل', 'تنظيف داخلي', 'تلميع'],
  'barber': ['حلاقة شعر', 'حلاقة لحية', 'شعر ولحية', 'عناية'],
  'beauty': ['تصفيف شعر', 'مكياج', 'عناية بالبشرة', 'مانيكير'],
  'cafe': ['قهوة', 'مشروبات باردة', 'حلويات', 'حجز طاولة', 'استلام طلب'],
  'home': ['حلويات', 'مخبوزات', 'عطور', 'مشغولات يدوية', 'طلب مناسبة'],
};
const appointmentLabels = <String, List<String>>{
  'laundry': ['موعد الاستلام', 'ملابسك جاهزة', 'موعد التسليم'],
  'carwash': ['موعد الغسيل', 'سيارتك جاهزة', 'موعد الاستلام'],
  'barber': ['موعد الحلاقة', 'تذكير بالحضور', 'موعد العناية'],
  'beauty': ['جلسة تجميل', 'موعد العناية', 'تذكير بالجلسة'],
  'cafe': ['استلام القهوة', 'حجز طاولة', 'طلبك جاهز'],
  'home': ['طلبك قيد التجهيز', 'طلبك جاهز', 'موعد التسليم'],
};
const promotionLabels = <String, List<String>>{
  'laundry': ['خصم الغسيل', 'عرض الكي', 'عرض المفارش'],
  'carwash': ['عرض الغسيل', 'خصم التلميع', 'باقة العناية'],
  'barber': ['خصم الشعر', 'عرض اللحية', 'باقة الإطلالة'],
  'beauty': ['عرض الجمال', 'خصم الجلسات', 'باقة العناية'],
  'cafe': ['عرض القهوة', 'خصم الحلويات', 'ساعة القهوة'],
  'home': ['عرض المنتجات', 'خصم المناسبات', 'هدية الطلب'],
};

String? normalizeSaudiPhone(String raw) {
  final s = raw.replaceAll(RegExp(r'[\s()\-]'), '');
  if (s.isEmpty) return null;
  if (RegExp(r'^05\d{8}$').hasMatch(s)) return '+966${s.substring(1)}';
  if (RegExp(r'^5\d{8}$').hasMatch(s)) return '+966$s';
  if (RegExp(r'^9665\d{8}$').hasMatch(s)) return '+$s';
  if (RegExp(r'^\+9665\d{8}$').hasMatch(s)) return s;
  throw const FormatException('رقم جوال سعودي غير صالح');
}

class Customer {
  final String id, code, name;
  final String? phone;
  const Customer(this.id, this.code, this.name, this.phone);
  Map<String, dynamic> toJson() => {'id':id,'code':code,'name':name,'phone':phone};
  factory Customer.fromJson(Map<String,dynamic> j) => Customer(j['id'],j['code'],j['name'],j['phone']);
}
class Sale {
  final String id, customerId, service;
  final int halalas, points;
  final DateTime date;
  const Sale(this.id,this.customerId,this.service,this.halalas,this.points,this.date);
  Map<String,dynamic> toJson() => {'id':id,'customerId':customerId,'service':service,'halalas':halalas,'points':points,'date':date.toIso8601String()};
  factory Sale.fromJson(Map<String,dynamic> j) => Sale(j['id'],j['customerId'],j['service'],j['halalas'],j['points'],DateTime.parse(j['date']));
}
class Booking {
  final String id, customerId, service;
  final DateTime at;
  const Booking(this.id,this.customerId,this.service,this.at);
  Map<String,dynamic> toJson() => {'id':id,'customerId':customerId,'service':service,'at':at.toIso8601String()};
  factory Booking.fromJson(Map<String,dynamic> j) => Booking(j['id'],j['customerId'],j['service'],DateTime.parse(j['at']));
}
class ShopData {
  String activity='cafe', shopName='منشأتي';
  int nextCode=1001;
  final List<Customer> customers=[];
  final List<Sale> sales=[];
  final List<Booking> bookings=[];
  Customer addCustomer(String id, String name, String phoneRaw) {
    final phone=normalizeSaudiPhone(phoneRaw);
    if(phone!=null && customers.any((c)=>c.phone==phone)) throw const FormatException('رقم الجوال مسجل مسبقًا');
    final c=Customer(id, '${nextCode++}', name.trim().isEmpty?'عميل ${nextCode-1}':name.trim(),phone);
    customers.add(c); return c;
  }
  Sale addSale(String id,String customerId,String service,int halalas) {
    if(!customers.any((c)=>c.id==customerId)) throw const FormatException('العميل غير موجود');
    if(halalas<=0) throw const FormatException('المبلغ يجب أن يكون موجبًا');
    if(sales.any((s)=>s.id==id)) throw const FormatException('عملية مكررة');
    final sale=Sale(id,customerId,service,halalas,halalas~/100,DateTime.now());
    sales.add(sale);return sale;
  }
  int balance(String id)=>sales.where((s)=>s.customerId==id).fold(0,(sum,s)=>sum+s.points);
  String encode()=>jsonEncode({'activity':activity,'shopName':shopName,'nextCode':nextCode,'customers':customers.map((e)=>e.toJson()).toList(),'sales':sales.map((e)=>e.toJson()).toList(),'bookings':bookings.map((e)=>e.toJson()).toList()});
  static ShopData decode(String text){
    final j=jsonDecode(text) as Map<String,dynamic>;
    if(!activities.containsKey(j['activity'])) throw const FormatException('نشاط غير معروف');
    final d=ShopData()..activity=j['activity']..shopName=j['shopName']..nextCode=j['nextCode'];
    d.customers.addAll((j['customers'] as List).map((x)=>Customer.fromJson(Map<String,dynamic>.from(x))));
    d.sales.addAll((j['sales'] as List).map((x)=>Sale.fromJson(Map<String,dynamic>.from(x))));
    d.bookings.addAll((j['bookings'] as List).map((x)=>Booking.fromJson(Map<String,dynamic>.from(x))));
    final phones=d.customers.map((e)=>e.phone).whereType<String>().toList();
    if(phones.toSet().length!=phones.length) throw const FormatException('أرقام مكررة في النسخة الاحتياطية');
    return d;
  }
}
