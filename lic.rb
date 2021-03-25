#frozen_string_literal: true

class License

  attr_accessor :paid_till, :max_version, :min_version

  def initialize(paid_till, max_version, min_version)
    @paid_till = paid_till
    @max_version = max_version
    @min_version = min_version
  end
end

class Checker < License

  def initialize(paid_till, max_version, min_version)
    max_version = '0.0' if max_version == ''
    min_version = '0.0' if min_version == ''
    super(paid_till, max_version, min_version)
  end

  #Метод, который возвращает список доступных версий для лицензии
  def check_version_list
    # Получаю необходимые параметры
    max_version = @max_version.split('.').map(&:to_i)
    min_version = @min_version.split('.').map(&:to_i)
    paid_till = @paid_till.split('.').map(&:to_i)
    paid_till.delete_at(0)
    paid_till.reverse!
    paid_till[0] = paid_till[0] % 100
    last_version = FlussonicLastVersion.get.split('.').map(&:to_i) # Получаю данные из черного ящика
    
    # Записываю в массив последние 5 версий
    possible_versions = [last_version]
    year = last_version[0]
    month = last_version[1]
    4.times do
      month -= 1 # Месяц
      if month.zero?
        year -= 1 # Год
        month = 12
      end
      possible_versions << [year, month]
    end
    #Удаляю ненужные
    possible_versions.reverse!.delete_if do |version|
      ((version[0] > max_version[0] || version[0] == max_version[0] && version[1] > max_version[1])) && !max_version[0].zero? || # Больше той, что в max_version
        (version[0] > paid_till[0] || version[0] == paid_till[0] && version[1] > paid_till[1]) || # Больше той, что в paid_till
        ((version[0] < min_version[0] || version[0] == min_version[0] && version[1] < min_version[1]) && !min_version[0].zero?) # Меньше той, что в min_version
    end

    #Если пустой массив, вывожу макс. возможную версию
    possible_versions << max_version if possible_versions.empty?
    #Делаю так, чтобы однозначный месяц выводился с ноликом
    possible_versions.map do |version|
      version[0] = (version[0]).to_s
      version[1] = if version[1] < 10
                     "0#{version[1]}"
                   else
                     (version[1]).to_s
                   end
    end
    #Делаю строку из массива строк
    possible_versions.map do |version|
      "#{version[0]}.#{version[1]}"
    end
  end

end

# Черный ящик
class FlussonicLastVersion
  def self.get
    '21.03'
  end
end


print 'Paid till: '
paid_till = gets.chomp
print 'Maximal version: '
max_version = gets.chomp
print 'Minimal version: '
min_version = gets.chomp

my_license = License.new(paid_till, max_version, min_version)
my_checker = Checker.new(my_license.paid_till, my_license.max_version, my_license.min_version)
print my_checker.check_version_list
