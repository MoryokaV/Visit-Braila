import 'dart:ui';
import 'package:visit_braila/models/question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String icon;
  final Color color;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

List<Quiz> quizes = [
  Quiz(
    id: "quiz1",
    title: "Istorie",
    icon: "assets/icons/history.svg",
    color: const Color(0xffff6b6b),
    questions: [
      Question(
        text: "În ce an a luat ființă Expoziția memorială permanenta 'Panait Istrati'?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "1984",
          "1999",
          "2001",
          "1960",
        ],
      ),
      Question(
        text: "În ce stil a fost făcută clădirea bibliotecii județene?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Modernist",
          "Neoclasic",
          "Baroc",
        ],
      ),
      Question(
        text: "Când a fost declarată Brăila port-liber?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "1350",
          "1836",
          "1989",
          "1401",
        ],
      ),
      Question(
        text: "Între anii 1849-1850 Teatrul Municipal a fost han",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "În ce an a fost Brăila declarată port?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "1836",
          "1324",
          "1989",
          "1644",
        ],
      ),
      Question(
        text: "Care a fost primul nume al orașului Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Vicinia",
          "Drinago",
          "Barilla",
          "Zemun",
        ],
      ),
      Question(
        text: "Care a fost momentul în care Brăila a fost menționată pentru prima dată în documente istorice?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "1368",
          "1436",
          "1503",
        ],
      ),
      Question(
        text: "Ce eveniment important a avut loc în 1829, în timpul istoriei Brăilei?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Brăila a devenit capitala României pentru scurt timp",
          "Brăila a fost înfrântă de otomani",
          "Brăila a fost eliberată de sub ocupația otomană",
        ],
      ),
      Question(
        text: "Ce statut a primit Brăila în timpul domniei lui Alexandru Ioan Cuza?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Statut de oraș autonom",
          "Statut de capitală a Moldovei",
          "Statut de porto-franco",
        ],
      ),
      Question(
        text: "Ce eveniment a marcat anul 1940 pentru Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Brăila a fost ocupată de trupele germane",
          "Brăila a fost inclusă în Basarabia Mare",
          "Brăila a fost ocupată de trupele sovietice",
        ],
      ),
      Question(
        text: "Care a fost una dintre industriile importante în Brăila în secolul al XIX-lea?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Industria navală",
          "Industria textilă",
          "Industria minieră",
        ],
      ),
      Question(
        text: "Care a fost impactul Războiului de Independență din 1877-1878 asupra Brăilei?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "A dus la creșterea economică și culturală",
          "A provocat distrugeri masive în oraș",
          "A determinat o migrare masivă a populației",
        ],
      ),
      Question(
        text: "Ceasul public da ora exacta de peste 100 de ani?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "In ce an a fost construit ceasul public?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "1909",
          "1900",
          "1880",
        ],
      ),
      Question(
        text: "Cine a facut constructia propriu-zisa a ceasului public?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Carol Sakar",
          "Apollodor din Damasc",
          "Zaha Hadid",
        ],
      ),
      Question(
        text: "Cine a facut constructia propriu-zisa a ceasului public?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Apollodor din Damasc",
          "Zaha Hadid",
          "Carol Sakar",
        ],
      ),
      Question(
        text: "Biserica 'Sfintii Arhangheli Mihail si Gavril'...",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "face parte din patrimoniul UNESCO",
          "are o vechime de 100 de ani",
          "a servit drept casa de rugaciune in perioada ocupatiei otomane",
        ],
      ),
      Question(
        text: "În ce an a fost fondat orașul Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "1308",
          "1375",
          "1420",
          "1506",
        ],
      ),
      Question(
        text: "În ce secol Brăila a devenit un important centru comercial și port la Dunăre?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Secolul al XVII-lea",
          "Secolul al XII-lea",
          "Secolul al XVI-lea",
          "Secolul al XIX-lea",
        ],
      ),
      Question(
        text: "Ce monument important din Brăila este dedicat luptei pentru independență din 1877-1878?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Monumentul Eroilor de pe Calea Galațiului",
          "Monumentul Independenței de pe Bulevardul Independentei",
          "Monumentul Domnitorului Alexandru Ioan Cuza",
          "Monumentul Soldatului Necunoscut",
        ],
      ),
      Question(
        text: "Care este numele celei mai vechi instituții de învățământ superior din Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Universitatea 'Alexandru Ioan Cuza'",
          "Universitatea 'Ovidius'",
          "Universitatea 'Dunărea de Jos'",
        ],
      ),
      Question(
        text:
            "Care obiectiv turistic al Brailei este asociat cu epoca medievală și a fost construit pentru apărarea orașului împotriva invaziilor turcești?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Biserica Sfântul Nicolae",
          "Biserica Sfântul Ioan",
          "Muzeul de istorie Carol I",
        ],
      ),
      Question(
        text:
            "Care a fost rolul principal al Brailei în secolul al XIX-lea, care a contribuit semnificativ la dezvoltarea sa economică și culturală?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Centru industrial",
          "Port fluvial important",
          "Centru de comerț cu târgurile otomane",
          "Capitală regională",
        ],
      ),
    ],
  ),
  Quiz(
    id: "quiz2",
    title: "Personalități",
    icon: "assets/icons/people.svg",
    color: const Color(0xffffa94d),
    questions: [
      Question(
        text: "Care a fost una dintre meseriile lui D.P.Perpessicius?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Agricultor",
          "Critic literar",
          "Arhitect",
        ],
      ),
      Question(
        text: "Care dintre următoarele personalități istorice este asociată cu Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Mihail Kogălniceanu",
          "Vlad Țepeș",
          "Mihai Eminescu",
        ],
      ),
      Question(
        text: "Ce statut a primit Brăila în timpul domniei lui Alexandru Ioan Cuza?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Statut de capitală a Moldovei",
          "Statut de porto-franco",
          "Statut de oraș autonom",
        ],
      ),
      Question(
        text: "Cine a fost domnitorul care a acordat Brăilei drepturi de oraș liber în 1458?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Ștefan cel Mare",
          "Vlad Țepeș",
          "Mircea cel Bătrân",
          "Alexandru Ioan Cuza",
        ],
      ),
      Question(
        text: "In Casa Ana Aslan ...",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "au fost scrise numeroase carti despre istoria Brailei",
          "s-au facut primele analize chimice sistematice din Tara Romaneasca",
          "a fost fabricat primul stilou",
        ],
      ),
      Question(
        text: "Mihail Sebastian a fost ...",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Medic, cercetator",
          "Scriitor, dramaturg și jurnalist",
          "Arhitect",
        ],
      ),
      Question(
        text: "Nicolae Iorga este considerat unul dintre cei mai importanți istorici și gânditori ai României",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "Ce origini are Panait Istrati?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Romanesti",
          "Grecestu",
          "Turcesti",
        ],
      ),
      Question(
        text: "Ce meserii a avut Nina Cassian?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Poetă, eseistă",
          "Arheolog",
          "Jurnalist",
        ],
      ),
      Question(
        text: "Nicolae Toniza a fost unul dintre cei mai importanți pictori români ai secolului al XX-lea?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "Nicolae Toniza este un pictor contemporan?",
        answearType: Answear.trueFalse,
        correctAnswear: 0,
      ),
      Question(
        text: "Braila are peste 30 de personalitati remarcabile de-a lungul istoriei?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "Nicolae Balcescu ca om politic a ...",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "a fost lider al mișcării de emancipare națională și socială din secolul al XIX-lea",
          "a facut parte din partidul liberal al secolului XX",
        ],
      ),
      Question(
        text:
            "Ana Aslan este cunoscută pentru dezvoltarea unei terapii utilizate în tratamentul cărui aspect al îmbătrânirii?",
        answearType: Answear.multipleChoice,
        correctAnswear: 4,
        answears: [
          "Riduri",
          "Pierderea memoriei",
          "Oboseala cronică",
          "Alergiile",
        ],
      ),
      Question(
        text: "Care este numele terapiei dezvoltate de Ana Aslan, utilizată pentru a încetini procesul de îmbătrânire?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Terapia cu vitamine",
          "Terapia hormonală",
          "Gerovitalul",
          "Crioterapia",
        ],
      ),
      Question(
        text: "Maria Filotti are un teatru consturit in memoria sa in centrul orasului?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "În ce an s-a născut Maria Filotti?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "1885",
          "1883",
          "1890",
        ],
      ),
      Question(
        text: "Care este una dintre cele mai cunoscute roluri interpretate de Maria Filotti în teatru?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Doamna Scrooge",
          "Doamna Olga",
          "Doamna Bovary",
        ],
      ),
      Question(
        text: "Care a fost numele real al lui Hariclea Darclée?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Elena Hariclea",
          "Minaev Elena",
          "Maria Hariclea",
        ],
      ),
      Question(
        text: "Care a fost rolul cel mai celebru interpretat de Hariclea Darclée?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Tosca",
          "Carmen",
          "Traviata",
        ],
      ),
      Question(
        text: "În ce an s-a născut Panait Istrati?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "1884",
          "1875",
          "1890",
        ],
      ),
      Question(
        text:
            "Care este titlul celei mai cunoscute opere a lui Panait Istrati, care a avut un mare impact în literatura română și europeană?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Codin",
          "Moara cu noroc",
          "Adela",
        ],
      ),
      Question(
        text: "Cine a fost mentorul și prietenul lui Panait Istrati, un alt scriitor celebru din aceeași perioadă?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Ion Luca Caragiale",
          "Mihail Sadoveanu",
          "Constantin Dobrogeanu-Gherea",
        ],
      ),
      Question(
        text: "Care este originea numelui 'Thüringer' al casei?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Este numele unui arhitect celebru care a proiectat casa",
          "Este numele proprietarului original al casei",
          "Este numele regiunii din Germania de unde proveneau proprietarii inițiali",
        ],
      ),
    ],
  ),
  Quiz(
    id: "quiz3",
    title: "Geografie",
    icon: "assets/icons/geography.svg",
    color: const Color(0xff12b886),
    questions: [
      Question(
        text: "Unde se afla Muzeul de istorie Carol I?",
        answearType: Answear.multipleChoice,
        correctAnswear: 4,
        answears: [
          "Bulevardul Dorobantilor",
          "Piata Poligon",
          "Calea Calarasilor",
          "Piata Traian",
        ],
      ),
      Question(
        text: "Care este denumirea principalului fluviu care străbate orașul Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 4,
        answears: [
          "Sena",
          "Nil",
          "Prut",
          "Dunarea",
        ],
      ),
      Question(
        text: "În ce secol Brăila a devenit un important centru comercial și port la Dunăre?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Secolul al XVII-lea",
          "Secolul al XII-lea",
          "Secolul al XVI-lea",
          "Secolul al XIX-lea",
        ],
      ),
      Question(
        text: "Braila nu are iesire la Dunare",
        answearType: Answear.trueFalse,
        correctAnswear: 0,
      ),
      Question(
        text: "Al câtelea sediu BNR din țară este cel din Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 4,
        answears: [
          "Primul",
          "Ultimul",
          "Al treilea",
          "Al doilea",
        ],
      ),
      Question(
        text: "Care este caracteristica principală a falezei Dunării din Brăila, România?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Este locul unde se află cel mai vechi far de pe malul Dunării",
          "Este o destinație populară pentru activități recreative și plimbări",
          "Este un sit arheologic unde au fost descoperite vestigii din perioada romană",
        ],
      ),
      Question(
        text: "Care dintre următoarele caracteristici este asociată cu grădina publică din Brăila, România?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Este locul unde se află cea mai veche staturie din țară",
          "Este amenajată în stilul baroc, cu sculpturi și fântâni ornamentale",
          "Este renumită pentru colecția sa de plante exotice și rare",
        ],
      ),
      Question(
        text: "Grădina Mare are un ceas floral?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "În ce an a fost pus în funcțiune ceasul floral din Grădina Mare?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "1956",
          "2001",
          "1890",
        ],
      ),
      Question(
        text: "Ce stil arhitectural are Biserica Greaca?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "bizanino-gotic",
          "baroc",
          "neomodernist",
        ],
      ),
      Question(
        text: "Ce regiuni ale țării unește podul peste Dunăre de la Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Muntenia și Moldova",
          "Moldova și Dobrogea",
          "Muntenia și Dobrogea",
        ],
      ),
      Question(
        text: "Unde se află Ceasul Public?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Piata Poligon",
          "Parcul Monument",
          "Piata Traian",
        ],
      ),
      Question(
        text: "Cum se numea Parcul Monument?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Traian",
          "Kiseleff",
          "Verde",
        ],
      ),
      Question(
        text: "Cum ce alta constructie seamana Podul suspendat peste Dunare?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Podul peste bosfor, Istanbul",
          "Podul cu lanturi, Budapesta",
          "Golden Gate, San Francisco",
        ],
      ),
      Question(
        text: "Unde se afla castelul de apa?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Strada Regala",
          "Parcul Monument",
          "Piata Carantinei",
        ],
      ),
      Question(
        text: "Castelul de apa a fost in 1913 cea mai mare constructie de acest gen din Romania?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "In Casa Ana Aslan ...",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "au fost scrise numeroase carti despre istoria Brailei",
          "s-au facut primele analize chimice sistematice din Tara Romaneasca",
          "a fost fabricat primul stilou",
        ],
      ),
      Question(
        text: "Biserica 'Sfintii Arhangheli Mihail si Gavril'...",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "face parte din patrimoniul UNESCO",
          "a servit drept casa de rugaciune in perioada ocupatiei otomane",
          "are o vechime de 100 de ani",
        ],
      ),
      Question(
        text: "Care este unul dintre simbolurile distinctive ale Brăilei, cunoscut pentru arhitectura sa Art Nouveau?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Casa cu Lei",
          "Turnul Clopotniță",
          "Teatrul Maria Filotti",
          "Palatul Administrativ",
        ],
      ),
      Question(
        text: "Ce nume purta grădina publică centrală din Brăila, care oferă o oază de verdeață și relaxare?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Grădina Cismigiu",
          "Grădina Alexandru Ioan Cuza",
          "Grădina Publică 'Ionel Brătianu'",
        ],
      ),
      Question(
        text: "Care este numele celei mai vechi instituții de învățământ superior din Brăila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Universitatea 'Alexandru Ioan Cuza'",
          "Universitatea 'Ovidius'",
          "Universitatea 'Dunărea de Jos'",
        ],
      ),
      Question(
        text: "Unde se afla casa unde s-a nascut Panait Istrati?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Strada M.Eminescu",
          "Strada Plevnei",
          "Calea Dorobantilor 52",
        ],
      ),
      Question(
        text: "Care este originea numelui 'Thüringer' al casei?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Este numele unui arhitect celebru care a proiectat casa",
          "Este numele proprietarului original al casei",
          "Este numele regiunii din Germania de unde proveneau proprietarii inițiali",
        ],
      ),
    ],
  ),
  Quiz(
    id: "quiz4",
    title: "Religie",
    icon: "assets/icons/cross.svg",
    color: const Color(0xffadb5bd),
    questions: [
      Question(
        text: "Biserica Greacă are hramul 'buna vestire'?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "Este prezenta in Braila minoritatea rusilor lipoveni",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "Ce cult religios este dominant in zona Brailei?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "Catolic",
          "Musulman",
          "Ortodox",
          "Protestant",
        ],
      ),
      Question(
        text: "Ce stil arhitectural are Biserica Greaca?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "bizanino-gotic",
          "baroc",
          "neomodernist",
        ],
      ),
      Question(
        text: "Cea mai importanta comunitate etnica din oraș în secolul al XIX-lea",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Maghiara",
          "Greaca",
          "Turca",
        ],
      ),
      Question(
        text: "Care este hramul bisericii bulgaresti?",
        answearType: Answear.multipleChoice,
        correctAnswear: 1,
        answears: [
          "Inaltarea domnului",
          "Sf. Nicolae",
          "Sf. Ioan",
        ],
      ),
      Question(
        text: "Biserica 'Sfintii Arhangheli Mihail si Gavril'...",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "face parte din patrimoniul UNESCO",
          "a servit drept casa de rugaciune in perioada ocupatiei otomane",
          "are o vechime de 100 de ani",
        ],
      ),
      Question(
        text: "Biserica 'Sfintii Arhangheli Mihail si Gavril' are mari influente turcesti",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
      Question(
        text: "Biserica Greaca este cea mai noua constructie de acest gen in municipiul Braila",
        answearType: Answear.trueFalse,
        correctAnswear: 0,
      ),
      Question(
        text: "Cate manastiri sunt in municipiul Braila?",
        answearType: Answear.multipleChoice,
        correctAnswear: 3,
        answears: [
          "5",
          "11",
          "0",
          "2",
        ],
      ),
    ],
  ),
];
