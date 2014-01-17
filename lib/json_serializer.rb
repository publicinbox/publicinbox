class JsonSerializer
  def self.load(string)
    return nil if string.nil?
    JSON.parse(string)
  end

  def self.dump(object)
    JSON.generate(object)
  end
end
