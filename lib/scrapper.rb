require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

#Recupération de l'e-mail d'une mairie du Val d'Oise
def get_townhall_email(townhall_url)
  page = Nokogiri::HTML(URI.open(townhall_url)) 
  email_array = []

  email = page.xpath('//*[contains(text(), "@")]').text
  town = page.xpath('//*[contains(text(), "Adresse mairie de")]').text.split 

  email_array << {town[3] => email} 
  puts email_array
  return email_array
end


#Recupération des URLs de chaque ville du Val d'Oise
def get_townhall_urls
  page = Nokogiri::HTML(URI.open("http://annuaire-des-mairies.com/val-d-oise.html"))
  url_array = []

  urls = page.xpath('//*[@class="lientxt"]/@href') 

  urls.each do |url| 
    url = "http://annuaire-des-mairies.com/"+ url.text[1..-1] 
    url_array << url
  end
  return url_array
end

#Assemblage des infos
def town_mail
  res = get_townhall_urls.map do |townhall_url| 
    get_townhall_email(townhall_url)
  end
  return res
end

town_mail

def save_as_json
    File.open("./db/email.json", 'w') do |file|
    file.write(town_mail.to_json)
  end
end

#save_as_json

def save_as_csv
  csv = town_mail.flatten.map{ |element| element.map{|k, v| [k, v]}}
  csv = csv.map { |data| data.join(",") }.join("\n")
  File.open("./db/email.csv", 'w') do |file|
    file.write(csv)
  end
end

save_as_csv