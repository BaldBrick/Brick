require 'open-uri'
require 'nokogiri'
require 'json'
require 'spreadsheet'
class Parse_auto_sto

  def initialize()
    @url = 'https://auto-sto.by/cena.html'
    @html = File.read('b.html') rescue open(@url)
    @doc = Nokogiri::HTML(@html)
  end

  def parse_page
    @doc.xpath("//table//tr").inject([]) do |acc, tr|
      td    = tr.xpath("./td")
      name  = td[0].text
      price = td[1].text[/([\d\.,]+)/, 1]
      acc << {name: name, price: price}
    end
  end
end

class Parse_akc

  def initialize()
    @url = 'http://akc.by/price'
    @html = File.read('b.html') rescue open(@url)
    @doc = Nokogiri::HTML(@html)
  end

  def parse_page
    @doc.xpath("//table//tbody//tr").inject([]) do |acc, tr|
      td    = tr.xpath("./td")
      name  = td[0].text
      price = td[1].text[/([\d\.,]+)/, 1]
      acc << {name: name, price: price}
    end
  end
end

class Parse_autoliga

  def initialize()
    @url = 'http://autoliga.by/prajsy.html'
    @html = File.read('b.html') rescue open(@url)
    @doc = Nokogiri::HTML(@html)
  end

  def parse_page
    @doc.xpath("//table//tr[contains(@style, 'background-color')]").inject([]) do |acc, tr|
      td          = tr.xpath("./td")
      name, price = td[0].text, td[1].text[/([\d\.,]+)/, 1]
      acc << {:name => name, :price => price}
    end
  end
end


class Comprator
  def initialize(akc, liga, sto)
    @mas1 = akc.parse_page
    @mas2 = liga.parse_page
    @mas3 = sto.parse_page
  end

  def is_similar(a, b, threshold)
    a_arr = a.downcase.split(' ')
    b_arr = b.downcase.split(' ')

    common_words = a_arr & b_arr
    ratio        = common_words.size / ((a_arr + b_arr).size / 2.0)
    ratio >= threshold
  end

  def compare_services

    similarities = []

    @mas1.each do |el_1|
      temp_1 = @mas2.find { |el_2| is_similar(el_2[:name], el_1[:name], 0.4) }
      temp_2 = @mas3.find { |el_3| is_similar(el_3[:name], el_1[:name], 0.4) }

      if temp_1 && temp_2
        similarities << [el_1, temp_1, temp_2]
      end
    end

    sum = [0, 0, 0]
    op  = similarities.inject([]) do |acc, sim|
      comp = compare_prices(sim[0][:price], sim[1][:price], sim[2][:price])
      sim.each_with_index { |offer, i| sum[i] += comp[i] }
      sim.each_with_index { |offer, i| acc << {name: offer[:name], price: offer[:price], score: comp[i], index: i} }
      acc
    end
    puts op
    write_excel(op)
  end

  def write_excel(acc)
    n=1
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).concat %w{akc.by autoliga.by auto-sto.by }
    sum1=0
    sum2=0
    sum3=0
    acc.each_slice(3).each do |b|
      
      a = b[0]
      sheet1[n,a[:index]] = a[:name]
      sheet1[n+1,a[:index]] = a[:price]
      sheet1[n+2,a[:index]] = a[:score]
      sum1+=a[:score]

      a = b[1]
      sheet1[n,a[:index]] = a[:name]
      sheet1[n+1,a[:index]] = a[:price]
      sheet1[n+2,a[:index]] = a[:score]
      sum2+=a[:score]

      a = b[2]
      sheet1[n,a[:index]] = a[:name]
      sheet1[n+1,a[:index]] = a[:price]
      sheet1[n+2,a[:index]] = a[:score]
      sum3+=a[:score]

      n+=3
     end
      sheet1[2,5] = sum1
      sheet1[2,6] = sum2
      sheet1[2,7] = sum3

    book.write 'excel.xls'
  end

  def compare_prices(val_1, val_2, val_3)
    a = Array.new(3)
    a[0] = Array.new(3)
    a[1] = Array.new(3)
    a[2] = Array.new(3)
    if val_1 < val_2
      a[0][1] = 1
      a[0][0] = 0
      a[1][0] = 0
    else
      a[0][0] = 0
      a[0][1] = 0
      a[1][0] = 1
    end
    if val_2 < val_3
      a[1][2] = 1
      a[1][1] = 0
      a[2][1] = 0
    else
      a[1][1] = 0
      a[2][1] = 1
      a[1][2] = 0
    end
    if val_3 < val_1
      a[2][2] = 0
      a[0][2] = 0
      a[2][0] = 1
    else
      a[0][2] = 1
      a[2][2] = 0
      a[2][0] = 0
    end

    return sum1 = a[0][0] + a[0][1] + a[0][2], sum2 = a[1][0] + a[1][1] + a[1][2], sum3 = a[2][0] + a[2][1] + a[2][2]


  end
end

