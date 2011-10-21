#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'diff/lcs'
require 'net/http'
require 'snp_reader.rb'

class Array
  def randomly_pick(number)
      sort_by{ rand(10) }.slice(0...number)
  end
end

test = false

test_positions = [1,2,3,4,5,6,7,8,9,10]
test_seqs = [ 'STYSTYSTYSABCDABCD',
              'SSSSSSSSSSABCDABCD',
              'TTTTTTTTTTABCDABCD',
              'YYYYYYYYYYABCDABCD',
              'AAAAAAAAAAABCDABCD',
              'ATYSTYSTYSABCDABCD',
              'BTYSTYSTYSABCDABCD',
              'SYYSTYSTYSABCDABCD',
              'SYYSTYSTYSABCDABCD'
            ]

accessions = JSON.parse(`cd ../../gator-v2/; ./tair.pl`)
accessions.delete("COL0")
#accessions.unshift("COL0")

total_positions = 0

mod_results = Hash.new() { |h,k| h[k] = 0 }
del_results = Hash.new() { |h,k| h[k] = 0 }

agis = []

File.open('tair9-agis.txt').each { |agi|
  agi.gsub!(/\s*\n/,'')
  agis.push(agi)
}

if (test)
  agis = ['AT1G22710.1']
end

agis.each { |agi|

  agi.gsub!(/\s*\n/,'')

  STDERR.puts(agi)
  STDERR.puts(agis.index(agi).to_s+"/"+agis.length.to_s)
  #agi = 'at1g03160.1'
  #http://phosphat.mpimp-golm.mpg.de
  #'172.16.128.128', '/static/proxy.pl
  #'phosphat.mpimp-golm.mpg.de', '/PhosPhAtHost30/productive/views/Prediction.php
  begin
    resp = (`cd ../../gator-v2/; ./rippdb.pl agi=#{agi}`)
    data = resp.length > 0 ? JSON.parse(resp) : nil
  rescue Timeout::Error
    retry
  end

  if ( ! test && ! data )
    next
  end

  if (test)
    data = { 'spectra' => [] }
  end

  if data['error']
    STDERR.puts("Error getting data for #{agi}")
  end

  ref_seq = test ? test_seqs[0] : JSON.parse(`cd ../../gator-v2/; ./tair.pl agi=#{agi}`)['data'][2]

  indexes = data['spectra'].collect { |spec|
    spec['peptides'].collect { |pep|
      seq_offset = ref_seq.index(pep['sequence'])
      if seq_offset
        pep['positions'].collect { |pos|
          pos + seq_offset
        }
      else 
        []
      end
    }.flatten.compact.uniq
  }.flatten.sort.uniq

  if (test)
    indexes = test_positions
  end


  if indexes.length == 0
    next
  end
  
  
    
  total_positions += indexes.length
  # begin
  #   all_accs = accessions.join(',')    
  #   snps = test ? test_seqs : JSON.parse(`cd ../../gator-v2/; ./tair.pl agi=#{agi} accession=#{all_accs}`).collect { |r|
  #     r['data'][2]
  #   }
  # rescue Timeout::Error
  #   retry
  # end
  
  
  index = 0

  killer_mods = []
  sub_mods = []
  mod_counts = []
  del_counts = []
  
  (0..(indexes.length - 1)).each { |i|
    mod_counts[i] = 0
    del_counts[i] = 0
  }
  
  MySnp.init_agi(agi)
  
  accessions.each { |acc|
    MySnp.read_snps(acc).each { |a_diff|
      if a_diff.action == '='
        next
      end
      if (a_diff.action == '!' && indexes.include?(a_diff.old_position + 1))
        mod_pos = a_diff.old_position + 1
        acc = accessions[index]        
        if a_diff.new_element =~ /[STY]/
          mod_counts[indexes.index(mod_pos)] += 1
          sub_mods.push([acc, mod_pos])
        else
          del_counts[indexes.index(mod_pos)] += 1
          killer_mods.push([acc, mod_pos])
        end
      end
    }
    index += 1
  }

  killer_mods.each { |del|
    puts [agi,"del"].concat(del).join("\t")
  }
  sub_mods.each { |del|
    puts [agi,"sub"].concat(del).join("\t")
  }
  mod_counts.each { |val|
    mod_results[val] += 1
  }
  del_counts.each { |val|
    del_results[val] += 1
  }

}

puts "Total positions #{total_positions}"

puts "Modification results\n"
mod_results.keys.sort.each { |v|
  puts "#{v}\t#{mod_results[v]}\n"
}

puts "Deletion results\n"
del_results.keys.sort.each { |v|
  puts "#{v}\t#{del_results[v]}\n"
}

if ((mod_results.keys + del_results.keys).max || 0)> 0
  puts "STY results\n"
  (1..(mod_results.keys + del_results.keys).max).each { |v|
    val = (mod_results[v] || 0) + (del_results[v] || 0)
    puts "#{v}\t#{val}\n"
  }
end