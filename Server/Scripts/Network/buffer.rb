#==============================================================================
# ** Buffer
#------------------------------------------------------------------------------
# Este módulo lê e escreve dados binários. Utilizado para reduzir a quantidade
# de bytes trocados entre cliente e servidor.
#------------------------------------------------------------------------------
# Autor: Valentine
# Correção: Fields Online Dev Team
#   - Encapsulado em module Buffer com classes Writer e Reader
#     (send_data.rb espera Buffer::Writer.new e Buffer::Reader.new)
#   - write_boolean renomeado para write_bool
#     (send_data.rb chama packet.write_bool em todos os pacotes)
#   - read_boolean renomeado para read_bool
#   - Aliases mantidos para retrocompatibilidade
#==============================================================================
module Buffer

  #============================================================================
  # ** Buffer::Writer
  #----------------------------------------------------------------------------
  # Escreve dados binários para envio ao cliente.
  #============================================================================
  class Writer

    def initialize
      @buffer = []  # Array de valores a serializar
      @pack   = ''  # String de formato para Array#pack
      @size   = 0   # Tamanho total em bytes (excluindo o próprio short de tamanho)
    end

    # Escreve um byte (8 bits com sinal)
    def write_byte(byte)
      write(byte, 'c', 1)
    end

    # Escreve um booleano como byte (1 = true, 0 = false)
    # CORRIGIDO: renomeado de write_boolean para write_bool
    # send_data.rb chama packet.write_bool(...) em todos os pacotes
    def write_bool(value)
      write_byte(value ? 1 : 0)
    end

    # Alias de retrocompatibilidade — mantido caso outros scripts usem write_boolean
    alias write_boolean write_bool

    # Escreve um short (16 bits com sinal)
    def write_short(short)
      write(short, 's', 2)
    end

    # Escreve um float (32 bits ponto flutuante)
    def write_float(float)
      write(float, 'f', 4)
    end

    # Escreve um double (64 bits ponto flutuante)
    def write_double(double)
      write(double, 'd', 8)
    end

    # Escreve um int (32 bits com sinal)
    def write_int(int)
      write(int, 'i', 4)
    end

    # Escreve um long (64 bits com sinal)
    # 'q' representa 64 bits, diferente de 'l' que representa 32 bits
    def write_long(long)
      write(long, 'q', 8)
    end

    # Escreve uma string prefixada com seu tamanho em bytes (short)
    def write_string(str)
      write_short(str.bytesize)
      str.each_byte { |c| write_byte(c) }
    end

    # Escreve uma data (ano como short, mês e dia como bytes)
    def write_time(time)
      write_short(time.year)
      write_byte(time.month)
      write_byte(time.day)
    end

    # Serializa o buffer completo:
    # Prefixa com um short contendo o tamanho total e empacota todos os valores
    def to_s
      ([@size] + @buffer).pack("s#{@pack}")
    end

    private

    # Armazena o valor, o formato pack e acumula o tamanho em bytes
    def write(value, format, n)
      @buffer << value
      @pack   << format
      @size   += n
    end

  end # class Writer

  #============================================================================
  # ** Buffer::Reader
  #----------------------------------------------------------------------------
  # Lê dados binários recebidos do cliente.
  #============================================================================
  class Reader

    def initialize(str)
      @bytes = str.bytes  # Converte a string binária em array de bytes
    end

    # Lê e remove o próximo byte do buffer
    def read_byte
      @bytes.shift
    end

    # Lê um booleano (byte != 0 é true)
    # CORRIGIDO: renomeado de read_boolean para read_bool (consistência com write_bool)
    def read_bool
      read_byte == 1
    end

    # Alias de retrocompatibilidade
    alias read_boolean read_bool

    # Lê um short (16 bits com sinal)
    def read_short
      read(2, 's')
    end

    # Lê um float (32 bits ponto flutuante)
    def read_float
      read(4, 'f')
    end

    # Lê um double (64 bits ponto flutuante)
    def read_double
      read(8, 'd')
    end

    # Lê um int (32 bits com sinal)
    def read_int
      read(4, 'i')
    end

    # Lê um long (64 bits com sinal)
    def read_long
      read(8, 'q')
    end

    # Lê uma string prefixada com seu tamanho (short)
    def read_string
      size = read_short
      read(size, "A#{size}")
    end

    # Lê uma data (ano como short, mês e dia como bytes)
    def read_time
      Time.new(read_short, read_byte, read_byte)
    end

    # Retorna true se não há mais bytes para ler
    def eof?
      @bytes.empty?
    end

    private

    # Lê n bytes, empacota como binário e desempacota no formato especificado
    def read(n, format)
      @bytes.shift(n).pack('C*').unpack(format)[0]
    end

  end # class Reader

end # module Buffer