# The last test result of each game, kept between runs in state/results.txt: "name passed failed time" per line.
module Results
  FILE = 'state/results.txt'.freeze

  def self.parse text
    text.split("\n").each_with_object({}) do |line, results|
      *words, passed, failed, at = line.split(' ')   # a name may have spaces
      results[words.join(' ')] = { passed: passed.to_i, failed: failed.to_i, at: at.to_i } unless words.empty?
    end
  end

  def self.dump results
    results.map { |name, r| "#{name} #{r[:passed]} #{r[:failed]} #{r[:at]}" }.join("\n")
  end

  def self.load
    parse GTK.read_file(FILE) || ''
  end

  def self.save results
    GTK.write_file FILE, dump(results)
  end
end
