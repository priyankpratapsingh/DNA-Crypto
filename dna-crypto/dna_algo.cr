require "big/big_int"

class DNA
  @@key : Hash(String, UInt8) = Hash(String, UInt8).new
  def initialize(key : BigInt)
    x = Array(UInt8).new()
    i = 0
    keys = ["AA", "AT", "AG", "AC", "TA", "TT", "TG", "TC", "GA", "GT", "GG", "GC", "CA", "CT", "CG", "CC"]

    while i < 16 && key > 0
      y = key & 0b1111
      x << y.to_u8()
      if x.uniq().size() != x.size()
        x = x.uniq()
        key = key >> 4
        next
      end
      key = key >> 4
      i += 1
    end

    @@key = Hash.zip(keys, x)
  end

  def self.encrypt(message : String)
    msg = ""

    # phase 1
    arr = ["A", "T", "G", "C"]
    enc1 = ""
    message.each_byte() do |b|
      i = 3
      while i >= 0
        enc1 += arr[(b >> (2 * i)) & 0b11]
        i = i - 1
      end
    end

    # phase 2
    puts enc1
    w = ""
    enc1.each_char() do |ch|
      w = w + ch
      if w.size() < 2
        next
      end

      x = @@key[w].to_s(2)
      while x.size() < 4
        x = "0" + x
      end
      msg += x
      w = ""
    end
    return msg
  end

  def self.decrypt(enc_msg : String)
    msg = String.new
    enc1 = ""
    hash = {'A' => 0, 'T' => 1, 'G' => 2, 'C' => 3}

    # phase 1
    w = ""
    enc_msg.each_char() do |ch|
      if w.size() == 4
        enc1 += @@key.key_for(w.to_i(2))
        w = ch.to_s()
        w = ""
      end
      w = w + ch
    end
    enc1 += @@key.key_for(w.to_i(2))

    # phase 2
    w = ""
    x = 0
    enc1.each_char() do |ch|
      if w.size() == 4
        i = 3
        while i >= 0
          x <<= 2
          x |= hash[w.chars[3 - i]]
          i = i - 1
        end
        msg += String.new(Bytes[x])
        w = ""
      end
      w = w + ch
    end
    i = 3
    while i >= 0
      x <<= 2
      x |= hash[w.chars[3 - i]]
      i = i - 1
    end
    msg += String.new(Bytes[x])
    w = ""
    return msg
  end
end
