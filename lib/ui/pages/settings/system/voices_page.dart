
import 'package:seagull/ui/all.dart';

class VoicesPage extends StatefulWidget{
  
  final List<String> allVoices;

  const VoicesPage({Key? key, required this.allVoices}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return VoicesPageState();
  }
  
}

class VoicesPageState extends State<VoicesPage>{

  final List<String> allVoices;
  final List<String> downloadedVoices;
  @override
  Widget build(BuildContext context) {
  }
  
}