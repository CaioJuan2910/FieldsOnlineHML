#==============================================================================
# ** VXAOS
#------------------------------------------------------------------------------
# Este módulo contém funções de segurança do cliente.
# SHA-256 implementado em Ruby puro para compatibilidade com RGSS3.
# Substitui o antigo MD5, que era inseguro.
#------------------------------------------------------------------------------
# Autores: Valentine (base VXA-OS) | Atualizado: Fields Online
#==============================================================================
module VXAOS

  # Máscara de 32 bits — usada para garantir que todas as operações
  # aritméticas permaneçam dentro do limite de 32 bits (sem overflow)
  MASK32 = 0xFFFFFFFF

  # Primeiros 32 bits das raízes cúbicas dos primeiros 64 números primos
  # Estas são as constantes de round oficiais do algoritmo SHA-256
  SHA256_K = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  ].freeze

  # Valores iniciais do hash SHA-256
  # Primeiros 32 bits das raízes quadradas dos primeiros 8 números primos
  SHA256_H0 = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
  ].freeze

  class << self

    private

    # Rotação de bits à direita — operação fundamental do SHA-256
    # Desloca os bits de x em n posições à direita de forma circular
    def rotr32(x, n)
      ((x >> n) | (x << (32 - n))) & MASK32
    end

    public

    #--------------------------------------------------------------------------
    # * sha256(message)
    #   Calcula o hash SHA-256 de uma string e retorna uma string hexadecimal
    #   de 64 caracteres (256 bits).
    #   Implementado em Ruby puro para compatibilidade total com RGSS3.
    #   Usado para proteger senhas antes de enviá-las ao servidor,
    #   substituindo o antigo MD5 que era considerado inseguro.
    #--------------------------------------------------------------------------
    def sha256(message)

      # Passo 1: Converte a mensagem em array de bytes
      msg          = message.bytes.to_a
      orig_bit_len = msg.length * 8

      # Passo 2: Preenchimento — prepara a mensagem para blocos de 512 bits
      # Adiciona o bit '1' (0x80), depois zeros até restar 8 bytes no bloco,
      # e por fim adiciona o tamanho original da mensagem em 64 bits (big-endian)
      msg << 0x80
      msg << 0x00 while (msg.length % 64) != 56
      8.times { |i| msg << ((orig_bit_len >> (56 - i * 8)) & 0xff) }

      # Passo 3: Inicializa os 8 valores do hash com os valores padrão SHA-256
      h = SHA256_H0.dup

      # Passo 4: Processa cada bloco de 512 bits (64 bytes) da mensagem
      msg.each_slice(64) do |bloco|

        # Expansão do cronograma de mensagens (message schedule)
        # Converte os 16 primeiros words de 32 bits a partir dos bytes do bloco
        w = bloco.each_slice(4).map { |b| (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3] }

        # Expande de 16 para 64 words usando as funções sigma do SHA-256
        16.upto(63) do |i|
          s0 = rotr32(w[i - 15], 7) ^ rotr32(w[i - 15], 18) ^ (w[i - 15] >> 3)
          s1 = rotr32(w[i - 2], 17) ^ rotr32(w[i - 2],  19) ^ (w[i - 2]  >> 10)
          w << ((w[i - 16] + s0 + w[i - 7] + s1) & MASK32)
        end

        # Variáveis de trabalho — inicializadas com os valores atuais do hash
        a, b, c, d, e, f, g, hh = h

        # 64 rounds de compressão SHA-256
        64.times do |i|
          s1    = rotr32(e, 6)  ^ rotr32(e, 11) ^ rotr32(e, 25)
          ch    = (e & f) ^ ((~e & MASK32) & g)
          temp1 = (hh + s1 + ch + SHA256_K[i] + w[i]) & MASK32
          s0    = rotr32(a, 2)  ^ rotr32(a, 13) ^ rotr32(a, 22)
          maj   = (a & b) ^ (a & c) ^ (b & c)
          temp2 = (s0 + maj) & MASK32
          hh = g;  g = f;  f = e
          e  = (d + temp1) & MASK32
          d  = c;  c = b;  b = a
          a  = (temp1 + temp2) & MASK32
        end

        # Acumulação — adiciona os valores comprimidos ao hash atual
        h[0] = (h[0] + a)  & MASK32
        h[1] = (h[1] + b)  & MASK32
        h[2] = (h[2] + c)  & MASK32
        h[3] = (h[3] + d)  & MASK32
        h[4] = (h[4] + e)  & MASK32
        h[5] = (h[5] + f)  & MASK32
        h[6] = (h[6] + g)  & MASK32
        h[7] = (h[7] + hh) & MASK32

      end

      # Passo 5: Converte o hash final em string hexadecimal (64 caracteres)
      h.map { |val| sprintf('%08x', val) }.join

    end

  end

end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
# Este script lida com as notas do banco de dados e o leitor
# de arquivos INI. Ele também é executado no servidor.
#------------------------------------------------------------------------------
# Autor: Valentine
#==============================================================================
module Kernel
  def enum(constant_names)
    Module.new do |mod|
      n = 0
      constant_names.each_with_index do |const, i|
        if constant_names[i + 1].to_i > 0
          n = constant_names[i + 1].to_i
          constant_names.delete_at(i + 1)
        end
        mod.const_set(const.to_s, n)
        n += 1
      end
    end
  end
end

#==============================================================================
# ** Note
#==============================================================================
module Note
  def self.read_graphics(note)
    note.each_line.map { |line| line.split('=')[1] }.map { |graphic|
      graphic.split(',').map { |graphic| split(graphic) }
    }
  end
  def self.read_paperdoll(note)
    split((note[/Paperdoll=(.*)/, 1] || ''))
  end
  def self.read_boolean(str, note)
    note[/#{str}=(....)/, 1] == 'true'
  end
  def self.read_number(str, note)
    note[/#{str}=(.*)/, 1].to_i
  end
  private
  def self.split(str)
    ary = str.split('/')
    return ary if ary.empty?
    return ary[0].chomp, ary[1].to_i
  end
end

#==============================================================================
# ** INI
#==============================================================================
class INI
  attr_reader :filename
  def initialize(filename)
    @filename = filename
    @data = {}
    create_properties
  end
  def create_properties
    str = File.open(@filename, 'r:bom|UTF-8', &:read)
    key = nil
    str.split("\n").each do |line|
      if line.start_with?('[')
        key = line[1...line.size - 1]
        @data[key] = {}
      elsif !line.strip.empty? && !line.include?(';')
        name, value = line.split('=')
        @data[key][name.rstrip] = parse(value.lstrip)
      end
    end
  end
  def [](key)
    @data[key]
  end
  def each(&block)
    @data.each { |key, property| yield(key, property) }
  end
  def parse(value)
    if value =~ /^([\d _]+)$/
      return value.to_i
    elsif value =~ /^([\d _]*\.\d+)$/
      return value.to_f
    elsif value =~ /true|false/i
      return value.downcase == 'true'
    else
      return value.gsub(/\"|'/, '')
    end
  end
end