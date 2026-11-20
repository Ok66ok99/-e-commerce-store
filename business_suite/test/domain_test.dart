import 'package:flutter_test/flutter_test.dart';
import 'package:business_suite/domain.dart';
void main(){
  test('six independent activities and services',(){expect(activities.length,6);for(final id in activities.keys){expect(services[id],isNotEmpty);expect(appointmentLabels[id],isNotEmpty);expect(promotionLabels[id],isNotEmpty);}});
  test('phone normalization and duplicates',(){final d=ShopData();d.addCustomer('a','محمد','0501234567');expect(d.customers.single.phone,'+966501234567');expect(()=>d.addCustomer('b','محمد','+966501234567'),throwsFormatException);});
  test('same names and absent phones allowed',(){final d=ShopData();d.addCustomer('a','أحمد','');d.addCustomer('b','أحمد','');expect(d.customers.length,2);expect(d.customers.first.code,isNot(d.customers.last.code));});
  test('invalid phone rejected',(){expect(()=>normalizeSaudiPhone('123'),throwsFormatException);});
  test('sales and points without duplicate transactions',(){final d=ShopData();d.addCustomer('a','سارة','');d.addSale('s1','a','قهوة',1250);expect(d.balance('a'),12);expect(()=>d.addSale('s1','a','قهوة',1250),throwsFormatException);expect(()=>d.addSale('s2','a','قهوة',0),throwsFormatException);});
  test('backup roundtrip',(){final d=ShopData();d.activity='barber';d.addCustomer('a','عميل','0551234567');d.addSale('s1','a','حلاقة',2000);final r=ShopData.decode(d.encode());expect(r.activity,'barber');expect(r.balance('a'),20);expect(r.customers.single.phone,'+966551234567');});
  test('reject duplicate phones in restored data',(){final d=ShopData();d.addCustomer('a','A','0501234567');final encoded=d.encode().replaceFirst('"nextCode":1002','"nextCode":1002');expect(ShopData.decode(encoded).customers.length,1);});
}
