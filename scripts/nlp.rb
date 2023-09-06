require 'awesome_print'
require 'oj'
require 'faraday'
require 'pry'
require 'pry-byebug'
require 'active_support/all'

require_relative './utils'
require_relative './yandex_transliteration'

# txt = '{of: 1, df: "123"}'
# ap JSON(txt)

# class LogOnError < Faraday::Response::Middleware
#
#   def initialize(app, options = {})
#     @app = app
#     @logger = options.fetch(:logger) {
#       require 'logger'
#       ::Logger.new($stdout)
#     }
#   end
#
#   def call(env)
#     @app.call(env).on_complete do
#       response = JSON.parse(env.body, symbolize_names: true)
#       # if ([:error, :execute_errors] & response&.keys).any?
#         tracestack = caller#.select { |entry| entry =~ /lib\/vk|app\/services|app\/workers/ }
#         #ErrorMonitoring.error("Failed Vk::Client: #{tracestack[-1]}", extra: { tracestack: tracestack, method: env.method, url: env.url.to_s, response: response_values(env, response) })
#         @logger.info [tracestack, response_values(env, response)]
#       # end
#     end
#   end
#
#   def response_values(env, response)
#     {:status => env.status, :headers => env.response_headers, :body => env.body, pb: response }
#   end
# end

# # 'http://localhost:3000/api/?q=text:%22%D0%9C%D1%8B%D1%81%D0%BB%D1%8C%22'
# def build_connection
#   Faraday.new(url: 'http://localhost:3000/api/') do |conn|
#     conn.request :multipart
#     conn.request :url_encoded
#     # conn.use LogOnError
#     conn.adapter Faraday.default_adapter
#     # conn.adapter :typhoeus
#   end
# end

# @connection = build_connection
@util = DavidBlaine::Utils.new(true)
# binding.pry
# @connection.get(URI.encode '?q=text:\"Мысль\"')

# def get_text(query, offset = 0, limit = 10)
#   @connection.get(URI.encode "?q=text:\"#{query}\"&nhits=#{limit}&offset=#{offset}")
#   # @connection.get(URI.encode '?q=text:\"Мысль\"')
# end

# binding.pry

titles = { 'огон' => 'огонь', 'огн' => 'огонь', 'мысл' => 'мысль', 'забот' => 'забота',
           'качеств' => 'качества', 'карм' => 'карма', 'дух' => 'дух', 'свобод' => 'свобода',
           'чувствознание' => 'чувствознан', 'сердц' => 'сердце', 'стих' => 'стихия', 'учен' => 'ученик',
           'сознан' => 'сознание', 'эволюц' => 'эволюция',  'мудрост' => 'мудрость', 'Спасит' => 'Спаситель',
           'жизн' => 'жизнь', 'косм' => 'космос', 'пространств' => 'пространство', 'подвиг' => 'подвиг',
           'вол' => 'воля', 'мудр' => 'мудрость', 'созвуч' => 'созвучие', 'твор' => 'творчество',
           'спокой' => 'спокойствие', 'равновес' => 'равновесие', 'челов' => 'человек',
           'гармон' => 'гармония', 'йог' => 'йог', 'выбор' => 'выбор', 'крас' => 'красота', 'правд' => 'правда',
           'Вселенная' => 'вселен', 'обычность' => '​обычн', 'сила' => '​сил', 'препятствие' => '​препятств', 'атом' => 'атом', 
           'дерзновение' => '​дерзновен', 'дерзание' => '​дерзан', 'планета' => '​планет', 'путь' => '​пут', 'сын' => '​сын', 
           'монада' => '​монад', 'пульс' => '​пульс', 'музыка' => '​музык', 'тело' => 'тел', 'закон' => '​закон',
           'гармония' => '​гармон', 'стержень' => '​стержен', 'основа' => '​основ', 'строитель' => '​строител', 'движение' => '​движен',
           'Хаос' => '​хаос', 'эволюция' => '​эволюц', 'Армагеддон' => '​армагеддон', 'рычаг' => '​рычаг', 'цикл' => '​цикл',
           'осознание' => '​осознан', 'правда' => '​правд', 'толпа' => '​толп', 'Голос' => '​голос', 'психотехника' => '​психотехн',
           'колесо исполнения' => '​колес исполнен', 'Арфа духа' => '​арф дух', 'природа' => '​природ', 'Астрофизика' => '​астрофиз',
           'астрохимия' => '​астрохим', 'астрономия' => '​астроном', 'Земля' => '​земл', 'Солнце' => 'солн', 'астрология' => '​астролог',
           'Рыбы' => '​рыб', 'Водолей  ' => '​водол', 'судьба' => '​судьб', 'свобода воли' => '​свобод вол',
           'борьба' => '​борьб', 'полет' => '​полет', 'единение' => '​единен', 'Матерь Мира' => '​матер мир',
           'слияние сознаний' => '​слиян сознан', 'степень' => '​степен', 'вид' => '​вид', 'аспект' => '​аспект',
           'напряжение' => '​напряжен', 'Круг' => '​круг', 'Цикл' => '​цикл', 'Пралайя' => '​пралай', 'Обскурация' => '​обскурац',
           'спираль' => '​спирал', 'Лестница Иерархии Света' => '​лестниц иерарх свет', 'воин' => '​воин', 'победитель' => '​победител', 
           'овладение' => '​овладен', 'микрокосм' => '​микрокосм', 'пранаяма' => '​пранаям', 'действие' => '​действ', 'суета' => '​сует',
           'нервная система' => '​нервн систем', 'город' => '​город', 'поток' => '​поток', 'привычка' => '​привычк', 'кристалл' => '​кристалл',
           'чистота' => '​чистот', 'благо' => '​благ', 'накопления' => '​накоплен', 'вред' => '​вред', 'результат' => '​результат',
           'Беспредельность' => '​беспредельн', 'плодонос ' => '​плодонос ', 'полет' => '​полет', 'преуспеяние' => '​преуспеян', 'сон ' => '​сон',
           'смерть' => '​смерт', 'прогноз' => '​прогноз', 'подъем' => '​под', 'спад' => '​спад', 'Аритмичность' => '​аритмичн',
           'звезд' => '​звезд', 'цель' => '​цел', 'кристалл' => '​кристалл', 'напряг' => '​напряг', 'мужество' => '​мужеств',
           'человек' => '​человек', 'энерг' => '​энерг', 'озарение' => '​озарен', 'власть' => '​власт', 'Аум' => '​аум', 'Агни' => '​агн',
           'рост' => '​рост', 'устремление' => '​устремлен', 'ритм' => '​ритм', 'путь' => '​пут', 'победа' => '​побед',
           'волна' => '​волн', 'Свет' => '​свет', 'крылья' => '​крыл', 'жизн' => '​жизн', 'радость' => '​радост',
           'работ' => '​работ', 'пламя' => '​плам', 'несломим' => '​неслом', 'упорство' => '​упорств', 'твердость' => '​твердост',
           'настойчивость' => '​настойчив', 'постоянство' => '​постоянств', 'машина' => '​машин', 'волна' => '​волн', 
           'длинная линия' => '​длин лин', 'победитель' => '​победител', 'мост' => '​мост', 'якорь' => '​якор',
           'Майтрейя' => '​майтрей', 'астрал' => 'астрал', 'Знамя Мира' => 'Знам Мир',
           'Сердце' => 'Сердц',    'получающий' => 'получа',   'устремление' => 'устремлен',
           'Высшему' => 'Высш',           'форма' => 'форм',           'очищение' => 'очищен',
           'равновесие' => 'равновес',           'утонченным' => 'утончен',           'Космический' => 'Космическ',

}

# ap titles.map { |k,v| [k, YandexTransliteration.convert(v)] }.to_h

lat_titles = {  "огон" => "ogon", "огн" => "ogon",  "мысл" => "mysl", "забот" => "zabota",
                "качеств" => "kachestva","карм" => "karma","дух" => "duh","свобод" => "svoboda","чувствознание" => "chuvstvoznan",
                "сердц" => "serdce","стих" => "stihiya","учен" => "uchenik","сознан" => "soznanie","эволюц" => "ehvolyuciya",
                "мудрост" => "mudrost","Спасит" => "spasitel","жизн" => "​zhizn","косм" => "kosmos",
                "пространств" => "prostranstvo","подвиг" => "podvig","вол" => "volya","мудр" => "mudrost",
                "созвуч" => "sozvuchie","твор" => "tvorchestvo","спокой" => "spokojstvie",
                "равновес" => "ravnovesie","челов" => "chelovek","гармон" => "garmoniya","йог" => "jog",
                "выбор" => "vybor","крас" => "krasota","правд" => "pravda","Вселенная" => "vselen",
                "обычность" => "​obychn","сила" => "​sil","препятствие" => "​prepyatstv","атом" => "atom",
                "дерзновение" => "​derznoven","дерзание" => "​derzan","планета" => "​planet","путь" => "​put",
                "сын" => "​syn","монада" => "​monad","пульс" => "​puls","музыка" => "​muzyk",
                "тело" => "tel","закон" => "​zakon","гармония" => "​garmon","стержень" => "​sterzhen","основы" => "​osnovy",
                "строитель" => "​stroitel","движение" => "​dvizhen","Хаос" => "​haos","эволюция" => "​ehvolyuc",
                "Армагеддон" => "​armageddon","рычаг" => "​rychag","цикл" => "​cikl","осознание" => "​osoznan","правда" => "​pravd",
                "толпа" => "​tolp","Голос" => "​golos","психотехника" => "​psihotekhnik","колесо исполнения" => "​koles-ispolnen",
                "Арфа духа" => "​arf-duh","природа" => "​prirod","Астрофизика" => "​astrofizik","астрохимия" => "​astrohim",
                "астрономия" => "​astronom","Земля" => "​zeml","Солнце" => "soln","астрология" => "​astrolog",
                "Рыбы" => "​ryb","Водолей  " => "​vodol","судьба" => "​sudb","свобода воли" => "​svobod-vol",
                "борьба" => "​borb","полет" => "​polet","единение" => "​edinen","Матерь Мира" => "​mater-mir",
                "слияние сознаний" => "​sliyan-soznan","степень" => "​stepen","вид" => "​vid","аспект" => "​aspekt",
                "напряжение" => "​napryazhen","Круг" => "​krug","Цикл" => "​cikl","Пралайя" => "​pralaj","Обскурация" => "​obskurac",
                "спираль" => "​spiral","Лестница Иерархии Света" => "​lestnic-ierarh-svet","воин" => "​voin","победитель" => "​pobeditel",
                "овладение" => "​ovladen","микрокосм" => "​mikrokosm","пранаяма" => "​pranayam","действие" => "​dejstv",
                "суета" => "​suet","нервная система" => "​nervn-sistem","город" => "​gorod","поток" => "​potok","привычка" => "​privychk",
                "кристалл" => "​kristall","чистота" => "​chistot","благо" => "​blag","накопления" => "​nakoplen",
                "вред" => "​vred","результат" => "​rezultat","Беспредельность" => "​bespredeln", "плодонос" => "​plodonos",
                "преуспеяние" => "​preuspeyan","сон " => "​son","смерть" => "​smert","прогноз" => "​prognoz","подъем" => "​pod",
                "спад" => "​spad","Аритмичность" => "​aritmichn","звезд" => "​zvezd","цель" => "​cel","напряг" => "​napryag",
                "мужество" => "​muzhestv","человек" => "​chelovek","энерг" => "​ehnerg","озарение" => "​ozaren",
                "власть" => "​vlast","Аум" => "​aum","Агни" => "​agn","рост" => "​rost","устремление" => "​ustremlen","ритм" => "​ritm",
                "победа" => "​pobed","волна" => "​voln","Свет" => "​svet","крылья" => "​kryl","радость" => "​radost",
                "работ" => "​rabot","пламя" => "​plam","несломим" => "​neslom","упорство" => "​uporstv","твердость" => "​tverdost",
                "настойчивость" => "​nastojchiv","постоянство" => "​postoyanstv","машина" => "​mashin","длинная линия" => "​dlin-lin",
                "мост" => "​most","якорь" => "​yakor","Майтрейя" => "​Maytreja","астрал" => "astral", 'Знамя Мира' => 'znam-mir'
}

limit = 10

def save_to_markdown(page, content)
  d = YAML::load_file('./scripts/test.yml') #Load
  d['title'] = 'agni'
  d['article'] = true
  d['category'] = 'словарь'
  d['tags'] = []
  d['tags'] << 'словарь'

  File.open("./scripts/post#{page}.md", 'w') do |f|
    f.write(d.to_yaml)
    f.write "\n"
    f.write content.join("\n\n")
  end
end

# titles.keys[0..0].each do |q|
#   resp = get_text(q, 0, 1)
#   resp_body = JSON(resp.body, symbolize_names: true)
#   total_hits = resp_body[:num_hits].to_i
#   pages = (total_hits/limit).ceil
#   pages = 2
#
#
#   (0..pages).to_a.each do |step|
#     offset = step * limit
#     resp = get_text(q, offset, limit)
#     resp_body = JSON(resp.body, symbolize_names: true)
#     # ap resp_body[:hits].map { |v| {title: v[:doc][:shloka][0], txt: v[:doc][:text][0]} }
#     ap [{ q: q, freq: resp_body[:num_hits] }.merge(hits: resp_body[:hits].map { |v| { title: v[:doc][:shloka][0], txt: v[:doc][:text][0], year: v[:doc][:year][0] } }) ]
#     # content = resp_body[:hits].map { |v| {title: v[:doc][:shloka][0], txt: v[:doc][:text][0], year: v[:doc][:year][0]} }
#     content = resp_body[:hits].map { |v| v[:doc][:text][0] }
#     binding.pry
#     stem_content = content.map { |txt| @util.stem(txt) }
#
#     save_to_markdown(step, content)
#   end
# end
