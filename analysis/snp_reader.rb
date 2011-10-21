class MySnp
  attr_accessor :action
  attr_accessor :old_position
  attr_accessor :new_element
  attr_accessor :old_element
  
  def self.init_agi(agi)
    @@cache = Hash.new()
    snps = `fgrep -m1 '#{agi} ' snp-cache/*-subs.txt`
    snps.split(/\n/).each { |snpline|
      snpline.scan(/\/(.*)-subs.txt:(.+)\s(.+)$/) do |a|
        @@cache[a[0]] = a[2]
      end
    }
  end
  
  def self.read_snps(snp_name)
    snps = @@cache[snp_name]
    if snps
      snps.split(',').collect { |snp|
        result = MySnp.new()
        snp.scan(/(\d+):(.)(.)/) do |a|
          result.action = '!'
          result.old_position = a[0].to_i
          result.new_element = a[2]
          result.old_element = a[1]
          if a[2] == '-'
            result.action = '-'
            result.new_element = ''
          end
        end
        result
      }
    else
      []
    end
  end    
end