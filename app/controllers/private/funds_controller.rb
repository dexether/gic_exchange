module Private
  class FundsController < BaseController
    layout 'funds'

    before_action :auth_activated!
    before_action :auth_verified!
    before_action :two_factor_activated!

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = Currency.all.sort
      @deposits = current_user.deposits
      @accounts = current_user.accounts.enabled
      @withdraws = current_user.withdraws
      @fund_sources = current_user.fund_sources

      gon.jbuilder
    end

    def gen_address
      current_user.accounts.each do |account|
        next unless account.currency_obj.coin?
        next unless account.payment_address.address.blank?
        account.payment_address.gen_address
      end
      render nothing: true
    end

  end
end

