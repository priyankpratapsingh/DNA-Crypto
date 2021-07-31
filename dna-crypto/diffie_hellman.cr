require "big/big_int"

@[Link("gmp")]
lib LibGMP
  fun mpz_powm_sec = __gmpz_powm_sec(rop : MPZ*, base : MPZ*, exp : MPZ*, mod : MPZ*)
end

class DH
  @@private_key : BigInt = BigInt.new
  @@p : BigInt = BigInt.new
  @@g : BigInt = BigInt.new

  def initialize()
    @@private_key = uninitialized BigInt
    @@p = uninitialized BigInt
    @@g = uninitialized BigInt
  end

  def initialize(pk : BigInt, p : BigInt, g :  BigInt)
    @@private_key = pk
    @@p = p
    @@g = g
  end

  def self.set_private_key(k : BigInt)
    @@private_key = k
  end

  def self.get_private_key()
    @@private_key
  end

  def self.get_public_key()
    public_key = BigInt.new
    LibGMP.mpz_powm_sec(public_key, @@g, @@private_key, @@p)
    return public_key
  end

  def self.get_secret_key(pub_key : BigInt) : BigInt
    secret_key = BigInt.new
    LibGMP.mpz_powm_sec(secret_key, pub_key, @@private_key, @@p)
    return secret_key
  end
end
