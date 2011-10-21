#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'diff/lcs'
require 'net/http'
require 'yaml'
require 'snp_reader.rb'

accessions = JSON.parse(`cd ../../gator-v2/; ./tair.pl`)
accessions.delete("COL0")
#accessions.unshift("COL0")

#  Add methods to Enumerable, which makes them available to Array
class Array
 
  #  sum of an array of numbers
  def sum
    return self.inject(0){|acc,i|acc +i}
  end
 
  #  average of an array of numbers
  def average
    return self.sum/self.length.to_f
  end
 
  #  variance of an array of numbers
  def sample_variance
    avg=self.average
    sum=self.inject(0){|acc,i|acc +(i-avg)**2}
    return(1/self.length.to_f*sum)
  end
 
  #  standard deviation of an array of numbers
  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
 
end  #  module Enumerable

class Array
  def randomly_pick(number)
      sort_by{ rand }.slice(0...number)
  end
end

agis = []

File.open('tair9-agis.txt').each { |agi|
  agi.gsub!(/\s*\n/,'')
  agis.push(agi)
}
agis = agis.delete_if { |agi|
  agi =~ /^AT[CM]/
}

all_results = []
all_counts_by_agi = []


agis = agis.sort

agis.each { |agi|

  # if File.exist?("/tmp/cached-#{agi}")
  #   ecos = YAML::load(File.open("/tmp/cached-#{agi}"))
  # else
  #     all_accs = accessions.join(',')
  #     ecos = JSON.parse(`cd ../../gator-v2/; ./tair.pl agi=#{agi} accession=#{all_accs}`).collect { |r|
  #       r['data'][2]
  #     }  
  #     File.open("/tmp/cached-#{agi}","w") do |f|
  #       f.write(YAML::dump(ecos))
  #     end
  # end
  STDERR.puts(agis.index(agi).to_s+" of #{agis.length}")
  index = 0

  seen_positions = Hash.new() { |h,k| h[k] = 0 }
  new_positions_by_eco = []
  total_changes = 0

  MySnp.init_agi(agi)

  accessions.sort_by { rand }.each { |acc|
    new_positions = 0
    any_diff = false
    MySnp.read_snps(acc).each { |a_diff|
      if a_diff.action == '='
        next
      end
      pos = a_diff.old_position
      any_diff = true
      if seen_positions[pos] == 0
        new_positions += 1        
      end
      seen_positions[pos] += 1
      total_changes += 1
    }
    if ( ! any_diff )
      new_positions_by_eco.push(0)
    else      
      new_positions_by_eco.push(new_positions)
    end
  }
  
  all_counts_by_agi.push(total_changes.to_f / (accessions.length).to_f)
  while( new_positions_by_eco[0] == 0 && new_positions_by_eco.uniq.length > 1 ) do
    new_positions_by_eco.push(new_positions_by_eco.shift)
  end 
  all_results.push(new_positions_by_eco)

}

def get_stats(matrix,col)
  vals = Array.new()
  matrix.each { |row|
    vals.push(row[col])
  }
  return [vals.average, vals.standard_deviation]  
end

(0..(all_results[0].length-1)).each { |i|
  vals = get_stats(all_results,i)
  puts "#{i} #{vals[0]} #{vals[1]}\n"
}

puts "Ave changes #{all_counts_by_agi.average} #{all_counts_by_agi.standard_deviation}\n"
