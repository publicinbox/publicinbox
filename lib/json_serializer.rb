class JsonSerializer
  def self.load(string)
    return nil if string.nil?
    JSON.parse(string)
  end

  def self.dump(object)
    return nil if object.nil?
    JSON.generate(object)
  end
end
