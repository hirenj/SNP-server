#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'diff/lcs'
require 'net/http'
require 'snp_reader.rb'

accessions = JSON.parse(`cd ../../gator-v2/; ./tair.pl`)
accessions.delete("COL0")
#accessions.unshift("COL0")

class Array
  def randomly_pick(number)
      sort_by{ rand }.slice(0...number)
  end
end

def find_indexes(string,regex)
  results = []
  last_index = -1
  while(last_index != nil)
    last_index = string.index(regex,last_index+1)
    if last_index
      results.push(last_index)
    end
  end
  
  return results.randomly_pick(10)
end

mod_results = Hash.new() { |h,k| h[k] = 0 }
del_results = Hash.new() { |h,k| h[k] = 0 }
ran_results = Hash.new() { |h,k| h[k] = 0 }
trunc_results = Hash.new() { |h,k| h[k] = 0 }

agis = []

File.open('tair9-agis.txt').each { |agi|
  agi.gsub!(/\s*\n/,'')
  agis.push(agi)
}

File.open('rippdb-agis.txt').each { |agi|
  agis.delete(agi)
}

agis.delete_if { |agi|
  agi =~ /^AT[CM]/
}.randomly_pick(545).each { |agi|
  STDERR.puts(agi)

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

  index = 0

  ref_seq = JSON.parse(`cd ../../gator-v2/; ./tair.pl agi=#{agi}`)['data'][2]


  indexes_mod = find_indexes(ref_seq,/[STY]/).sort
  indexes_ran = find_indexes(ref_seq,/[ARNDCEQGHILKMFPWVUO]/).sort

  mod_counts = []
  del_counts = []
  ran_counts = []
  trunc_counts = []
  (0..(indexes_mod.length-1)).each { |i|
    mod_counts[i] = 0
    del_counts[i] = 0
    trunc_counts[i] = 0
  }
  (0..(indexes_ran.length-1)).each { |i|
    ran_counts[i] = 0
  }

  MySnp.init_agi(agi)

  accessions.each { |acc|
    MySnp.read_snps(acc).each { |a_diff|
      if a_diff.action == '='
        next
      end
      if (a_diff.action == '-' && indexes_mod.include?(a_diff.old_position))
        the_pos = indexes_mod.index(a_diff.old_position)
        trunc_counts[the_pos] += 1
        next
      end
      if (a_diff.action == '!' && indexes_mod.include?(a_diff.old_position))
        the_pos = indexes_mod.index(a_diff.old_position)
        if a_diff.new_element =~ /^[STY]$/
          mod_counts[the_pos] += 1
        else
          del_counts[the_pos] += 1
        end
      end
      if (a_diff.action != '=' && indexes_ran.include?(a_diff.old_position))
        the_pos = indexes_ran.index(a_diff.old_position)
        ran_counts[the_pos] += 1
      end
    }

  }

  mod_counts.each { |val|
    mod_results[val] += 1
  }

  del_counts.each { |val|
    del_results[val] += 1
  }

  ran_counts.each { |val|
    ran_results[val] += 1
  }

  trunc_counts.each { |val|
    trunc_results[val] += 1
  }

}


puts "Count\tModification results\tDeletion results\tSTY results\tTrunc results\tRandom results\n"
(0..(accessions.length)).each { |v|
  puts "#{v}\t"+[mod_results[v],del_results[v],(mod_results[v]+del_results[v]),trunc_results[v],ran_results[v]].join("\t")+"\n"
}