require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

puts 'EventManager Initialized!'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "Look somewhere else"
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)

=begin contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end
=end

def registrations_by_hour(csv_file)
  hour_array = []

  csv_file.each do |row|
    regdate = row[:regdate]
    regdate = DateTime.strptime(regdate, '%m/%d/%Y %H:%M')
    hour_array << regdate.hour
  end
  puts hour_array.tally.sort.to_h
end

def registrations_by_day(csv_file)
  day_hash = Hash.new{0}

  csv_file.each do |row|
    regdate = row[:regdate]
    regdate = DateTime.strptime(regdate, '%m/%d/%Y %H:%M')
    day_hash[regdate.wday] += 1
  end
  puts "Sunday: #{day_hash[0]}, Monday: #{day_hash[1]}, Tuesday: #{day_hash[2]}, Wednesday: #{day_hash[3]}, Thursday: #{day_hash[4]}, Friday: #{day_hash[5]}, Saturday: #{day_hash[6]} }"
end

registrations_by_day(contents)
