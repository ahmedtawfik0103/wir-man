import 'package:flutter/material.dart';

void main() => runApp(const WirApp());

class WirRequest {
  String id;
  String project;
  String workType;
  String location;
  String floor;
  String axes;
  String description;
  String status;
  String contractor;
  String? inspector;
  String? notes;
  DateTime createdAt;

  WirRequest({required this.id, required this.project, required this.workType,
    required this.location, required this.floor, required this.axes,
    required this.description, required this.status, required this.contractor,
    this.inspector, this.notes, required this.createdAt});
}

class WirApp extends StatefulWidget {
  const WirApp({super.key});
  @override State<WirApp> createState() => _WirAppState();
}

class _WirAppState extends State<WirApp> {
  final List<WirRequest> requests = [
    WirRequest(id:'WIR-2026-000125', project:'مشروع المبنى الإداري', workType:'حديد تسليح', location:'المبنى A - الدور الثالث', floor:'الثالث', axes:'A-B / 1-5', description:'فحص حديد تسليح بلاطة الدور الثالث قبل الصب.', status:'بانتظار الفحص', contractor:'شركة المقاولات المتحدة', createdAt:DateTime.now().subtract(const Duration(hours:2))),
    WirRequest(id:'WIR-2026-000124', project:'مشروع المبنى الإداري', workType:'خرسانة', location:'المبنى A - الدور الثاني', floor:'الثاني', axes:'C-D / 2-6', description:'فحص جاهزية الصب للكمرات.', status:'مقبول', contractor:'شركة المقاولات المتحدة', inspector:'م. أحمد', createdAt:DateTime.now().subtract(const Duration(days:1))),
    WirRequest(id:'WIR-2026-000123', project:'مشروع الفلل السكنية', workType:'بلوك', location:'فيلا 4', floor:'الأرضي', axes:'—', description:'فحص أعمال البلوك الداخلي.', status:'إعادة فحص', contractor:'مؤسسة البناء الحديث', inspector:'م. محمد', notes:'استكمال المعالجة وإعادة تقديم الطلب.', createdAt:DateTime.now().subtract(const Duration(days:2))),
  ];

  void addRequest(WirRequest r) => setState(() => requests.insert(0, r));

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner:false,
    title:'طلبات فحص الأعمال',
    theme:ThemeData(useMaterial3:true, colorSchemeSeed:Colors.indigo, fontFamily:'sans-serif'),
    home: Directionality(textDirection:TextDirection.rtl, child: Dashboard(requests:requests, onAdd:addRequest)),
  );
}

class Dashboard extends StatefulWidget {
  final List<WirRequest> requests; final void Function(WirRequest) onAdd;
  const Dashboard({super.key, required this.requests, required this.onAdd});
  @override State<Dashboard> createState()=>_DashboardState();
}
class _DashboardState extends State<Dashboard> {
  int tab=0;
  @override Widget build(BuildContext context){
    final pending=widget.requests.where((r)=>r.status=='بانتظار الفحص'||r.status=='قيد المراجعة').length;
    final accepted=widget.requests.where((r)=>r.status=='مقبول').length;
    final returned=widget.requests.where((r)=>r.status=='إعادة فحص').length;
    final rejected=widget.requests.where((r)=>r.status=='مرفوض').length;
    return Scaffold(
      appBar:AppBar(title:const Text('طلبات فحص الأعمال'), actions:[IconButton(onPressed:()=>showAboutDialog(context:context,applicationName:'WIR Manager',applicationVersion:'0.1.0',children:[const Text('نظام مبسط لإدارة طلبات فحص الأعمال.')]),icon:const Icon(Icons.info_outline))]),
      body: tab==0 ? ListView(padding:const EdgeInsets.all(16),children:[
        const Text('لوحة التحكم',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),const SizedBox(height:16),
        GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:12,crossAxisSpacing:12,children:[
          StatCard('بانتظار الفحص','$pending',Icons.schedule),StatCard('مقبولة','$accepted',Icons.check_circle),StatCard('إعادة فحص','$returned',Icons.refresh),StatCard('مرفوضة','$rejected',Icons.cancel)]),
        const SizedBox(height:24),const Text('آخر الطلبات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:8),
        ...widget.requests.take(10).map((r)=>RequestCard(r,onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>RequestDetails(request:r,onChanged:()=>setState((){}))))),
      ]) : RequestsList(requests:widget.requests,onChanged:()=>setState((){})),
      floatingActionButton:FloatingActionButton.extended(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>NewInspection(onCreate:(r){widget.onAdd(r); Navigator.pop(context);}))),icon:const Icon(Icons.add),label:const Text('طلب فحص جديد')),
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const [NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'الرئيسية'),NavigationDestination(icon:Icon(Icons.assignment_outlined),selectedIcon:Icon(Icons.assignment),label:'الطلبات')]),
    );
  }
}

class StatCard extends StatelessWidget {final String title,value;final IconData icon;const StatCard(this.title,this.value,this.icon,{super.key});@override Widget build(BuildContext c)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:34),const SizedBox(height:8),Text(value,style:const TextStyle(fontSize:28,fontWeight:FontWeight.bold)),Text(title)])));}

class RequestCard extends StatelessWidget {final WirRequest r;final VoidCallback onTap;const RequestCard(this.r,{super.key,required this.onTap});@override Widget build(BuildContext c)=>Card(child:ListTile(onTap:onTap,leading:CircleAvatar(child:Icon(statusIcon(r.status))),title:Text(r.id,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${r.workType} • ${r.project}'),trailing:StatusChip(r.status)));}
IconData statusIcon(String s)=>s=='مقبول'?Icons.check:s=='مرفوض'?Icons.close:s=='إعادة فحص'?Icons.refresh:Icons.schedule;

class StatusChip extends StatelessWidget {final String status;const StatusChip(this.status,{super.key});@override Widget build(BuildContext c){final color=status=='مقبول'?Colors.green:status=='مرفوض'?Colors.red:status=='إعادة فحص'?Colors.orange:Colors.indigo;return Chip(label:Text(status),avatar:Icon(statusIcon(status),size:16),side:BorderSide.none);}}

class RequestsList extends StatelessWidget {final List<WirRequest> requests;final VoidCallback onChanged;const RequestsList({super.key,required this.requests,required this.onChanged});@override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('جميع الطلبات',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),const SizedBox(height:12),...requests.map((r)=>RequestCard(r,onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>RequestDetails(request:r,onChanged:onChanged))))]);}

class NewInspection extends StatefulWidget {final void Function(WirRequest) onCreate;const NewInspection({super.key,required this.onCreate});@override State<NewInspection> createState()=>_NewInspectionState();}
class _NewInspectionState extends State<NewInspection>{final keyForm=GlobalKey<FormState>();final project=TextEditingController();final location=TextEditingController();final floor=TextEditingController();final axes=TextEditingController();final desc=TextEditingController();String type='خرسانة';@override void dispose(){project.dispose();location.dispose();floor.dispose();axes.dispose();desc.dispose();super.dispose();}
@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('إنشاء طلب فحص')),body:Form(key:keyForm,child:ListView(padding:const EdgeInsets.all(16),children:[field(project,'المشروع',required:true),const SizedBox(height:12),DropdownButtonFormField<String>(value:type,decoration:const InputDecoration(labelText:'نوع الأعمال',border:OutlineInputBorder()),items:['خرسانة','حديد تسليح','بلوك','عزل','تشطيبات','أعمال كهرباء','أعمال ميكانيكية'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>type=v!)),const SizedBox(height:12),field(location,'الموقع / المنطقة'),const SizedBox(height:12),field(floor,'الدور'),const SizedBox(height:12),field(axes,'المحاور'),const SizedBox(height:12),field(desc,'وصف الأعمال',maxLines:5),const SizedBox(height:16),OutlinedButton.icon(onPressed:()=>ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content:Text('سيتم تفعيل رفع الصور في النسخة المتصلة بالخادم.'))),icon:const Icon(Icons.attach_file),label:const Text('إضافة صور ومرفقات')),const SizedBox(height:16),FilledButton.icon(onPressed:(){if(keyForm.currentState!.validate()){final n=DateTime.now().millisecondsSinceEpoch%1000000;widget.onCreate(WirRequest(id:'WIR-${DateTime.now().year}-${n.toString().padLeft(6,'0')}',project:project.text,workType:type,location:location.text,floor:floor.text,axes:axes.text,description:desc.text,status:'بانتظار الفحص',contractor:'المستخدم الحالي',createdAt:DateTime.now()));}},icon:const Icon(Icons.send),label:const Text('إرسال طلب الفحص'))]));}
Widget field(TextEditingController x,String label,{bool required=false,int maxLines=1})=>TextFormField(controller:x,maxLines:maxLines,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder()),validator:required?(v)=>v==null||v.trim().isEmpty?'هذا الحقل مطلوب':null:null);}

class RequestDetails extends StatefulWidget {final WirRequest request;final VoidCallback onChanged;const RequestDetails({super.key,required this.request,required this.onChanged});@override State<RequestDetails> createState()=>_RequestDetailsState();}
class _RequestDetailsState extends State<RequestDetails>{final notes=TextEditingController();@override void dispose(){notes.dispose();super.dispose();}
void update(String status){setState((){widget.request.status=status;widget.request.inspector='المهندس الحالي';widget.request.notes=notes.text;});widget.onChanged();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تم تحديث الطلب إلى: $status')));}
@override Widget build(BuildContext c){final r=widget.request;return Scaffold(appBar:AppBar(title:Text(r.id)),body:ListView(padding:const EdgeInsets.all(16),children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('حالة الطلب',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),StatusChip(r.status)]),const SizedBox(height:16),info('المشروع',r.project),info('نوع الأعمال',r.workType),info('الموقع',r.location),info('الدور',r.floor),info('المحاور',r.axes),info('المقاول',r.contractor),info('الوصف',r.description),const SizedBox(height:16),TextField(controller:notes,maxLines:4,decoration:const InputDecoration(labelText:'ملاحظات المهندس',border:OutlineInputBorder())),const SizedBox(height:16),Wrap(spacing:8,runSpacing:8,children:[FilledButton.icon(onPressed:()=>update('مقبول'),icon:const Icon(Icons.check),label:const Text('قبول')),FilledButton.tonalIcon(onPressed:()=>update('مرفوض'),icon:const Icon(Icons.close),label:const Text('رفض')),OutlinedButton.icon(onPressed:()=>update('إعادة فحص'),icon:const Icon(Icons.refresh),label:const Text('إعادة فحص'))]),const SizedBox(height:24),OutlinedButton.icon(onPressed:()=>showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('التقرير'),content:Text('تقرير ${r.id}\nالحالة: ${r.status}\nالمشروع: ${r.project}\nالنتيجة: ${r.notes??'—'}'),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('إغلاق'))])),icon:const Icon(Icons.picture_as_pdf),label:const Text('معاينة التقرير'))]);}
Widget info(String a,String b)=>Card(child:ListTile(title:Text(a,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(b.isEmpty?'—':b)));}
