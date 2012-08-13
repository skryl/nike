class Hash

  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = \
        if tv.is_a?(Hash) && v.is_a?(Hash) 
          tv.deep_merge(v)
        elsif tv.is_a?(Array) && v.is_a?(Array)  
          tv + v
        else v
        end
    end
    self
  end

  def underscore_keys
    self.inject({}) do |h, (k,v)|
      h[k.to_s.underscore] = \
        case v
        when Hash
          v.underscore_keys
        when Array
          v.map { |i| i.is_a?(Hash) ? i.underscore_keys : i }
        else v
        end; h
    end
  end

end
