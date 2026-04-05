#==============================================================================
# ** Buffer
#------------------------------------------------------------------------------
#  Esta classe lê e escreve dados binários. Ela é utilizada
# especialmente para reduzir a quantidade de bytes trocados
# pelo cliente e servidor.
#------------------------------------------------------------------------------
#  Autor: Valentine
#  Correção: write_byte 'c' → 'C' (unsigned byte, 0-255)
#            Evita ArgumentError com caracteres não-ASCII e valores ≥ 128
#==============================================================================

class Buffer_Writer

  def initialize
    @buffer = []
    @pack = ''
  end

  # [CORRIGIDO] 'c' (signed, -128..127) → 'C' (unsigned, 0..255)
  # Valores como opacity=255, bytes de strings UTF-8 (ã, é, ç) causavam
  # ArgumentError: argument out of range com o formato 'c'
  def write_byte(byte)
    write(byte, 'C')
  end

  def write_boolean(value)
    write_byte(value ? 1 : 0)
  end

  def write_short(short)
    write(short, 's')
  end

  def write_float(float)
    write(float, 'f')
  end

  def write_double(double)
    write(double, 'd')
  end

  def write_int(int)
    write(int, 'i')
  end

  def write_long(long)
    # q representa um número de 64 bits, diferentemente
    # de l que representa um número de 32 bits
    write(long, 'q')
  end

  def write_string(str)
    write_short(str.bytesize)
    # Cada byte pode ser 0-255 (especialmente em strings UTF-8 com acentos)
    # write_byte agora usa 'C' (unsigned) para suportar todos os valores
    str.each_byte { |c| write_byte(c) }
  end

  def to_s
    @buffer.pack(@pack)
  end

  private

  def write(value, format)
    @buffer << value
    @pack << format
  end

end

#==============================================================================
# ** Buffer_Reader
#==============================================================================
class Buffer_Reader

  def initialize(str)
    # O método to_a é usado, pois, nesta versão do Ruby,
    # bytes retorna Enumerator em vez de Array
    @bytes = str.bytes.to_a
  end

  # Já retorna unsigned (0-255) via Array#shift — sem alteração necessária
  def read_byte
    @bytes.shift
  end

  def read_boolean
    read_byte == 1
  end

  def read_short
    read(2, 's')
  end

  def read_float
    read(4, 'f')
  end

  def read_double
    read(8, 'd')
  end

  def read_int
    read(4, 'i')
  end

  def read_long
    read(8, 'q')
  end

  def read_string
    size = read_short
    read(size, "A#{size}")
  end

#==============================================================================
# ** read_time
#------------------------------------------------------------------------------
# Lê uma data do buffer no formato: short(year) + byte(month) + byte(day)
#
# Proteção defensiva:
#   - Garante que month esteja entre 1 e 12 (Time.new rejeita 0 ou >12)
#   - Garante que day esteja entre 1 e 31
#   - Em caso de ArgumentError residual, retorna Time.now como fallback
#
# Isso evita o crash "ArgumentError: argument out of range" quando o servidor
# envia dados de VIP corrompidos, zerados ou de pacote adjacente no socket.
#==============================================================================
def read_time
  year  = read_short.to_i
  month = read_byte.to_i
  day   = read_byte.to_i

  # Sanitiza valores fora do range aceito por Time.new
  month = month.between?(1, 12) ? month : 1
  day   = day.between?(1, 31)   ? day   : 1

  Time.new(year, month, day)
rescue ArgumentError
  # Fallback seguro: retorna data atual se ainda assim falhar
  Time.now
end

  private

  def read(n, format)
    @bytes.shift(n).pack('C*').unpack(format)[0]
  end

end