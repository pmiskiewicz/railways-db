require "highline/import"

@db = [
  {"USA": 293564},
  {"China": 139000},
  {"Russia": 85600},
  {"India": 67415},
  {"Canada": 64000},
  {"Germany": 40625},
  {"Argentina": 36966},
  {"Australia": 33168},
  {"Brazil": 29817},
  {"France": 29273}
]

@transaction_mode = false

# Helpers

def press_to_continue
  print "Press any key to continue"
  STDIN.getch
  puts "\n\n"
end

def repository
  @transaction_mode ? @db_transaction : @db
end

def get_name
  @name = ask("Country: ", String)
  if @name.empty? == false && @name[/\s/] == nil
    @name.size > 3 ? @name = @name.downcase.capitalize : @name = @name.upcase
  else
    puts "The name cannot be empty and cannot contain spaces! Try again..."
    return get_name
  end
end

def get_value
  @value = ask("Length [km]: ", Integer)
end

def find_by_name
  @record = repository.find{|x| x.has_key?(@name.to_sym)}
end

def select_by_value
  @record = repository.select{|x| x.has_value?(@value)}
end

def table_header
  puts "\nCountry" + " " * 8 + "Length [km]"
  puts "-" * 28
end

# Main methods

def set_record
  get_name
  get_value
  find_by_name
  if @record.nil?
    record = Hash.new
    record[@name.to_sym] = @value
    repository << record
    puts "#{@name} has been created!"
  else
    change_value = repository.map{|x| x.has_key?(@name.to_sym) ? x.transform_values{|n| n = @value} : x}
    @transaction_mode ? @db_transaction = change_value : @db = change_value
    puts "#{@name} has been updated!"
  end
  press_to_continue
end

def get_record
  get_name
  find_by_name
  if @record.nil?
    puts "Country doesn't exist!"
  else
    table_header
    puts @record.keys.join.to_s + " " * (15 - @record.keys.join.to_s.length) + @record.values.join
    puts "\n"
  end
  press_to_continue
end

def delete_record
  get_name
  find_by_name
  if @record.nil?
    puts "Country doesn't exist!"
  else
    repository.delete_if{|x| x.has_key?(@name.to_sym)}
    puts "#{@name} has been deleted!"
  end
  press_to_continue
end

def count_records
  get_value
  select_by_value
  puts "Number of countries with #{@value} kilometers of railroad: #{@record.count}"
  press_to_continue
end

# Transactions

def begin_transaction
  @transaction_mode = true
  @db_transaction = []
  @db_transaction.concat(@db)
end

def rollback_transaction
  if @transaction_mode
    @transaction_mode = false
    @db_transaction = []
    puts "Changes have been rolled back"
  else
    puts "No transactions"
  end
  press_to_continue
end

def commit_transaction
  if @transaction_mode
    @transaction_mode = false
    @db = @db_transaction
    puts "Changes have been saved!"
  else
    puts "No transactions"
  end
  press_to_continue
end

# Menu

begin
  puts
  loop do
    print "\nWelcome to the World's Railway Database!\n\n".upcase
    table_header
    repository.size > 1 ? repository.sort_by{|x| x.values}.reverse.each{|x| puts x.keys.join.to_s + " " * (15 - x.keys.join.to_s.length) + x.values.join.to_s} : repository.each{|x| puts x.keys.join.to_s + " " * (15 - x.keys.join.to_s.length) + x.values.join.to_s}
    puts "\nTransaction mode: #{@transaction_mode ? "ON" : "OFF"}\n" 
    puts "\n#### MENU ####"
    choose do |menu|
      menu.prompt = "\nPlease select number of action: "
      menu.choice(:SET) { set_record() }
      menu.choice(:GET) { get_record() }
      menu.choice(:DELETE) { delete_record() }
      menu.choice(:COUNT) { count_records() }
      menu.choice(:BEGIN) { begin_transaction() }
      menu.choice(:ROLLBACK) { rollback_transaction() }
      menu.choice(:COMMIT) { commit_transaction() }
      menu.choice(:QUIT) { exit }
    end
  end
end
