module Admin
  module Withdraws
    class CtwdtokensController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Ctwdtoken'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24 * 365)
        @one_ctwdtokens = @ctwdtokens.with_aasm_state(:accepted).order("id DESC")
        @all_ctwdtokens = @ctwdtokens.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @ctwdtoken.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @ctwdtoken.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
