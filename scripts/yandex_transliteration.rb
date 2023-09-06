module YandexTransliteration
  extend self

  def convert(text)
    text = text.mb_chars.downcase.to_s

    translit_rules.each do |key, value|
      text.gsub!(Regexp.new(key.to_s), value)
    end

    text
  end

  private

  def translit_rules
    {
      'кх': 'kkh',
      'зх': 'zkh',
      'цх': 'ckh',
      'сх': 'skh',
      'ех': 'ekh',
      'хх': 'khkh',
      'а': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'j',
      'к': 'k',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'о': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ф': 'f',
      'х': 'h',
      'ц': 'c',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'shch',
      'ъ': '',
      'ы': 'y',
      'ь': '',
      'э': 'eh',
      'ю': 'yu',
      'я': 'ya',
      '[\s!@#$%^&*(),.?":{}|<>]': '-',
      '(-)+': '-'
    }
  end
end
