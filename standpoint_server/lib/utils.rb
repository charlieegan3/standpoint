module Utils
  def self.sorted_dup_hash(array, lower_threshold=1)
      Hash[
        *array.
        inject(Hash.new(0)) { |h,e| h[e] += 1; h }.
        select { |k,v| v > lower_threshold }.
        inject({}) { |r, e| r[e.first] = e.last; r }.
        sort_by {|_,v| v}.
        reverse.
        flatten(1)
      ]
  end
end
