module Admin
  module Withdraws
    class GictokensController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Gictoken'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24 * 365)
        @one_gictokens = @gictokens.with_aasm_state(:accepted).order("id DESC")
        @all_gictokens = @gictokens.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @gictoken.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @gictoken.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
