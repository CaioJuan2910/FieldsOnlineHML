require 'bcrypt'

#=============================================================================
# Módulo: Handle_Data
# Descrição: Lida com dados recebidos do cliente
# Autor Original: Valentine
# Modificado por: Caio Juan De Lima Silva — Fields Online
# Data: Abril 2026
# Versão: 1.1
#-----------------------------------------------------------------------------
# MODIFICAÇÕES APLICADAS
#-----------------------------------------------------------------------------
# [FIX #01 - v1.1] Validação de senha com BCrypt no login
#   PROBLEMA ORIGINAL: account.pass == pass (comparação em texto puro)
#   SOLUÇÃO: BCrypt::Password.new(account.pass) == pass
#   MOTIVO: account.pass agora é um hash bcrypt gerado em database.rb,
#           portanto a comparação direta de strings não é mais válida.
#           O BCrypt::Password.new() reconstrói o objeto de hash e permite
#           a comparação segura com a senha em texto puro fornecida pelo cliente.
#=============================================================================

module Handle_Data

  module Vocab
    InvalidPass     = "Usuário ou senha inválidos."
    InvalidHash     = "Conta com senha desatualizada. Recadastre-se."
    AccountExist    = "Este nome de usuário já está em uso."
    AccountCreated  = "Conta criada com sucesso! Faça login para continuar."
    AccountNotFound = "Conta não encontrada."
    AlreadyLogged   = "Esta conta já está conectada."
    LogoutSuccess   = "Você foi desconectado com segurança."
    InvalidUser     = "Nome de usuário inválido ou vazio."
    InvalidEmail    = "Endereço de e-mail inválido ou vazio."
  end

  #===========================================================================
  # ** handle_login
  #---------------------------------------------------------------------------
  # Processa a tentativa de login de um cliente.
  #
  # Parâmetros:
  #   client  — objeto do cliente que está tentando se autenticar
  #   pass    — senha em texto puro enviada pelo cliente
  #===========================================================================
  def self.handle_login(client, pass)
    account = Database.load_account(client.user)

    unless account
      client.send_message(Vocab::AccountNotFound)
      return
    end

    if Network.clients.any? { |c| c && c != client && c.user == client.user && c.in_game? }
      client.send_message(Vocab::AlreadyLogged)
      return
    end

    #-------------------------------------------------------------------------
    # [FIX #01 - v1.1] Validação de senha com BCrypt
    #-------------------------------------------------------------------------
    begin
      hashed = BCrypt::Password.new(account.pass)

      unless hashed == pass
        client.send_message(Vocab::InvalidPass)
        return
      end

    rescue BCrypt::Errors::InvalidHash
      # Conta criada antes da migração para BCrypt (senha em texto puro antiga).
      # O jogador deve recadastrar a conta para gerar um hash válido.
      client.send_message(Vocab::InvalidHash)
      return
    end

    # Login bem-sucedido — vincula a conta ao cliente e inicia a sessão
    client.account_id_db = account.id
    client.logged_in     = true
    client.send_account_data(account)

    print("[LOGIN] Cliente '#{client.user}' autenticado com sucesso.\n")
  end

  #===========================================================================
  # ** handle_create_account
  #---------------------------------------------------------------------------
  # Processa a criação de uma nova conta de jogador.
  # O hash BCrypt da senha é gerado internamente em Database.create_account.
  #===========================================================================
  def self.handle_create_account(client, user, pass, email)
    if user.nil? || user.strip.empty?
      client.send_message(Vocab::InvalidUser)
      return
    end

    if email.nil? || email.strip.empty?
      client.send_message(Vocab::InvalidEmail)
      return
    end

    if Database.account_exist?(user)
      client.send_message(Vocab::AccountExist)
      return
    end

    # Delega ao Database — o hash BCrypt é gerado lá, nunca armazenamos texto puro
    Database.create_account(user, pass, email)
    client.send_message(Vocab::AccountCreated)

    print("[CADASTRO] Nova conta criada para o usuário '#{user}'.\n")
  end

  #===========================================================================
  # ** handle_logout
  #---------------------------------------------------------------------------
  # Processa a desconexão voluntária ou forçada de um cliente.
  #===========================================================================
  def self.handle_logout(client)
    if client.in_game?
      Database.save_player(client)
      print("[LOGOUT] Dados do jogador '#{client.user}' salvos com sucesso.\n")
    end

    Network.remove_client(client)

    print("[LOGOUT] Cliente '#{client.user}' desconectado. #{Vocab::LogoutSuccess}\n")
  end

end # module Handle_Data