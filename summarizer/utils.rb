module Utils
  def self.sorted_dup_hash(array)
    Hash[*array.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
      select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }.
      sort_by {|_,v| v}.reverse.flatten]
  end
end
