#==============================================================================
# ■ [VS] Settings_File — Fields Online v1.0.0
#------------------------------------------------------------------------------
#  Responsável pela leitura e escrita do arquivo INI de configurações do
#  jogador. Gerencia volume de áudio, modo tela cheia, VSync, resolução e
#  último usuário logado.
#
#  Arquivo INI esperado:
#    [Settings]
#    User        = ""
#    MusicVolume = 100
#    SoundVolume = 100
#    ResolutionID = 0
#    Fullscreen  = 0
#    VSync       = 1
#
#  Autor original: Valentine
#  Modernizado por: Fields Online Team
#  Versão: 1.0.0
#==============================================================================

#==============================================================================
# ■ CONFIGURAÇÕES PADRÃO
#  Valores utilizados quando o arquivo INI não existir ou estiver corrompido.
#  Altere aqui para mudar os padrões do jogo.
#==============================================================================
module Settings_Defaults
  USER          = ""       # Nome do último usuário logado (vazio = nenhum)
  MUSIC_VOLUME  = 100      # Volume da música (BGM). Range: 0 a 100
  SOUND_VOLUME  = 100      # Volume dos efeitos sonoros (BGS/SE). Range: 0 a 100
  RESOLUTION_ID = 0        # ID da resolução padrão (veja Configs::RESOLUTIONS)
  FULLSCREEN    = 0        # Tela cheia: 0 = janela, 1 = tela cheia
  VSYNC         = 1        # VSync: 0 = desativado, 1 = ativado (recomendado)
end

#==============================================================================
# ■ Settings_File
#  Classe principal que gerencia o arquivo de configurações do jogador.
#==============================================================================
class Settings_File

  #----------------------------------------------------------------------------
  # ■ ATRIBUTOS
  #  Leitura direta dos valores carregados do arquivo INI.
  #  Para alterar com efeito colateral (aplicar ao jogo), use os setters.
  #----------------------------------------------------------------------------
  attr_reader :music_volume   # Volume da música (0–100)
  attr_reader :sound_volume   # Volume dos efeitos (0–100)
  attr_reader :fullscreen     # Modo de exibição: 0=janela, 1=tela cheia
  attr_reader :vsync          # VSync: 0=desativado, 1=ativado

  attr_accessor :user         # Nome do último usuário logado
  attr_accessor :resolution_id # ID da resolução selecionada

  #----------------------------------------------------------------------------
  # ■ INICIALIZAÇÃO
  #  Carrega o arquivo INI e popula os atributos.
  #  Usa valores padrão de Settings_Defaults quando uma chave estiver ausente.
  #  @param filename [String] — Caminho do arquivo INI de configurações
  #----------------------------------------------------------------------------
  def initialize(filename)
    @ini = INI.new(filename)

    # Lê cada configuração do INI, aplicando valor padrão se ausente
    @user          = read_ini('User',         Settings_Defaults::USER)
    @music_volume  = read_ini('MusicVolume',  Settings_Defaults::MUSIC_VOLUME).to_i
    @sound_volume  = read_ini('SoundVolume',  Settings_Defaults::SOUND_VOLUME).to_i
    @resolution_id = read_ini('ResolutionID', Settings_Defaults::RESOLUTION_ID).to_i
    @fullscreen    = read_ini('Fullscreen',   Settings_Defaults::FULLSCREEN).to_i
    @vsync         = read_ini('VSync',        Settings_Defaults::VSYNC).to_i
  end

  #============================================================================
  # ■ SETTERS COM EFEITO COLATERAL
  #  Além de atualizar o atributo interno, aplicam a mudança ao jogo
  #  imediatamente (sem precisar chamar save).
  #============================================================================

  #----------------------------------------------------------------------------
  # ■ music_volume= — Define volume da música (BGM)
  #  Aplica imediatamente via Audio.update_bgm_volume.
  #  @param volume [Integer] — Valor entre 0 (mudo) e 100 (máximo)
  #----------------------------------------------------------------------------
  def music_volume=(volume)
    @music_volume = clamp(volume.to_i, 0, 100)
    Audio.update_bgm_volume
  end

  #----------------------------------------------------------------------------
  # ■ sound_volume= — Define volume dos efeitos sonoros (BGS/SE)
  #  Aplica imediatamente via Audio.update_bgs_volume.
  #  @param volume [Integer] — Valor entre 0 (mudo) e 100 (máximo)
  #----------------------------------------------------------------------------
  def sound_volume=(volume)
    @sound_volume = clamp(volume.to_i, 0, 100)
    Audio.update_bgs_volume
  end

  #----------------------------------------------------------------------------
  # ■ fullscreen= — Alterna modo de exibição
  #  Aciona Graphics.toggle_fullscreen somente se o estado precisar mudar.
  #  Evita chamadas duplicadas ao comparar com o estado atual da tela.
  #  @param value [Integer] — 0 = janela, 1 = tela cheia
  #----------------------------------------------------------------------------
  def fullscreen=(value)
    @fullscreen = value.to_i

    # Verifica se o estado atual é diferente do desejado antes de alternar
    currently_fullscreen = Graphics.is_fullscreen?
    should_be_fullscreen = (@fullscreen == 1)

    Graphics.toggle_fullscreen if currently_fullscreen != should_be_fullscreen
  end

  #----------------------------------------------------------------------------
  # ■ vsync= — Ativa ou desativa a sincronização vertical (VSync)
  #  Aplica imediatamente via Graphics.vsync=.
  #  @param value [Integer] — 0 = desativado, 1 = ativado
  #----------------------------------------------------------------------------
  def vsync=(value)
    @vsync = value.to_i

    # VSync ativo quando @vsync == 1 (Graphics.vsync recebe true/false)
    Graphics.vsync = (@vsync == 1)
  end

  #============================================================================
  # ■ PERSISTÊNCIA
  #============================================================================

  #----------------------------------------------------------------------------
  # ■ save — Salva todas as configurações de volta no arquivo INI
  #  Usa begin/ensure para garantir que o arquivo seja fechado mesmo em erro.
  #----------------------------------------------------------------------------
  def save
    # Atualiza os valores no objeto INI antes de escrever
    @ini['Settings']['User']         = @user.to_s
    @ini['Settings']['MusicVolume']  = @music_volume.to_s
    @ini['Settings']['SoundVolume']  = @sound_volume.to_s
    @ini['Settings']['ResolutionID'] = @resolution_id.to_s
    @ini['Settings']['Fullscreen']   = @fullscreen.to_s
    @ini['Settings']['VSync']        = @vsync.to_s

    # Escreve no arquivo com tratamento de erro
    begin
      file = File.open(@ini.filename, 'w')
      @ini.each do |key, property|
        file.puts("[#{key}]")
        property.each { |name, value| file.puts("#{name} = #{value}") }
      end
    rescue => e
      # Em caso de falha, registra no console sem interromper o jogo
      p "[Settings_File] Erro ao salvar configurações: #{e.message}"
    ensure
      file.close if file && !file.closed?
    end
  end

  #============================================================================
  # ■ MÉTODOS PRIVADOS
  #============================================================================
  private

  #----------------------------------------------------------------------------
  # ■ read_ini — Lê uma chave do INI com fallback para valor padrão
  #  @param key     [String] — Nome da chave dentro de [Settings]
  #  @param default [Object] — Valor retornado se a chave estiver ausente
  #  @return [Object] — Valor lido ou padrão
  #----------------------------------------------------------------------------
  def read_ini(key, default)
    value = @ini['Settings'][key] rescue nil
    (value.nil? || value.to_s.strip.empty?) ? default : value
  end

  #----------------------------------------------------------------------------
  # ■ clamp — Limita um valor entre mínimo e máximo
  #  @param value [Numeric] — Valor a limitar
  #  @param min   [Numeric] — Limite inferior
  #  @param max   [Numeric] — Limite superior
  #  @return [Numeric] — Valor dentro do intervalo [min, max]
  #----------------------------------------------------------------------------
  def clamp(value, min, max)
    [[value, min].max, max].min
  end

end # class Settings_File