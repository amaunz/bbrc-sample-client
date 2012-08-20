# Get fraction of values above threshold from two hashes
# @param [Hash] h1 the first hash
# @param [Hash] h2 the second hash, not larger than h1
# @return [Float] the proportion of common hash keys on which the values are both above threshold
# @example {
#   h1 = { "foo" => 0.96, "bar" => 0.94, "baz" => 1 }
#   h2 = { "bar" => 0.96, "foo" => 0.96 }
#   correctSignFraction(h1,h2,0.95) # 0.5
# }

def correctSignFraction(h1,h2,thr)
  unless (h2 && h2.length>0) 
    puts "Error: h2 is empty"
    return nil
  end
  if ((h2.keys - h1.keys).length>0) 
    puts "Error: h2 is larger"
    return nil
  end
  if ((h1.keys - h2.keys).length > (h1.size-h2.size))
    puts "Error: h2 has keys unknown to h1"
    return nil
  end
  sum = 0
  h1.each { |k,v| sum+=1 if (h2[k] && h2[k] >= thr) }
  sum / h2.length.to_f
end



# Get fraction of common values from two hashes
# @param [Hash] h1 the first hash
# @param [Hash] h2 the second hash, not larger than h1
# @return [Float] the proportion of common hash keys on which the values agree
# @example {
#   h1 = { "foo" => 1, "bar" => 0, "baz" => 1 }
#   h2 = { "bar" => 0, "foo" => 0 }
#   commonFractionKV(h1,h2) # 0.5
# }

def commonFractionKV(h1,h2)
  unless (h2 && h2.length>0) 
    puts "Error: h2 is empty"
    return nil
  end
  if ((h2.keys - h1.keys).length>0) 
    puts "Error: h2 is larger"
    return nil
  end
  if ((h1.keys - h2.keys).length > (h1.size-h2.size))
    puts "Error: h2 has keys unknown to h1"
    return nil
  end
  sum = 0
  h1.each { |k,v| sum+=1 if (h2[k] && h2[k] == v) }
  sum / h2.length.to_f
end


# Get relative support values
# @param classes vector of possible class values (Strings or Numerics)
# @param y vector of class values (Strings or Numerics)
# @param occ vector of occurrence indicators (Integer >=0)
# @return vector of size of (size of classes), containing support values relative to the length of y, or nil
# @example {
#  getRelSupVal([3,2,1],[1,2,1,3],[1,1,1,0]) # [0.0, 0.25, 0.5]
#  getRelSupVal([1,2,3],[1,2,1,3],[1,1,1,0]) # [0.5, 0.25, 0.0]
#  getRelSupVal([1,2,3],[1,2,1,nil],[1,1,1,0]) # nil
# }

def getRelSupVal(classes,y,occ)
  y.each   { |val| 
             unless (val.is_a?(String) || OpenTox::Algorithm::numeric?(val))
               puts "incorrect type for y '#{val}'"
               return nil
             end
             unless (classes.index(val))
               puts "y '#{val}' not in allowed classes '#{classes.join(',')}', index is '#{classes.index(val)}'"
               return nil
             end
           }
  occ.each { |val| 
             unless ( val.is_a?(Integer) && val>=0 )
               puts "occ '#{val}' not an Integer >= 0"
               return nil
             end
           }
  unless y.length == occ.length
    puts "Error: y and occ differ in length"
    return nil
  end

  # Contingency array for classes
  # run over y and increase cell
  res = Array.new(classes.size, 0)
  y.each_with_index { |val,idx|
    idx2 = classes.index(val)
    res[idx2] += 1 if occ[idx] >= 1
  }
  
  res = (Vector.elements(res) / occ.to_gv.sum.to_f).to_a.collect! { |x| x.to_f } 
end


# Get relative support differences of two support vectors
# @param y vector of class values (Strings or Numerics)
# @param occ1 vector of occurrence indicators (Integer >=0)
# @param occ2 vector of occurrence indicators (Integer >=0)
# @return vector of size of (size of classes), containing support values relative to the length of y, or nil
# @example {
#  getRelSupVal([3,2,1],[1,2,1,3],[1,1,1,0]) # [0.0, 0.25, 0.5]
#  getRelSupVal([1,2,3],[1,2,1,3],[1,1,1,0]) # [0.5, 0.25, 0.0]
#  getRelSupVal([1,2,3],[1,2,1,nil],[1,1,1,0]) # nil
# }

def getRelSupDif(classes,y,occ1,occ2)
  y.each    { |val| (return nil) unless ( ( val.is_a?(String) || OpenTox::Algorithm::numeric?(val) ) && classes.index(val) ) }
  occ1.each { |val| (return nil) unless ( val.is_a?(Integer) && val>=0 ) }
  occ2.each { |val| (return nil) unless ( val.is_a?(Integer) && val>=0 ) }
  return (nil) unless (y.length == occ1.length && y.length == occ2.length)

  res=0
  y.each_with_index { |val,idx|
    res += 1 if ((occ1[idx] >0 || occ2[idx] >0) && occ1[idx] != occ2[idx])
  }
  res/y.length.to_f
end


# Read CSV from URI
# @param uri URI to read from
# @return Array with CSV data
# @example {
# }

def readCSV(uri)
  CSV.parse( OpenTox::RestClientWrapper.get(uri, {:accept => "text/csv"}) )
end


# Get column from csv
# @param csv data
# @return Array column
# @example {
#  getCol([["foo","bar"],[1,2],[1,3]],1) # ["bar",2,3]
#}

def getCol(csv,idx)
  return (nil) unless (idx>=0 && idx < csv[0].size)
  csv.collect { |line|
    line[idx]
  }
end
