require 'spec_helper'

describe ApplicationController do
  describe "CoinAPI::ConnectionRefusedError handling" do
    controller do
      def index
        raise CoinAPI::ConnectionRefusedError
      end
    end

    it 'renders errors/connection' do
      get :index
      expect(response).to render_template 'errors/connection'
    end
  end
end
